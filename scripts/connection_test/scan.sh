#!/bin/bash

function scan()
{
    for agreementConfigFile in $(ls /ext/comsys*/agr/*/*_dump.xml)
    do
        protocol=$(grep '<Protocol>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
        agreementName=$(grep '<AgrID>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
        echo "${agreementName}:${protocol}" >> "${logFile}";
        if [[ "${protocol}" == "ftp" ]]; then
            hostname=$(grep '<RemoteHost>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
            user=$(grep '<User>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
            passwd=$(grep '<Password>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
            if [[ "${hostname}" != "" ]]; then
                IPaddr=$(grep -w ${hostname} /etc/hosts | head -1 | /usr/sfw/bin/ggrep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}");
            fi
            if [[ ${IPaddr} != "" ]]; then
                url="ftp://${user}:${passwd}@${IPaddr}";
            else
                url="ftp://${user}:${passwd}@${hostname}";
            fi
            echo "${url}" >> "${connectionURLTmpFile}";
            echo "${agreementName}|${url}" >> "${agreementURLMap}";
        fi
    done
}


timeOutSec=5;
connectionURLTmpFile="$(dirname $0)/connectionURL_$(date "+%Y%m%d%H%M%S").url";
agreementURLMap="$(dirname $0)/agreementURL_$(date "+%Y%m%d%H%M%S").map";
logFile="$(dirname $0)/log.$(date "+%Y%m%d")";
scan;
