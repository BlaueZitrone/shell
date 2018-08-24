#!/bin/bash

configFile="findAgreement.cfg";
keywordFile="keyword.cfg";

function printLine()
{
    echo "===================================================================";
}

function check()
{
    for gw in $(grep GW ${configFile} | grep -v "^#")
    do
        server=$(echo ${gw} | cut -d\| -f1);
        remoteHostName=$(echo ${gw} | cut -d\| -f2);
        echo "${server}";
        /usr/bin/scp -o StrictHostKeyChecking=no -r /ext/schenker/support/allen/findAgreement xib@${remoteHostName}:/ext/schenker/support/allen 2>/dev/null;
        /usr/bin/ssh -o StrictHostKeyChecking=no ${remoteHostName} '\
        cd /ext/schenker/support/allen/findAgreement;\
        for line in $(/usr/sfw/bin/ggrep -e $(cat keyword.cfg | head -1) /ext/coms*/agr*/*/*xml); do echo $line; cat $(echo $line | cut -d\: -f 1); echo; done\
        ' 2>/dev/null;
        printLine;
    done
}

function init()
{
    LD_LIBRARY_PATH="";
    ftpPath=$1;
    if [[ -z "${ftpPath}" ]]; then
        exit;
    fi

    echo "Please input the field your keyword belongs to.";
    echo "Protocol|AgrID|Dir|CmdFile|RemoteHost|User|Password|RemoteFileMask|RemoteDir|Archive|Counter|DstFileName|KeepArchive|LocalDstDir|Mode|RunMode";
    read filed;

    if [[ -z "${filed}" ]];then
        echo "${ftpPath}" > ${keywordFile};
    else
        keyword="<${filed}>.*${ftpPath}.*</${filed}>";
        echo "${keyword}" > ${keywordFile};
    fi
}

function main()
{
    init $@;
    check;
}

main $@;

