start;
    CLIR,x1,0x56; # semilla
    CLIR,x2,0x100; # addr
    STM,x1,x2,0;
    CLIR,x3,0; # i
    CLIR,x4,100; # iteraciones
    loop;
        SUMI,x3,x3,1;
        SUM,x20,zero,x2; # pasar a reg de arg0
        JLL,x31,gen_numero; # saltar
        SUMI,x2,x2,4; # addr +4
        STM,x20,x2,0; # almacenar palabra
        JILT,x3,x4,loop;
end;
    JLL,zero,end;

gen_numero;
    LDM,x15,x20,0; # cargar valor actual

    ANDI,x16,x15,0x10; #x^4
    SLLI,x16,x16,0x3;
    ANDI,x17,x15,0x08; #x^5
    SLLI,x17,x17,0x4;
    ANDI,x18,x15,0x04; #x^6
    SLLI,x18,x18,0x5;
    ANDI,x19,x15,0x01; #x^8
    SLLI,x19,x19,0x7;

    XOR,x21,x16,x17;
    XOR,x21,x21,x18;
    XOR,x21,x21,x19;

    SLRI,x15,x15,0x1;
    ANDI,x15,x15,0x7F;
    OR,x15,x15,x21;

    SUM,x20,x15,zero;
    JLRL,zero,x31,0;