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
    echo -n "number of $1:";
    ls -l | grep $1 | grep -c ".att$";
    ls -l | grep $1 | head;
}

function massclean()
{
    echo "TODO";
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
        ls -l | grep ${processID};
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

function ref()
{
    for file in $(ls /ext/schenker/data/error/*$1*.att)
    do
        echo; basename ${file};
        transaction=$(ggrep -A1 -E 'TransactionAttribute' ${file} | sed -n '2p');
        echo "Date/Time : $(echo ${transaction} | ggrep -Eo "[0-9]{4}-[a-zA-Z]{3}-[0-9]{2} [0-9:]{8}") CET";
        echo "TRID : $(ggrep -A1 -E 'TRID' ${file} | sed -n '2p')";
        BDIDRefValues=$(ggrep -A1 -E 'BDIDRefValues' ${file} | sed -n '2p');
        if [[ ${BDIDRefValues} != '' ]];then
            echo ${BDIDRefValues} | awk -F\" '{print "BDID : "$2}';
            echo "BDIDRefValues : ";
            echo $BDIDRefValues | grep -Eo "\{[^\{\}]*\}" | awk -F\" '{print $2" : "$4}'
        fi
        echo "TransactionAttribute : ";
        echo "${transaction}";
    done
    echo;
}

function checkResend()
{
    cd /ext/comsys0009/archive/scheduler/CISCUCEOUT_inbound/2018/10/08;
    for file in $(gfind . -size 0);
    do
        ori=$(echo $file | cut -d\. -f4-);
        count=$(gfind . -name "*$ori" -size +0 | wc -l | bc);
        echo -n "$ori;";
    if [[ $count == 0 ]];then
        echo NO;
    else
        echo OK;
    fi
    done
}

function info()
{
    echo "alias:";
    echo "..|...|ll|l|allen|new|old|grep|vi|xfb";
    echo "values:";
    echo "houseKeepPath|downloadPath|allen|ftpLog";
    echo "functions:";
    echo "info|getBDID|massinfo|download|downloadError|monitor|catError|checkDEA|statByTime|statByAgrOrPID|sameFile|hk|clean|loop|oldFile|catAgr|cdAgr|ref";
}



info;
