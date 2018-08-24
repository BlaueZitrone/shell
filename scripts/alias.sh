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

#values
houseKeepPath=$sup/error/$(date "+%Y/%m/");
downloadPath=$sup/allen/download/$(date "+%Y%m%d")
allen=${sup}/allen;

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

function info()
{
    echo "alias:";
    echo "..|...|ll|l|allen|new|old|grep|vi";
    echo "values:";
    echo "houseKeepPath|downloadPath|allen";
    echo "functions:";
    echo "info|getBDID|massinfo|download|downloadError|monitor|catError|checkDEA";
}



info;