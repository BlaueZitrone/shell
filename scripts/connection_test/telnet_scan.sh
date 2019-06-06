#!/bin/bash

timestamp=$(date "+%Y%m%d%H%M%S");
connectionURLTmpFile="$(dirname $0)/$(hostname)_${timestamp}.url";
agreementURLMap="$(dirname $0)/$(hostname)_${timestamp}.map";

for agreementConfigFile in $(ls /ext/comsys*/agr/*/*_dump.xml)
do
    protocol=$(grep '<Protocol>.*</Protocol>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
    agreementName=$(grep '<AgrID>.*</AgrID>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
    hostname=$(grep '<RemoteHost>.*</RemoteHost>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
    port=$(grep '<Port>.*</Port>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
    url="";
    if [[ "X${port}" == "X" ]]; then
        if [[ "ftp" == "${protocol}" ]]; then
            port="21";
        elif [[ "script" == "${protocol}" ]]; then
            port="22";
        fi
    fi
    if [[ "X${hostname}" != "X" ]]; then
        IPaddr=$(grep -w ${hostname} /etc/hosts | head -1 | /usr/sfw/bin/ggrep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}");
    fi
    if [[ "X${IPaddr}" != "X" ]]; then
        url="telnet://${IPaddr}:${port}";
    else
        url="telnet://${hostname}:${port}";
    fi
    echo "${url}" >> "${connectionURLTmpFile}";
    echo "${agreementName}|${url}" >> "${agreementURLMap}";
done


