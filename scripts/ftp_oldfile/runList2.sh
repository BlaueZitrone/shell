#!/bin/bash
scanout="$sup/allen/old_file_scan_record/$(date "+%Y%m")/old_file_scan_$(date "+%Y%m%d_%H%M%S")_$(hostname)";
mkdir -p $sup/allen/old_file_scan_record/$(date "+%Y%m")/;
touch ${scanout};
list2 -runbycron | tee ${scanout};
chmod 666 ${scanout};
