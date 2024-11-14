#include <stdio.h>
#include "arbol-sintactico.c"
#include "pila.c"
#include <string.h>

#define PATH_TEMPLATE "asm/template.asm"
#define PATH_OUT_ASSEMBLY "outputs/final.asm"

FILE *archivo;
int cantidad_etiqueta_if = 1;
int cantidad_etiqueta_while = 1;
Pila *pila_ifs = NULL;
Pila *pila_whiles = NULL;
bool boolComparacionOrEncontrada = false;
bool boolComparacionIf = true;

void generar_archivo_assembler(struct Nodo* raiz);
char*escribir_nodo_arbol(struct Nodo* nodo);
void copiar_template_archivo();
void escribir_valor_assembler(char*variable);
void cargar_valor_copro_en_variable(char*variable);
void escribir_instruccion(char*variable);
int esUnComparador(char*valorNodo);
void escribirComparador(char*valorNodo);
void tratamientoIfElse(struct Nodo*nodo);

void copiar_template_archivo(){
    FILE *archivoOrigen, *archivoDestino;
    char buffer[1024];
    size_t bytesLeidos;

    // Abrir el archivo origen en modo lectura binaria
    archivoOrigen = fopen(PATH_TEMPLATE, "rb");
    if (archivoOrigen == NULL) {
        perror("Error al abrir el archivo origen");
        exit(EXIT_FAILURE);
    }

    // Abrir o crear el archivo destino en modo escritura binaria
    archivoDestino = fopen(PATH_OUT_ASSEMBLY, "wb");
    if (archivoDestino == NULL) {
        perror("Error al abrir o crear el archivo destino");
        fclose(archivoOrigen);
        exit(EXIT_FAILURE);
    }

    while ((bytesLeidos = fread(buffer, 1, sizeof(buffer), archivoOrigen)) > 0) {
        fwrite(buffer, 1, bytesLeidos, archivoDestino);
    }

    // Cerrar ambos archivos
    fclose(archivoOrigen);
    fclose(archivoDestino);
}

void generar_archivo_assembler(struct Nodo* raiz) {
    archivo = fopen(PATH_OUT_ASSEMBLY, "w");
    if (archivo == NULL) {
        printf("Error al abrir el archivo %s\n", NAME_DOT_FILE);
        return;
    }

    pila_ifs = crear_pila();
    pila_whiles = crear_pila();

    if (raiz != NULL) {
        fprintf(archivo,"include numbers.asm\ninclude macros2.asm\n\n.MODEL SMALL\n.386\n.STACK 200h\n\n.DATA\n");
        //Funcion para escribir .DATA
        fprintf(archivo,"\n.CODE\nSTART:\n\n\tMOV AX, @DATA\n\tMOV DS, AX\n\n");
        escribir_nodo_arbol(raiz);
        fprintf(archivo,"\n\tMOV AX, 4C00h\n\tINT 21h\n\nEND START");
    }

    liberar_pila(pila_ifs);
    liberar_pila(pila_whiles);
    fclose(archivo);
    
}


