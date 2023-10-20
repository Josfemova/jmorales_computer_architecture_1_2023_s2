#!/bin/sh

rm -rf build
mkdir build;
pre=build/preproc.s
# eliminar todo después de numeral, lineas vacías
# y todo depués del punto y coma 
cpp $1 \
    | sed 's/\#.*//' \
    | sed 's/:/;/g' \
    | sed '/^$/d' \
    | sed 's/ //g' \
    | sed 's/\;.*/;/' \
    > $pre 
../assembler/compiler/build/compiler < $pre 
