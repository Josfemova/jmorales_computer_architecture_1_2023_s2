#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>


/**
 * Función que me transforma un int a binario (string)
*/
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

/**
 * Suma de los bits que representan la parte fraccional del numero de punto fijo
*/
int32_t suma_fraccional(int32_t num1, int32_t num2){
    uint32_t mascara =  0x00FFFFFF;
    num1 = num1 & mascara;
    num2 = num2 & mascara;
    int32_t resultado = num1 + num2;
    char* string = int2bin(resultado,25);
    printf("fracionaria %s \n",string);
    char* string_1 = int2bin(num1,24);
    printf("Num1: %s \n",string_1);
    char* string_2 = int2bin(num2,24);
    printf("NUm:2 %s \n",string_2);
    return resultado;
}
/*
Suma que toma los bits que representa la parte entera y los suma
*/
int32_t suma_entera(int32_t num1, int32_t num2){
    int32_t num_aux_1= num1>>24; // Elimina los bits de la parte fraccionaria para el número 1
    int32_t num_aux_2= num2 >>24;// Elimina los bit de la parte fraccionaria para el número 2 
    int32_t suma_entero = num_aux_1 + num_aux_2; 
    char* string = int2bin(suma_entera,7);
    printf("entera %s \n",string);
    return suma_entero;
}
/**
 * Esta función se encarga de realizar la suma de la parte fraccionaria 
*/
int32_t suma_punto_fijo(int32_t num_1, int32_t num_2){
    int32_t resultado_f= suma_fraccional(num_1,num_2);
    int32_t resultado_int = suma_entera(num_1,num_2);
    resultado_int = resultado_int << 24;
    int32_t resultado_final = resultado_int + resultado_f; 
    return resultado_final;                                
}
/**
 * Obtiene el valor high en para la multiplicación
*/
int32_t high(int32_t num1, int32_t num2){
    int32_t num_aux_1= num1>>24; // Elimina los bits de la parte fraccionaria para el número 1
    int32_t num_aux_2= num2 >>24;// Elimina los bit de la parte fraccionaria para el número 2 
    return num_aux_1 * num_aux_2;
}
/**
 * Obtiene el valor low para la multiplicación
*/
int32_t low(int32_t num1, int32_t num2){
    uint32_t mascara =  0x00FFFFFF;
    num1 = num1 & mascara;
    num2 = num2 & mascara;
    return num1*num2;
}
/**
 * Obtiene el valor medio para la multiplicacion
*/
int32_t mid(int32_t num1, int32_t num2){
    int32_t a= num1>>24; // Elimina los bits de la parte fraccionaria para el número 1
    int32_t c= num2 >>24;// Elimina los bit de la parte fraccionaria para el número 2 
    uint32_t mascara =  0x00FFFFFF;
    num1 = num1 & mascara;
    num2 = num2 & mascara;
    return (a*num2)+(c*num1);
}
/**
 * Funcion a llamar para hacer la multiplicación de dos números en punto fijo
*/
int32_t mult_punto_fijo(int32_t num1, int32_t num2){
    int32_t high_ = high(num1,num2);
    int32_t low_ = low(num1,num2);
    int32_t mid_ = mid(num1,num2);
    high_ = high_ <<24;
    low_ = low_ >>24;
    return high_+mid_+low_;

}
void leer_archivo(){
// Abre el archivo de texto
    FILE *file = fopen("input.txt", "r");
    if (file == NULL) {
        perror("No se puede abrir el archivo");
        return 1;
    }

    // Variables para almacenar las líneas y el número decimal
    char line[100]; // Ajusta el tamaño según tus necesidades
    double decimalNumber;

    while (fgets(line, sizeof(line), file) != NULL) {
        // Lee una línea del archivo
        if (sscanf(line, "%lf", &decimalNumber) == 1) {
            // Convierte el número decimal a punto fijo Q7.24
            int32_t q7_24 = (int32_t)(decimalNumber * (1 << 24));
            //Aqui se llaman las funciones aritmeticas necesarias
            int32_t num_2 = 0b0001100000000000000000000000;
            int32_t resultado = suma_punto_fijo(q7_24, num_2);
            printf(int2bin(resultado, 32));
        }
    }

    // Cierra el archivo
    fclose(file);


}
/*
PREGUNTAS:
- Signo en la multiplicación
- Overflow, tamaño de registro
-Valores iniciales para el algoritmo 
- Q7.24 bit sobrante de signo 
*/
int main(){
    leer_archivo();

    return 0;
}
