#include "lista.h"

#define minimo(X,Y) ((X) <= (Y) ? (X) : (Y))
#define CON_MSJ 1

void crear_lista(tLista *p){
    *p = NULL;
}

int listaVacia(const tLista *p){
    return *p == NULL;
}

int listaLlena(const tLista *p, unsigned cantBytes){
    tNodo   *aux = (tNodo *)malloc(sizeof(tNodo));
    void    *info = malloc(cantBytes);

    free(aux);
    free(info);
    return aux == NULL || info == NULL;
}

int vaciarLista(tLista *p){
    int cant = 0;
    while(*p){
        tNodo *aux = *p;

        cant++;
        *p = aux->sig;
        free(aux->info);
        free(aux);
    }
    return cant;
}

int ponerAlComienzo(tLista *p, const void *d, unsigned cantBytes){
    tNodo *nue;

    if((nue = (tNodo *)malloc(sizeof(tNodo))) == NULL ||
        (nue->info = malloc (cantBytes)) == NULL) {
        free(nue);
        return 0;
    }
    memcpy(nue->info, d, cantBytes);
    nue->tamInfo = cantBytes;
    nue->sig = *p;
    *p = nue;
    return 1;
}

int sacarPrimeroLista(tLista *p, void *d, unsigned cantBytes){
    tNodo *aux = *p;

    if(aux == NULL){
        return 0;
    }
    *p = aux->sig;
    memcpy(d, aux->info, minimo(cantBytes, aux->tamInfo));
    free(aux->info);
    free(aux);
    return 1;
}

int verPrimeroLista(const tLista *p, void *d, unsigned cantBytes){
    if(*p == NULL){
        return 0;
    }
    memcpy(d, (*p)->info, minimo(cantBytes, (*p)->tamInfo));
    return 1;
}

int ponerAlFinal(tLista *p, const void *d, unsigned cantBytes){
    tNodo *nue;

    while(*p){
        p = &(*p)->sig;
    }
    if((nue = (tNodo *)malloc(sizeof(tNodo))) == NULL ||
       (nue->info = malloc(cantBytes)) == NULL){
        free(nue);
        return 0;
    }
    memcpy(nue->info, d, cantBytes);
    nue->tamInfo = cantBytes;
    nue->sig = NULL;
    *p = nue;
    return 1;
}

int sacarUltimoLista(tLista *p, void *d, unsigned cantBytes){
    if(*p == NULL){
        return 0;
    }
    while((*p)->sig){
        p = &(*p)->sig;
    }
    memcpy(d, (*p)->info, minimo(cantBytes, (*p)->tamInfo));
    free((*p)->info);
    free(*p);
    *p = NULL;
    return 1;
}

int verUltimoLista(const tLista *p, void *d, unsigned cantBytes){
    if(*p == NULL){
        return 0;
    }
    while((*p)->sig){
        p = &(*p)->sig;
    }
    memcpy(d, (*p)->info, minimo(cantBytes, (*p)->tamInfo));
    return 1;
}

int vaciarListaYMostrar(tLista *p, void (*mostrar)(const void *, FILE *), FILE *fp){
    int cant = 0;
    while(*p){
        tNodo *aux = *p;

        cant++;
        *p = aux->sig;
        if(mostrar && fp)
            mostrar(aux->info, fp);
        free(aux->info);
        free(aux);
    }
    return cant;
}

int ponerAlFinalYEscribir(tLista *p, const void *d, unsigned cantBytes, FILE *fp,
                          int(* comparar)(const void *, const void *),
                          void(* escribir)(const void *, FILE *)) {
    tNodo *nue;

    while(*p) {
        if(comparar((*p)->info, d) == 0) {
            printf("clave dup");
            return CLA_DUP;
        }
        
        p = &(*p)->sig;
    }

    if((nue = (tNodo *)malloc(sizeof(tNodo))) == NULL ||
       (nue->info = malloc(cantBytes)) == NULL) {
        free(nue);
        return 0;
    }

    memcpy(nue->info, d, cantBytes);
    nue->tamInfo = cantBytes;
    nue->sig = NULL;
    *p = nue;

    escribir((*p)->info, fp);
    return 1;
}

void mostrarLista(tLista *p, void (*mostrar)(const void *d, FILE *fp)){
      while(*p){
            mostrar((*p)->info, stdout);
            p = &(*p)->sig;
      }
}