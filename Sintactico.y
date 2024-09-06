//Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
#include "symbol-table.c"

int yystopparser=0;
FILE *yyin;

int yyerror();
int yylex();

extern char* yytext;

%}

%token CONST_INT
%token CONST_STRING
%token INIT_VAR
%token DECL_STRING
%token DECL_INT
%token DECL_FLOAT
%token KC
%token ID
%token OP_AS
%token OP_SUM
%token OP_MUL
%token OP_RES
%token OP_DIV
%token PA
%token PC
%token OP_ARIT
%token KA
%token CORCH_A
%token CORCH_C
%token DOS_PUNTOS
%token COMA
%token COMILLA
%token BLANCOS
%token COMENTARIO
%token COMP_MAY
%token COMP_MEN
%token COMP_MAY_EQ
%token COMP_MEN_EQ
%token COMP_EQ
%token COMP_DIST

%token START_WHILE
%token START_IF
%token START_ELSE
%token START_LECTURA
%token START_ESCRITURA

%token CONST_FLOAT

%token COND_OP_NOT
%token COND_OP_AND
%token COND_OP_OR

%token CONST_BINARY
%token FUNCT_BC
%token FUNCT_GPP


%%

linea_codigo:
          codigo 
          | linea_codigo codigo
          ;

codigo:
          variables | 
          asignacion_variables {printf("\n"); } | 
          sentencia_aritmetica |
          while_sentence KA linea_codigo KC {printf("FIN de ciclo WHILE.\n\n"); } |
          if_sentence KA linea_codigo KC {printf("FIN de sentencia IF.\n\n"); }|
          KC START_ELSE KA |
          escritura_sentence |
          lectura_sentence
          ;

variables:  	   
          INIT_VAR KA declaracion KC {printf("FIN de declaracion de variables.\n\n");}
          ;

declaracion: 
          conj_var DOS_PUNTOS tipo_var 
          | declaracion conj_var DOS_PUNTOS tipo_var
	  ;   

conj_var:
      conj_var COMA ID {
            Simbolo simbolo = {"", "", "---", 0};
            strncpy(simbolo.nombre, yytext, MAX_LENGTH - 1);
            write_symbol_table(simbolo);
            printf(",%s",yytext);
      }
      | ID {
            Simbolo simbolo = {"", "", "---", 0};
            strncpy(simbolo.nombre, yytext, MAX_LENGTH - 1);
            write_symbol_table(simbolo);
            printf("%s",yytext);
      } ;
         
tipo_var: 
       DECL_STRING {printf(": variable/s de tipo String.\n");}
       | DECL_FLOAT {printf(": variable/s de tipo Float.\n");}
       | DECL_INT {printf(": variable/s de tipo Integer.\n");} 
       ;


asignacion_variables:
      ID OP_AS constante_variable {printf("ID se le asigna constante: %s",yytext);};

constante_variable:
      CONST_INT {
            Simbolo simbolo = {"", "", "", sizeof(int)};
            snprintf(simbolo.nombre, MAX_LENGTH, "_%s", yytext);
            strncpy(simbolo.valor, yytext, MAX_LENGTH - 1);
            write_symbol_table(simbolo);
      }
      | CONST_FLOAT {
            Simbolo simbolo = {"", "", "", sizeof(float)};
            snprintf(simbolo.nombre, MAX_LENGTH, "_%s", yytext);
            strncpy(simbolo.valor, yytext, MAX_LENGTH - 1);
            snprintf(simbolo.valor, MAX_LENGTH, "%.2f", strtof(simbolo.valor, NULL));
            write_symbol_table(simbolo);
      }
      | CONST_STRING {
            int len = ((int) strlen(yytext)) - 2;
            Simbolo simbolo = {"", "", "", len};
            snprintf(simbolo.nombre, MAX_LENGTH, "_%s", yytext);
            strncpy(simbolo.valor, yytext, MAX_LENGTH - 1);
            snprintf(simbolo.nombre, MAX_LENGTH, "_%.*s", len, yytext + 1);
            snprintf(simbolo.valor, MAX_LENGTH, "%.*s", len, yytext + 1);
            write_symbol_table(simbolo);
      }
      ;

while_sentence:
      START_WHILE PA condicion_multiple PC {printf(" entonces hace el siguiente codigo:\n\n"); };

if_sentence:
      START_IF PA condicion_multiple PC {printf(" entonces hace el siguiente codigo:\n\n"); };

condicion_multiple:
      valores_admitidos_condicion comparador valores_admitidos_condicion
      | COND_OP_NOT valores_admitidos_condicion comparador valores_admitidos_condicion
      | condicion_multiple COND_OP_AND condicion_multiple
      | condicion_multiple COND_OP_OR condicion_multiple
      ;

comparador:
      COMP_MAY {printf(" es mayor a ");} | COMP_MEN {printf(" es menor a ");}| COMP_EQ {printf(" es igual a ");} | COMP_MAY_EQ {printf(" es mayor o igual a ");} | COMP_MEN_EQ {printf(" es menor o igual a ");} | COMP_DIST {printf(" es distinto a ");};

valores_admitidos_condicion:
      ID {printf("ID");}
      | constante_variable {printf("CONSTANTE");}

sentencia_aritmetica:
      ID OP_ARIT expresion 
	;
 
expresion:
         termino {printf("    Termino es Expresion\n");}
	 |expresion OP_SUM termino {printf("    Expresion+Termino es Expresion\n");}
	 |expresion OP_RES termino {printf("    Expresion-Termino es Expresion\n");}
	 ;
 
termino: 
       factor {printf("    Factor es Termino\n");}
       |termino OP_MUL factor {printf("     Termino*Factor es Termino\n");}
       |termino OP_DIV factor {printf("     Termino/Factor es Termino\n");}
       ;
 
factor: 
      ID {printf("    ID es Factor \n");}
      | variable_aritmetica {printf("    CTE es Factor\n");}
	| PA expresion PC {printf("    Expresion entre parentesis es Factor\n");}
     	;

variable_aritmetica:
      ID | CONST_FLOAT | CONST_INT ;

lectura_sentence:
      START_LECTURA PA ID PC {printf("Comienzo de lectura. Guardar resultado en ID.\n");}
      ;

escritura_sentence:
      START_ESCRITURA PA CONST_STRING PC  {printf("Comienzo de escritura de constante STRING.\n");}
      | START_ESCRITURA PA ID PC {printf("Comienzo de escritura de valor de ID.\n");}
      ;


%%

int main(int argc, char *argv[])
{
      if((yyin = fopen(argv[1], "rt")) == NULL)
      {
            printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
            return 1;
      }
      open_symbol_table_file();
      yyparse();
      close_symbol_table_file();
	fclose(yyin);

      return 0;
}

int yyerror(void)
{
      printf("Error Sintactico\n");
      exit (1);
}