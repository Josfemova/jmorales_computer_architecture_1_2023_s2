clean:
	rm -rf build
	mkdir build
build: clean
	riscv64-linux-gnu-as wave.s -o build/wave.o -g
	riscv64-linux-gnu-ld build/wave.o -o build/wave
	riscv64-linux-gnu-objdump -Dxg build/wave > build/wave.txt
launch: build
	qemu-riscv64-static -g 8000 build/wave
debug: 
	gdb-multiarch -se build/wave -x debug.gdb
	
