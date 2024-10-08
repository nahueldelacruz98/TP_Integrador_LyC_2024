#include <stdio.h>

#define NAME_DOT_FILE "dot.txt"

struct Nodo {
    char *valor;
    struct Nodo *izq, *der;
};

struct Nodo *crear_nodo(char *operador, struct Nodo *izq, struct Nodo *der);
struct Nodo *crear_hoja(char *valor);

void imprimirInorden(struct Nodo* nodo);
void imprimirPreorden(struct Nodo* nodo);
void imprimirPostorden(struct Nodo* nodo);
void imprimirArbol(struct Nodo* nodo, int nivel);

void generarDOT(struct Nodo* nodo, FILE* archivo);
void generarArchivoDOT(struct Nodo* raiz);

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
        printf("   ");
    }
    printf("%s\n", nodo->valor);

    imprimirArbol(nodo->izq, nivel + 1);
}

void generarDOT(struct Nodo* nodo, FILE* archivo) {
    if (nodo == NULL)
        return;

    fprintf(archivo, "    \"%p\" [label=\"%s\"];\n", (void*)nodo, nodo->valor);

    if (nodo->izq != NULL) {
        fprintf(archivo, "    \"%p\" -> \"%p\";\n", (void*)nodo, (void*)nodo->izq);
        generarDOT(nodo->izq, archivo);
    }

    if (nodo->der != NULL) {
        fprintf(archivo, "    \"%p\" -> \"%p\";\n", (void*)nodo, (void*)nodo->der);
        generarDOT(nodo->der, archivo);
    }
}

void generarArchivoDOT(struct Nodo* raiz) {
    FILE* archivo = fopen(NAME_DOT_FILE, "w");
    if (archivo == NULL) {
        printf("Error al abrir el archivo %s\n", NAME_DOT_FILE);
        return;
    }

    fprintf(archivo, "digraph Arbol {\n");
    fprintf(archivo, "    node [fontname=\"Arial\"];\n");

    if (raiz != NULL) {
        generarDOT(raiz, archivo);
    }

    fprintf(archivo, "}\n");

    fclose(archivo);
    printf("Archivo DOT generado: %s.\nCopialo y pegalo en http://www.webgraphviz.com/\n", NAME_DOT_FILE);
}