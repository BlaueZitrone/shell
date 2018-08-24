#!/bin/bash

err_folder="/ext/schenker/data/error";
while true
do
	clear;
	if [[ $(ls -l ${err_folder} | grep -vc "total") != "0" ]]; then
		echo "============$(date "+%Y-%m-%d %H:%M:%S")==============";
		ls -l -htr ${err_folder} | grep -v "MassFilter" | grep -v total;
		if [[ $(ls -l ${err_folder} | grep -c "MassFilter") != "0" ]]; then
			echo "==============Massfilter==============";
			ls -l ${err_folder} | grep 'MassFilter' | grep '.att$' | awk -F'.' '{print $2}' | sort | uniq -c;
		fi
		echo "============$(date "+%Y-%m-%d %H:%M:%S")==============" >> clean.log;
		clean_up2 -v | tee -a clean.log;
		echo -e '\a';
		sleep 50;
	fi
	sleep 10;
done