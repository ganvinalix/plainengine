if [ "$1" == "" ];
then
	echo Usage: $0 subjectname
	exit 0
fi

SUBJECTNAME=$1

if [ -e $SUBJECTNAME ];
then
	echo Subject already exists;
	exit 1
fi

mkdir $SUBJECTNAME
mkdir .createsubject_temp

cp ./subjtemplate.tar ./.createsubject_temp/

cd ./.createsubject_temp
tar -xf subjtemplate.tar
cd ..

./genbytempl.sh ./.createsubject_temp/GNUmakefile SUBJECTNAME=$SUBJECTNAME > ./$SUBJECTNAME/GNUmakefile
./genbytempl.sh ./.createsubject_temp/Subject.h SUBJECTNAME=$SUBJECTNAME > ./$SUBJECTNAME/$SUBJECTNAME.h
./genbytempl.sh ./.createsubject_temp/Subject.m SUBJECTNAME=$SUBJECTNAME > ./$SUBJECTNAME/$SUBJECTNAME.m
rm -rf ./.createsubject_temp

