#!/bin/bash

if [ "$1" == "--help" ];
then
	echo Usage:
	echo $0 template varlist
	echo $0 template var1=val1 var2=val2 ...
	exit 0
fi

TEMPLATE=$1
VARLIST=$2

if [ "$TEMPLATE" == "" ] || [ ! -e $TEMPLATE ];
then
	echo TEMPLATE incorrect > /dev/stderr
	exit 1;
fi

if [ -e $VARLIST ];
then
	while read LINE;
	do
		read LINE
		eval $LINE
	done < $VARLIST
else
	shift
	while [ "$1" != "" ];
	do
		eval $1
		shift
	done
fi

while read LINE;
do
	echo -e $(eval echo $LINE)
done < $TEMPLATE

