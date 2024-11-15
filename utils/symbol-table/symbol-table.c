#include "symbol-table.h"

int open_symbol_table(FILE *fp)
{
    fp = fopen(NAME_SYMBOL_TABLE_FILE, "wt");
    if (!fp)
    {
        fprintf(stderr, "Error al abrir el archivo %s\n", NAME_SYMBOL_TABLE_FILE);
        return 1;
    }
    // Construye el formato dinámico para la cabecera
    char format[100];
    snprintf(format, sizeof(format), "%%-%ds%%-%ds%%-%ds%%-%ds\n",
             MAX_LENGTH_NOMBRE - 1, MAX_LENGTH_TIPO_DATO - 1,
             MAX_LENGTH_VALOR - 1, MAX_LENGTH_LONGITUD - 1);

    fprintf(fp, format, "NOMBRE", "TIPO_DATO", "VALOR", "LONGITUD");
    fclose(fp);

    return 0;
}

int close_symbol_table(FILE *fp)
{
    if (fp)
    {
        fclose(fp);
    }
    return 0;
}

int write_symbol_table(Simbolo simbolo, FILE *fp)
{
    char buffer[256];
    char nombre_archivo[MAX_LENGTH_NOMBRE];
    FILE *temp_file;

    // Verificar duplicados
    temp_file = fopen(NAME_SYMBOL_TABLE_FILE, "rt");
    if (!temp_file)
    {
        printf("Error al abrir el archivo para leer %s\n", NAME_SYMBOL_TABLE_FILE);
        return 1;
    }

    while (fgets(buffer, sizeof(buffer), temp_file))
    {
        sscanf(buffer, "%s", nombre_archivo);
        if (strcmp(nombre_archivo, simbolo.nombre) == 0)
        {
            fclose(temp_file);
            printf("Simbolo con el nombre '%s' ya existe en la tabla de simbolos\n", simbolo.nombre);
            return 1;
        }
    }
    fclose(temp_file);

    // Construir el formato dinámico para escribir los datos
    fp = fopen(NAME_SYMBOL_TABLE_FILE, "at");
    if (!fp)
    {
        printf("Error al abrir el archivo para escribir %s\n", NAME_SYMBOL_TABLE_FILE);
        return 1;
    }

    char format[100];
    snprintf(format, sizeof(format), "%%-%ds%%-%ds%%-%ds%%-%dd\n",
             MAX_LENGTH_NOMBRE - 1, MAX_LENGTH_TIPO_DATO - 1,
             MAX_LENGTH_VALOR - 1, MAX_LENGTH_LONGITUD - 1);

    fprintf(fp, format, simbolo.nombre, simbolo.tipo_dato, simbolo.valor, simbolo.longitud != 0 ? simbolo.longitud : 0);

    fclose(fp);
    return 0;
}

const char *normalizarTipo(const char *tipo)
{
    if (strcmp(tipo, "CTE_INTEGER") == 0 || strcmp(tipo, "Int") == 0)
        return "INT";
    else if (strcmp(tipo, "CTE_FLOAT") == 0 || strcmp(tipo, "Float") == 0)
        return "FLOAT";
    else if (strcmp(tipo, "CTE_STRING") == 0 || strcmp(tipo, "String") == 0)
        return "STRING";
    return "UNKNOWN";
}

int compararTipoDato(const Simbolo *simbolo_1, const Simbolo *simbolo_2)
{
    return strcmp(normalizarTipo(simbolo_1->tipo_dato), normalizarTipo(simbolo_2->tipo_dato));
}

void mostrarSimbolo(const void *simb, FILE *fp)
{
    char format[100];

    snprintf(format, sizeof(format), "%%-%ds%%-%ds%%-%ds%%-%dd\n",
             MAX_LENGTH_NOMBRE - 1, MAX_LENGTH_TIPO_DATO - 1,
             MAX_LENGTH_VALOR - 1, MAX_LENGTH_LONGITUD - 1);
    fprintf(fp, format,
            ((const Simbolo *)simb)->nombre,
            ((const Simbolo *)simb)->tipo_dato,
            ((const Simbolo *)simb)->valor,
            ((const Simbolo *)simb)->longitud);
}

int compararNombre(const void *d1, const void *d2)
{
    return strcmp(((const Simbolo *)d1)->nombre,
                  ((const Simbolo *)d2)->nombre);
}

void copiarTipoDato(void *tipo_dato, const void *simbolo)
{
    strcpy(tipo_dato, ((Simbolo *)simbolo)->tipo_dato);
}