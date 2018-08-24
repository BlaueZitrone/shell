#!/bin/ksh
##########################################################################
#
#  Checks if loggers are currently archiving and lists the files still 
#  to go on request
#
#
#
##########################################################################
#** $Revision:: 38977                                                    $
#** $LastChangedDate:: 2014-02-21 15:04:15 +0100 (Fr, 21 Feb 2014)       $
#** $Author:: oliver.rogowski                                            $
##########################################################################
#set -x

. $FRAME_ROOT/tools/ScriptFunctions
clear
count=`ls /ext/xib/data/logger/*/j* 2>/dev/null|wc -l`

count=`echo "$count + 0"|bc`
if [[ $count = 0 ]];then
  echo  "Currently no Logger archiving is active!"
  exit
fi
echo  "
There are currently $count Logger files that are archived"
echo "
Do you want to see the files involved? 
(Y/y + [enter] for Yes, any key for No)"
read yesno
if [[ $yesno = Y|| $yesno = y ]];then
#  ls -l /ext/xib/data/logger/*/j*
  ls /ext/xib/data/logger/*/j*
fi

