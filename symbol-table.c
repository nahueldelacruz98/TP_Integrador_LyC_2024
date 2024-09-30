#include<stdio.h>

#define MAX_LENGTH 40
#define NAME_SYMBOL_TABLE_FILE "symbol-table.txt"

typedef struct {
    char nombre[MAX_LENGTH];
    char tipoDato[MAX_LENGTH];
    char valor[MAX_LENGTH];
    int longitud;
} Simbolo;

FILE *symbol_file;

int write_symbol_table(Simbolo);
int open_symbol_table();
int close_symbol_table();

int open_symbol_table() {
    symbol_file = fopen(NAME_SYMBOL_TABLE_FILE, "wt");
    if (!symbol_file) {
        fprintf(stderr, "Error al abrir el archivo %s\n", NAME_SYMBOL_TABLE_FILE);
        return 1;
    }
    fprintf(symbol_file, "Nombre,TipoDato,Valor,Longitud\n");
    fclose(symbol_file);

    return 0;
}

int close_symbol_table() {
    if (symbol_file) {
        fclose(symbol_file);
    }

    return 0;
}

int write_symbol_table(Simbolo simbolo) {
    char buffer[256];
    char nombreArchivo[MAX_LENGTH];
    FILE *temp_file;

    temp_file = fopen(NAME_SYMBOL_TABLE_FILE, "rt");
    if (!temp_file) {
        printf("Error al abrir el archivo para leer %s\n", NAME_SYMBOL_TABLE_FILE);
        return 1;
    }

    while (fgets(buffer, sizeof(buffer), temp_file)) {
        sscanf(buffer, "%[^,]", nombreArchivo);
        if (strcmp(nombreArchivo, simbolo.nombre) == 0) {
            fclose(temp_file);
            printf("Simbolo con el nombre '%s' ya existe en la tabla de simbolos\n", simbolo.nombre);
            return 1;
        }
    }
    fclose(temp_file);

    symbol_file = fopen(NAME_SYMBOL_TABLE_FILE, "a");
    if (!symbol_file) {
        printf("Error al abrir el archivo para escribir %s\n", NAME_SYMBOL_TABLE_FILE);
        return 1;
    }

    fprintf(symbol_file, "%s,%s,%s,", simbolo.nombre, simbolo.tipoDato, simbolo.valor);
    if (simbolo.longitud != 0)
        fprintf(symbol_file, "%d", simbolo.longitud);
    fprintf(symbol_file, "\n");

    fclose(symbol_file);

    return 0;
}