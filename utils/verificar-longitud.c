#include <string.h>

#define MAX_LENGTH_ID 30
#define MAX_LENGTH_STRING 40
#define MAX_LENGTH_INT 16
#define MAX_LENGTH_FLOAT 32

void verificar_longitud(const char*, int);

void verificar_longitud(const char* token, int max) {
      if (strlen(token) > max) {
            printf("Error: %s excede la longitud maxima de %d caracteres.\n", token, max);
            exit(1);
      }
}