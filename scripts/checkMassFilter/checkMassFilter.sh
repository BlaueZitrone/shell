#!/bin/bash
##########################################################################
#
# script for checking MassFilter and do basic investigation
# $LastChangedDate:: 2017-11-08
# $Author:: Allen Chen
#
##########################################################################

#include some ScriptFunctions
. $FRAME_ROOT/tools/ScriptFunctions
. ./checkMassFilter.cfg

currentDir=$(pwd);
recordFile="${currentDir}/record.data";

[[ ! -f ${recordFile} ]] && touch ${recordFile};

function main()
{
    cd ${errorFolder};
    #cd /ext/schenker/support/allen/checkMassFilter/test
    while true;
    do
    	clear;
    	echo "==========$(date "+%Y-%m-%d %H:%M:%S")==========";
    	clean_up2 -v;
    	echo "==========Massfilter==========";
    	for PROCESSID in $(ls -l | grep 'MassFilter' | awk -F'.' '{print $2}' | sort | uniq);
    	do
            readRecord "${PROCESSID}";
    		
    	done
    	sleep $sleepSeconds;
    done
}

function writeRecord()
{
    pid=$1;
    intergrationType=$2;
    values=$3;
    [[ -z ${pid} ]] && exit;
    [[ -z ${intergrationType} ]] && exit;
    echo "${pid}|${intergrationType}|${values}" >> ${recordFile};
}

function readRecord()
{
    pid=$1;
    [[ -z ${pid} ]] && exit;
    echo "PROCESSID : ${pid}";
    echo "MFFileNumber : $(ls -l | grep 'MassFilter' | grep '.att$' | grep -c "${pid}")";
    grep ${pid} ${recordFile};
    if [[ "$?" != "0" ]];then
        echo "Read from data file failed, try to read from database.";
        INTEGRATIONTYPE=`SQLselect INTEGRATIONTYPE XIB_PROCESSIDPROPERTIES PROCESSIDCODE $pid | sed 's#^.* ##'`;
        echo "IntergrationType : ${INTEGRATIONTYPE}";
        MFVALUES=`SQLselect PROCESSID,NOFILES,NOBYTES,FILTER_REACHED MON_MASSFILTER PROCESSID $pid | sed -e 's#, #,#g' -e 's# ,#,#g'`;
        echo "MFVALUES : ${MFVALUES}";
        writeRecord "${pid}" "${INTEGRATIONTYPE}" "${MFVALUES}";
    fi
    echo;
}

main;

