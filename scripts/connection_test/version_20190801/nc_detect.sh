#!/bin/bash

function connectionDetect()
{
    cat "${connectionURLTmpFile}" | sort | uniq | while read URL
    do
        echo -n "${URL};" >> "${resultFile}";
        echo -n "[$(date)] : " | tee -a "${logFile}";
        echo "${URL}" | tee -a "${logFile}";
        for hostname in $(fgrep "|${URL}" "${agreementURLMap}" | cut -d \| -f2 | sort | uniq)
        do
            echo -n "${hostname}|" >> "${resultFile}";
        done
        echo -n ";" >> "${resultFile}";
        if [[ "X$(fgrep "|${URL}" "${agreementURLMap}" | cut -d \| -f3 | grep -c "Y")" != "X0" ]];then
            echo -n "Y;" >> "${resultFile}";
        else
            echo -n "N;" >> "${resultFile}";
        fi
        ${URL} >> "${logFile}" 2>&1;
        retCode=$?;
        if [[ "X${retCode}" == "X0" ]];then
            echo -n "Y;" >> "${resultFile}";
        else
            echo -n "N;" >> "${resultFile}";
        fi
        for agr in $(fgrep "|${URL}" "${agreementURLMap}" | cut -d \| -f1)
        do
            echo -n "${agr}|" >> "${resultFile}";
        done
        echo >> "${resultFile}";
    done
}

server=$1;
timeOutSec=5;
logFile="$(dirname $0)/log.${server}.$(date "+%Y%m%d%H%M%S")";
resultFile="${server}.csv";
echo "URL;Hostname;Origin_Result;Current_Result;Agreement" > ${resultFile};
connectionURLTmpFile="${server}.url";
agreementURLMap="${server}.map"
connectionDetect;
