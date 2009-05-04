#!/bin/bash

if [ "$1" = "help" ]; then
	echo Compiles all subjects;
	echo If you do not want some subject to be compiled, you should create file "nomake" in a subject directory;
	echo Returns count of failed compilations;
	exit;
fi

MP_SUC=0
MP_FAIL=0
MP_FAIL_LIST=

for i in $( ls -d */ ); do
	cd $i;
	if [ -e "GNUmakefile" ] && [ ! -e "nomake" ]; then
		if make $1; then
			MP_SUC=$((MP_SUC+1));
		else
			MP_FAIL=$((MP_FAIL+1));
			MP_FAIL_LIST="$MP_FAIL_LIST\n\t$i"
		fi;
	fi;
	cd ..;
done

echo
echo Subjects compilation finished\;
echo -e Successful: $MP_SUC\;
echo -e Failed: $MP_FAIL\;

if [ "$MP_FAIL" != "0" ]; then
	echo -e Failed subjects: $MP_FAIL_LIST;
fi;

exit $MP_FAIL;

