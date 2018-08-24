#!/bin/bash
##########################################################################
#
# script for updating MassFilter record from database
# $LastChangedDate:: 2017-11-10
# $Author:: Allen Chen
#
##########################################################################

#include some ScriptFunctions
. $FRAME_ROOT/tools/ScriptFunctions
. ./checkMassFilter.cfg

currentDir=$(pwd);
recordFile="${currentDir}/record.data";
tmpRecordFile="${currentDir}/record.tmp";

function writeTmpRecord()
{
    pid=$1;
    intergrationType=$2;
    values=$3;
    [[ -z ${pid} ]] && exit;
    [[ -z ${intergrationType} ]] && exit;
    echo "${pid}|${intergrationType}|${values}" >> ${tmpRecordFile};
}

for pid in $(cat ${recordFile} | awk -F'|' '{print $1}' | uniq)
do
	INTEGRATIONTYPE=`SQLselect INTEGRATIONTYPE XIB_PROCESSIDPROPERTIES PROCESSIDCODE $pid | sed 's#^.* ##'`;
	MFVALUES=`SQLselect PROCESSID,NOFILES,NOBYTES,FILTER_REACHED MON_MASSFILTER PROCESSID $pid | sed -e 's#, #,#g' -e 's# ,#,#g'`;
	writeTmpRecord "${pid}" "${INTEGRATIONTYPE}" "${MFVALUES}";
	sleep ${updateGap};
done

mv ${tmpRecordFile} ${recordFile};