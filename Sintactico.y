//Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>  // Include this header for boolean variables support
#include "y.tab.h"

#include "utils/intermediate-code.c"
#include "utils/arbol-sintactico.c"
#include "utils/symbol-table.c"
#include "utils/pila.c"

int yystopparser=0;
FILE *yyin;
FILE *or;

int yyerror();
int yylex();

extern char* yytext;

Pila *pila = NULL;
Pila *pila_cond = NULL;
Pila *pila_sent_aritmetica = NULL;
bool boolNegativeCondition = false;

char* aux = NULL;
char* res = NULL;

struct Nodo *linea_cod_ptr = NULL;
struct Nodo *codigo_ptr = NULL;
struct Nodo *init_var = NULL;
struct Nodo *asig_var_ptr = NULL;
struct Nodo *const_ptr = NULL;
struct Nodo *cond_mult_ptr = NULL;
struct Nodo *cond_ptr = NULL;
struct Nodo *val_adm_cond_ptr = NULL;
struct Nodo *comp_ptr = NULL;
struct Nodo *while_sent_ptr = NULL;
struct Nodo *if_sent_ptr = NULL;
struct Nodo *cond_op_ptr = NULL;

struct Nodo *sent_arit_ptr = NULL;
struct Nodo *expr_ptr = NULL;
struct Nodo *term_ptr = NULL;
struct Nodo *fact_ptr = NULL;
struct Nodo *var_arit_ptr = NULL;
struct Nodo *var_ptr = NULL;
struct Nodo *decl_ptr = NULL;
struct Nodo *conj_var_ptr = NULL;
struct Nodo *tipo_var_ptr = NULL;
struct Nodo *get_pen_pos_ptr = NULL;
struct Nodo *vec_num_ptr = NULL;
struct Nodo *list_arit_ptr = NULL;
struct Nodo *bin_count_ptr = NULL;
struct Nodo *bin_count_vec_num_ptr = NULL;
struct Nodo *bin_count_list_arit_ptr = NULL;
struct Nodo *lectura_ptr = NULL;
struct Nodo *escritura_ptr = NULL;

%}

%union YYSTYPE {
    int intval;
    float floatval;
    char *strval;
}

%token <strval> ID
%token <strval> CONST_INT
%token <strval> CONST_FLOAT
%token <strval> CONST_STRING
%token <strval> CONST_BINARY
%token <strval> DECL_STRING
%token <strval> DECL_INT
%token <strval> DECL_FLOAT
%token <strval> OP_AS
%token <strval> OP_SUM
%token <strval> OP_MUL
%token <strval> OP_RES
%token <strval> OP_DIV
%token <strval> OP_ARIT
%token <strval> PAREN_A
%token <strval> PAREN_C
%token <strval> CORCH_A
%token <strval> CORCH_C
%token <strval> LLAVE_A
%token <strval> LLAVE_C
%token <strval> DOS_PUNTOS
%token <strval> COMA
%token <strval> COMILLA
%token <strval> BLANCOS
%token <strval> COMENTARIO
%token <strval> COMP_MAY
%token <strval> COMP_MEN
%token <strval> COMP_MAY_EQ
%token <strval> COMP_MEN_EQ
%token <strval> COMP_EQ
%token <strval> COMP_DIST

%token <strval> START_WHILE
%token <strval> START_IF
%token <strval> START_ELSE
%token <strval> START_LECTURA
%token <strval> START_ESCRITURA

%token <strval> COND_OP_NOT
%token <strval> COND_OP_AND
%token <strval> COND_OP_OR

%token <strval> INIT_VAR
%token <strval> FUNCT_BC
%token <strval> FUNCT_GPP

%%

start:
      linea_codigo {
            imprimirInorden(linea_cod_ptr);
            generarArchivoDOT(linea_cod_ptr);
      }

linea_codigo:
      codigo {
            linea_cod_ptr = codigo_ptr;
            apilar(pila, linea_cod_ptr);
            mostrar_pila(pila);
            fprintf(or, "linea_codigo_1\n");
      }
      | linea_codigo codigo {
            linea_cod_ptr = crear_nodo("-LINEA CODIGO-", desapilar(pila), codigo_ptr);
            apilar(pila, linea_cod_ptr);
            mostrar_pila(pila);
            fprintf(or, "linea_codigo_2\n");
      }
      ;

