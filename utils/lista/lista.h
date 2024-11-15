#ifndef LISTA_H_INCLUDED
#define LISTA_H_INCLUDED

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#define SIN_MEM 1
#define CLA_DUP 2
#define TODO_BIEN 0

typedef struct sNodo{
    void            *info;
    unsigned         tamInfo;
    struct sNodo    *sig;
}tNodo;

typedef tNodo *tLista;

void crear_lista(tLista *p);
int listaVacia(const tLista *p);
int listaLlena(const tLista *p, unsigned cantBytes);
int vaciarLista(tLista *p); 
int ponerAlComienzo(tLista *p, const void *d, unsigned cantBytes);
int sacarPrimeroLista(tLista *p, void *d, unsigned cantBytes);
int verPrimeroLista(const tLista *p, void *d, unsigned cantBytes);
int ponerAlFinal(tLista *p, const void *d, unsigned cantBytes);
int sacarUltimoLista(tLista *p, void  *d, unsigned cantBytes);
int verUltimoLista(const tLista *p, void *d, unsigned cantBytes);
int ponerAlFinalYEscribir(tLista *p, const void *d, unsigned cantBytes, FILE *fp,
                          int(* comparar)(const void *, const void *),
                          void(* escribir)(const void *, FILE *));
int vaciarListaYMostrar(tLista *p,
                        void (*mostrar)(const void *, FILE *), FILE *fp);
void mostrarLista(tLista *p, void (*mostrar)(const void *, FILE *));

#endif // LISTA_H_INCLUDED
