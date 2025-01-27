#include <inttypes.h>
#include <stdio.h>

/**
 * VALORES QUE SE PUEDEN USAR COMO CONSTANTES CON PERMISO DEL PROFESOR
 */
#define BUFFER_SIZE 800                    // K
#define ATENUACION 0b0010011001100110      // a
#define ATENUACION_M 0b0001100110011001    //(1-a)
#define ATENUACION_DIV 0b1010000000000000  // 1/(1-a)

/*###############OPEREACIONES NECESARIAS PARA EL ISA##############
 * SUMA
 * SHIFT RIGHT AND LEFT
 * MULTIPLICACION
 * AND
 * OR
 * MODULO (PARA EL BUFFER)
 */

// ########################## FUNCIONES de SUMA Y MULTIPLICACIÓN EN PUNTO FIJO
// ######################################
/**
 * Suma de los bits que representan la parte fraccional del numero de punto fijo
 */
int32_t suma_fraccional(int32_t num1, int32_t num2) {
  uint32_t mascara = 0x00003FFF;
  num1 = num1 & mascara;
  num2 = num2 & mascara;
  int32_t resultado = num1 + num2;
  return resultado;
}
/*
Suma que toma los bits que representa la parte entera y los suma
*/
int32_t suma_entera(int32_t num1, int32_t num2) {
  int32_t num_aux_1 =
      num1 >> 14;  // Elimina los bits de la parte fraccionaria para el número 1
  int32_t num_aux_2 =
      num2 >> 14;  // Elimina los bit de la parte fraccionaria para el número 2
  int32_t suma_entero = num_aux_1 + num_aux_2;
  return suma_entero;
}
/**
 * Esta función se encarga de realizar la suma de la parte fraccionaria
 */
int32_t suma_punto_fijo(int32_t num_1, int32_t num_2) {
  int32_t resultado_f = suma_fraccional(num_1, num_2);
  int32_t resultado_int = suma_entera(num_1, num_2);
  resultado_int = resultado_int << 14;
  int32_t resultado_final = resultado_int + resultado_f;
  return resultado_final;
}
/**
 * Obtiene el valor high en para la multiplicación
 */
int32_t high(int32_t num1, int32_t num2) {
  int32_t num_aux_1 =
      num1 >> 14;  // Elimina los bits de la parte fraccionaria para el número 1
  int32_t num_aux_2 =
      num2 >> 14;  // Elimina los bit de la parte fraccionaria para el número 2
  return num_aux_1 * num_aux_2;
}
/**
 * Obtiene el valor low para la multiplicación
 */
int32_t low(int32_t num1, int32_t num2) {
  uint32_t mascara = 0x00003FFF;
  num1 = num1 & mascara;
  num2 = num2 & mascara;
  return num1 * num2;
}
/**
 * Obtiene el valor medio para la multiplicacion
 */
int32_t mid(int32_t num1, int32_t num2) {
  int32_t a =
      num1 >> 14;  // Elimina los bits de la parte fraccionaria para el número 1
  int32_t c =
      num2 >> 14;  // Elimina los bit de la parte fraccionaria para el número 2
  uint32_t mascara = 0x00003FFF;
  num1 = num1 & mascara;
  num2 = num2 & mascara;
  return (a * num2) + (c * num1);
}
/**
 * Funcion a llamar para hacer la multiplicación de dos números en punto fijo
 */
int32_t mult_punto_fijo(int32_t num1, int32_t num2) {
  int32_t high_ = high(num1, num2);
  int32_t low_ = low(num1, num2);
  int32_t mid_ = mid(num1, num2);
  high_ = high_ << 14;
  low_ = low_ >> 14;
  return high_ + mid_ + low_;
}

// ##########################################ESTRUCTURA DEL ALOGRITMO
// #################################################
//  Estructura del buffer circular esto se hace en memoria en el ISA propio,
//  aqui se sigue la estructura de C
typedef struct {
  int32_t data[BUFFER_SIZE];
  int head;  // Índice para agregar nuevos elementos
} CircularBuffer;

