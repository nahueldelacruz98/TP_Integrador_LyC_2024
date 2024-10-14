#include <stdio.h>
#include <stdlib.h>

// Definición de la estructura de la pila
#define MAX 100  // Tamaño máximo de la pila

typedef struct {
    void* elementos[MAX];  // Ahora los elementos son punteros genéricos (void*)
    int tope;
} Pila;

Pila* crear_pila();
int es_vacia(Pila* pila);
int es_llena(Pila* pila);
void apilar(Pila* pila, void* valor);
void* desapilar(Pila* pila);

// Función para crear una pila vacía
Pila* crear_pila() {
    Pila* nueva_pila = (Pila*)malloc(sizeof(Pila));
    if (!nueva_pila) {
        printf("Error al crear la pila\n");
        return NULL;
    }
    nueva_pila->tope = -1;
    return nueva_pila;
}

// Función para verificar si la pila está vacía
int es_vacia(Pila* pila) {
    return pila->tope == -1;
}

// Función para verificar si la pila está llena
int es_llena(Pila* pila) {
    return pila->tope == MAX - 1;
}

// Función para apilar un puntero
void apilar(Pila* pila, void* valor) {
    if (es_llena(pila)) {
        printf("La pila está llena, no se puede apilar\n");
        return;
    }
    pila->elementos[++(pila->tope)] = valor;
    printf("Elemento apilado en la pila\n");
}

// Función para desapilar un puntero
void* desapilar(Pila* pila) {
    if (es_vacia(pila)) {
        printf("La pila está vacía, no se puede desapilar\n");
        return NULL;
    }
    return pila->elementos[(pila->tope)--];
}

void mostrar_pila(Pila* pila) {
    if (es_vacia(pila)) {
        printf("La pila está vacía\n");
        return;
    }
    
    printf("Elementos de la pila:\n");
    for (int i = pila->tope; i >= 0; i--) {
        printf("%p\n", pila->elementos[i]);
    }
}

void liberar_pila(Pila* pila) {
    free(pila);
}