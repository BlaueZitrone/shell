#!/bin/bash

. ../common_func/colorfulEcho.sh;

big_file=$1;
if [[ -z "${big_file}" ]]; then
	Input;
	echo -n "Enter the name of the big file: ";
	read big_file;
fi

if [[ ! -f ${big_file} ]]; then
	Error;
	echo "Cannot find file according to the name.";
	exit;
fi
ls -l ${big_file};

agreementID=$(echo ${big_file} | cut -d\. -f1);
counter=$(echo ${big_file} | cut -d\. -f2);
prefix="${agreementID}.${counter}";
original_filename=$(echo ${big_file} | cut -d\. -f3-);
suffix="${original_filename}";
fileSize=$(ls -l ${big_file} | awk -F' ' '{print $5}');

Check;
echo "agreementID : ${agreementID}";
Check;
echo "counter : ${counter}";
#Debug;
#echo "prefix : ${prefix}";
Check;
echo "original_filename : ${original_filename}";
#Debug;
#echo "suffix : ${suffix}";
#Debug;
#echo "fileSize : ${fileSize}";

agreementPath="$(/ext/schenker/toolslocal/agrcheck ${agreementID} | ggrep -B 1 ${agreementID} | head -1)";
if [[ -z "${agreementPath}" ]];then
	Error;
	echo "Agreement path not found!";
	exit;
fi

Check;
echo "agreementPath : ${agreementPath}";
Check;
grep "<MaxSize>" ${agreementPath}/${agreementID}/${agreementID}_dump.xml;
maxSize=$(grep "<MaxSize>" ${agreementPath}/${agreementID}/${agreementID}_dump.xml | ggrep -Eo "[0-9]+" );
minSize=$(echo "${maxSize} / 10" | bc);
#Debug;
#echo "minSize : ${minSize}";
Info;
echo "Now we are going to split the file";

Input;
echo -n "Input the size (between ${minSize} and ${maxSize}, $(echo "${minSize} * 6" | bc) recommended) to split big file into (Unit: byte): ";
read inputNum;
splitSize=$(echo "${inputNum}" | bc);
if [[ ${splitSize} != ${inputNum} ]];then
	Error;
	echo "Input invalid!";
	exit;
fi
#Debug;
#echo "splitSize : ${splitSize}";
if [[ ${splitSize} -gt ${maxSize} || ${splitSize} -lt ${minSize} ]];then
	Error;
	echo "Input number out of reasonable range!";
	exit;
fi
estimatedFileNum=$(echo "${fileSize} / ${splitSize} + 1" | bc);

#Debug;
#echo "estimatedFileNum : ${estimatedFileNum}";
Info;
echo "File will be split into about ${estimatedFileNum} * ${splitSize} bytes files";
tmp_folder=$(date "+%Y%m%d_%H%M%S");
mkdir -p ${tmp_folder};
mv ${big_file} ${tmp_folder};
cd ${tmp_folder};
/ext/schenker/toolslocal/msplit ${big_file} ${splitSize};

Check;
echo "Small files are as below:";
ls -l;
processID=$(ls | head -1 | awk -F'.' '{print $1}');
totalnum=$(ls -l | grep -c ${processID});
if [[ "${totalnum}" -eq 1 ]];then
	Error;
	echo "Only one file generated, split action failed!";
	exit;
fi
for splittedFileSize in $(ls -l | awk -F' ' '{print $5}')
do
	if [[ "${splittedFileSize}" -gt "${maxSize}" ]];then
		Error;
		echo "Splitted file size is bigger than limit, split action failed!";
		exit;
	fi
done

Check;
echo "Below steps will be taken:";
for num in $(ls ${processID}* | cut -d\. -f2 | sort -n)
do
	file="${processID}.${num}";
	echo "[${num}/${totalnum}] moving ${file} to > ${agreementPath}/../comexp_ok/${prefix}_${num}.${suffix}";
done

Info;
echo -n "You can press \"Ctrl + C\" to stop or \"Enter\" to continue: ";
read gapSec;
gapSec=$(echo "${gapSec}" | bc);
if [[ -z ${gapSec} ]];then
	gapSec=30;
fi

#Debug;
#echo "gapSec : ${gapSec}";
Processing;
for num in $(ls ${processID}* | cut -d\. -f2 | sort -n)
do
	file="${processID}.${num}";
	mv ${file} ${agreementPath}/../comexp_ok/${prefix}_${num}.${suffix};
	echo -n "[${num}/${totalnum}]|";
	sleep ${gapSec};
done
echo "All moving tasks done!";
cd ..;
rmdir ${tmp_folder};

Check;
echo "Now grabbing the log, please have a check:";
grep ${original_filename} ${agreementPath}/../log/log | grep ExportF*;
