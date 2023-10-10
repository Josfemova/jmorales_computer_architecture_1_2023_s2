#include <stdio.h>
#include "compiler.h"
#include <string.h>
#include <stdbool.h>

int main() {
    
    // while ((c = getchar()) != EOF) {
    //     putchar(c);
    // }
    char line[1024];  
    int token_counter =0;
    int lines;
    while (fgets(line, sizeof(line), stdin)) {
        
        if(is_line(line)){
            //printf("line is: %s\n", line);
            lines++;
        
            char str[1024];
            strcpy(str, line);
            char *parts[4]; // Adjust the size as needed

            // Use strtok to tokenize 'newLine' by commas
            char *token = strtok(str, ",");
            int count = 0;

            while (token != NULL) {
                parts[count++] = token;
                token = strtok(NULL, ",");
                token_counter++;
            }
            
            //char* binaryString = typeA_assembly2bin(parts[0], parts[1], parts[2], parts[3]);
            char* check_line = strtok(parts[token_counter-1], ";");
            // printf("tokens %d \n", token_counter);
            // printf("part0 %s \n", parts[0]);
            // printf("part1 %s \n", parts[1]);
            // printf("part2 %s \n", parts[2]);
            // printf("part3 %s \n", parts[3]);
            // printf("lines %d \n", lines);
            handle_instruction(parts, token_counter);
            
            token_counter=0;
            for (int i = 0; i < 4; i++) {
                parts[i] = ""; // An empty string
            }
            //printf("%s\n", binaryString);
        }

        
    }
    return 0;
}

//gcc main.c compiler.c -o main
//./main < input_assembly.txt > output.txt