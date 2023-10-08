#include <stdio.h>
#include "compiler.h"
#include <string.h>

int main() {
    
    // while ((c = getchar()) != EOF) {
    //     putchar(c);
    // }
    char line[1024];  
    int counter =0;
    while (fgets(line, sizeof(line), stdin)) {
        char str[1024];
        strcpy(str, line);
        char *parts[4]; // Adjust the size as needed

        // Use strtok to tokenize 'newLine' by commas
        char *token = strtok(str, ",");
        int count = 0;

        while (token != NULL) {
            parts[count++] = token;
            token = strtok(NULL, ",");
        }

        char* binaryString = assembly2bin(parts[0], parts[1], parts[2], parts[3]);

        printf("%s\n", binaryString);

        
    }
    return 0;
}

//gcc main.c compiler.c -o main
//./main < input_assembly.txt > output.txt