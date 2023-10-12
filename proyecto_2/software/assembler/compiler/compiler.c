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
int tagPositions[100];
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
const int func3[]={
    0b000,
    0b001,
    0b010,
    0b011,
    0b100,
    0b101,
    0b110,
    0b111,//ops tipo A->op=000
    0b000,
    0b001,
    0b010,
    0b011,
    0b100,
    0b101,
    0b110,
    0b111,//ops tipo B->op=001
    0b000, //ops tipo C->op=010
    0b000, //ops tipo D->op=011
    0b001,
    0b010,
    0b000,//ops tipo F->op=101
    0b010,
    0b000,//ops tipo G->op=110
    0b001,
    0b010,
    0b011,
    0b100,
    0b101

};
const int op[]={
    0b000,
    0b000,
    0b000,
    0b000,
    0b000,
    0b000,
    0b000,
    0b000,//ops tipo A->op=000
    0b001,
    0b001,
    0b001,
    0b001,
    0b001,
    0b001,
    0b001,
    0b001,//ops tipo B->op=001
    0b010, //ops tipo C->op=010
    0b011, //ops tipo D->op=011
    0b011,
    0b011,
    0b101,//ops tipo F->op=101
    0b101,
    0b110,//ops tipo G->op=110
    0b110,
    0b110,
    0b110,
    0b110,
    0b110

};

reg string2reg( char* str) {
    for (int i = 0; i < sizeof(regNames) / sizeof(regNames[0]); i++) {
        if (strcmp(str, regNames[i]) == 0) {
            return (reg)i;
        }
    }
    return -1; 
}

