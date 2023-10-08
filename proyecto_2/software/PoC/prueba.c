#include <stdio.h>
#include <inttypes.h>

char* int2bin(int num, int numBits) {
    if (numBits <= 0) {
        fprintf(stderr, "Invalid number of bits.\n");
        return NULL;
    }

    char* binaryString = (char*)malloc(numBits + 1); // +1 for null terminator

    if (binaryString == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        exit(1); // Handle memory allocation failure
    }

    for (int i = 0; i < numBits; i++) {
        int bit = (num >> (numBits - 1 - i)) & 1;
        binaryString[i] = bit ? '1' : '0';
    }

    binaryString[numBits] = '\0'; // Null-terminate the string
    return binaryString;
}


int32_t suma_fraccional(int32_t num1, int16_t num2){
    uint32_t mascara =  0x0001FFFF;
    num1 = num1 & mascara;
    num2 = num2 & mascara;
    int32_t resultado = num1 + num2;
    char* string = int2bin(resultado,17);
    printf("fracionaria %s \n",string);
    char* string_1 = int2bin(num1,16);
    printf("Num1: %s \n",string_1);
    char* string_2 = int2bin(num2,16);
    printf("NUm:2 %s \n",string_2);
    return resultado;
}
/*
Suma que toma los bits que representa la parte entera y los suma
*/
int_fast32_t suma_entera(int_fast32_t num1, int32_t num2){
    int_fast32_t num_aux_1= num1>>16; // Elimina los bits de la parte fraccionaria para el número 1
    int_fast32_t num_aux_2= num2 >>16;// Elimina los bit de la parte fraccionaria para el número 2 
    int_fast32_t suma_entero = num_aux_1 + num_aux_2; 
    char* string = int2bin(suma_entera,5);
    printf("entera %s \n",string);
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

int_fast32_t high(int_fast32_t num1, int_fast32_t num2){
    int_fast32_t num_aux_1= num1>>16; // Elimina los bits de la parte fraccionaria para el número 1
    int_fast32_t num_aux_2= num2 >>16;// Elimina los bit de la parte fraccionaria para el número 2 
    return num_aux_1 * num_aux_2;
}
int_fast32_t low(int_fast32_t num1, int_fast32_t num2){
    uint32_t mascara =  0x0000FFFF;
    num1 = num1 & mascara;
    num2 = num2 & mascara;
    return num1*num2;
}
int_fast32_t mid(int_fast32_t num1, int_fast32_t num2){
    int_fast32_t a= num1>>16; // Elimina los bits de la parte fraccionaria para el número 1
    int_fast32_t c= num2 >>16;// Elimina los bit de la parte fraccionaria para el número 2 
    uint32_t mascara =  0x0000FFFF;
    num1 = num1 & mascara;
    num2 = num2 & mascara;
    return (a*num2)+(c*num1);
}
int_fast32_t mult_punto_fijo(int_fast32_t num1, int_fast32_t num2){
    int_fast32_t high_ = high(num1,num2);
    int_fast32_t low_ = low(num1,num2);
    int_fast32_t mid_ = mid(num1,num2);
    high_ = high_ <<16;
    low_ = low_ >>16;
    return high_+mid_+low_;

}
/*
PREGUNTAS:
- Signo en la multiplicación
- Overflow, tamaño de registro
-Valores iniciales para el algoritmo 
*/
int main(){
    int_fast32_t num_1 = 0b00011000000000000000; // bit de signo + 4 bits enteros +16 fracionales
    int_fast32_t num_2 = 0b00110100000000000000;
    int_fast32_t resultado_final = mult_punto_fijo(num_1, num_2);
    
    printf(int2bin(resultado_final, 21));


    return 0;
}
