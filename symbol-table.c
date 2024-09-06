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
int open_symbol_table_file();
int close_symbol_table_file();

int open_symbol_table_file() {
    symbol_file = fopen(NAME_SYMBOL_TABLE_FILE, "wt");
    if (!symbol_file) {
        fprintf(stderr, "Error al abrir el archivo %s\n", NAME_SYMBOL_TABLE_FILE);
        return 1;
    }
    fprintf(symbol_file, "Nombre,TipoDato,Valor,Longitud\n");

    return 0;
}

int close_symbol_table_file() {
    if (symbol_file) {
        fclose(symbol_file);
    }

    return 0;
}

int write_symbol_table(Simbolo simbolo) 
{
    fprintf(symbol_file, "%s,%s,%s,%d\n", simbolo.nombre, simbolo.tipoDato, simbolo.valor, simbolo.longitud);

    return 0;
}