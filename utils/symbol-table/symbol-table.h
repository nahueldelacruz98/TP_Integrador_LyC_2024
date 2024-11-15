#ifndef SYMBOL_TABLE_H_INCLUDED
#define SYMBOL_TABLE_H_INCLUDED

#include <stdio.h>
#include <string.h>

#define MAX_LENGTH 40

#define MAX_LENGTH_NOMBRE 41
#define MAX_LENGTH_TIPO_DATO 13
#define MAX_LENGTH_VALOR 40
#define MAX_LENGTH_LONGITUD 11

#define NAME_SYMBOL_TABLE_FILE "outputs/symbol-table.txt"

typedef struct
{
    char nombre[MAX_LENGTH_NOMBRE];
    char tipo_dato[MAX_LENGTH_TIPO_DATO];
    char valor[MAX_LENGTH_VALOR];
    int longitud;
} Simbolo;

int write_symbol_table(Simbolo simbolo, FILE *fp);
int open_symbol_table(FILE *fp);
int close_symbol_table(FILE *fp);
void mostrarSimbolo(const void *simb, FILE *fp);
int compararNombre(const void *d1, const void *d2);
int compararTipoDato(const Simbolo *simbolo_const, const Simbolo *simbolo_id);
void copiarTipoDato(void *tipo_dato, const void *simbolo);
const char *normalizarTipo(const char *tipo);

#endif // SYMBOL_TABLE_H_INCLUDED