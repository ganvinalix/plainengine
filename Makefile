all:
	cd ./src/
	make GNUmakefile
	cd ..
clean:
	cd ./src
	make clean
	cd ..