codigo:
      inicializacion_variables {
            codigo_ptr = init_var;
            fprintf(or, "codigo_1\n");
      }
      | asignacion_variables {
            codigo_ptr = asig_var_ptr; 
            printf("\n");
            fprintf(or, "codigo_2\n");
      }
      | sentencia_aritmetica {
            codigo_ptr = sent_arit_ptr;
            fprintf(or, "codigo_3\n");
      }
      | while_sentence {
            codigo_ptr = while_sent_ptr; 
            printf("FIN de ciclo WHILE.\n\n");
            fprintf(or, "codigo_4\n");
      }
      | if_sentence {
            codigo_ptr = if_sent_ptr;
            printf("FIN de sentencia IF.\n\n");
            fprintf(or, "codigo_5\n");
      }
      | LLAVE_C START_ELSE LLAVE_A {printf("\nInicio sentencia IF ELSE.\n\n"); }
      | escritura_sentence { codigo_ptr = escritura_ptr; }
      | lectura_sentence { codigo_ptr = lectura_ptr; }
      | get_penultimate_position
      | binary_count
      ;

inicializacion_variables:
      INIT_VAR LLAVE_A declaracion LLAVE_C {
            printf("FIN de declaracion de variables.\n\n");
            init_var = crear_nodo("init", NULL, decl_ptr);
      }
      ;

declaracion:
      conjunto_variables DOS_PUNTOS tipo_variables {
            decl_ptr = crear_nodo(":", conj_var_ptr, tipo_var_ptr);
      }
      | declaracion conjunto_variables DOS_PUNTOS tipo_variables {
            struct Nodo* aux_ptr;
            aux_ptr = crear_nodo(":", conj_var_ptr, tipo_var_ptr);
            decl_ptr = crear_nodo("-DECLARACION-", aux_ptr, decl_ptr);
      }
	;

conjunto_variables:
      conjunto_variables COMA ID {
            Simbolo simbolo = {"", "", "-", 0};
            strncpy(simbolo.nombre, yytext, MAX_LENGTH - 1);
            write_symbol_table(simbolo);
            printf(",%s",yytext);
            
            conj_var_ptr = crear_nodo(",", conj_var_ptr, crear_hoja($3));
      }
      | ID {
            Simbolo simbolo = {"", "", "-", 0};
            strncpy(simbolo.nombre, yytext, MAX_LENGTH - 1);
            write_symbol_table(simbolo);
            printf("%s",yytext);

            conj_var_ptr = crear_hoja($1);
      }
      ;
         
tipo_variables:
      DECL_STRING {
            printf(": variable/s de tipo String.\n"); 
            tipo_var_ptr = crear_hoja("String");
      }
      | DECL_FLOAT {
            printf(": variable/s de tipo Float.\n"); 
            tipo_var_ptr = crear_hoja("Float");
      }
      | DECL_INT {
            printf(": variable/s de tipo Integer.\n"); 
            tipo_var_ptr = crear_hoja("Int");
      }
      ;

asignacion_variables:
      ID OP_AS constante {
            asig_var_ptr = crear_nodo(":=", crear_hoja($1), const_ptr);
            fprintf(or, "asignacion_variables_1\n");
            printf("%s se le asigna constante: %s", $1, yytext);
      }
      | ID OP_AS get_penultimate_position {
            asig_var_ptr = crear_nodo(":=", crear_hoja($1), get_pen_pos_ptr);
            fprintf(or, "asignacion_variables_2\n");
      }
      | ID OP_AS binary_count {
            asig_var_ptr = crear_nodo(":=", crear_hoja($1), bin_count_ptr);
            fprintf(or, "asignacion_variables_3\n");
      }
      ;

