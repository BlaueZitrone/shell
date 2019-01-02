#!/bin/bash

LD_LIBRARY_PATH="";
for server in xibapprd1.dc.signintra.com xibapprd2.dc.signintra.com xibapprd3.dc.signintra.com xibapprd4.dc.signintra.com xibgwprd1.dc.signintra.com xibgwprd2.dc.signintra.com xibgwprd3.dc.signintra.com xibgwprd4.dc.signintra.com
do
    echo ${server};
    /usr/bin/scp -o StrictHostKeyChecking=no -r /ext/schenker/support/allen/Alias/alias.sh xib@${server}:/app/xib/home/xib 2>/dev/null;
done
/usr/bin/scp -o StrictHostKeyChecking=no -r /ext/schenker/support/allen/Alias/alias.sh amtrix@xibftprd1.dc.signintra.com:/app/xib/home/amtrix 2>/dev/null;
