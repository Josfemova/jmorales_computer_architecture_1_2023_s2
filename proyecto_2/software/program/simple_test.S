#include "UTIL.S"
#define DELAY_T 6250

/*CLIR, t0, GPIO0_VAL_BASE;
CLIR, t1, GPIO0_DIR_BASE;
CLIR, t5, LED_BASE;
CLIR, t2, 0x3; #solo usar primeros dos pines 
STM, t2, t1, 0; # Solo habilitar dos pines para output
CLIR, lr,0xFFFFF;
repeat:
    LDM, t4, t0, 0;
    CLIR,t1,DELAY_T;
    SUM, t2, zero, zero;
    delay:
        SUMI, t2, t2, 1;
        JILT, t2, t1, delay;
    NOT(lr,lr);
    STM,lr,t0,0;
    STM, t4, t5, 0;
    JLL, zero, repeat;*/

start:
    CLIR,x1,0x56; # semilla ---0
    CLIR,x2,RAM_BASE; # addr ---4
    STM,x1,x2,0; # ---8
    CLIR,x3,0; # i ---c
    CLIR,x4,100; # iteraciones---10
    loop:
        SUMI,x3,x3,1; #---14
        SUM,x24,zero,x2; # pasar a reg de arg0 ---18
        JLL,x31,gen_numero; # saltar ---1c
        SUMI,x2,x2,4; # addr +4 ---20
        STM,x24,x2,0; # almacenar palabra ---24
        JLL,x31, espera_toggle;
        STM,x24,t0,0;
        JILT,x3,x4,loop; #---28
end:
    JLL,zero,end; #---2c

gen_numero:
    LDM,x15,x24,0; # cargar valor actual #--30

    ANDI,x16,x15,0x10; #x^4  ---34
    SLLI,x16,x16,0x3;  
    ANDI,x17,x15,0x08; #x^5  ---38
    SLLI,x17,x17,0x4;
    ANDI,x18,x15,0x04; #x^6  ---3c
    SLLI,x18,x18,0x5;
    ANDI,x19,x15,0x01; #x^8  ---40
    SLLI,x19,x19,0x7;

    XOR,x21,x16,x17; # --- 44
    XOR,x21,x21,x18; # --- 48
    XOR,x21,x21,x19; # --- 4c

    SLRI,x15,x15,0x1; # --- 50
    ANDI,x15,x15,0x7F; # --- 54
    OR,x15,x15,x21; # --- 58

    MOV(x24,x15); # --- 5c
    JLRL,zero,x31,0; # --- 60

espera_toggle:
    CLIR, t0, KEY_BASE;
    LDM, t1,t0,0x0;
    ANDI,t2,t1,0x1; # Solo quiero el primer bit
    JINE,t2,zero,espera_toggle; #espera 0
    espera_1:
        LDM,t1,t0,0x0;
        ANDI,t2,t1,0x1; # Solo quiero el primer bit
        JIEQ,t2,zero,espera_1; #espera 1
    JLRL, zero, x31, 0;


