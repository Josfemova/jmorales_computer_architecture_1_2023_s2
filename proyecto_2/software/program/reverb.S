#include "UTIL.S"
#define MUESTRAS_1SEG 16000
#define MUESTRAS_2SEG 32000
#define MUESTRAS_4SEG 64000
#define MUESTRAS_7SEG 112000
#define SELECTED_MUESTRAS MUESTRAS_7SEG
#define BUFFER_SIZE 800 
#define BUFFER_HEAD_MAX 799 
#define ATENUACION 0x2666
#define ATENUACION_M 0x1999
#define ATENUACION_DIV 0xa000

#define CIRCULAR_BUFFER_BASE RAM_BASE

/* 
 * Interacción con el sistema:
 * SW0 es el reset
 * SW1 == 1: indica audio a procesar
 * SW2 == 1: insertar reverb
 * SW2 == 0: quitar reverb 
 * SW3 == 1: PWM out 
 * SW3 == 0: stream out
*/

# variables globales:
# g7 - puntero a gpio0
# g6 - buffer->data
# g5 - buffer->head

#define gpio0_ptr g7
#define buffer_data_ptr g6
#define buffer_head g5

setup:
    CLIR, gpio0_ptr, GPIO0_VAL_BASE;
    CLIR, t0, GPIO0_DIR_BASE;
    CLIR, t1, GPIO0_OUTPUTS_MASK; 
    STM, t1, t0, 0; # configurar pines de salida
    CLIR, t0, 1;
    SLLI, t1, t0, ACK_PIN_POS;

    STM, t1, gpio0_ptr,0; # poner todos los pines de salida en 0, INCLUYE A READY
    CLIR, sp, STACK_START; # inicializar sp

    /* Inicializar buffer */ 
    CLIR, buffer_data_ptr, CIRCULAR_BUFFER_BASE;
    MOV(t0, buffer_data_ptr);
    CLIR, t1, BUFFER_SIZE;
    MOV(t2, zero); # i = 0

    buffer_init_loop:
        STM, zero, t0, NO_OFFSET; # buffer->data[i] = 0;
        SUMI, t2, t2, 1; # i ++
        SUMI, t0, t0, 4; # buffer_ptr++
        JILT, t2, t1, buffer_init_loop;
    
    CLIR, t3, 1;
    STM, t3, buffer_data_ptr, NO_OFFSET; # buffer->data[0] = 1
    CLIR, t2, ATENUACION;
    STM, t2, t0, -4; # buffer->data[BUFFER_SIZE-1] = ATENUACION;
    MOV(buffer_head, zero); # buffer->head = 0
    

    /* Termina inicialización de buffer */

    /* Saltar a programa principal */
    JMP, start;

#include "Q114.S"

start:
    /* Chequear switches para verificar modo */
    CLIR, t0, SW_BASE;
    CLIR, t1, LED_BASE;
    LDM, t0, t0, NO_OFFSET;
    
    /* Escribir valor de switches a Leds */
    STM, t0, t1, NO_OFFSET; 

    /* Chequear SW1 */    
    ANDI, t2, t0, SW1_MASK;

    JIEQ, zero, t2, sel_audio_reverbed; # 1 selecciona audio normal
    CUIR, g2, ROM_AUD1_BASE_UP21; # audio_ptr 
    JMP, end_audio_sel;
    sel_audio_reverbed:
    CUIR, g2, ROM_AUD2_BASE_UP21;
    end_audio_sel:

    /* Pre cargar variables de loop principal x(n) */
    MOV(g0, zero); # i = 0
    CLIR, g1, SELECTED_MUESTRAS; # i_max
    
    /* Chequear SW2 */
    ANDI, t2, t0, SW2_MASK;
    JIEQ, zero, t2, reducc_reverb;  # SW2 == 0  
    JMP, insertar_reverb; # SW2 == 1

