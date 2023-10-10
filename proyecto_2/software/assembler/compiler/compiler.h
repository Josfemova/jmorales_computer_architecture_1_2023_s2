// compiler.h

#include <stdbool.h>
#ifndef COMPILER_H
#define COMPILER_H

// Declare the placeholder functions

char* int2bin(int num, int numBits);
char *typeA_assembly2bin(char *assembly_instruction, char *reg, char *reg_or_inmm1, char *reg_or_inmm2);
char *typeB_assembly2bin(char *assembly_instruction, char *rd, char *reg1, char *inmm);
char *typeC_assembly2bin(char *assembly_instruction, char *inmm, char *reg1, char *reg2);

char *typeF_assembly2bin(char *tag, int position);
char *typeD_assembly2bin(char *assembly_instruction, char *tag);

int find_element_i(const char *target);
bool is_line(const char *str);
char *handle_instruction(char* parts[], int token_counter);
#endif
