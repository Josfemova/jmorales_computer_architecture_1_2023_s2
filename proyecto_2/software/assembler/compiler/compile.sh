#!/bin/sh

rm -rf build
mkdir build;
pre0=build/preproc0
pre1=build/preproc1
pre2=build/preproc2
# eliminar lineas vacías 
sed '/^$/d' $1 > $pre0
# eliminar espacios
sed 's/ //g' $pre0 > $pre1
# eliminar todo después de punto y coma
sed 's/\;.*/;\n/' $pre1 > $pre2 
./main < $pre2 
