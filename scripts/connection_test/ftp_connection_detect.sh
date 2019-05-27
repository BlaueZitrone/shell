#!/bin/bash

function connectionDetect()
{
    for URL in $(cat "${connectionURLTmpFile}" | sort | uniq)
    do
        echo -n "${URL} ";
        echo -n "[$(date)]:" >> "${logFile}";
        echo "${URL}" >> "${logFile}";
        curl "${URL}" --connect-timeout "${timeOutSec}" >> "${logFile}" 2>&1;
        if [[ $(echo $?) == '0' ]];then
            echo -e "\033[1;32mSuccess\033[0m";
        else
            echo -e "\033[1;31;5mFail\033[0m";
        fi
        for agr in $(fgrep "|${URL}" "${agreementURLMap}" | cut -d \| -f1)
        do
            echo -n "${agr}|";
        done
        echo;
    done
}

function init()
{
    timeOutSec=5;
    connectionURLTmpFile="/tmp/connectionURL_$(date "+%Y%m%d%H%M%S").tmp";
    agreementURLMap="/tmp/agreementURL_$(date "+%Y%m%d%H%M%S").map";
    logFile="$(dirname $0)/log.$(date "+%Y%m%d")";
    find "/tmp/" -mtime +1 -name "connectionURL_*.tmp" -exec /usr/bin/rm {} \; 2>/dev/null;
    find "/tmp/" -mtime +1 -name "agreementURL_*.map" -exec /usr/bin/rm {} \; 2>/dev/null;
    find "$(dirname $0)/" -mtime +10 -name "log.*" -exec /usr/bin/rm {} \; 2>/dev/null;
}

function main()
{
    init;
    for agreementConfigFile in $(ls /app/sword/schenker/comsys/COMSYS*/agr/*/*_dump.xml)
    do
        protocol=$(grep '<Protocol>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
        agreementName=$(grep '<AgrID>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
        if [[ "${protocol}" == "ftp" ]]; then
            hostname=$(grep '<RemoteHost>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
            user=$(grep '<User>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
            passwd=$(grep '<Password>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
            url="ftp://${user}:${passwd}@${hostname}";
            echo "${url}" >> "${connectionURLTmpFile}";
            echo "${agreementName}|${url}" >> "${agreementURLMap}";
        fi
    done
    connectionDetect;
    /usr/bin/rm "${connectionURLTmpFile}";
    /usr/bin/rm "${agreementURLMap}";
}

main