/*
Función que inicializa los valores del buffer en 0
*/
void initializeBuffer(CircularBuffer *buffer) {
  for (int i = 0; i < BUFFER_SIZE; i++) {
    buffer->data[i] = 0;  // todo el buffer en 0
  }
  buffer->data[0] = 1;
  buffer->data[BUFFER_SIZE - 1] = ATENUACION;
  buffer->head = 0;
}
/**
 * Calculo de la insercion
 */
int32_t insertar_rever_aux(int32_t num, CircularBuffer *buffer) {
  // Aqui se agrega las sumas y las multiplicaciones
  // desarrolla la parte de (1-a)*x(n)
  int32_t result = mult_punto_fijo(num, ATENUACION_M);

  // Calcula el valor de y(x-k) utilizando el buffer
  int32_t index = 0;
  // Calcula el valor de x(n-k) utilizando el buffer
  if (buffer->head == BUFFER_SIZE - 1) {
    index = 0;
  } else {
    index = buffer->head + 1;
  }

  // Desarrolla la parte de y(n-k)*a
  int32_t result_aux = mult_punto_fijo((buffer->data[index]), ATENUACION);
  // suma los resultados de las multiplicaciones
  result = suma_punto_fijo(result, result_aux);
  // Agrega el nuevo resultado al buffer circular
  buffer->data[buffer->head] = result;
  buffer->head = (buffer->head + 1) % BUFFER_SIZE;

  return result;
}
/**
 * Calculo de la reduccion
 */
int32_t reducc_rever_aux(int32_t num, CircularBuffer *buffer) {
  // Aqui se agrega las sumas y las multiplicaciones
  int32_t index = 0;
  // Calcula el valor de x(n-k) utilizando el buffer
  if (buffer->head == BUFFER_SIZE - 1) {
    index = 0;
  } else {
    index = buffer->head + 1;
  }
  // Desarrolla la parte de x(n-k)*a
  int32_t result = mult_punto_fijo((buffer->data[index]), ATENUACION);
  // Convierto a -a*x(n-k)
  result = -result;
  // realizo la resta (x(n)-ax(n-k))
  result = suma_punto_fijo(num, result);
  // multiplico la suma por 1/(1-a)
  result = mult_punto_fijo(result, ATENUACION_DIV);
  // Agrega el valor de entrada usado al buffer circular
  buffer->data[buffer->head] = num;
  buffer->head = (buffer->head + 1) % BUFFER_SIZE;

  return result;
}

/*
Esta funcion escribe el valor en binario en el txt ESTA FUNCIÓN SE PUEDE OBVIAR
PARA EFECTOS DE ENSAMBLADOR
*/
void int16ToBinary(int32_t num, int flag) {
  FILE *file;
  if (flag == 0) {
    file = fopen("insercion_bin.txt", "a");
  } else {
    file = fopen("reduccion_bin.txt", "a");
  }
  if (file == NULL) {
    perror("Error al abrir el archivo");
    return;
  }
  if (num < 0) {
    fprintf(file, "%d", 1);
    num = -num;  // deshacer complemento a dos
  } else {
    fprintf(file, "%d", 0);
  }
  for (int i = 14; i >= 0; i--) {
    int32_t mask = 1 << i;
    int32_t bit = (num & mask) ? 1 : 0;
    fprintf(file, "%d", bit);
  }
  fprintf(file, "%s", "\n");

  fclose(file);
}
// Función para convertir de punto fijo Q5.16 a decimal OBVIAR PARA ENSAMBLADOR
double puntoFijoADecimal(int32_t puntoFijo) {
  int parteEntera = puntoFijo >> 14;      // 5 bits para la parte entera
  int mascaraFraccional = (1 << 14) - 1;  // 16 bits para la parte fraccional
  double parteFraccional = (double)(puntoFijo & mascaraFraccional) / (1 << 14);

  return parteEntera + parteFraccional;
}
/**
 * Funcionque escribe el resultado en el txt de salida SON FUNCIONES DE MANEJO
 * DE ARCHIVOS, SE PUEDE OMITIR EN ENSAMBLADOR
 */
