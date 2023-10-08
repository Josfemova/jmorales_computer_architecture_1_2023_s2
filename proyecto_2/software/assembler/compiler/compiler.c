// compiler.c

#include "compiler.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

const char* functNames[] = {
    "SUM", "DIF", "SLL", "SRR", "XOR", "CIR", "CPV", "AND",
    "ORR", "JMP", "JRL", "JBA", "JIQ", "JLT", "LDM", "STM"
};
const char* regNames[] = {
    "rd","rs1","rs2","rs3","rs4","rs5","rs6","rs7","rs8","rs9",
    "rs10","rs11","rs12","rs13","rs14","rs15","rs16","rs17","rs18",
    "rs19","rs20","rs21","rs22","rs23","rs24","rs25","rs26","rs27",
    "rs28","rs29","rs30","rs31"
};

typedef enum{
  rd = 0, 
  rs1 = 1,
  rs2 = 2,
  rs3 = 3,
  rs4 = 4,
  rs5 = 5,
  rs6 = 6,
  rs7 = 7,
  rs8 = 8,
  rs9 = 9,
  rs10 = 10,
  rs11 = 11,
  rs12 = 12,
  rs13 = 13,
  rs14 = 14,
  rs15 = 15,
  rs16 = 16,
  rs17 = 17,
  rs18 = 18,
  rs19 = 19,
  rs20 = 20,
  rs21 = 21,
  rs22 = 22,
  rs23 = 23,
  rs24 = 24,
  rs25 = 25,
  rs26 = 26,
  rs27 = 27,
  rs28 = 28,
  rs29 = 29,
  rs30 = 30,
  rs31 = 31
}reg;
typedef enum{
    SUM = 0b0000,
    DIF = 0b0001,
    SLL = 0b0100,
    SRR = 0b0101,
    XOR = 0b0100,
    CIR = 5,
    CPV = 6,
    AND = 0b0010,
    ORR = 0b0011,
    JMP = 9,
    JRL = 10,
    JBA = 11,
    JIQ = 12,
    JLT = 13,
    LDM = 14,
    STM = 15

}funct;

typedef enum{
    TypeA = 0,
    TypeB = 1,
    TypeC = 2,
    TypeD = 3,
    TypeE = 4
}opcode;

reg string2reg( char* str) {
    for (int i = 0; i < sizeof(regNames) / sizeof(regNames[0]); i++) {
        if (strcmp(str, regNames[i]) == 0) {
            return (reg)i;
        }
    }
    return -1; 
}
funct string2funct(char* str) {
    for (int i = 0; i < sizeof(functNames) / sizeof(functNames[0]); i++) {
        if (strcmp(str, functNames[i]) == 0) {
            return (funct)i;
        }
    }
    return -1; 
}

char* int2bin(int num, int numBits) {
    if (numBits <= 0) {
        fprintf(stderr, "Invalid number of bits.\n");
        return NULL;
    }

    char* binaryString = (char*)malloc(numBits + 1); // +1 for null terminator

    if (binaryString == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        exit(1); // Handle memory allocation failure
    }

    for (int i = 0; i < numBits; i++) {
        int bit = (num >> (numBits - 1 - i)) & 1;
        binaryString[i] = bit ? '1' : '0';
    }

    binaryString[numBits] = '\0'; // Null-terminate the string
    return binaryString;
}

char *assembly2bin(char *assembly_instruction, char *reg, char *reg2, char *reg_or_inmm){
    const char* opcode_str = int2bin(string2funct(assembly_instruction),4);
    const char* reg_str = int2bin(string2reg(reg),5);
    const char* reg2_str = int2bin(string2reg(reg2),5);
    const char* reg_or_inmm_str;

    if(string2reg(reg_or_inmm)==-1){
        reg_or_inmm_str = reg_or_inmm;
    }
    else{
        reg_or_inmm_str = int2bin(string2reg(reg_or_inmm),20);
    }

    size_t totalLength = strlen(opcode_str) + strlen(reg_str) + strlen(reg2_str) + strlen(reg_or_inmm_str) + 1; //para terminar en null

    char* result = (char*)malloc(totalLength);
    if (result == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        return NULL; 
    }

    result[0] = '\0';

    
    
    
    strcat(result, reg_or_inmm_str);
    strcat(result, reg2_str);
    strcat(result, reg_str);
    strcat(result, opcode_str);

    return result;
}
