#!/bin/bash

function checkAndBeep()
{
    if [[ ${needBeep} == true ]];then
        /usr/bin/ssh -o StrictHostKeyChecking=no $1 'if [[ $(ls /ext/schenker/data/error | wc -l | bc) != 0 ]];then for i in $(/opt/sfw/bin/seq 1 5);  do echo -en "\a"; /usr/local/bin/usleep 600000 ; done; fi' 2>/dev/null;
    fi
}

function checkApp()
{
    for app in $(grep APP ${configFile} | grep -v "^#")
    do
        server=$(echo ${app} | cut -d\| -f1);
        remoteHostName=$(echo ${app} | cut -d\| -f2);
        echo "${server}";
        /usr/bin/ssh -o StrictHostKeyChecking=no ${remoteHostName} '\
        echo -en "Massfilter:"; ls /ext/schenker/data/error | grep 'MassFilter' | grep -c '.att$'; ls /ext/schenker/data/error | grep 'MassFilter' | grep '.att$' | cut -d\. -f2 | sort | uniq -c;\
        echo -en "Error:"; ls /ext/schenker/data/error | grep -v 'MassFilter' | grep -c '.att$'; ls /ext/schenker/data/error | grep -v 'MassFilter' | grep '.att$' | cut -d\. -f1 | sort | uniq -c;\
        ' 2>/dev/null;
        checkAndBeep ${remoteHostName};
        printLine;
    done
}

function checkGw()
{
    for gw in $(grep GW ${configFile} | grep -v "^#")
    do
        server=$(echo ${gw} | cut -d\| -f1);
        remoteHostName=$(echo ${gw} | cut -d\| -f2);
        echo "${server}";
        case ${willCheckOldFile} in
            true)
                    /usr/bin/ssh -o StrictHostKeyChecking=no ${remoteHostName} '\
                    echo -en "Error:"; ls /ext/schenker/data/error | wc -l; ls /ext/schenker/data/error | cut -d\. -f1 | sort | uniq -c;\
                    echo "Old file checking:"; /ext/schenker/toolslocal/list2 -fileagemin=30;\
                    ' 2>/dev/null;
                    ;;
            false)
                    /usr/bin/ssh -o StrictHostKeyChecking=no ${remoteHostName} '\
                    echo -en "Error:"; ls /ext/schenker/data/error | wc -l; ls /ext/schenker/data/error | cut -d\. -f1 | sort | uniq -c;\
                    ' 2>/dev/null;
                    ;;
        esac
        checkAndBeep ${remoteHostName};
        printLine;
    done
}

function checkFtp()
{
    echo "FTP part not complete yet...";
    #TODO
}

function init()
{
    LD_LIBRARY_PATH="";
    localHostName=$(hostname);
    willCheckOldFile=false;
    isLoopCheck=false;
    needBeep=false;

    while getopts "f:t:obh" arg
    do
        case ${arg} in
            f)
                configFile=${OPTARG};
                ;;
            t)
                isLoopCheck=true;
                gap=${OPTARG};
                ;;
            o)
                willCheckOldFile=true;
                ;;
            b)
                needBeep=true;
                ;;
            h)
                printHelp;
                exit;
                ;;
            *)
                printHelp;
                exit;
                ;;
        esac
    done
    if [[ -z "${configFile}" ]]; then
        configFile="monitor.cfg";
    fi
}

function printNow()
{
    echo "=======================$(date "+%Y-%m-%d %H:%M:%S")=========================";
}

function printLine()
{
    echo "===================================================================";
}

function printHelp()
{
    printLine;
    echo "This script is used to monitor all APP and GW server in one location.";
    printLine;
    echo "./monitor.sh -f custom.cfg | use a customised config file instead of monitor.cfg as default.";
    echo "in config file, line starts with '#' will be ignored.";
    echo "./monitor.sh -t 300 | create a loop check, the gap will be 300 seconds.";
    echo "./monitor.sh -o | check old file when checking GW.";
    echo "./monitor.sh -b | script will beep if error folder is not empty.";
    echo "./monitor.sh -h | print help info.";
    printLine;
}

function main()
{
    init $@;
    case ${isLoopCheck} in
        false)
                printNow;
                checkApp;
                checkGw;
                checkFtp;
                ;;
        true)
                while true
                do
                    clear;
                    printNow;
                    checkApp;
                    checkGw;
                    checkFtp;
                    sleep ${gap};
                done
                ;;
    esac
}

main $@;
