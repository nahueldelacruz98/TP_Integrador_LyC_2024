#include<stdio.h>

#define NAME_INTERMEDIATE_CODE_FILE "intermediate-code.txt"

FILE *intermediate_file;

int write_intermediate_code(const char *);
int create_intermediate_code();
int close_intermediate_code();

int create_intermediate_code() {
    intermediate_file = fopen(NAME_INTERMEDIATE_CODE_FILE, "wt");
    if (!intermediate_file) {
        fprintf(stderr, "Error al abrir el archivo %s\n", NAME_INTERMEDIATE_CODE_FILE);
        return 1;
    }

    return 0;
}

int close_intermediate_code() {
    if (intermediate_file) {
        fclose(intermediate_file);
    }

    return 0;
}

int write_intermediate_code(const char *string) {
    fprintf(intermediate_file, "%s", string);

    return 0;
}