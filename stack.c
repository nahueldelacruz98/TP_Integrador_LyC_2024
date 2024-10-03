#include <stdio.h>
#include <stdlib.h>

// Definición de la estructura de la pila
#define MAX 100  // Tamaño máximo de la pila

struct Pila{
    void* elementos[MAX];  // Ahora los elementos son punteros genéricos (void*)
    int tope;
} ;

// Función para crear una pila vacía
struct Pila *CrearPila() {
    struct Pila* nuevaPila = (struct Pila*)malloc(sizeof(struct Pila));
    if (!nuevaPila) {
        printf("Error al crear la pila\n");
        return NULL;
    }
    nuevaPila->tope = -1;
    return nuevaPila;
}

// Función para verificar si la pila está vacía
int esVacia(struct Pila* pila) {
    return pila->tope == -1;
}

// Función para verificar si la pila está llena
int esLlena(struct Pila* pila) {
    return pila->tope == MAX - 1;
}

// Función para apilar un puntero
void Apilar(struct Pila* pila, void* valor) {
    if (esLlena(pila)) {
        printf("La pila está llena, no se puede apilar\n");
        return;
    }
    pila->elementos[++(pila->tope)] = valor;
    printf("Elemento apilado en la pila\n");
}

// Función para desapilar un puntero
void* Desapilar(struct Pila* pila) {
    if (esVacia(pila)) {
        printf("La pila está vacía, no se puede desapilar\n");
        return NULL;
    }
    return pila->elementos[(pila->tope)--];
}