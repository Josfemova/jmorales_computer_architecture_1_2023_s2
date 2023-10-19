#include "UTIL.S"

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

start:
    CLIR, g0,0x56; # semilla
    CLIR, g1,RAM_BASE; # addr 
    STM,  g0,g1,0; # 
    CLIR, g2,0; # i 
    CLIR, g3,100; # iteraciones
    loop:
        SUMI, g2,g2,1; # i++
        SUM,  arg0,zero,g1; # pasar a reg de arg0
        CALL, gen_numero; # saltar
        SUMI, g1,g1,4; # addr + 4
        STM,  arg0,g1,NO_OFFSET; # almacenar palabra en RAM         

        JILT, g2, g3, faltan;
        no_faltan:
            CLIR, arg1, TRUE;
            JMP, end_faltan_check;
        faltan:
            CLIR, arg1, FALSE;
        end_faltan_check:
        CALL, send_data;
        JILT, g2,g3,loop; 
end:
    JLL,zero,end; 


gen_numero:
    LDM,t0,x24,0; # cargar valor actual 

    ANDI, t1, t0, 0x10; #x^4 
    SLLI, t1, t1, 0x3;  
    ANDI, t2, t0, 0x08; #x^5 
    SLLI, t2, t2, 0x4;
    ANDI, t3, t0, 0x04; #x^6  
    SLLI, t3, t3, 0x5;
    ANDI, t4, t0, 0x01; #x^8  
    SLLI, t4, t4, 0x7;

    XOR, t5, t1, t2; 
    XOR, t5, t5, t3;
    XOR, t5, t5, t4; 

    SLRI, t0, t0, 0x1; 
    ANDI, t0, t0, 0x7F; 
    OR,   t0, t0, t5; 

    MOV(arg0,t0); 
    JBA;

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