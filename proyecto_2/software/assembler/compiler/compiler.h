// compiler.h

#include <stdbool.h>
#ifndef COMPILER_H
#define COMPILER_H

// Declare the placeholder functions

char* int2bin(int num, int numBits);
char *typeA_assembly2bin(char *assembly_instruction, char *reg, char *reg_or_inmm1, char *reg_or_inmm2);
char *typeB_assembly2bin(char *assembly_instruction, char *rd, char *reg1, char *inmm);
char *typeC_assembly2bin(char *assembly_instruction, char *inmm, char *reg1, char *reg2);
char *typeD_assembly2bin(char *assembly_instruction, char *rd, char *inmm);
char *typeF_assembly2bin(char *assembly_instruction, char *reg1, char *reg2, char *inmm);
char *typeG_assembly2bin(char *assembly_instruction, char *reg1, char *reg2, char *inmm);
int find_position_by_tag(char* tag);
bool is_line(const char *str);
int save_label_address(char *tag, int line);
char *handle_instruction(char* parts[], int token_counter);
#endif
