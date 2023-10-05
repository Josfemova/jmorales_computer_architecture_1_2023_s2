#include <stdio.h>


#define Q 16  // Número de bits de la parte fraccional


/***
 * Función encargada de realizar la suma de dos números en formato de punto fijo con signo Q4.16
*/
int suma(int punto_fijo_1, int punto_fijo_2){
    int resultado = punto_fijo_1 + punto_fijo_2;

    if (resultado > 0x7FFFFFFF || resultado < -0x80000000) {
    // AJutar el valor del overflow para el caso visto 
        if (resultado > 0x7FFFFFFF) {
            resultado = 0x7FFFFFFF;
        } else {
            resultado = -0x80000000; 
        }
    }
    return resultado;
}

void ver_resultado(int numero){
    // Imprimir el resultado en formato Q15.16
    printf("Resultado en formato Q15.16: 0x%X\n", numero);

    // Convertir el resultado a punto flotante
    double resultado_float = (double)numero / (1 << Q);

    // Imprimir el resultado en formato de punto flotante
    printf("Resultado en punto flotante: %lf\n", resultado_float);
}

int main() {
    int q4_16_a = 0x18000;  // -1.0 en formato Q15.16
    int q4_16_b = 0xFFFCC000;  // 0.1 en formato Q15.16

    int resultado = suma(q4_16_a,q4_16_b);

    ver_resultado(resultado);
    
    return 0;
}







/*#define Q 16  // Número de bits de la parte fraccional

int main() {
    int q15_16_a = 0x18000;  // Ejemplo de número en formato Q15.16
    int q15_16_b = 0x34000;  // Otro ejemplo de número en formato Q15.16

    // Realizar la suma en formato Q15.16
    int resultado = q15_16_a + q15_16_b;

    // Imprimir el resultado en formato Q15.16
    printf("Resultado en formato Q15.16: 0x%X\n", resultado);

    // Convertir el resultado a punto flotante
    double resultado_float = (double)resultado / (1 << Q);

    // Imprimir el resultado en formato de punto flotante
    printf("Resultado en punto flotante: %lf\n", resultado_float);

    return 0;
}*/