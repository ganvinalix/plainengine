#!/bin/bash

STARTINGDIR=$(pwd)

if [ ! -e dlls ]; then
	mkdir dlls;
fi

rm ./dlls/*

for i in $( ls -d */ ); do
	cd $i;
	if [ -e "obj" ]; then
		cp ./obj/*.dll $STARTINGDIR/dlls &> /dev/null;
	fi
	cd ..;
done

