#!/bin/bash

output="monitor_disk_$(date "+%Y%m%d_%H%M%S")_$(hostname).csv";
while true
do
	echo -n $(date "+%H:%M:%S,") >> ${output};
	touch ${output};
	df -k | grep $1 | awk '{print $3/$2*100"%"}' >> ${output};
	sleep 30;
done
