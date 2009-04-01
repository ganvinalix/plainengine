all:
	./compile
clean:
	. ./src/envsetup.sh
	cd ./src
	make clean
	cd ../sc_gen_src
	make clean
