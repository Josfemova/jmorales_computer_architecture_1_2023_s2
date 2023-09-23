clean:
	rm -rf build
	mkdir build
build: clean
	riscv64-linux-gnu-as poc.s -o build/poc.o -g
	riscv64-linux-gnu-ld build/poc.o -o build/poc
	riscv64-linux-gnu-objdump -Dxg build/poc > build/poc.txt
launch: build
	qemu-riscv64-static -g 8000 build/poc
debug: 
	gdb-multiarch -se build/poc -x debug.gdb
	
