#!/bin/ksh
##########################################################################
#
#  gets the readable task name if $1 is something like
#  "HierchMsgTask_7902_6884_1"
#
#
#
#
#
#
##########################################################################
# $Revision:: 11468                                                      $
# $LastChangedDate:: 2011-01-05 13:37:29 +0100 (Mi, 05 Jan 2011)         $
# $Author:: oliver.rogowski                                              $
##########################################################################
#set -x
. /app/sword/schenker/framework/ScriptFunctions
if [[ "$#" != 1 ]];then
 echo "
  Please enter a TaskName as \$1,
   i.e.: HierchMsgTask_7902_6884_1
 "
exit
fi

if echo $1 | grep "__" >>/dev/null 2>>/dev/null;then
   NAQUEUENR=`echo $1 | awk -F"_" '{
      if ($4 == "")
        print $3
      else
        print $2
      }'`
else
   NAQUEUENR=`echo $1 | awk -F"_" '{ print $2 }'`
fi
##### PERL CALL TO GET "REAL" QUEUE NAME ###############
NATRQUEUE=`perl -e '
$pfad="/app/sword/axway/Integrator/data/starter";
$datei="starter2.cfg";
#$dateiraus="starter2.csv";
open (REIN, "$pfad/$datei") or die ("kann REIN nicht oeffnen: $!\n");
while (<REIN>)   {
@INarray = split(/\{$ARGV[0]\,1\,\\\"/);
@REVERSEarray = reverse(@INarray);
foreach $line(@REVERSEarray)
{
  $line =~ s/(^.*?)\\\.*/$1/;

#  print RAUS "$line\n";
  if ($line !~ /\{/gi)
    {
      print "$line\n";
    }
   else {print "not found\n";}
last;
}
}
close REIN;
#close RAUS;
' $NAQUEUENR`
###endofperl####

echo $NATRQUEUE
