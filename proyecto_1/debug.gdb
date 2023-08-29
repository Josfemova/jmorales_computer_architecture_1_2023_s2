target exec build/wave
target extended-remote localhost:8000
layout regs
#layout asm
set print asm-demangle on
break _start
