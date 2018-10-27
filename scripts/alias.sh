#alias
alias ..='cd ..';
alias ...='cd ../..';
alias ll='ls -l';
alias l='ls -l';
alias allen='cd $sup/allen';
alias new='ls -lt | head';
alias old='ls -lt | tail';
alias grep='ggrep --color=auto';
alias vi='vim';
alias xfb='cd /ext/schenker/logarchive/';
alias a1='ssh -o StrictHostKeyChecking=no xibapprd1.dc.signintra.com';
alias a2='ssh -o StrictHostKeyChecking=no xibapprd2.dc.signintra.com';
alias a3='ssh -o StrictHostKeyChecking=no xibapprd3.dc.signintra.com';
alias a4='ssh -o StrictHostKeyChecking=no xibapprd4.dc.signintra.com';
alias g1='ssh -o StrictHostKeyChecking=no xibgwprd1.dc.signintra.com';
alias g2='ssh -o StrictHostKeyChecking=no xibgwprd2.dc.signintra.com';
alias g3='ssh -o StrictHostKeyChecking=no xibgwprd3.dc.signintra.com';
alias g4='ssh -o StrictHostKeyChecking=no xibgwprd4.dc.signintra.com';
alias FTP='ssh -o StrictHostKeyChecking=no amtrix@xibftprd1.dc.signintra.com';

#values
houseKeepPath=$sup/error/$(date "+%Y/%m/");
downloadPath=$sup/allen/download/$(date "+%Y%m%d");
allen=${sup}/allen;
ftpLog="/ext/schenker/prot/proftpd/proftpd.access_log";

mkdir -p ${downloadPath};
chmod 777 ${downloadPath};
mkdir -p ${houseKeepPath};

#functions
function getBDID()
{
    agreementID=$(echo $1 | cut -d\. -f1);
    counter=$(echo $1 | cut -d\. -f2);
    prefix="${agreementID}.${counter}";
    agreementPath="$(/ext/schenker/toolslocal/agrcheck ${agreementID} | ggrep -B 1 ${agreementID} | head -1)";
    cat "${agreementPath}/../archive/imptmp/${prefix}";
}

function massinfo()
{
    echo -n "MassFilterFileNumber of $1:";
    ls -l | grep "MassFilter" | grep $1 | grep -c ".att$";
    ls -l | grep "MassFilter" | grep $1 | head;
}

function runmass()
{
    . $FRAME_ROOT/tools/ScriptFunctions;
    if [[ $1 != '' ]]; then
        massinfo $1;
        INTEGRATIONTYPE=$(SQLselect INTEGRATIONTYPE XIB_PROCESSIDPROPERTIES PROCESSIDCODE $1 | sed 's#^.* ##');
        echo "Integration type : ${INTEGRATIONTYPE}";
        if [[ "${INTEGRATIONTYPE}" == "Parallel" ]];then
            echo -e "\n>>>deletemassfilterflag $1";
            echo | deletemassfilterflag $1;
            echo -e "\n>>>remafi $1 2";
            remafi $1 2;
        elif [[ "${INTEGRATIONTYPE}" == "Serial" ]]; then
            echo -e "\n>>>remafi $1 6";
            remafi $1 6;
            echo -e "\n>>>deletemassfilterflag $1";
            echo | deletemassfilterflag $1;
        fi
    fi
}

function download()
{
    cp $@ ${downloadPath};
    chmod 666 ${downloadPath}/*;
}

function downloadError()
{
    cp ${houseKeepPath}/$@ ${downloadPath};
    chmod 666 ${downloadPath}/*;
}

function monitor()
{
    cd $sup/monitor;
    ./monitor.sh $@;
}

function catError()
{
    cat ${houseKeepPath}/$@;
}

function checkDEA()
{
    /ext/schenker/toolslocal/PassportTool/ppt -s"$1" -sd -i "$2";
}

function statByTime()
{
    ls -ltr | awk '{print $8}' | uniq -c | grep ':'
}

function statByAgrOrPID()
{
    ls | cut -d\. -f1 | sort | uniq -c | sort -nr
}

function sameFile()
{
    oldREF=${REF};
    REF='';

    gfind . -type f -exec md5sum {} \; | awk '{print $1}' | sort | uniq -c | while read rec
    do
        if [[ $(echo ${rec} | awk '{print $1}' | bc) -gt 1 ]];then
            MD5=$(echo ${rec} | awk '{print $2}');
            echo "MD5: ${MD5}";
            gfind . -type f -exec md5sum {} \; | grep ${MD5} | awk '{print $2}';
            echo;
        fi
    done

    REF=${oldREF};
}

function hk()
{
    if [[ $1 != '' ]]; then
        processID=$1;
        echo -n "ErrorFileNumber of $1:";
        ls -l | grep -v "MassFilter" | grep $1 | grep -c ".att$";
        ls -l | grep ${processID} | head;
        ref ${processID};
        /opt/sfw/bin/mv -v ${processID}* ${houseKeepPath};
    fi
}

function clean()
{
    err;
    echo "============$(date "+%Y-%m-%d %H:%M:%S")==============" >> ${sup}/allen/clean.log;
    clean_up2 -v | tee -a ${sup}/allen/clean.log;
}

function loop()
{
    cd $sup/allen;
    ./check_error.sh;
}

function oldFile()
{
    scan_out="$sup/allen/old_file_scan_record/$(date "+%Y%m")/old_file_scan_$(date "+%Y%m%d_%H%M%S")_$(hostname)";
    mkdir -p $sup/allen/old_file_scan_record/$(date "+%Y%m")/;
    chmod 777 $sup/allen/old_file_scan_record/$(date "+%Y%m");
    list2 -fileagemin=30 | tee ${scan_out}; chmod 666 ${scan_out};
}

function catAgr()
{
    if [[ $1 != '' ]]; then
        cat /ext/comsys*/agr/$1/$1_dump.xml;
    fi
}

