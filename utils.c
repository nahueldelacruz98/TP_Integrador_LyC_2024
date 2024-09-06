#define MAX_LENGTH_ID 30
#define MAX_LENGTH_STRING 40

void verificar_longitud(const char *, int);

void verificar_longitud(const char *id, int max) {
      if (strlen(id) > max) {
            printf("Error: %s excede la longitud maxima de %d caracteres.\n", id, max);
            exit(1);
      }
}