void escribir_salida(double salida, int flag) {
  if (flag == 0)  // Si está en 0 se debe guardar la insercion
  {
    FILE *archivo = fopen("insercion.txt", "a");
    if (archivo == NULL) {
      printf("No se pudo abrir el archivo.\n");
      return 1;
    }
    fprintf(archivo, "%lf\n", salida);
    fclose(archivo);
  } else {  // si está en 1 se guarda la reduccion
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
void insercion_reverberacion() {
  FILE *file_ = fopen("/tmp/vitas.txt", "r");
  if (file_ == NULL) {
    perror("No se puede abrir el archivo");
    return 1;
  }
  CircularBuffer buffer = {0};
  initializeBuffer(&buffer);
  char line[20];
  double decimalNumber;
  while (fgets(line, sizeof(line), file_) != NULL) {
    // Lee una línea del archivo
    if (sscanf(line, "%lf", &decimalNumber) == 1) {
      // AQUI SE CONVIERTE LO LEIDO DEL ARCHIVO TXT A PUNTO FIJO
      int32_t q1_14 = strtol(line, NULL, 2);
      int32_t mascara = 0x7FFF;
      q1_14 = q1_14 & mascara;
      if (line[0] == '1') {
        q1_14 = (-q1_14);  // Complemento a dos
      }
      // AQUI SE ENVIA GENERAR EL ALGORTIMO ESTO SE GUARDA EN LA SALIDA
      int32_t resultado = insertar_rever_aux(q1_14, &buffer);
      // AQUI SE GUARDA EN OTRO TXT SE PUEDE OMITIR PARA ENSAMBLADOR
      // Guarda la insercion en binario en un txt
      
      int16ToBinary(resultado, 0);
      // Guarda la insercion en flotante en un txt
      double salida = puntoFijoADecimal(
          resultado);  // convierte el numero a doble (solo para fines de C)
      escribir_salida(salida, 0);
    }
  }
  fclose(file_);
}
/**
 * Desde aqui se hace el procesamiento del archivo para la reduccion
 */
void reduccion_reverberacion() {
  FILE *file = fopen("insercion_bin.txt", "r");
  if (file == NULL) {
    perror("No se puede abrir el archivo");
    return 1;
  }
  CircularBuffer buffer = {0};
  initializeBuffer(&buffer);
  char line[20];
  double decimalNumber;
  while (fgets(line, sizeof(line), file) != NULL) {
    // Lee una línea del archivo
    if (sscanf(line, "%lf", &decimalNumber) == 1) {
      // AQUI SE CONVIERTE LO LEIDO DEL ARCHIVO TXT A PUNTO FIJO
      int32_t q1_14 = strtol(line, NULL, 2);
      int32_t mascara = 0x7FFF;
      q1_14 = q1_14 & mascara;
      if (line[0] == '1') {
        q1_14 = (-q1_14);  // Complemento a dos
      }
      // AQUI SE ENVIA GENERAR EL ALGORTIMO
      int32_t resultado = reducc_rever_aux(q1_14, &buffer);
      // GUarda la salida en binario en un txt SE PUEDE OMITIR PARA ENSAMBLADOR
      int16ToBinary(resultado, 1);
      // GUarda la salida en flotante en otro txt
      double salida = puntoFijoADecimal(
          resultado);  // convierte el numero a doble (solo para fines de C)
      escribir_salida(salida, 1);
    }
  }
  fclose(file);
}
int main() {
  insercion_reverberacion();
  reduccion_reverberacion();
  return 0;
}