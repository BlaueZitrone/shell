#!/bin/bash

timestamp=$(date "+%Y%m%d%H%M%S");
connectionURLTmpFile="$(dirname $0)/$(hostname)_${timestamp}.url";
agreementURLMap="$(dirname $0)/$(hostname)_${timestamp}.map";

for agreementConfigFile in $(ls /ext/comsys*/agr/*/*_dump.xml)
do
    protocol=$(grep '<Protocol>.*</Protocol>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
    agreementName=$(grep '<AgrID>.*</AgrID>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
    hostname=$(grep '<RemoteHost>.*</RemoteHost>' ${agreementConfigFile} | sed "s/<[^<>]*>//g" | /opt/sfw/bin/sed -e "s/\s//g");
    port=$(grep '<Port>.*</Port>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
    url="";
    if [[ "X${port}" == "X" ]]; then
        if [[ "ftp" == "${protocol}" ]]; then
            port="21";
        elif [[ "script" == "${protocol}" ]]; then
            port="22";
        fi
    fi
    if [[ "X${hostname}" == "X" ]]; then
        scriptline=$(grep '<ScriptName>.*</ScriptName>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
        script=$(echo ${scriptline} | awk '{print $1}');
        if [[ "${script}" == "sftp_inbound.sh" || "${script}" == "sftp_outbound.sh" ]]; then
            hostname=$(echo ${scriptline} | awk '{print $3}');
        fi
    fi
    if [[ "X${hostname}" != "X" ]]; then
        IPaddr=$(grep -w ${hostname} /etc/hosts | head -1 | /usr/sfw/bin/ggrep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}");
        if [[ "X${IPaddr}" != "X" ]]; then
            url="/usr/local/bin/nc -vzw3 ${IPaddr} ${port}";
        else
            url="/usr/local/bin/nc -vzw3 ${hostname} ${port}";
        fi
    else
        url="dummy";
    fi
    echo "${url}" >> "${connectionURLTmpFile}";
    echo "${agreementName}|${url}" >> "${agreementURLMap}";
done

LD_LIBRARY_PATH="";
/usr/bin/scp -o StrictHostKeyChecking=no ${connectionURLTmpFile} amtrix@xibftprd1.dc.signintra.com:/app/xib/ext/support/allen/connection_test;
/usr/bin/scp -o StrictHostKeyChecking=no ${agreementURLMap} amtrix@xibftprd1.dc.signintra.com:/app/xib/ext/support/allen/connection_test;