insertar_reverb:

    insertar_loop:
        SUMI, g0, g0, 1; # i++
        LDM, arg0, g2, NO_OFFSET; # arg0 = *audio_ptr // num

        /* Pasar a complemento a dos */
        ANDI, t0, arg0, Q_SIGN_MASK;
        ANDI, arg0, arg0, Q_NUM_MASK;
        JIEQ, t0, zero, insertar_cmpl2_end0;
        NEG(arg0, arg0);
        insertar_cmpl2_end0:
        /* Fin de pasar a complemento 2*/

        CLIR, arg1, ATENUACION_M;
        CALL, mult_punto_fijo; # result = mult_punto_fijo(num, ATENUACION_M)
        MOV(g3, arg0); # copiar result porque arg0 se necesita pa otra mul

        CLIR, t1, BUFFER_HEAD_MAX;
        JIEQ, buffer_head, t1, insertar_yn_zero;
        insertar_yn_is_bfh_p1:
            SUMI, t1, buffer_head, 1; # index = buffer->head + 1
            JMP, insertar_yn_calc_end;    
        insertar_yn_zero:
            MOV(t1, zero); # index = 0
        insertar_yn_calc_end:  

        /* Desarrolla la parte de y(n-k)*a */
        /* Calcular &buffer->data[index] */
        SLLI, t1,t1, 2; // multiplicar index por 4
        SUM, t0, buffer_data_ptr, t1;

        LDM, arg0, t0, NO_OFFSET;  # arg0 = buffer->data[index]
        CLIR, arg1, ATENUACION;
        CALL, mult_punto_fijo; # arg0 =  mult_punto_fijo((buffer->data[index]), ATENUACION);

        /* Suma los resultados de las multiplicaciones */
        MOV(arg1, g3); # recuperar primer resultado 
        CALL, suma_punto_fijo;

        /* Agrega el nuevo resultado al buffer circular*/
        /* Calcular &buffer->data[buffer_head] */
        SLLI, t0, buffer_head, 2; # multiplicar index por 4
        SUM, t1, buffer_data_ptr, t0;
        STM, arg0, t1, NO_OFFSET; # buffer->data[buffer->head] = result;

        /* calcular nuevo valor de buffer_head */
        CLIR, t0, BUFFER_HEAD_MAX;
        JILT, buffer_head, t0, insertar_bfh_is0;
        insertar_bfh_plus1:
            MOV(buffer_head, zero);
            JMP, insertar_bfh_calc_end;
        insertar_bfh_is0:
            SUMI, buffer_head, buffer_head, 1;
        insertar_bfh_calc_end:        

        /* Acá arg0 sigue siendo el y(n) actual */

        /* Pasar de complemento a dos al formato custom */
        ANDI, t0, arg0, Q_SIGN_MASK; # extraer signo
        JIEQ, t0, zero, insertar_cmpl2x; # si no tiene signo bye
        NEG(arg0, arg0);
        OR, arg0, arg0, t0; 
        insertar_cmpl2x:
        CLIR, t1, Q_ALL_MASK;
        AND, arg0, arg0, t1; // asegurarse de no mandar mas de 16 bits
        /* Fin de pasar a complemento 2*/

        /* Inicia envío de dato */
        JILT, g0, g1, insertar_faltan;
        insertar_no_faltan:
            CLIR, arg1, TRUE;
            JMP, insertar_end_faltan;
        insertar_faltan:
            CLIR, arg1, FALSE;
        insertar_end_faltan:
            CALL, send_data;
        /* Termina envío de dato */

        SUMI, g2, g2, 4;  # audio_ptr + 1
        JILT, g0, g1, insertar_loop;
    JMP, end;

