#!/bin/bash

function FTPURLGen()
{
    hostname=$(grep '<RemoteHost>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
    user=$(grep '<User>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
    passwd=$(grep '<Password>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
    url="ftp://${user}:${passwd}@${hostname}";
    echo "${url}" >> "${connectionURLTmpFile}";
    echo "${agreementName}|${url}" >> "${agreementURLMap}";
}

function SFTPURLGen()
{
    hostname=$(grep '<RemoteHost>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
    user=$(grep '<User>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
    passwd=$(grep '<Password>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
    echo "sftp:${agreementName}:${hostname}:${user}:${passwd}";
}

function FTPSURLGen()
{
    echo "ftps:${agreementName}";
}

function connectionTest()
{
    for URL in $(cat "${connectionURLTmpFile}")
    do
        echo -n "${URL}";
        echo "${URL}" >> "${logFile}";
        curl "${URL}" --connect-timeout "${timeOutSec}" >> "${logFile}" 2>&1;
        if [[ $(echo $?) == '0' ]];then
            echo -e "\033[1;32mSuccess\033[0m";
        else
            echo -e "\033[1;31;5mFail\033[0m";
        fi
        for agr in $(grep "|${URL}$" "${agreementURLMap}" | cut -d \| -f1)
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
    gfind "/tmp/" -mtime +1 -name "connectionURL_*.tmp" -exec /usr/bin/rm {} \; 2>/dev/null;
    gfind "/tmp/" -mtime +1 -name "agreementURL_*.map" -exec /usr/bin/rm {} \; 2>/dev/null;
    gfind "$(dirname $0)/" -mtime +10 -name "log.*" -exec /usr/bin/rm {} \; 2>/dev/null;
}

function main()
{
    init;
    for agreementConfigFile in $(ls /ext/comsys*/agr/*/*_dump.xml)
    do
        protocol=$(grep '<Protocol>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
        agreementName=$(grep '<AgrID>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
        case "${protocol}" in
            ftp)
            FTPURLGen;
            ;;
            script)
            SFTPURLGen;
            ;;
            ftps)
            FTPSURLGen;
            ;;
            *)
            echo "Failed to check agreement ${agreementName} cause undefined protocol ${protocol}.";
            ;;
        esac
    done
    #remove duplicate connection URLs
    cat "${connectionURLTmpFile}" | sort | uniq > "${connectionURLTmpFile}";
    connectionTest;
    /usr/bin/rm "${connectionURLTmpFile}";
    /usr/bin/rm "${agreementURLMap}";
}

main
