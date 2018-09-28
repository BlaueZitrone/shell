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
    cd $sup/allen/monitor;
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
        abr ${processID};
        echo "mv ${processID}* ${houseKeepPath}";
        read;
        mv ${processID}* ${houseKeepPath};
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

function info()
{
    echo "alias:";
    echo "..|...|ll|l|allen|new|old|grep|vi|xfb";
    echo "values:";
    echo "houseKeepPath|downloadPath|allen|ftpLog";
    echo "functions:";
    echo "info|getBDID|massinfo|download|downloadError|monitor|catError|checkDEA|statByTime|statByAgrOrPID|sameFile|hk|clean|loop|oldFile";
}



info;
