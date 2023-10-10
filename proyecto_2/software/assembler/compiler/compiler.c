// compiler.c

#include "compiler.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>

const char *functNames[] = {
    "SUM", "DIF", "AND", "OR", "XOR", "SLL", "SLR", "SAR",
    "SUMI", "DIFI", "ANDI", "ORI", "XORI", "SLLI", "SLRI", "SARI",
    "STM", "CLIR", "CUIR", "JLL", "LDM", "JLRL",
    "JIEQ", "JINE", "JIGT", "JILT", "JIGE", "JILE"
};
const char* regNames[] = {
    "rd","rs1","rs2","rs3","rs4","rs5","rs6","rs7","rs8","rs9",
    "rs10","rs11","rs12","rs13","rs14","rs15","rs16","rs17","rs18",
    "rs19","rs20","rs21","rs22","rs23","rs24","rs25","rs26","rs27",
    "rs28","rs29","rs30","rs31"
};
char* tagNames[100];
char* tagPositions[100];
int tagCounter = 0;
int lineCounter =-1;

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
    SUM = 0b000,
    DIF = 0b001,
    AND = 0b010,
    OR = 0b011,
    XOR = 0b100,
    SLL = 0b101,
    SLR = 0b110,
    SAR = 0b111,//ops tipo A->op=000
    SUMI = 0b000,
    DIFI = 0b001,
    ANDI = 0b010,
    ORI = 0b011,
    XORI = 0b100,
    SLLI = 0b101,
    SLRI = 0b110,
    SARI = 0b111,//ops tipo B->op=001
    STM = 0b000, //ops tipo C->op=010
    CLIR = 0b000, //ops tipo D->op=011
    CUIR = 0b001,
    JLL = 0b010,
    LDM = 0b000,//ops tipo F->op=101
    JLRL = 0b010,
    JIEQ = 0b000,//ops tipo G->op=110
    JINE = 0b001,
    JIGT = 0b010,
    JILT = 0b011,
    JIGE = 0b100,
    JILE = 0b101

}func3;


reg string2reg( char* str) {
    for (int i = 0; i < sizeof(regNames) / sizeof(regNames[0]); i++) {
        if (strcmp(str, regNames[i]) == 0) {
            return (reg)i;
        }
    }
    return -1; 
}

func3 string2funct(char* str) {
    for (int i = 0; i < sizeof(functNames) / sizeof(functNames[0]); i++) {
        if (strcmp(str, functNames[i]) == 0) {
            return (func3)i;
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

char *handle_instruction(char* parts[], int token_counter){
   /* printf("tokens %d -", token_counter);
    printf("part0 %s -", parts[0]);
    printf("part1 %s -", parts[1]);
    printf("part2 %s -", parts[2]);
    printf("part3 %s \n", parts[3]);*/
    
    char* binaryString;

    if (token_counter == 4){
        if(string2reg(parts[3]) == -1){
            binaryString = typeB_assembly2bin(parts[0], parts[1], parts[2], parts[3]);
        }else{
            binaryString = typeA_assembly2bin(parts[0], parts[1], parts[2], parts[3]);
        }
        
        lineCounter++;
    }
    else if (token_counter == 3){
        binaryString = typeC_assembly2bin(parts[0], parts[1], parts[2]);
        lineCounter++;
    }
    else if(token_counter==2){
        //jmp a tag
        binaryString="es un jump a tag";
        //binaryString = typeD_assembly2bin(parts[0], parts[1]);

    }
    else if (token_counter == 1){
        //es un tag
        binaryString="Es un tag";
        //binaryString = typeF_assembly2bin(parts[0], lineCounter+1);
    }
    else{
        binaryString="No se pudo interpretar esta instruccion";
    }
    printf("%d %s\n", lineCounter,binaryString);
    
    //printf("lines %d \n", lines);

}
char *typeD_assembly2bin(char *assembly_instruction, char *tag){
    int position = find_element_i(tag);
    return tagPositions[position];

}
char *typeC_assembly2bin(char *assembly_instruction, char *rd, char *reg2){
    //
    char* result = "instruccion tipo c";
    return result;
}
char *typeF_assembly2bin(char *tag, int position){
    // Guardar las posiciones de los jumps
    tagNames[tagCounter] = tag;
    tagPositions[tagCounter]= int2bin(position,5);
    tagCounter++;
    return tag;
    
}
char *typeA_assembly2bin(char *assembly_instruction, char *rd, char *reg1, char *reg2){
    // Para SUM, DIF, AND, OR, XOR, SLL, SLR, SAR
    const char* opcode_str = "000";
    const char* func3_str = int2bin(string2funct(assembly_instruction),3);
    const char* reg_str = int2bin(string2reg(rd),5);
    const char* reg1_str = int2bin(string2reg(reg1),5);
    const char* reg2_str = int2bin(string2reg(reg2),5);
    const char* func11_str = "00000000000";

    size_t totalLength = strlen(opcode_str) + strlen(func3_str) + 
                    strlen(reg_str) + strlen(reg2_str) + 
                    strlen(reg1_str) + strlen(func11_str) + 1; //para terminar en null

    char* result = (char*)malloc(totalLength);
    if (result == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        return NULL; 
    }

    result[0] = '\0';

    strcat(result, opcode_str);
    strcat(result, func3_str);
    strcat(result, reg_str);
    strcat(result, reg1_str);
    strcat(result, reg2_str);
    strcat(result, func11_str);

    return result;
}
char *typeB_assembly2bin(char *assembly_instruction, char *rd, char *reg1, char *inmm){
    // Para SUM, DIF, AND, OR, XOR, SLL, SLR, SAR
    const char* opcode_str = "001";
    const char* func3_str = int2bin(string2funct(assembly_instruction),3);
    const char* reg_str = int2bin(string2reg(rd),5);
    const char* reg1_str = int2bin(string2reg(reg1),5);
    int inmm_int = atoi(inmm);
    const char* inmm_str = int2bin(inmm_int, 16);

    size_t totalLength = strlen(opcode_str) + strlen(func3_str) + 
                    strlen(reg_str) + strlen(inmm_str) + 
                    strlen(reg1_str) + 1; //para terminar en null

    char* result = (char*)malloc(totalLength);
    if (result == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        return NULL; 
    }

    result[0] = '\0';

    strcat(result, opcode_str);
    strcat(result, func3_str);
    strcat(result, reg_str);
    strcat(result, reg1_str);
    strcat(result, inmm_str);

    return result;
}

int find_element_i(const char *target) {
    for (int i = 0; i < 100; i++) {
        if (strcmp(target, tagNames[i]) == 0) {
            return i; // Return the position if found
        }
    }
    return -1; // Return -1 if not found
}
bool is_line(const char *str) {
    if (str == NULL || str[0] == '\0') {
        return false;  // 
    }

    size_t len = strlen(str);
    return str[len - 2] == ';';
}