constante:
      CONST_INT {
            Simbolo simbolo = {"", "CTE_INTEGER", "", 0};
            snprintf(simbolo.nombre, MAX_LENGTH, "_%s", yytext);
            strncpy(simbolo.valor, yytext, MAX_LENGTH - 1);
            write_symbol_table(simbolo);

            const_ptr = crear_hoja($1);
            fprintf(or, "constante_1\n");
      }
      | CONST_FLOAT {
            Simbolo simbolo = {"", "CTE_FLOAT", "", 0};
            snprintf(simbolo.nombre, MAX_LENGTH, "_%s", yytext);
            strncpy(simbolo.valor, yytext, MAX_LENGTH - 1);
            snprintf(simbolo.valor, MAX_LENGTH, "%.2f", strtof(simbolo.valor, NULL));
            write_symbol_table(simbolo);

            const_ptr = crear_hoja($1);
            fprintf(or, "constante_2\n");
      }
      | CONST_STRING {
            int len = ((int) strlen(yytext)) - 2;
            Simbolo simbolo = {"", "CTE_STRING", "", len};
            snprintf(simbolo.nombre, MAX_LENGTH, "_%s", yytext);
            strncpy(simbolo.valor, yytext, MAX_LENGTH - 1);
            snprintf(simbolo.nombre, MAX_LENGTH, "_%.*s", len, yytext + 1);
            snprintf(simbolo.valor, MAX_LENGTH, "%.*s", len, yytext + 1);
            write_symbol_table(simbolo);

            const_ptr = crear_hoja($1);
            fprintf(or, "constante_3\n");
      }
      ;

while_sentence:
      START_WHILE PAREN_A {printf("Sentencia WHILE hace el siguiente codigo:\n\n");} condicion_multiple PAREN_C LLAVE_A linea_codigo LLAVE_C {
                  while_sent_ptr = crear_nodo("-WHILE-", cond_mult_ptr, linea_cod_ptr);
      }
      ;

if_sentence:
      START_IF PAREN_A condicion_multiple PAREN_C LLAVE_A linea_codigo LLAVE_C {
            if_sent_ptr = crear_nodo("-IF-", desapilar(pila_cond), desapilar(pila));
            fprintf(or, "if_sentence_1\n");
            printf("Sentencia IF hace el siguiente codigo:\n\n");
            mostrar_pila(pila);
      }
      | START_IF PAREN_A condicion_multiple PAREN_C LLAVE_A LLAVE_C {
            if_sent_ptr = crear_nodo("-IF-", cond_mult_ptr, NULL);
            fprintf(or, "if_sentence_2\n");
      }
      ;

condicion_multiple:
      condicion {
            cond_mult_ptr = cond_ptr;
            apilar(pila_cond, cond_mult_ptr);
            fprintf(or, "condicion_multiple_1\n");
      }
      | condicion_multiple COND_OP_AND condicion {
            cond_mult_ptr = crear_nodo("AND", cond_mult_ptr, cond_ptr);
            fprintf(or, "condicion_multiple_2\n");
      }
      | condicion_multiple COND_OP_OR condicion {
            cond_mult_ptr = crear_nodo("OR", cond_mult_ptr, cond_ptr);
            fprintf(or, "condicion_multiple_3\n");
      }
      ;

condicion:
      valores_admitidos_condicion comparador { comp_ptr->izq = val_adm_cond_ptr; } valores_admitidos_condicion {
            comp_ptr->der = val_adm_cond_ptr;
            cond_ptr = comp_ptr;
            fprintf(or, "condicion_1\n");
      }
      | COND_OP_NOT {boolNegativeCondition = true;} valores_admitidos_condicion comparador { comp_ptr->izq = val_adm_cond_ptr; } valores_admitidos_condicion {
            comp_ptr->der = val_adm_cond_ptr;
            cond_ptr = comp_ptr;
            //cond_ptr = crear_nodo("NOT", comp_ptr, NULL);
            fprintf(or, "condicion_2\n");
      };
      
valores_admitidos_condicion:
      ID {
            printf("ID");
            val_adm_cond_ptr = crear_hoja($1);
      }
      | constante {
            printf("CONSTANTE");
            val_adm_cond_ptr = const_ptr;
      };

