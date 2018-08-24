#!/bin/bash
read num;
echo $num;
if [[ $num -gt 10 ]];then
	echo a;
fi
if [[ $num -lt 5 ]];then
	echo b;
fi

if [[ $num -gt 10 || $num -lt 5 ]];then
	echo no;
fi