char*escribir_nodo_arbol(struct Nodo* nodo){
    
    if(nodo == NULL){
        return NULL;
    }

    if(nodo->izq == NULL && nodo->der == NULL){
        return nodo->valor;
    }

    if(strcmp(nodo->valor,"-END-") == 0){
        return nodo->valor;
    }

    if(strcmp(nodo->valor,"-IF-") == 0) {
        boolComparacionIf = true;
        fprintf(archivo,"ET_START_IF_%d:\n",cantidad_etiqueta_if);
        //Apilo numero
        int* punteroNumero = (int*)malloc(sizeof(int));
        *punteroNumero = cantidad_etiqueta_if;
        apilar(pila_ifs,punteroNumero);
        cantidad_etiqueta_if++;
    } else if(strcmp(nodo->valor,"-WHILE-") == 0) {
        boolComparacionIf = false;
        printf("while encontrado. Numero while %d\n",cantidad_etiqueta_while);
        fprintf(archivo,"ET_START_WHILE_%d:\n",cantidad_etiqueta_while);
        //Apilo numero
        int* punteroNumero = (int*)malloc(sizeof(int));
        *punteroNumero = cantidad_etiqueta_while;
        apilar(pila_whiles,punteroNumero);
        cantidad_etiqueta_while++;
    } else if(strcmp(nodo->valor,"-CUERPO IF/ELSE-") == 0) {
        tratamientoIfElse(nodo);
        nodo->der->valor = strdup("-END-"); //Para que despues no procese mas el subarbol derecho
        nodo->izq->valor = strdup("-END-"); //Para que despues no procese mas el subarbol izquierdo
    } else if(strcmp(nodo->valor,"OR") == 0) {
        
        boolComparacionOrEncontrada = true;
    }

    char*valorHojaIzq = escribir_nodo_arbol(nodo->izq);
    char*valorHojaDer = escribir_nodo_arbol(nodo->der);
    char*valorNodo = nodo->valor;
    //Switch para todos los tipos de nodos que puede aparecer en un arbol
    
    if(strcmp(valorNodo,":=") == 0) { //Operador de asignacion
        
        escribir_valor_assembler(valorHojaDer);
        cargar_valor_copro_en_variable(valorHojaIzq);
        nodo->valor = strdup("-SENTENCIA-");

    } else if(strcmp(valorNodo,"=:") == 0) {
        cargar_valor_copro_en_variable(valorHojaIzq);
    } else if(strcmp(valorNodo,"*") == 0) {

        if(strcmp(valorHojaIzq,"-OPERACION-") != 0) {
            escribir_valor_assembler(valorHojaIzq);
        }
        if(strcmp(valorHojaDer,"-OPERACION-") != 0) {
            escribir_valor_assembler(valorHojaDer);
        }
        escribir_instruccion("FMUL");
        valorNodo = strdup("-OPERACION-");
    } else if(strcmp(valorNodo,"/") == 0) {
        if(strcmp(valorHojaIzq,"-OPERACION-") != 0) {
            escribir_valor_assembler(valorHojaIzq);
        }
        if(strcmp(valorHojaDer,"-OPERACION-") != 0) {
            escribir_valor_assembler(valorHojaDer);
        }
        escribir_instruccion("FDIV");
        valorNodo = strdup("-OPERACION-");
    } else if(strcmp(valorNodo,"+") == 0) {
        if(strcmp(valorHojaIzq,"-OPERACION-") != 0) {
            escribir_valor_assembler(valorHojaIzq);
        }
        if(strcmp(valorHojaDer,"-OPERACION-") != 0) {
            escribir_valor_assembler(valorHojaDer);
        }
        escribir_instruccion("FADD");
        valorNodo = strdup("-OPERACION-");
    } else if(strcmp(valorNodo,"-") == 0) {
        if(strcmp(valorHojaIzq,"-OPERACION-") != 0) {
            escribir_valor_assembler(valorHojaIzq);
        }
        if(strcmp(valorHojaDer,"-OPERACION-") != 0) {
            escribir_valor_assembler(valorHojaDer);
        }
        escribir_instruccion("FSUB");
        valorNodo = strdup("-OPERACION-");
    } else if(strcmp(valorNodo,"-LECTURA-") == 0) {
        fprintf(archivo,"getString %s\n",valorHojaDer);
    } else if(strcmp(valorNodo,"-ESCRITURA-") == 0) {
        fprintf(archivo,"displayString %s\n",valorHojaDer);
    } else if(strcmp(valorNodo,"-GET_PENULTIMATE_POSITION-") == 0) {
        valorNodo = strdup("@res");
    } else if(esUnComparador(valorNodo) == 0) {
        escribir_valor_assembler(valorHojaIzq);
        escribir_valor_assembler(valorHojaDer);
        escribir_instruccion("FXCH");
        escribir_instruccion("FCOM");
        escribir_instruccion("FSTSW ax");
        escribir_instruccion("SAHF");
        escribirComparador(valorNodo);
        
    } else if(strcmp(valorNodo,"-IF-") == 0) { 
        printf("IF finalizado. Numero while %d\n",cantidad_etiqueta_while);
        int* valorDesapilado = (int*)desapilar(pila_ifs);

        fprintf(archivo,"ET_END_IF_%d:\n",*valorDesapilado);
    } else if(strcmp(valorNodo,"-WHILE-") == 0) {
        printf("while finalizado. Numero while %d\n",cantidad_etiqueta_while);
        int* valorDesapilado = (int*)desapilar(pila_whiles);
        fprintf(archivo,"\tJMP ET_START_WHILE_%d\n",*valorDesapilado);
        fprintf(archivo,"ET_END_WHILE_%d:\n",*valorDesapilado);
    }
    
    return valorNodo;

}

