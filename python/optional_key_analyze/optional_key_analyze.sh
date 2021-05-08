#!/bin/bash

cd /var/ftp/optional_key_analyze;
for filename in $(ls OKA_* 2>/dev/null)
do
    original_filename=$(echo $filename | cut -d_ -f2-);
    echo "Analyzing optional key for file : ${filename}";
    /home/allen/bin/optional_key_analyze.py ${filename} > result_${original_filename}.txt;
    chown ftp:ftp result_${original_filename}.txt;
    mv ${filename} done_${filename};
done