comparador:
      COMP_MAY {
            printf(" es mayor a ");
            if(boolNegativeCondition) { comp_ptr = crear_hoja("<="); boolNegativeCondition = false;} else { comp_ptr = crear_hoja(">"); }
      }
      | COMP_MEN {
            printf(" es menor a ");
            if(boolNegativeCondition) { comp_ptr = crear_hoja(">="); boolNegativeCondition = false;} else { comp_ptr = crear_hoja("<"); }
      }
      | COMP_EQ {
            printf(" es igual a ");
            if(boolNegativeCondition) { comp_ptr = crear_hoja("<>"); boolNegativeCondition = false;} else { comp_ptr = crear_hoja("=="); }
      }
      | COMP_MAY_EQ {
            printf(" es mayor o igual a ");
            if(boolNegativeCondition) { comp_ptr = crear_hoja("<"); boolNegativeCondition = false;} else { comp_ptr = crear_hoja(">="); }
      }
      | COMP_MEN_EQ {
            printf(" es menor o igual a ");
            if(boolNegativeCondition) { comp_ptr = crear_hoja(">"); boolNegativeCondition = false;} else { comp_ptr = crear_hoja("<="); }
      }
      | COMP_DIST {
            printf(" es distinto a ");
            if(boolNegativeCondition) { comp_ptr = crear_hoja("=="); boolNegativeCondition = false;} else { comp_ptr = crear_hoja("<>"); }
      };

sentencia_aritmetica:
      ID OP_ARIT {
            pila_sent_aritmetica = crear_pila();
            } expresion {     
            sent_arit_ptr = crear_nodo("=:", crear_hoja($1), expr_ptr);
            //imprimirInorden(sent_arit_ptr);
            //write_intermediate_code("\n");
      };
 
expresion:
      termino {
            printf("    Termino es Expresion\n"); 
            expr_ptr = term_ptr;
      }
	| expresion OP_SUM {
            apilar(pila_sent_aritmetica,expr_ptr);
      } termino {
            printf("    Expresion+Termino es Expresion\n"); 
            expr_ptr = crear_nodo("+", desapilar(pila_sent_aritmetica), term_ptr);
      }
	| expresion OP_RES {
            apilar(pila_sent_aritmetica,expr_ptr);
      } termino {
            printf("    Expresion-Termino es Expresion\n"); 
            expr_ptr = crear_nodo("-", desapilar(pila_sent_aritmetica), term_ptr);
      };
 
termino: 
      factor {printf("    Factor es Termino\n"); term_ptr = fact_ptr;}
      | termino OP_MUL {
            apilar(pila_sent_aritmetica,term_ptr);
            } factor {
                  printf("     Termino*Factor es Termino\n"); 
                  term_ptr = crear_nodo("*", desapilar(pila_sent_aritmetica), fact_ptr);
            }
      | termino OP_DIV {
            apilar(pila_sent_aritmetica,term_ptr);
            } factor {
                  printf("     Termino/Factor es Termino\n"); 
                  term_ptr = crear_nodo("/", desapilar(pila_sent_aritmetica), fact_ptr);
            };
 
factor: 
      variable_aritmetica {
            printf("    %s es Factor\n", yytext); 
            fact_ptr = var_arit_ptr;
      }
	| PAREN_A expresion PAREN_C {
            printf("    Expresion entre parentesis es Factor\n"); 
            fact_ptr = expr_ptr;
      }
     	;

variable_aritmetica:
      ID {
            var_arit_ptr = crear_hoja($1);
      }
      | CONST_FLOAT {
            var_arit_ptr = crear_hoja($1);
      }
      | CONST_INT {
            var_arit_ptr = crear_hoja($1);
      }
      ;

lectura_sentence:
      START_LECTURA PAREN_A ID PAREN_C {
            lectura_ptr = crear_nodo("->",crear_hoja("READ"), crear_hoja($3));
            printf("Comienzo de lectura. Guardar resultado en ID.\n");}
      ;

escritura_sentence:
      START_ESCRITURA PAREN_A CONST_STRING PAREN_C  {escritura_ptr = crear_nodo("<-",crear_hoja("WRITE"), crear_hoja($3)); printf("Comienzo de escritura de constante STRING.\n");}
      | START_ESCRITURA PAREN_A ID PAREN_C {escritura_ptr = crear_nodo("<-",crear_hoja("WRITE"), crear_hoja($3)); printf("Comienzo de escritura de valor de ID.\n");}
      ;

