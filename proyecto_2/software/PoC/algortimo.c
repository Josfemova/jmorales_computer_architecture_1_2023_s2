#include <stdio.h>
#include<inttypes.h>

#include <stdio.h>

/**
 * VALORES QUE SE PUEDEN USAR COMO CONSTANTES CON PERMISO DEL PROFESOR
*/
#define BUFFER_SIZE 2205 // K
#define ATENUACION 0b0000001001100110011001 // a
#define ATENUACION_M 0b0000000110011001100110 //(1-a)
#define ATENUACION_DIV 0b0000101000000000000000 //1/(1-a)

/*###############OPEREACIONES NECESARIAS PARA EL ISA##############
* SUMA 
* SHIFT RIGHT AND LEFT
* MULTIPLICACION
* AND
* OR
* MODULO (PARA EL BUFFER)
*/



//########################## FUNCIONES de SUMA Y MULTIPLICACIÓN EN PUNTO FIJO ######################################
/**
 * Suma de los bits que representan la parte fraccional del numero de punto fijo
*/
int32_t suma_fraccional(int32_t num1, int32_t num2){
    uint32_t mascara =  0x0000FFFF;
    num1 = num1 & mascara;
    num2 = num2 & mascara;
    int32_t resultado = num1 + num2;
    return resultado;
}
/*
Suma que toma los bits que representa la parte entera y los suma
*/
int32_t suma_entera(int32_t num1, int32_t num2){
    int32_t num_aux_1= num1>>16; // Elimina los bits de la parte fraccionaria para el número 1
    int32_t num_aux_2= num2 >>16;// Elimina los bit de la parte fraccionaria para el número 2 
    int32_t suma_entero = num_aux_1 + num_aux_2; 
    return suma_entero;
}
/**
 * Esta función se encarga de realizar la suma de la parte fraccionaria 
*/
int32_t suma_punto_fijo(int32_t num_1, int32_t num_2){
    int32_t resultado_f= suma_fraccional(num_1,num_2);
    int32_t resultado_int = suma_entera(num_1,num_2);
    resultado_int = resultado_int << 16;
    int32_t resultado_final = resultado_int + resultado_f;
    return resultado_final;                                
}
/**
 * Obtiene el valor high en para la multiplicación
*/
int32_t high(int32_t num1, int32_t num2){
    int32_t num_aux_1= num1>>16; // Elimina los bits de la parte fraccionaria para el número 1
    int32_t num_aux_2= num2 >>16;// Elimina los bit de la parte fraccionaria para el número 2 
    return num_aux_1 * num_aux_2;
}
/**
 * Obtiene el valor low para la multiplicación
*/
int32_t low(int32_t num1, int32_t num2){
    uint32_t mascara =  0x0000FFFF;
    num1 = num1 & mascara;
    num2 = num2 & mascara;
    return num1*num2;
}
/**
 * Obtiene el valor medio para la multiplicacion
*/
int32_t mid(int32_t num1, int32_t num2){
    int32_t a= num1>>16; // Elimina los bits de la parte fraccionaria para el número 1
    int32_t c= num2 >>16;// Elimina los bit de la parte fraccionaria para el número 2 
    uint32_t mascara =  0x0000FFFF;
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
    high_ = high_ <<16;
    low_ = low_ >>16;
    return high_+mid_+low_;

}

//##########################################ESTRUCTURA DEL ALOGRITMO #################################################
// Estructura del buffer circular esto se hace en memoria en el ISA propio, aqui se sigue la estructura de C
typedef struct {
    int32_t data[BUFFER_SIZE];
    int head; // Índice para agregar nuevos elementos
} CircularBuffer;

