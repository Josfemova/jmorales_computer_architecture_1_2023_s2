#include <stdio.h>
#include <inttypes.h>

int32_t suma_fraccional(int32_t num1, int16_t num2){
    uint32_t mascara =  0x0000FFFF;
    num1 = num1 & mascara;
    num2 = num2 & mascara;
    int32_t resultado = num1 + num2;
     printf("frac: %d", num2);
    return resultado;
}
/*
Suma que toma los bits que representa la parte entera y los suma
*/
int_fast32_t suma_entera(int_fast32_t num1, int32_t num2){
    int_fast32_t num_aux_1= num1>>16; // Elimina los bits de la parte fraccionaria para el número 1
    int_fast32_t num_aux_2= num2 >>16;// Elimina los bit de la parte fraccionaria para el número 2 
    int_fast32_t suma_entero = num_aux_1 + num_aux_2; 
    return suma_entero;
}
/**
 * Esta función se encarga de realizar la suma de la parte fraccionaria 
*/
int_fast32_t suma_punto_fijo(int_fast32_t num_1, int_fast32_t num_2){
    int_fast32_t resultado_f= suma_fraccional(num_1,num_2);
    int_fast32_t resultado_int = suma_entera(num_1,num_2);
    resultado_int = resultado_int << 16;
    int32_t resultado_final = resultado_int + resultado_f;
    return resultado_final;
}
int main(){
    int_fast32_t num_1 = 0b000011000000000000000; // bit de signo + 4 bits enteros +16 fracionales
    int_fast32_t num_2 = 0b111001100000000000000;
    int_fast32_t resultado_final = suma_punto_fijo(num_1,num_2);
    

    
    printf("parte entera: %d", resultado_final);


    return 0;
}