get_penultimate_position:
      FUNCT_GPP PAREN_A vector_numerico PAREN_C {
            printf("\nEjecutando get_penultimate_position\n");

            get_pen_pos_ptr = crear_nodo("get_penultimate_position", crear_hoja("@res"), vec_num_ptr);
            imprimirInorden(get_pen_pos_ptr);
            write_intermediate_code("\n");
      };

vector_numerico:
      CORCH_A lista_aritmetica CORCH_C {
            printf("\nVector numerico\n");
            vec_num_ptr = list_arit_ptr;
      }
      ;

lista_aritmetica:
      variable_aritmetica {
            struct Nodo* aux_hoja;
            struct Nodo* yytext_hoja;
            struct Nodo* res_hoja;

            struct Nodo* aux_nodo;
            struct Nodo* res_nodo;
            struct Nodo* cuerpo_nodo;

            //aux = yytext;
            aux_hoja = crear_hoja("@aux");
            yytext_hoja = crear_hoja(yytext);
            aux_nodo = crear_nodo(":=", aux_hoja, yytext_hoja);

            //res = NULL;
            res_hoja = crear_hoja("@res");
            res_nodo = crear_nodo(":=", res_hoja, NULL);

            //list_arit_ptr = var_arit_ptr;
            cuerpo_nodo = crear_nodo("-CUERPO-", aux_nodo, res_nodo);
            list_arit_ptr = cuerpo_nodo;
      }
      | lista_aritmetica COMA variable_aritmetica {
            struct Nodo* aux_hoja;
            struct Nodo* yytext_hoja;
            struct Nodo* res_hoja;
            struct Nodo* aux2_hoja;

            struct Nodo* aux2_nodo;
            struct Nodo* res_nodo;
            struct Nodo* cuerpo_nodo;

            //res = aux;
            res_hoja = crear_hoja("@res");
            aux_hoja = crear_hoja("@aux");
            res_nodo = crear_nodo(":=", res_hoja, aux_hoja);

            //aux = yytext;
            aux2_hoja = crear_hoja("@aux");
            yytext_hoja = crear_hoja(yytext);
            aux2_nodo = crear_nodo(":=", aux2_hoja, yytext_hoja);

            cuerpo_nodo = crear_nodo("-CUERPO-", res_nodo, aux2_nodo);

            list_arit_ptr = crear_nodo(",", list_arit_ptr, cuerpo_nodo);
      }
      ;

binary_count:
      FUNCT_BC PAREN_A binary_count_vector_numerico PAREN_C {
            printf("\nEjecutando binary_count \n");

            bin_count_ptr = crear_nodo("binary_count", crear_hoja("@count"), bin_count_vec_num_ptr);
            imprimirInorden(bin_count_ptr);
            write_intermediate_code("\n");
      }
      ;

binary_count_vector_numerico:
      CORCH_A binary_count_lista_aritmetica CORCH_C {
            printf("\nVector numerico\n");
            bin_count_vec_num_ptr = bin_count_list_arit_ptr;
      }
      ;

