#!/bin/ksh
#
# CreateAllXIBQueueNamesDump.ksh
#
# Prints all Queues on a host as csv for use with Icinga checks.
# Has to be run as user xib.
#
# 1: Human readable name of the Queue.
# 2: XIB name of the Queue.
# 3: Human readable name of the Queue Server.
# 4: XIB name of the Queue Server.

. /app/sword/axway/Integrator/profile

# File to dump to:
file_to_dump_to="/opt/sword/tools/shards/run/AllXIBQueueNames.csv"
file_to_dump_to_tmp=${file_to_dump_to}.tmp
	
# make sure old tmp file is removed.
if [[ -f ${file_to_dump_to_tmp} ]]; then
  /bin/rm -f ${file_to_dump_to_tmp}
fi

# Get all running Queue Servers
for name_server in `r4edi queue_util.x4 -S`; do
  # Get human readable (hr) name of Queue Server.
  # Fix on B2Bi :)
  hr_name_server="B2Bi CS Queue Task"
  #print -n "input - ${name_server} output - ${hr_name_server}"
  # Get all Queues of Queue Server.
  for name_queue in `r4edi queue_util.x4 -Q ${name_server}` ; do
    hr_name_queue=`/app/sword/schenker/framework/getTaskName.sh ${name_queue}`
    #print -n "input - ${name_server} output - ${hr_name_queue}" 
    print -n "${hr_name_queue},${name_queue},${hr_name_server},${name_server}" >> ${file_to_dump_to_tmp}
    print >> ${file_to_dump_to_tmp}
  done
done

# Remove old dump.
if [[ -f ${file_to_dump_to} ]]; then
  /bin/rm -f ${file_to_dump_to}
fi
cat ${file_to_dump_to_tmp} | sort| uniq > ${file_to_dump_to}
rm -f ${file_to_dump_to_tmp}