/*
Función que inicializa los valores del buffer en 0 
*/
void initializeBuffer(CircularBuffer* buffer) {
    for (int i = 0; i < BUFFER_SIZE; i++) {
        buffer->data[i] = 0; //todo el buffer en 0
    }
    buffer->head = 0;
}
/**
 * Calculo de la insercion
*/
int32_t insertar_rever_aux(int32_t num, CircularBuffer* buffer) {
    // Aqui se agrega las sumas y las multiplicaciones
    //desarrolla la parte de (1-a)*x(n)
    int32_t result = mult_punto_fijo(num, ATENUACION_M);

    // Calcula el valor de y(x-k) utilizando el buffer
    int index = (buffer->head + BUFFER_SIZE - 2205) % BUFFER_SIZE;
    //Desarrolla la parte de y(n-k)*a
    int32_t result_aux = mult_punto_fijo((buffer->data[index]), ATENUACION);
    //suma los resultados de las multiplicaciones
    result = suma_punto_fijo(result, result_aux);

    // Agrega el nuevo resultado al buffer circular
    buffer->data[buffer->head] = result;
    buffer->head = (buffer->head + 1) % BUFFER_SIZE;

    return result;
}
/**
 * Calculo de la reduccion
*/
int32_t reducc_rever_aux(int32_t num, CircularBuffer* buffer) {
    // Aqui se agrega las sumas y las multiplicaciones

    // Calcula el valor de x(n-k) utilizando el buffer
    int index = (buffer->head + BUFFER_SIZE - 2205) % BUFFER_SIZE;
    //Desarrolla la parte de x(n-k)*a
    int32_t result = mult_punto_fijo((buffer->data[index]), ATENUACION);
    //Convierto a -a*x(n-k)
    result = suma_punto_fijo(0, result);
    // realizo la resta (x(n)-ax(n-k))
    result = suma_punto_fijo(num,result);
    //multiplico la suma por 1/(1-a)
    result = mult_punto_fijo(result, ATENUACION_DIV);
    // Agrega el valor de entrada usado al buffer circular
    buffer->data[buffer->head] = num;
    buffer->head = (buffer->head + 1) % BUFFER_SIZE;

    return result;
}
/**
 * Funcion que me permite verificar el buffer NO TOMAR EN CUENTA, SE BORRA AL FINAL
*/
void print(CircularBuffer* buffer){
    printf("ejemplo: %d\n", buffer->data[0]);
}
// Función para convertir de punto fijo Q5.16 a decimal
double puntoFijoADecimal(int32_t puntoFijo) {
    int parteEntera = puntoFijo >> 16; // 5 bits para la parte entera
    int mascaraFraccional = (1 << 16) - 1; // 16 bits para la parte fraccional
    double parteFraccional = (double)(puntoFijo & mascaraFraccional) / (1 << 16);

    return parteEntera + parteFraccional;
}
/**
 * Funcionque escribe el resultado en el txt de salida SON FUNCIONES DE MANEJO DE ARCHIVOS, SE PUEDE OMITIR
*/
void escribir_salida(double salida, int flag){
    if (flag ==0) //Si está en 0 se debe guardar la insercion
    {
         FILE *archivo = fopen("insercion.txt", "a");
        if (archivo == NULL) {
            printf("No se pudo abrir el archivo.\n");
            return 1;
        }
        fprintf(archivo, "%lf\n", salida);
        fclose(archivo);
    }else{ //si está en 1 se guarda la reduccion
         FILE *archivo = fopen("reduccion.txt", "a");
        if (archivo == NULL) {
            printf("No se pudo abrir el archivo.\n");
            return 1;
        }
        fprintf(archivo, "%lf\n", salida);
        fclose(archivo);
    }
}
/**
 * Desde aqui se hace el procesamiento del archivo para la insercion
*/
void insercion_reverberacion(){
    FILE *file = fopen("input.txt", "r");
    if (file == NULL) {
        perror("No se puede abrir el archivo");
        return 1;
    }
    CircularBuffer buffer ={0};
    initializeBuffer(&buffer);
    char line[10];
    double decimalNumber;
    while (fgets(line, sizeof(line), file) != NULL) {
        // Lee una línea del archivo
        if (sscanf(line, "%lf", &decimalNumber) == 1) {
            //AQUI SE CONVIERTE LO LEIDO DEL ARCHIVO TXT A PUNTO FIJO
            int32_t q5_16 = (int32_t)(decimalNumber * (1 << 16));
            // AQUI SE ENVIA GENERAR EL ALGORTIMO
            int32_t resultado = insertar_rever_aux(q5_16, &buffer);
            //AQUI SE GUARDA EN OTRO TXT
            double salida = puntoFijoADecimal(resultado); // convierte el numero a doble (solo para fines de C)
            escribir_salida(salida,0);
        }
    }
    fclose(file);
}
/**
 * Desde aqui se hace el procesamiento del archivo para la reduccion
*/
void reduccion_reverberacion(){
    FILE *file = fopen("input.txt", "r");
    if (file == NULL) {
        perror("No se puede abrir el archivo");
        return 1;
    }
    CircularBuffer buffer ={0};
    initializeBuffer(&buffer);
    char line[10];
    double decimalNumber;
    while (fgets(line, sizeof(line), file) != NULL) {
        // Lee una línea del archivo
        if (sscanf(line, "%lf", &decimalNumber) == 1) {
            //AQUI SE CONVIERTE LO LEIDO DEL ARCHIVO TXT A PUNTO FIJO
            int32_t q5_16 = (int32_t)(decimalNumber * (1 << 16));
            // AQUI SE ENVIA GENERAR EL ALGORTIMO
            int32_t resultado = reducc_rever_aux(q5_16, &buffer);
            //AQUI SE GUARDA EN OTRO TXT
            double salida = puntoFijoADecimal(resultado); // convierte el numero a doble (solo para fines de C)
            escribir_salida(salida,1);
        }
    }
    fclose(file);
}
int main(){
    insercion_reverberacion();
    reduccion_reverberacion();
    return 0;
}