function cdAgr()
{
    if [[ $1 != '' ]]; then
        cd /ext/comsys*/agr/$1/;
    fi
}

function grepAgr()
{
    echo "TODO";
    #will simplify findAgreement.sh to this function
}

function cdArchive_G()
{
    if [[ $1 != '' ]]; then
        cd /ext/comsys*/archive/scheduler/$1/;
        cd $(date +"%Y/%m/%d");
    fi
}

function cdArchive_A()
{
    if [[ $1 != '' ]]; then
        processID=$1;
        if [[ $2 != '' ]];then
            cd "/archive/${processID:0:4}/${processID:4:10}/IN/$(/opt/sfw/bin/date -d "1 day ago" +"%Y/%m/%d")";
        else
            cd "/ext/schenker/archive/${processID:0:4}/${processID:4:10}/IN/$(date +"%Y/%m/%d")";
        fi
    fi
}

function ref()
{
    for file in $(ls /ext/schenker/data/error/*$1*.att | grep -v "MassFilter")
    do
        echo; basename ${file};
        transaction=$(ggrep -A1 -E 'TransactionAttribute' ${file} | grep -v "^TransactionAttribute$" | head -1);
        echo "Date/Time : $(echo ${transaction} | ggrep -Eo "[0-9]{4}-[a-zA-Z]{3}-[0-9]{2} [0-9:]{8}") CET";
        echo "TRID : $(ggrep -A1 -E 'TRID' ${file} | sed -n '2p')";
        BDIDRefValues=$(ggrep -A1 -E 'BDIDRefValues' ${file} | grep -v "^BDIDRefValues$" | head -1);
        if [[ ${BDIDRefValues} != '' ]];then
            echo ${BDIDRefValues:0:99} | awk -F\" '{print "BDID : "$2}';
            echo "BDIDRefValues : ";
            echo $BDIDRefValues | grep -Eo "\{[^\{\}]*\}" | awk -F\" '{print $2" : "$4}'
        fi
        echo "TransactionAttribute : ";
        echo "${transaction}";
    done
    echo;
}

function 0byte()
{
    for emptyFile in $(gfind $err -size 0 -name "*$1*" -type f -exec basename {} \;)
    do
        fileName=$(basename ${emptyFile});
        agrName=$(echo ${fileName} | cut -d\. -f1);
        oriName=$(echo ${fileName} | cut -d\. -f3-);
        archiveFolder="/ext/comsys*/archive/scheduler/${agrName}/$(date +"%Y/%m/%d")";
        echo "0 byte file name : ${fileName}";
        echo -e "\n===checking file with the same name in archive folder(${archiveFolder})===";
        echo "0 byte file received : ";
        gfind ${archiveFolder} -name "*${oriName}" -size 0 -type f -exec ls -l {} \;;
        echo "file with content : ";
        gfind ${archiveFolder} -name "*${oriName}" -size +0 -type f -exec ls -l {} \;;

        comsysLogFile="/ext/comsys*/agr/${agrName}/../../log/log";
        echo -e "\n===checking comsys log===";
        grep ${oriName} ${comsysLogFile};

        echo -e "\n===checking ftp access log===";
        echo -n "Please input the keyword you want to use for grep ftp log, original filename (${oriName}) will be used if nothing was input:";
        read -t 30 keywordForFTP;
        if [[ ${keywordForFTP} == "" ]];then
            keywordForFTP=${oriName};
        fi
        ssh -o StrictHostKeyChecking=no amtrix@xibftprd1.dc.signintra.com "/opt/amtcftp/tools/support/bin/ggrep ${keywordForFTP} /ext/schenker/prot/proftpd/proftpd.access_log";
    done
}

function info()
{
    echo "alias:";
    echo "..|...|ll|l|allen|new|old|grep|vi|xfb|a1|a2|a3|a4|g1|g2|g3|g4|FTP";
    echo "values:";
    echo "houseKeepPath|downloadPath|allen|ftpLog";
    echo "functions:";
    echo "info|getBDID|massinfo|download|downloadError|monitor|catError|checkDEA|statByTime|statByAgrOrPID|sameFile|hk|clean|loop|oldFile|catAgr|cdAgr|ref|0byte|cdArchive_G|cdArchive_A";
}



info;
