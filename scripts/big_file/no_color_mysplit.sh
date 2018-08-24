#!/bin/bash

big_file=$1;
if [[ -z "${big_file}" ]]; then
	echo -n "[Input] Enter the name of the big file: ";
	read big_file;
fi

if [[ ! -f ${big_file} ]]; then
	echo "[Error] Cannot find file according to the name.";
	exit;
fi
ls -l ${big_file};

agreementID=$(echo ${big_file} | cut -d\. -f1);
counter=$(echo ${big_file} | cut -d\. -f2);
prefix="${agreementID}.${counter}";
original_filename=$(echo ${big_file} | cut -d\. -f3-);
suffix="${original_filename}";
fileSize=$(ls -l ${big_file} | awk -F' ' '{print $5}');

echo "[Check] agreementID : ${agreementID}";
echo "[Check] counter : ${counter}";
#echo "[Debug] prefix : ${prefix}";
echo "[Check] original_filename : ${original_filename}";
#echo "[Debug] suffix : ${suffix}";
#echo "[Debug] fileSize : ${fileSize}";

agreementPath="$(/ext/schenker/toolslocal/agrcheck ${agreementID} | ggrep -B 1 ${agreementID} | head -1)";
echo "[Check] agreementPath : ${agreementPath}";
echo -n "[Check] ";
grep "<MaxSize>" ${agreementPath}/${agreementID}/${agreementID}_dump.xml;
maxSize=$(grep "<MaxSize>" ${agreementPath}/${agreementID}/${agreementID}_dump.xml | ggrep -Eo "[0-9]+" );
minSize=$(echo "${maxSize} / 10" | bc);
#echo "[Debug] minSize : ${minSize}";

echo "[Info] Now we are going to split the file";
echo -n "[Input] Input the size (between ${minSize} and ${maxSize}, $(echo "${minSize} * 6" | bc) recommended) to split big file into (Unit: byte): ";
read inputNum;
splitSize=$(echo "${inputNum}" | bc);
if [[ $? != 0 ]];then
	echo "[Error] Input invalid!";
	exit;
fi
#echo "[Debug] splitSize : ${splitSize}";
if [[ ${splitSize} -gt ${maxSize} || ${splitSize} -lt ${minSize} ]];then
	echo "[Error] Input number out of reasonable range!";
	exit;
fi
estimatedFileNum=$(echo "${fileSize} / ${splitSize} + 1" | bc);
#echo "[Debug] estimatedFileNum : ${estimatedFileNum}";
echo "[Info] File will be split into about ${estimatedFileNum} * ${splitSize} bytes files";
tmp_folder=$(date "+%Y%m%d_%H%M%S");
mkdir -p ${tmp_folder};
mv ${big_file} ${tmp_folder};
cd ${tmp_folder};
/ext/schenker/toolslocal/msplit ${big_file} ${splitSize};
echo "[Check] Small files are as below:";
ls -l;
processID=$(ls | head -1 | awk -F'.' '{print $1}');
totalnum=$(ls -l | grep -c ${processID});
if [[ "${totalnum}" -eq 1 ]];then
	echo "[Error] Only one file generated, split action failed!";
	exit;
fi
for splittedFileSize in $(ls -l | awk -F' ' '{print $5}')
do
	if [[ "${splittedFileSize}" -gt "${maxSize}" ]];then
		echo "[Error] Splitted file size is bigger than limit, split action failed!";
		exit;
	fi
done
echo "[Check] Below steps will be taken:";
for num in $(ls ${processID}* | cut -d\. -f2 | sort -n)
do
	file="${processID}.${num}";
	echo "[${num}/${totalnum}] moving ${file} to > ${agreementPath}/../comexp_ok/${prefix}_${num}.${suffix}";
done
echo -n "[Info] You can press \"Ctrl + C\" to stop or \"Enter\" to continue: ";
read gapSec;
if [[ -z ${gapSec} ]];then
	gapSec=30;
fi
#echo "[Debug] gapSec : ${gapSec}";
echo -n "[Processing] ";
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

echo "[Info] Now grabbing the log, please have a check:";
grep ${original_filename} ${agreementPath}/../log/log | grep ExportF*;
