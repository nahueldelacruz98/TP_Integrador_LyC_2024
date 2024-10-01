#include <stdio.h>

struct Nodo {
    char *valor;
    struct Nodo *izq, *der;
};

struct Nodo *crear_nodo(char *operador, struct Nodo *izq, struct Nodo *der) {
    struct Nodo *nuevo = (struct Nodo *)malloc(sizeof(struct Nodo));
    nuevo->valor = strdup(operador);
    nuevo->izq = izq;
    nuevo->der = der;
    return nuevo;
}

struct Nodo *crear_hoja(char *valor) {
    struct Nodo *hoja = (struct Nodo *)malloc(sizeof(struct Nodo));
    hoja->valor = strdup(valor);
    hoja->izq = NULL;
    hoja->der = NULL;
    return hoja;
}

void imprimirInorden(struct Nodo* nodo) {
    if (nodo == NULL) return;
    
    imprimirInorden(nodo->izq);
    write_intermediate_code(nodo->valor);
    //printf("%s ", nodo->valor);
    imprimirInorden(nodo->der);
}

void imprimirPreorden(struct Nodo* nodo) {
    if (nodo == NULL) return;
    
    //printf("%s ", nodo->valor);
    write_intermediate_code(nodo->valor);
    imprimirPreorden(nodo->izq);
    imprimirPreorden(nodo->der);
}

void imprimirPostorden(struct Nodo* nodo) {
    if (nodo == NULL) return;
    
    imprimirPostorden(nodo->izq);
    imprimirPostorden(nodo->der);
    //printf("%s ", nodo->valor);
    write_intermediate_code(nodo->valor);
}

void imprimirArbol(struct Nodo* nodo, int nivel) {
    if (nodo == NULL) return;

    imprimirArbol(nodo->der, nivel + 1);
    
    for (int i = 0; i < nivel; i++) {
        printf("   ");  // Indentación según el nivel
    }
    printf("%s\n", nodo->valor);

    imprimirArbol(nodo->izq, nivel + 1);
}