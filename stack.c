#include <stdio.h>
#include <stdlib.h>

// Definición de la estructura de la pila
#define MAX 100  // Tamaño máximo de la pila

typedef struct {
    void* elementos[MAX];  // Ahora los elementos son punteros genéricos (void*)
    int tope;
} Pila;

// Función para crear una pila vacía
Pila* CrearPila() {
    Pila* nuevaPila = (Pila*)malloc(sizeof(Pila));
    if (!nuevaPila) {
        printf("Error al crear la pila\n");
        return NULL;
    }
    nuevaPila->tope = -1;
    return nuevaPila;
}

// Función para verificar si la pila está vacía
int esVacia(Pila* pila) {
    return pila->tope == -1;
}

// Función para verificar si la pila está llena
int esLlena(Pila* pila) {
    return pila->tope == MAX - 1;
}

// Función para apilar un puntero
void Apilar(Pila* pila, void* valor) {
    if (esLlena(pila)) {
        printf("La pila está llena, no se puede apilar\n");
        return;
    }
    pila->elementos[++(pila->tope)] = valor;
    printf("Elemento apilado en la pila\n");
}

// Función para desapilar un puntero
void* Desapilar(Pila* pila) {
    if (esVacia(pila)) {
        printf("La pila está vacía, no se puede desapilar\n");
        return NULL;
    }
    return pila->elementos[(pila->tope)--];
}