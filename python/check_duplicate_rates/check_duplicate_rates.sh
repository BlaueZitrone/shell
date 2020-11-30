#!/bin/bash

cd /var/ftp/check_duplicate_rates;
for filename in $(ls CDR_* 2>/dev/null)
do
    original_filename=$(echo $filename | cut -d_ -f2-);
    echo "Checking duplicate rates for file : ${filename}";
    /home/allen/bin/check_duplicate_rates.py ${filename} > result_${original_filename}.txt;
    chown ftp:ftp result_${original_filename}.txt;
    mv ${filename} done_${filename};
done