reducc_reverb:
    reducc_loop:
        SUMI, g0, g0, 1; # i++
        LDM, g3, g2, NO_OFFSET; # g3 = *audio_ptr // num

        /* Pasar a complemento a dos */
        ANDI, t0, g3, Q_SIGN_MASK;
        ANDI, g3, g3, Q_NUM_MASK;
        JIEQ, t0, zero, reducc_cmpl2_end0;
        NEG(g3, g3);
        reducc_cmpl2_end0:
        /* Fin de pasar a complemento 2*/
        
        /* Calcular el index en el buffer */
        CLIR, t1, BUFFER_HEAD_MAX;
        JIEQ, buffer_head, t1, reducc_xn_zero;
        reducc_xn_is_bfh_p1:
            SUMI, t1, buffer_head, 1; # index = buffer->head + 1
            JMP, reducc_xn_calc_end;    
        reducc_xn_zero:
            MOV(t1, zero); # index = 0
        reducc_xn_calc_end:  


        /* Desarrolla la parte de x(n-k)*a */
        /* Calcular &buffer->data[index] */
        SLLI, t1, t1, 2; // multiplicar index por 4
        SUM, t0, buffer_data_ptr, t1;

        LDM, arg0, t0, NO_OFFSET;  # arg0 = buffer->data[index]
        CLIR, arg1, ATENUACION;
        CALL, mult_punto_fijo; # arg0 =  mult_punto_fijo((buffer->data[index]), ATENUACION);

        /* Convierto a ~a*x(n-k) */
        NEG(arg1, arg0); #  result = -result;
        /* Realizo la resta (x(n) - ax(n-k)) */
        MOV(arg0, g3);
        CALL, suma_punto_fijo; # result = suma_punto_fijo(num, result); 
        /* Multiplico la suma por 1/(1-a) */
        CLIR, arg1, ATENUACION_DIV;
        CALL, mult_punto_fijo; # result = mult_punto_fijo(result, ATENUACION_DIV);

        /* Agrega el nuevo resultado al buffer circular*/
        /* Calcular &buffer->data[buffer_head] */
        SLLI, t0, buffer_head, 2; # multiplicar index por 4
        SUM, t1, buffer_data_ptr, t0;
        STM, g3, t1, NO_OFFSET; # buffer->data[buffer->head] = num, sí, num

        /* calcular nuevo valor de buffer_head */
        CLIR, t0, BUFFER_HEAD_MAX;
        JILT, buffer_head, t0, reducc_bfh_is0;
        reducc_bfh_plus1:
            MOV(buffer_head, zero);
            JMP, reducc_bfh_calc_end;
        reducc_bfh_is0:
            SUMI, buffer_head, buffer_head, 1;
        reducc_bfh_calc_end:        
        /* Acá arg0 sigue siendo el x(n) actual */

        /* Pasar de complemento a dos */
        ANDI, t0, arg0, Q_SIGN_MASK;
        JIEQ, t0, zero, reducc_cmpl2_end1;
        NEG(arg0, arg0);
        OR, arg0, arg0, t0;
        reducc_cmpl2_end1:
        CLIR, t1, Q_ALL_MASK;
        AND, arg0, arg0, t1; // asegurarse de no mandar mas de 16 bits
        /* Fin de pasar a complemento 2*/
        
        /* Inicia envío de dato */
        JILT, g0, g1, reducc_faltan;
        reducc_no_faltan:
            CLIR, arg1, TRUE;
            JMP, reducc_end_faltan;
        reducc_faltan:
            CLIR, arg1, FALSE;
        reducc_end_faltan:
            CALL, send_data;
        /* Termina envío de dato */

        SUMI, g2, g2, 4;  # audio_ptr + 1
        JILT, g0, g1, reducc_loop;
    JMP, end;


end:
    JLL,zero,end; 

/**
 * Funcion que realiza handshake con el extractor de datos
 * @param arg0 son los datos
 * @param arg1 indica si es el último dato. 1 si es verdadero
 */
send_data:
    CLIR, t0, SW_BASE;
    LDM, t1, t0, NO_OFFSET;
    ANDI, t2, t1, SW3_MASK;
    JIEQ, t2, zero, send_data_stream;
    send_data_pwm: 
        JBA;

    send_data_stream:
    /* si leo un 0 en request, escribo un 0 a ack y espero a un 1 en 
     * request. Apenas recibo el 1, 
     * 1. Escribo arg0 al espacio de datos
     * 2. Escribo 1 a ready si arg1 != 0 a ready
     * 3. Escribo 1 a ack
     */ 
    SUMI, t0, zero, 1; 
    SLLI, t1, t0, REQUEST_PIN_POS; # mascara request 
    LDM, t2, gpio0_ptr, NO_OFFSET; # Leer GPIOS
    AND, t3, t1, t2;
    
    JINE, t3, zero, send_data; # si leo un 1, vuelvo a intentar leer 0

    /*  Escribir 0 a ACK */
    STM, zero, gpio0_ptr, NO_OFFSET; # escribo todo 0, más rápido
    espera_1_sd:
        LDM, t2, gpio0_ptr, NO_OFFSET;
        AND, t3, t1, t2; 
        JIEQ, t3, zero, espera_1_sd;
    
    /* Calcular dato a escribir en GPIOS */
    JIEQ, arg1, zero, arg1_eq_false;
    arg1_eq_true:
        CLIR, arg1, READY_PIN_MASK;
        JMP,  arg1_check_end;
    arg1_eq_false:
        SUM, arg1, zero, zero;
    arg1_check_end:

    SLLI, t2, t0, ACK_PIN_POS; # ack mask 
    OR, arg0, arg0, arg1; # dato + ready_flag
    OR, arg0, arg0, t2; # + ack 

    /* Por fin, escribir a pines */
    STM, arg0, gpio0_ptr, NO_OFFSET;
    JBA;