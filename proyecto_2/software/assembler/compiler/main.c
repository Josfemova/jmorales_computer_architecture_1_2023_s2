#include <stdio.h>
#include "compiler.h"
#include <string.h>
#include <stdbool.h>



int send_instructions(bool tags_saved){
    char line[1024];  
    int token_counter =0;
    int lines = 0;
    while (fgets(line, sizeof(line), stdin)) {
        
        if(is_line(line)){
            
            
            
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
            char* check_line = strtok(parts[token_counter-1], ";");
            
            if(tags_saved){
                if (token_counter!=1)
                {
                    handle_instruction(parts, token_counter);
                }
                else{
                    lines--;
                }
            }
            else{
                
                if (token_counter==1)
                {
                    
                    save_label_address(parts[0], lines);
                    lines--;
                }
                
            }
            token_counter=0;
            for (int i = 0; i < 4; i++) {
                parts[i] = ""; // An empty string
            }
            lines++;
        }

        
    }
    clearerr(stdin);
    return lines;
}

int main() {
    
    // while ((c = getchar()) != EOF) {
    //     putchar(c);
    // }
    bool tags_saved = false; // save tag names
    int lines1 = send_instructions(tags_saved);

    
    fseek(stdin, 0, SEEK_SET);// set to read the stdin from beggining
    tags_saved = true; // translate instructions with tas saved
    int lines2 = send_instructions(tags_saved);
    return 0;
}

//gcc main.c compiler.c -o main
//./main < input_assembly.txt > output.txt