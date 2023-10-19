#include "UTIL.S"
#define MUESTRAS_4SEG 64000
#define MUESTRAS_7SEG 112000
#define BUFFER_SIZE 800 
#define ATENUACION 0x2666
#define ATENUACION_M 0x1999
#define ATENUCACION_DIV 0xa000

#define CIRCULAR_BUFFER_BASE RAM_BASE

/* 
 * Interacción con el sistema:
 * SW0 es el reset
 * SW1 == 1: indica si ya se puede comenzar 
 * SW2 == 1: insertar reverb
 * SW2 == 0: quitar reverb 
 * SW3: ?
 *
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
        SUM, t2, t2, 1; # i ++
        SUM, t0, t0, 4; # buffer_ptr++
        JILT, t2, t1, buffer_init_loop;
    CLIR, t1, 1;
    STM, t1, buffer_data_ptr, NO_OFFSET; # buffer->data[i] = 1
    CLIR, t2, ATENUACION;
    STM, t2, t0, -4; # buffer->data[BUFFER_SIZE-1] = ATENUACION;
    MOV(buffer_head, zero); # buffer->head = 0

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
    JIEQ, zero, t2, start; # si no está en 1, me devuelvo

    /* Pre cargar variables de loop principal x(n) */
    MOV(g0, zero); # i = 0
    CLIR, g1, MUESTRAS_4SEG; # i_max
    
    /* Chequear SW2 */
    ANDI, t2, t0, SW2_MASK;
    JIEQ, zero, t2, quitar_reverb;  # SW2 == 0  
    JMP, insertar_reverb; # SW2 == 1

insertar_reverb:
    CLIR, g2, ROM_AUD1_BASE; # audio_ptr 

    insertar_loop:
        SUMI, g0, g0, 1; # i++
        LDM, arg0, g2, NO_OFFSET; # arg0 = *audio_ptr
        
        /* Inicia envío de dato */
        JILT, g0, g1, faltan;
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
    CLIR, g2, ROM_AUD2_BASE;
    reducc_loop:
        SUMI, g0, g0, 1; # i++
        LDM, arg0, g2, NO_OFFSET; # arg0 = *audio_ptr
        
        /* Inicia envío de dato */
        JILT, g0, g1, faltan;
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