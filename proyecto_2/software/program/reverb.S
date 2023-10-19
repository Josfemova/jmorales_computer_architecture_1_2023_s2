#include "UTIL.S"
#define MUESTRAS_4SEG 64000
#define MUESTRAS_7SEG 112000
#define BUFFER_SIZE 800 
#define ATENUACION 0x2666
#define ATENUACION_M 0x1999
#define ATENUCACION_DIV 0xa000

# variables globales:
# g7 - puntero a gpio0
# g6 - mascara para pin de request
# g5 - mascara para pin de ack

setup:
    CLIR, g7, GPIO0_VAL_BASE; # var global 
    CLIR, t0, GPIO0_DIR_BASE;
    CLIR, t1, GPIO0_OUTPUTS_MASK; 
    STM, t1, t0, 0; # configurar pines de salida
    CLIR, t0, 1;
    SLLI, t1, t0, ACK_PIN_POS;

    STM, t1, g7,0; # poner todos los pines de salida en 0, INCLUYE A READY
    CLIR, sp, STACK_START; # inicializar sp
    JMP, start;

#include "Q114.S"

start:
    CLIR, g0, ROM_AUD1_BASE;
    CLIR, g1, 0; # i = 0
    CLIR, g2, MUESTRAS_4SEG; # i_max
    main_loop:
        SUMI, g1, g1, 1;

        LDM, arg0, g0, NO_OFFSET;

        JILT, g1, g2, faltan;
        no_faltan:
            CLIR, arg1, TRUE;
            JMP, end_faltan_check;
        faltan:
            CLIR, arg1, FALSE;
        end_faltan_check:

        CALL, send_data;

        SUMI, g0, g0, 4;
        JILT, g1, g2, main_loop;

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
    LDM, t2, g7, NO_OFFSET; # Leer GPIOS
    AND, t3, t1, t2;
    
    /*SLRI, g6, t3, 16;
    CLIR, g5, LED_BASE;
    STM, g6, g5, NO_OFFSET;*/
    
    JINE, t3, zero, send_data; # si leo un 1, vuelvo a intentar leer 0

    /*  Escribir 0 a ACK */
    STM, zero, g7, NO_OFFSET; # escribo todo 0, más rápido
    espera_1_sd:
        LDM, t2, g7, NO_OFFSET;
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
    STM, arg0, g7, NO_OFFSET;
    JBA;