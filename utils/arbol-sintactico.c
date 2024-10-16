#include <stdio.h>

#define NAME_DOT_FILE "outputs/arbol-dot.txt"

struct Nodo {
    char *valor;
    struct Nodo *izq, *der;
};

struct Nodo *crear_nodo(char *operador, struct Nodo *izq, struct Nodo *der);
struct Nodo *crear_hoja(char *valor);

void imprimir_inorden(struct Nodo* nodo);
void imprimir_preorden(struct Nodo* nodo);
void imprimir_postorden(struct Nodo* nodo);
void imprimir_arbol(struct Nodo* nodo, int nivel);
void liberar_arbol(struct Nodo* nodo);

void generar_DOT(struct Nodo* nodo, FILE* archivo);
void generar_archivo_DOT(struct Nodo* raiz);

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

void imprimir_inorden(struct Nodo* nodo) {
    if (nodo == NULL) return;
    
    imprimir_inorden(nodo->izq);
    write_intermediate_code(nodo->valor);
    //printf("%s ", nodo->valor);
    imprimir_inorden(nodo->der);
}

void imprimir_preorden(struct Nodo* nodo) {
    if (nodo == NULL) return;
    
    //printf("%s ", nodo->valor);
    write_intermediate_code(nodo->valor);
    imprimir_preorden(nodo->izq);
    imprimir_preorden(nodo->der);
}

void imprimir_postorden(struct Nodo* nodo) {
    if (nodo == NULL) return;
    
    imprimir_postorden(nodo->izq);
    imprimir_postorden(nodo->der);
    //printf("%s ", nodo->valor);
    write_intermediate_code(nodo->valor);
}

void imprimir_arbol(struct Nodo* nodo, int nivel) {
    if (nodo == NULL) return;

    imprimir_arbol(nodo->der, nivel + 1);
    
    for (int i = 0; i < nivel; i++) {
        printf("   ");
    }
    printf("%s\n", nodo->valor);

    imprimir_arbol(nodo->izq, nivel + 1);
}

void liberar_arbol(struct Nodo* nodo) {
    if (nodo == NULL) return;

    liberar_arbol(nodo->izq);
    liberar_arbol(nodo->der);
    
    free(nodo->valor); 
    free(nodo);
}

char* escapar_DOT(const char* str) {
    size_t len = strlen(str);
    size_t new_len = len; // Almacenará la longitud del nuevo string

    // Contar cuántos caracteres especiales hay
    for (size_t i = 0; i < len; i++) {
        if (str[i] == '"' || str[i] == '\\' || str[i] == '{' || str[i] == '}' || str[i] == '[' || str[i] == ']' || str[i] == '\n') {
            new_len++; // Aumentar el tamaño para el carácter de escape
        }
    }

    char* nuevo_str = (char*)malloc(new_len + 1); // +1 para el terminador nulo
    if (nuevo_str == NULL) {
        perror("No se pudo alocar memoria");
        exit(1);
    }

    size_t j = 0;
    for (size_t i = 0; i < len; i++) {
        if (str[i] == '"' || str[i] == '\\' || str[i] == '{' || str[i] == '}' || str[i] == '[' || str[i] == ']' || str[i] == '\n') {
            nuevo_str[j++] = '\\'; // Agregar el carácter de escape
        }
        nuevo_str[j++] = str[i]; // Agregar el carácter original
    }

    nuevo_str[j] = '\0'; // Terminador nulo
    return nuevo_str;
}

void generar_DOT(struct Nodo* nodo, FILE* archivo) {
    if (nodo == NULL)
        return;

    char* valor_escapado = escapar_DOT(nodo->valor);
    fprintf(archivo, "    \"%p\" [label=\"%s\"];\n", (void*)nodo, valor_escapado);
    free(valor_escapado);

    if (nodo->izq != NULL) {
        fprintf(archivo, "    \"%p\" -> \"%p\";\n", (void*)nodo, (void*)nodo->izq);
        generar_DOT(nodo->izq, archivo);
    }

    if (nodo->der != NULL) {
        fprintf(archivo, "    \"%p\" -> \"%p\";\n", (void*)nodo, (void*)nodo->der);
        generar_DOT(nodo->der, archivo);
    }
}

void generar_archivo_DOT(struct Nodo* raiz) {
    FILE* archivo = fopen(NAME_DOT_FILE, "w");
    if (archivo == NULL) {
        printf("Error al abrir el archivo %s\n", NAME_DOT_FILE);
        return;
    }

    fprintf(archivo, "digraph Arbol {\n");
    fprintf(archivo, "    node [fontname=\"Arial\"];\n");

    if (raiz != NULL) {
        generar_DOT(raiz, archivo);
    }

    fprintf(archivo, "}\n");

    fclose(archivo);
    printf("Archivo DOT generado: %s.\nCopialo y pegalo en http://www.webgraphviz.com/\n", NAME_DOT_FILE);
}