binary_count_lista_aritmetica:
      variable_aritmetica {
            struct Nodo* auxiliar_nodo;
            //bin_count_list_arit_ptr = var_arit_ptr;
            //count = 0;

            auxiliar_nodo = crear_nodo(":=", crear_hoja("@count"), crear_hoja("0"));

            struct Nodo* asig_nodo = NULL;
            struct Nodo* res_nodo = NULL;
            struct Nodo* aux_nodo = NULL;
            struct Nodo* aux2_nodo = NULL;
            struct Nodo* flag_nodo = NULL;
            struct Nodo* condwhile_nodo = NULL;
            struct Nodo* condif1_nodo = NULL;
            struct Nodo* condif2_nodo = NULL;
            struct Nodo* condif3_nodo = NULL;
            struct Nodo* if_nodo = NULL;
            struct Nodo* cuerpo_res_nodo = NULL;
            struct Nodo* cuerpo_if_nodo = NULL;
            struct Nodo* cuerpo_asig_nodo = NULL;
            struct Nodo* cuerpo_while_nodo = NULL;
            struct Nodo* cuerpo_flag_nodo = NULL;
            struct Nodo* flag_0_nodo = NULL;
            struct Nodo* if_flag_nodo = NULL;
            struct Nodo* cond_if_flag_nodo = NULL;
            struct Nodo* cuerpo_if_flag_nodo = NULL;
            struct Nodo* count_nodo = NULL;
            
            //aux = yytext;
            asig_nodo = crear_nodo(":=", crear_hoja("@aux"), crear_hoja(yytext));

            //flag = 0;
            flag_nodo = crear_nodo(":=", crear_hoja("@flag"), crear_hoja("1"));

            //      res := aux % 10;
            res_nodo = crear_nodo("%", crear_hoja("@aux"), crear_hoja("10"));
            res_nodo = crear_nodo(":=", crear_hoja("@res"), res_nodo);
            
            //      if(res <> 0 | res <> 1)
            condif1_nodo = crear_nodo("<>", crear_hoja("@res"), crear_hoja("0"));
            condif2_nodo = crear_nodo("<>", crear_hoja("@res"), crear_hoja("1"));
            condif3_nodo = crear_nodo("|", condif1_nodo, condif2_nodo);

            //            flag := 0;
            flag_0_nodo = crear_nodo(":=", crear_hoja("@flag"), crear_hoja("0"));

            if_nodo = crear_nodo("IF", condif3_nodo, flag_0_nodo);

            //      aux := aux / 10;
            aux_nodo = crear_nodo("/", crear_hoja("@aux"), crear_hoja("10"));
            aux_nodo = crear_nodo(":=", crear_hoja("@aux"), aux_nodo);

            cuerpo_if_nodo = crear_nodo("-CUERPO-", if_nodo, aux_nodo);
            cuerpo_res_nodo = crear_nodo("-CUERPO-", res_nodo, cuerpo_if_nodo);

            //while(aux > 0):
            condwhile_nodo = crear_nodo(">", crear_hoja("@aux"), crear_hoja("0"));
            condwhile_nodo = crear_nodo("WHILE", condwhile_nodo, cuerpo_res_nodo);

            //aux := aux / 10;
            aux2_nodo = crear_nodo("/", crear_hoja("@aux"), crear_hoja("10"));
            aux2_nodo = crear_nodo(":=", crear_hoja("@aux"), aux2_nodo);

            //if(flag == 1)
            cond_if_flag_nodo = crear_nodo("==", crear_hoja("@flag"), crear_hoja("1"));

            //      count := count + 1;
            count_nodo = crear_nodo("+", crear_hoja("@count"), crear_hoja("1"));
            count_nodo = crear_nodo(":=", crear_hoja("@count"), count_nodo);

            if_flag_nodo = crear_nodo("IF", cond_if_flag_nodo, count_nodo);

            cuerpo_if_flag_nodo = crear_nodo("-CUERPO-", if_flag_nodo, aux2_nodo);
            cuerpo_while_nodo = crear_nodo("-CUERPO-", condwhile_nodo, cuerpo_if_flag_nodo);
            cuerpo_flag_nodo = crear_nodo("-CUERPO-", flag_nodo, cuerpo_while_nodo);
            cuerpo_asig_nodo = crear_nodo("-CUERPO-", asig_nodo, cuerpo_flag_nodo);

            bin_count_list_arit_ptr = cuerpo_asig_nodo;
            
            bin_count_list_arit_ptr = crear_nodo("-CUERPO-", auxiliar_nodo, bin_count_list_arit_ptr);
      }
      | binary_count_lista_aritmetica COMA variable_aritmetica {
            struct Nodo* asig_nodo = NULL;
            struct Nodo* res_nodo = NULL;
            struct Nodo* aux_nodo = NULL;
            struct Nodo* aux2_nodo = NULL;
            struct Nodo* flag_nodo = NULL;
            struct Nodo* condwhile_nodo = NULL;
            struct Nodo* condif1_nodo = NULL;
            struct Nodo* condif2_nodo = NULL;
            struct Nodo* condif3_nodo = NULL;
            struct Nodo* if_nodo = NULL;
            struct Nodo* cuerpo_res_nodo = NULL;
            struct Nodo* cuerpo_if_nodo = NULL;
            struct Nodo* cuerpo_asig_nodo = NULL;
            struct Nodo* cuerpo_while_nodo = NULL;
            struct Nodo* cuerpo_flag_nodo = NULL;
            struct Nodo* flag_0_nodo = NULL;
            struct Nodo* if_flag_nodo = NULL;
            struct Nodo* cond_if_flag_nodo = NULL;
            struct Nodo* cuerpo_if_flag_nodo = NULL;
            struct Nodo* count_nodo = NULL;
            
            //aux = yytext;
            asig_nodo = crear_nodo(":=", crear_hoja("@aux"), crear_hoja(yytext));

            //flag = 0;
            flag_nodo = crear_nodo(":=", crear_hoja("@flag"), crear_hoja("1"));

            //      res := aux % 10;
            res_nodo = crear_nodo("%", crear_hoja("@aux"), crear_hoja("10"));
            res_nodo = crear_nodo(":=", crear_hoja("@res"), res_nodo);
            
            //      if(res <> 0 | res <> 1)
            condif1_nodo = crear_nodo("<>", crear_hoja("@res"), crear_hoja("0"));
            condif2_nodo = crear_nodo("<>", crear_hoja("@res"), crear_hoja("1"));
            condif3_nodo = crear_nodo("|", condif1_nodo, condif2_nodo);

            //            flag := 0;
            flag_0_nodo = crear_nodo(":=", crear_hoja("@flag"), crear_hoja("0"));

            if_nodo = crear_nodo("IF", condif3_nodo, flag_0_nodo);

            //      aux := aux / 10;
            aux_nodo = crear_nodo("/", crear_hoja("@aux"), crear_hoja("10"));
            aux_nodo = crear_nodo(":=", crear_hoja("@aux"), aux_nodo);

            cuerpo_if_nodo = crear_nodo("-CUERPO-", if_nodo, aux_nodo);
            cuerpo_res_nodo = crear_nodo("-CUERPO-", res_nodo, cuerpo_if_nodo);

            //while(aux > 0):
            condwhile_nodo = crear_nodo(">", crear_hoja("@aux"), crear_hoja("0"));
            condwhile_nodo = crear_nodo("WHILE", condwhile_nodo, cuerpo_res_nodo);

            //aux := aux / 10;
            aux2_nodo = crear_nodo("/", crear_hoja("@aux"), crear_hoja("10"));
            aux2_nodo = crear_nodo(":=", crear_hoja("@aux"), aux2_nodo);

            //if(flag == 1)
            cond_if_flag_nodo = crear_nodo("==", crear_hoja("@flag"), crear_hoja("1"));

            //      count := count + 1;
            count_nodo = crear_nodo("+", crear_hoja("@count"), crear_hoja("1"));
            count_nodo = crear_nodo(":=", crear_hoja("@count"), count_nodo);

            if_flag_nodo = crear_nodo("IF", cond_if_flag_nodo, count_nodo);

            cuerpo_if_flag_nodo = crear_nodo("-CUERPO-", if_flag_nodo, aux2_nodo);
            cuerpo_while_nodo = crear_nodo("-CUERPO-", condwhile_nodo, cuerpo_if_flag_nodo);
            cuerpo_flag_nodo = crear_nodo("-CUERPO-", flag_nodo, cuerpo_while_nodo);
            cuerpo_asig_nodo = crear_nodo("-CUERPO-", asig_nodo, cuerpo_flag_nodo);

            bin_count_list_arit_ptr = crear_nodo(",", bin_count_list_arit_ptr, cuerpo_asig_nodo);
      }
      ;

%%

int main(int argc, char *argv[])
{
      or = fopen("outputs/orden-reglas.txt", "wt");

      pila = crear_pila();
      pila_cond = crear_pila();

      if((yyin = fopen(argv[1], "rt")) == NULL) {
            printf("\nNo se puede abrir el archivo de prueba: %s\n", argv[1]);
            return 1;
      }
      open_symbol_table();
      create_intermediate_code();
      yyparse();
      close_symbol_table();
      close_intermediate_code();
	fclose(yyin);
      fclose(or);

      liberar_pila(pila);
      liberar_pila(pila_cond);

      return 0;
}

int yyerror(void)
{
      printf("Error Sintactico\n");
      exit (1);
}