#!/bin/bash

big_file=$1;
if [[ -z "${big_file}" ]]; then
	echo -n "Enter the name of the big file:";
	read big_file;
fi

if [[ ! -f ${big_file} ]]; then
	echo "Cannot find file according to the name.";
	exit;
fi
ls -lh ${big_file};

agreementID=$(echo ${big_file} | cut -d\. -f1);
counter=$(echo ${big_file} | cut -d\. -f2);
prefix="${agreementID}.${counter}";
original_filename=$(echo ${big_file} | cut -d\. -f3-);
suffix="${original_filename}";

echo "agreementID : ${agreementID}";
echo "counter : ${counter}";
echo "prefix : ${prefix}";
echo "original_filename : ${original_filename}";
echo "suffix : ${suffix}";

agreementPath="$(/ext/schenker/toolslocal/agrcheck ${agreementID} | ggrep -B 1 ${agreementID} | head -1)";
echo "agreementPath : ${agreementPath}";
grep "<MaxSize>" ${agreementPath}/${agreementID}/${agreementID}_dump.xml;

echo ">>>>>>>>>>>>>>>Now we are going to split the file>>>>>>>>>>>>>>>>>";
echo -n "Input the size you want to split the big file into (Unit: byte):";
read splitSize;
tmp_folder=$(date "+%Y%m%d_%H%M%S");
mkdir -p ${tmp_folder};
mv ${big_file} ${tmp_folder};
cd ${tmp_folder};
/ext/schenker/toolslocal/msplit ${big_file} ${splitSize};
processID=$(ls | head -1 | awk -F'.' '{print $1}');
for num in $(ls ${processID}* | cut -d\. -f2 | sort -n)
do
	file="${processID}.${num}";
	echo "moving ${file} to > ${agreementPath}/../comexp_ok/${prefix}_${num}.${suffix}";
	sleep 15;
	mv ${file} ${agreementPath}/../comexp_ok/${prefix}_${num}.${suffix};
	sleep 15;
done
cd ..;
rmdir ${tmp_folder};

grep ${original_filename} ${agreementPath}/../log/log | grep ExportF*;