int esUnComparador(char*valorNodo){
    int res = 0;

    if(strcmp(valorNodo,"==") != 0 && strcmp(valorNodo,"<>") != 0 &&
    strcmp(valorNodo,">") != 0 && strcmp(valorNodo,"<") != 0 &&
    strcmp(valorNodo,">=") != 0 && strcmp(valorNodo,"<=") != 0) {
        res = -1;
    }

    return res;
}

void tratamientoIfElse(struct Nodo*nodo){

    escribir_nodo_arbol(nodo->izq); //Escribo todo lo del lado izquierdo
    //Termino el lado del THEN, escribo JMP y arranco la etiqueta del else
    fprintf(archivo,"\tJMP ET_END_IF_%d\n",cantidad_etiqueta_if);
    int* valorDesapilado = (int*)desapilar(pila_ifs);
    printf("desapilado\n");
    fprintf(archivo,"ET_END_IF_%d:\n",*valorDesapilado);
    //Apilo nueva etiqueta
    int* punteroNumero = (int*)malloc(sizeof(int));
    *punteroNumero = cantidad_etiqueta_if;
    apilar(pila_ifs,punteroNumero);
    cantidad_etiqueta_if++;
    escribir_nodo_arbol(nodo->der); //Escribo todo lo del lado derecho
    //Lo que hago con el nodo, lo hago fuera de esta funcion
}

void escribirComparador(char*valorNodo){
    
    int*nroEtiqueta;
    char finEtiqueta[20];
    if(boolComparacionIf) {
        nroEtiqueta = (int*)verTope(pila_ifs);
        strcpy(finEtiqueta,"ET_END_IF_");
    } else {
        nroEtiqueta = (int*)verTope(pila_whiles);
        strcpy(finEtiqueta,"ET_END_WHILE_");
    }

    if(boolComparacionOrEncontrada){
        if(strcmp(valorNodo,"==") == 0) {
        fprintf(archivo,"\tJE %s%d\n",finEtiqueta,*nroEtiqueta);
        } else if(strcmp(valorNodo,"<>") == 0) {
            fprintf(archivo,"\tJNE %s%d\n",finEtiqueta,*nroEtiqueta);
        } else if(strcmp(valorNodo,">") == 0) {
            fprintf(archivo,"\tJA %s%d\n",finEtiqueta,*nroEtiqueta);
        } else if(strcmp(valorNodo,"<") == 0) {
            fprintf(archivo,"\tJB %s%d\n",finEtiqueta,*nroEtiqueta);
        } else if(strcmp(valorNodo,">=") == 0) {
            fprintf(archivo,"\tJAE %s%d\n",finEtiqueta,*nroEtiqueta);
        } else if(strcmp(valorNodo,"<=") == 0) {
            fprintf(archivo,"\tJNA %s%d\n",finEtiqueta,*nroEtiqueta);
        }

        boolComparacionOrEncontrada = false;
    } else {
        if(strcmp(valorNodo,"==") == 0) {
        fprintf(archivo,"\tJNE %s%d\n",finEtiqueta,*nroEtiqueta);
        } else if(strcmp(valorNodo,"<>") == 0) {
            fprintf(archivo,"\tJE %s%d\n",finEtiqueta,*nroEtiqueta);
        } else if(strcmp(valorNodo,">") == 0) {
            fprintf(archivo,"\tJNA %s%d\n",finEtiqueta,*nroEtiqueta);
        } else if(strcmp(valorNodo,"<") == 0) {
            fprintf(archivo,"\tJAE %s%d\n",finEtiqueta,*nroEtiqueta);
        } else if(strcmp(valorNodo,">=") == 0) {
            fprintf(archivo,"\tJB %s%d\n",finEtiqueta,*nroEtiqueta);
        } else if(strcmp(valorNodo,"<=") == 0) {
            fprintf(archivo,"\tJA %s%d\n",finEtiqueta,*nroEtiqueta);
        }
    }
     
}

void escribir_instruccion(char*variable){
    fprintf(archivo,"\t%s\n",variable);
}

void escribir_valor_assembler(char*variable){
    fprintf(archivo,"\tFLD %s\n",variable); //Logica para decidir cuando usar FLD o FILD
}

void cargar_valor_copro_en_variable(char*variable) {
    fprintf(archivo,"\tFSTP %s\n",variable); //Logica para decidir cuando usar FSTP o FISTP
}