int string2funct(char* str) {
    for (int i = 0; i < sizeof(functNames) / sizeof(functNames[0]); i++) {
        if (strcmp(str, functNames[i]) == 0) {
            return func3[i];
        }
    }
    return -1; 
}
int string2op(char* str) {
    for (int i = 0; i < sizeof(functNames) / sizeof(functNames[0]); i++) {
        if (strcmp(str, functNames[i]) == 0) {
            return op[i];
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

    // Determine the most significant bit
    int signBit = (num < 0) ? 1 : 0;

    // If it's negative, take two's complement
    if (num < 0) {
        num = (1 << numBits) + num;
    }

    for (int i = 0; i < numBits; i++) {
        int bit = (num >> (numBits - 1 - i)) & 1;
        binaryString[i] = bit ? '1' : '0';
    }

    binaryString[numBits] = '\0'; // Null-terminate the string

    // Apply the sign bit
    binaryString[0] = (signBit == 1) ? '1' : binaryString[0];

    return binaryString;
}

char *handle_instruction(char* parts[], int token_counter){
   
    
    char* binaryString;
    
    int operation = string2op(parts[0]);
    
    //printf("op %d ,",operation);
    //printf("opstr %s ",parts[0]);
    //elegir traduccion segun el tipo de instruccion
    
    if (operation == 0b000){
        binaryString = typeA_assembly2bin(parts[0], parts[1], parts[2], parts[3]);
        lineCounter++;
        //printf("Type A \n");
    }
    else if(operation == 0b001 || operation == 0b101){
        binaryString = typeB_assembly2bin(parts[0], parts[1], parts[2], parts[3]);
        lineCounter++;
        //printf("Type B \n");
    }
    else if (operation == 0b010){
        binaryString = typeC_assembly2bin(parts[0], parts[1], parts[2], parts[3]);
        lineCounter++;
        //printf("Type C \n");
    }
    else if (operation == 0b011){
        binaryString = typeD_assembly2bin(parts[0], parts[1], parts[2]);
        lineCounter++;
        //printf("Type D \n");
    }
     else if (operation == 0b101){
        binaryString = typeF_assembly2bin(parts[0], parts[1], parts[2], parts[3]);
        lineCounter++;
        //printf("Type F \n");
     }
    else if (operation == 0b110){
        binaryString = typeG_assembly2bin(parts[0], parts[1], parts[2],parts[3]);
        lineCounter++;
        //printf("Type G \n");
    }
    
    else{
        binaryString="No se pudo interpretar esta instruccion";
    }
    printf("%d %s\n", lineCounter,binaryString);
    
    //printf("lines %d \n", lines);

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
    // Para SUMI, DIFI, ANDI, ORI, XORI, SLLI, SLRI, SARI
    
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
char *typeC_assembly2bin(char *assembly_instruction, char *reg1, char *reg2, char *inmm){
    // Para SUMI, DIFI, ANDI, ORI, XORI, SLLI, SLRI, SARI
    const char* opcode_str = "010";
    const char* func3_str = int2bin(string2funct(assembly_instruction),3);
    const char* reg1_str = int2bin(string2reg(reg1),5);
    const char* reg2_str = int2bin(string2reg(reg2),5);
    int inmm_int = atoi(inmm);
    const char* inmm_str = int2bin(inmm_int, 16);

    size_t totalLength = strlen(opcode_str) + strlen(func3_str) + 
                    strlen(reg2_str) + strlen(inmm_str) + 
                    strlen(reg1_str) + 1; //para terminar en null

    char* result = (char*)malloc(totalLength);
    if (result == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        return NULL; 
    }

    result[0] = '\0';
    //01000000000000001010000100011111
    strcat(result, opcode_str);
    strcat(result, func3_str);
    strncat(result, inmm_str, 5);
    strcat(result, reg1_str);
    strcat(result, reg2_str);
    strcat(result, &inmm_str[5]);
    return result;
}
char *typeD_assembly2bin(char *assembly_instruction, char *rd, char *inmm){
    // Para CLIR, CUIR, JLL
    const char* opcode_str = "011";
    const char* func3_str = int2bin(string2funct(assembly_instruction),3);
    const char* reg_str = int2bin(string2reg(rd),5);
    const char* inmm_str;

    if(strcmp(func3_str, "010")){
        const int inmm_int = atoi(inmm);
        inmm_str = int2bin(inmm_int,21);
    }
    else{
        //inmm es un label
        int label_pos = find_position_by_tag(inmm);
        inmm_str = int2bin(label_pos-lineCounter,21);
        //printf("\nlabel_pos %d, inmm %s, lineCounter %d, inmm_srt %s\n", label_pos, inmm, lineCounter, inmm_str);
        
    }
    size_t totalLength = strlen(opcode_str) + strlen(func3_str) + 
                    strlen(reg_str) +  strlen(inmm_str) + 1; //para terminar en null

    char* result = (char*)malloc(totalLength);
    if (result == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        return NULL; 
    }

    result[0] = '\0';

    strcat(result, opcode_str);
    strcat(result, func3_str);
    strcat(result, reg_str);
    strcat(result, inmm_str);

    return result;

}
char *typeF_assembly2bin(char *assembly_instruction, char *reg1, char *reg2, char *inmm){
    const char* opcode_str = "101";
    const char* func3_str = int2bin(string2funct(assembly_instruction),3);
    const char* reg_str = int2bin(string2reg(rd),5);
    const char* reg1_str = int2bin(string2reg(reg1),5);
    const char* inmm_str;

    if(strcmp(func3_str, "010")){
        const int inmm_int = atoi(inmm);
        inmm_str = int2bin(inmm_int,16);
    }
    else{
        //inmm es un label
        int label_pos = find_position_by_tag(inmm);
        inmm_str = int2bin(label_pos-lineCounter,16);
        //printf("\nlabel_pos %d, inmm_srt %s\n", label_pos-lineCounter, inmm_str);
        
    }
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
char *typeG_assembly2bin(char *assembly_instruction, char *reg1, char *reg2, char *inmm){
    const char* opcode_str = "110";
    const char* func3_str = int2bin(string2funct(assembly_instruction),3);
    const char* reg1_str = int2bin(string2reg(reg1),5);
    const char* reg2_str = int2bin(string2reg(reg2),5);
    int label_pos = find_position_by_tag(inmm);
    const char* inmm_str = int2bin(label_pos-lineCounter,16);
    //printf("\nlabel_pos %d, inmm %s\n", label_pos-lineCounter, inmm_str);
    
    
    size_t totalLength = strlen(opcode_str) + strlen(func3_str) + 
                    strlen(reg2_str) + strlen(inmm_str) + 
                    strlen(reg1_str) + 1; //para terminar en null

    char* result = (char*)malloc(totalLength);
    if (result == NULL) {
        fprintf(stderr, "Memory allocation failed.\n");
        return NULL; 
    }

    result[0] = '\0';
    //01000000000000001010000100011111
    strcat(result, opcode_str);
    strcat(result, func3_str);
    strncat(result, inmm_str, 5);
    strcat(result, reg1_str);
    strcat(result, reg2_str);
    strcat(result, &inmm_str[5]);
    return result;
    
}

int save_label_address(char *tag, int line){
    //printf("\ntagcounter %d tag %s \n",tagCounter, tag);
    tagNames[tagCounter] = (char*)malloc(strlen(tag) + 1); // +1 for the null terminator
    if (tagNames[tagCounter] == NULL) {
        exit(1);
    }
    strcpy(tagNames[tagCounter], tag);
    tagPositions[tagCounter] = line;
    tagCounter++;
    // for (int i = 0; i < 5; i++) { // Adjust the loop range based on the number of elements
    //     printf("Tag Name: %s, Position: %d\n", tagNames[i], tagPositions[i]);
    // }
    return tagCounter;
}


int find_position_by_tag(char* tag) {
    for (int i = 0; i < tagCounter; i++) {
        if (strcmp(tag, tagNames[i]) == 0) {
            return tagPositions[i];
        }
    }
    // Return a sentinel value to indicate that the tag was not found
    return -1;
}
bool is_line(const char *str) {
    if (str == NULL || str[0] == '\0') {
        return false;  // 
    }

    size_t len = strlen(str);
    return str[len - 2] == ';';
}