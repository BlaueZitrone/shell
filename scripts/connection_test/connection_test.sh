#!/bin/bash

function ftpConnectionTest()
{
    hostname=$(grep '<RemoteHost>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
    user=$(grep '<User>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
    passwd=$(grep '<Password>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
    echo -n "RemoteHost:${hostname}|User:${user}|Password:${passwd}|";
    curl "ftp://${user}:${passwd}@${hostname}" > /dev/null 2>&1;
    if [[ $(echo $?) == '0' ]];then
        echo -e "\033[1;32mSuccess\033[0m";
    else
        echo -e "\033[1;31;5mFail\033[0m";
    fi
}

function sftpConnectionTest()
{
    echo "sftp:${agreementName}";
}

function ftpsConnectionTest()
{
    echo "ftps:${agreementName}";
}

function main()
{
    for agreementConfigFile in $(ls /ext/comsys*/agr/*/*_dump.xml)
    do
        protocol=$(grep '<Protocol>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
        agreementName=$(grep '<AgrID>' ${agreementConfigFile} | sed "s/<[^<>]*>//g");
        case ${protocol} in
            ftp)
            ftpConnectionTest;
            ;;
            script)
            sftpConnectionTest;
            ;;
            ftps)
            ftpsConnectionTest;
            ;;
            *)
            echo "Failed to check agreement ${agreementName} cause undefined protocol ${protocol}.";
            ;;
        esac
    done
}

main
