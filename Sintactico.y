// Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "y.tab.h"
int yystopparser=0;
FILE *yyin;
FILE *symbol_file;

int yyerror();
int yylex();

extern char* yytext;

void abrir_archivo() {
    symbol_file = fopen("simbolos.txt", "w");
    if (!symbol_file) {
        fprintf(stderr, "Error al abrir el archivo simbolos.txt\n");
        exit(1);
    }
}

void cerrar_archivo() {
    if (symbol_file) {
        fclose(symbol_file);
    }
}

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
          | linea_codigo while_sentence KA linea_codigo KC;

codigo:
          variables | 
          asignacion_variables {printf("Sentencia de asignacion => %s\n\n",yytext); } | 
          sentencia_aritmetica |
          COMENTARIO { printf("Comentario: %s\n\n",yytext); };

variables:  	   
          INIT_VAR KA declaracion KC {printf("FIN de declaracion de variables.\n\n");}
          ;

declaracion: 
          conj_var DOS_PUNTOS tipo_var 
          | declaracion conj_var DOS_PUNTOS tipo_var
	  ;   

conj_var:
         conj_var COMA ID {  fprintf(symbol_file, "%s\n", yytext);
            printf(",'%s'",yytext);}
         | ID {  fprintf(symbol_file, "%s\n", yytext);
            printf("Variable/s '%s'",yytext);}
         ;
         
tipo_var: 
       DECL_STRING {printf(": tipo String\n");}
       | DECL_FLOAT {printf(": tipo Float\n");}
       | DECL_INT {printf(": tipo Integer\n");} 
       ;


asignacion_variables:
      ID OP_AS constante_variable ;

constante_variable:
      CONST_INT | CONST_FLOAT | CONST_STRING ;

while_sentence:
      START_WHILE PA condicion_multiple PC {printf("Fin sentencia WHILE\n\n");} ;

condicion_multiple:
      condicion
      | COND_OP_NOT condicion
      | condicion_multiple COND_OP_AND condicion
      | condicion_multiple COND_OP_OR condicion
      | condicion_multiple COND_OP_AND COND_OP_NOT condicion
      | condicion_multiple COND_OP_OR COND_OP_NOT condicion ;

condicion:
      constante_variable comparador constante_variable
      | constante_variable comparador ID
      | ID comparador constante_variable
      | ID comparador ID ;

comparador:
      COMP_MAY | COMP_MEN | COMP_EQ | COMP_MAY_EQ | COMP_MEN_EQ | COMP_DIST ;

sentencia_aritmetica:
      ID OP_ARIT operacion_aritmetica ;

operacion_aritmetica:
      variable_aritmetica OP_SUM variable_aritmetica
      | variable_aritmetica OP_RES variable_aritmetica
      | variable_aritmetica OP_MUL variable_aritmetica
      | variable_aritmetica OP_DIV variable_aritmetica ;

variable_aritmetica:
      ID | CONST_FLOAT | CONST_INT ;

%%

int main(int argc, char *argv[])
{
    if((yyin = fopen(argv[1], "rt"))==NULL)
    {
        printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
       
    }
    else
    { 
        abrir_archivo();
        yyparse();
        cerrar_archivo();
    }
	fclose(yyin);
        return 0;
}

int yyerror(void)
     {
       printf("Error Sintactico\n");
	 exit (1);
     }