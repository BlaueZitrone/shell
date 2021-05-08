#!/bin/bash

cd /var/ftp/remove_duplicate_rates;
for filename in $(ls RDR_* 2>/dev/null)
do
    original_filename=$(echo $filename | cut -d_ -f2-);
    echo "Removing duplicate rates for file : ${filename}";
    /home/allen/bin/remove_duplicate_rates.py ${filename} > result_${original_filename}.csv;
    chown ftp:ftp result_${original_filename}.csv;
    mv ${filename} done_${filename};
done
