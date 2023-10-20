#include "UTIL.S"

/* No debe pasarse de 16 bits */
#define Q_FRAC_MASK 0x3FFF
#define Q_INT_MASK 0x4000
#define Q_FACTOR 14
#define Q_SIGN_BIT 15
#define Q_SIGN_MASK 0x8000
#define Q_NUM_MASK 0x7FFF
#define Q_ALL_MASK 0xFFFF
/**
 * @brief Realiza operacion de suma de punto fijo
 *
 * @param arg0: operando 1
 * @param arg1: operando 2
 * @return arg0 con el resultado de la op
*/
suma_punto_fijo:
    MOV(t0, arg0);
    MOV(t1, arg1);
    /* Suma fraccional */ 
    ANDI, arg0, arg0, Q_FRAC_MASK;
    ANDI, arg1, arg1, Q_FRAC_MASK;
    SUM, arg0, arg0, arg1;
    /* Suma entera */ 
    SARI, t0, t0, Q_FACTOR;
    SARI, t1, t1, Q_FACTOR;
    SUM, t0, t0, t1;
    SLLI, t0, t0, Q_FACTOR;
    /* Finalizar suma */
    SUM, arg0, arg0, t0;
    JBA;

/**
 * @brief Obtiene el valor de multiplicación
 *
 * @param arg0: operando 1
 * @param arg1: operando 2
 * @return arg0 con el resultado de la op
*/
mult_punto_fijo:
    MOV(t0, arg0); #num1
    MOV(t1, arg1); #num2
    MOV(t2, arg0); #num1
    MOV(t3, arg1); #num2
    SARI, arg0, arg0, Q_FACTOR; # op1 = op1 >> 14 = a
    SARI, arg1, arg1, Q_FACTOR; # op2 = op2 >> 14 = c
    /* HIGH */
    MUL, t4, arg0, arg1; # high_ en t4
    /* LOW */
    ANDI, t0, t0, Q_FRAC_MASK;
    ANDI, t1, t1, Q_FRAC_MASK;
    MUL, t0, t0, t1; # low_ en t0
    /* MID */
    ANDI, t2, t2, Q_FRAC_MASK; #num1
    ANDI, t3, t3, Q_FRAC_MASK; #num2
    MUL, t3, t3, arg0; # a*num2 
    MUL, t2, t2, arg1; # c*num1 
    SUM, t2, t2, t3; # mid_ en t3
    /* FIN */
    SLLI, t4, t4, Q_FACTOR; #high_ = high_ << 14;
    SARI, t0, t0, Q_FACTOR; #low_ = low_ >> 14;
    SUM, arg0, t4, t0;  # high_ + mid_
    SUM, arg0, arg0, t3; # + low_
    JBA;

