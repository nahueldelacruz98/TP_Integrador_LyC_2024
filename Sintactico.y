//Usa Lexico_ClasePractica
//Solo expresiones sin ()
%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>  // Include this header for boolean variables support
#include "y.tab.h"

#include "utils/intermediate-code.c"
#include "utils/symbol-table.c"
#include "utils/generacion_assembler.c"

int   yystopparser=0,
      yyerror(),
      yylex();

FILE  *yyin,
      *orden_reglas;

extern char* yytext;

bool boolNegativeCondition = false;

Pila  *pila_bloq_cod = NULL,
      *pila_cond_mult = NULL,
      *pila_asig_arit = NULL;

struct Nodo *bloq_cod_ptr = NULL,
            *sent_ptr = NULL,
            *inic_var_ptr = NULL,
            *asig_var_ptr = NULL,
            *const_ptr = NULL,
            *cond_mult_ptr = NULL,
            *cond_ptr = NULL,
            *val_adm_cond_ptr = NULL,
            *comp_ptr = NULL,
            *while_ptr = NULL,
            *if_ptr = NULL,
            *cond_op_ptr = NULL,
            *else_sent_ptr = NULL,
            *asig_arit_ptr = NULL,
            *expr_ptr = NULL,
            *term_ptr = NULL,
            *fact_ptr = NULL,
            *var_arit_ptr = NULL,
            *var_ptr = NULL,
            *decl_ptr = NULL,
            *conj_var_ptr = NULL,
            *tipo_var_ptr = NULL,
            *get_pen_pos_ptr = NULL,
            *gpp_vec_num_ptr = NULL,
            *gpp_list_arit_ptr = NULL,
            *bin_count_ptr = NULL,
            *bc_vec_num_ptr = NULL,
            *bc_list_arit_ptr = NULL,
            *lect_ptr = NULL,
            *escr_ptr = NULL;

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
      bloque_cod1go {
            imprimir_postorden(bloq_cod_ptr);
            generar_archivo_DOT(bloq_cod_ptr);
            generar_archivo_assembler(bloq_cod_ptr);
            liberar_arbol(bloq_cod_ptr);
      }

bloque_cod1go:
      sentencia {
            bloq_cod_ptr = sent_ptr;
            apilar(pila_bloq_cod, bloq_cod_ptr);
            fprintf(orden_reglas, "bloque_cod1go_1\n");
      }
      | bloque_cod1go sentencia {
            bloq_cod_ptr = crear_nodo("-SENTENCIA-", desapilar(pila_bloq_cod), sent_ptr);
            apilar(pila_bloq_cod, bloq_cod_ptr);
            fprintf(orden_reglas, "bloque_cod1go_2\n");
      }
      ;

sentencia:
      inicializacion_variables {
            fprintf(orden_reglas, "sentencia_1\n");
      }
      | asignacion_variables {
            sent_ptr = asig_var_ptr; 
            fprintf(orden_reglas, "sentencia_2\n");
            printf("\n");
      }
      | asignacion_aritmetica {
            sent_ptr = asig_arit_ptr;
            fprintf(orden_reglas, "sentencia_3\n");
      }
      | while {
            sent_ptr = while_ptr; 
            fprintf(orden_reglas, "sentencia_4\n");
            printf("FIN de ciclo WHILE.\n\n");
      }
      | if {
            sent_ptr = if_ptr;
            fprintf(orden_reglas, "sentencia_5\n");
            printf("FIN de sentencia IF.\n\n");
      }
      | escritura {
            sent_ptr = escr_ptr;
            fprintf(orden_reglas, "sentencia_6\n");
      }
      | lectura {
            sent_ptr = lect_ptr;
            fprintf(orden_reglas, "sentencia_7\n");
      }
      | get_penultimate_position {
            sent_ptr = get_pen_pos_ptr;
            fprintf(orden_reglas, "sentencia_8\n");
      }
      | binary_count {
            sent_ptr = bin_count_ptr;
            fprintf(orden_reglas, "sentencia_9\n");
      }
      ;

inicializacion_variables:
      INIT_VAR LLAVE_A declaracion LLAVE_C {
            fprintf(orden_reglas, "inicializacion_variables_1\n");
            printf("FIN de declaracion de variables.\n\n");
      }
      ;

declaracion:
      conjunto_variables DOS_PUNTOS tipo_variables {
            fprintf(orden_reglas, "declaracion_1\n");
      }
      | declaracion conjunto_variables DOS_PUNTOS tipo_variables {
            fprintf(orden_reglas, "declaracion_2\n");
      }
	;

conjunto_variables:
      conjunto_variables COMA ID {
            Simbolo simbolo = {"", "", "-", 0};
            strncpy(simbolo.nombre, yytext, MAX_LENGTH - 1);
            write_symbol_table(simbolo);
            
            fprintf(orden_reglas, "conjunto_variables_1\n");
            printf(",%s",yytext);
      }
      | ID {
            Simbolo simbolo = {"", "", "-", 0};
            strncpy(simbolo.nombre, yytext, MAX_LENGTH - 1);
            write_symbol_table(simbolo);

            fprintf(orden_reglas, "conjunto_variables_2\n");
            printf("%s", yytext);
      }
      ;
         
tipo_variables:
      DECL_STRING {
            fprintf(orden_reglas, "tipo_variables_1\n");
            printf(": variable/s de tipo String.\n"); 
      }
      | DECL_FLOAT {
            fprintf(orden_reglas, "tipo_variables_2\n");
            printf(": variable/s de tipo Float.\n"); 
      }
      | DECL_INT {
            fprintf(orden_reglas, "tipo_variables_3\n");
            printf(": variable/s de tipo Integer.\n"); 
      }
      ;

asignacion_variables:
      ID OP_AS constante {
            asig_var_ptr = crear_nodo(":=", crear_hoja($1), const_ptr);
            fprintf(orden_reglas, "asignacion_variables_1\n");
            printf("%s se le asigna constante: %s", $1, yytext);
      }
      | ID OP_AS get_penultimate_position {
            asig_var_ptr = crear_nodo(":=", crear_hoja($1), get_pen_pos_ptr);
            fprintf(orden_reglas, "asignacion_variables_2\n");
      }
      | ID OP_AS binary_count {
            asig_var_ptr = crear_nodo(":=", crear_hoja($1), bin_count_ptr);
            fprintf(orden_reglas, "asignacion_variables_3\n");
      }
      ;

constante:
      CONST_INT {
            Simbolo simbolo = {"", "CTE_INTEGER", "", 0};
            snprintf(simbolo.nombre, MAX_LENGTH, "_%s", yytext);
            strncpy(simbolo.valor, yytext, MAX_LENGTH - 1);
            write_symbol_table(simbolo);

            const_ptr = crear_hoja($1);
            fprintf(orden_reglas, "constante_1\n");
      }
      | CONST_FLOAT {
            Simbolo simbolo = {"", "CTE_FLOAT", "", 0};
            snprintf(simbolo.nombre, MAX_LENGTH, "_%s", yytext);
            strncpy(simbolo.valor, yytext, MAX_LENGTH - 1);
            snprintf(simbolo.valor, MAX_LENGTH, "%.2f", strtof(simbolo.valor, NULL));
            write_symbol_table(simbolo);

            const_ptr = crear_hoja($1);
            fprintf(orden_reglas, "constante_2\n");
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
            fprintf(orden_reglas, "constante_3\n");
      }
      ;

while:
      START_WHILE PAREN_A condicion_multiple PAREN_C LLAVE_A bloque_cod1go LLAVE_C {
            while_ptr = crear_nodo("-WHILE-", desapilar(pila_cond_mult), desapilar(pila_bloq_cod));
            fprintf(orden_reglas, "while_1\n");
      }
      | START_WHILE PAREN_A condicion_multiple PAREN_C LLAVE_A LLAVE_C {
            while_ptr = crear_nodo("-WHILE-", desapilar(pila_cond_mult), NULL);
            fprintf(orden_reglas, "while_2\n");
      }
      ;


if:
      START_IF PAREN_A condicion_multiple PAREN_C LLAVE_A bloque_cod1go LLAVE_C {
            if_ptr = crear_nodo("-IF-", desapilar(pila_cond_mult), desapilar(pila_bloq_cod));
            fprintf(orden_reglas, "if_1\n");
            printf("Sentencia IF hace el siguiente codigo:\n\n");
      }
      | START_IF PAREN_A condicion_multiple PAREN_C LLAVE_A LLAVE_C {
            if_ptr = crear_nodo("-IF-", desapilar(pila_cond_mult), NULL);
            fprintf(orden_reglas, "if_2\n");
      }
      | START_IF PAREN_A condicion_multiple PAREN_C LLAVE_A bloque_cod1go LLAVE_C else {
            struct Nodo* cuerpo_nodo;
            cuerpo_nodo = crear_nodo("-CUERPO IF/ELSE-", desapilar(pila_bloq_cod), else_sent_ptr);
            if_ptr = crear_nodo("-IF-", desapilar(pila_cond_mult), cuerpo_nodo);
            fprintf(orden_reglas, "if_3\n");
            printf("Sentencia IF hace el siguiente codigo:\n\n");
      }
      ;

else:
      START_ELSE LLAVE_A bloque_cod1go LLAVE_C {
            else_sent_ptr = desapilar(pila_bloq_cod);
            fprintf(orden_reglas, "else_1\n");
      }
      | START_ELSE LLAVE_A LLAVE_C {
            else_sent_ptr = NULL;
            fprintf(orden_reglas, "else_2\n");
      }
      ;

condicion_multiple:
      condicion {
            cond_mult_ptr = cond_ptr;
            apilar(pila_cond_mult, cond_mult_ptr);
            fprintf(orden_reglas, "condicion_multiple_1\n");
      }
      | condicion_multiple COND_OP_AND condicion {
            cond_mult_ptr = crear_nodo("AND", desapilar(pila_cond_mult), cond_ptr);
            apilar(pila_cond_mult, cond_mult_ptr);
            fprintf(orden_reglas, "condicion_multiple_2\n");
      }
      | condicion_multiple COND_OP_OR condicion {
            cond_mult_ptr = crear_nodo("OR", desapilar(pila_cond_mult), cond_ptr);
            apilar(pila_cond_mult, cond_mult_ptr);
            fprintf(orden_reglas, "condicion_multiple_3\n");
      }
      ;

condicion:
      valores_admitidos_condicion comparador {
            comp_ptr->izq = val_adm_cond_ptr; 
      } valores_admitidos_condicion {
            comp_ptr->der = val_adm_cond_ptr;
            cond_ptr = comp_ptr;
            fprintf(orden_reglas, "condicion_1\n");
      }
      | COND_OP_NOT {
            boolNegativeCondition = true;
      } valores_admitidos_condicion comparador {
            comp_ptr->izq = val_adm_cond_ptr;
      } valores_admitidos_condicion {
            comp_ptr->der = val_adm_cond_ptr;
            cond_ptr = comp_ptr;
            fprintf(orden_reglas, "condicion_2\n");
      }
      ;
      
valores_admitidos_condicion:
      ID {
            val_adm_cond_ptr = crear_hoja($1);
            fprintf(orden_reglas, "valores_admitidos_condicion_1\n");
            printf("ID");
      }
      | constante {
            val_adm_cond_ptr = const_ptr;
            fprintf(orden_reglas, "valores_admitidos_condicion_2\n");
            printf("CONSTANTE");
      }
      ;

comparador:
      COMP_MAY {
            if(boolNegativeCondition) {
                  comp_ptr = crear_hoja("<="); 
                  boolNegativeCondition = false;
            } else { 
                  comp_ptr = crear_hoja(">"); 
            }
            fprintf(orden_reglas, "comparador_1\n");
            printf(" es mayor a ");
      }
      | COMP_MEN {
            if(boolNegativeCondition) {
                  comp_ptr = crear_hoja(">=");
                  boolNegativeCondition = false;
            } else {
                  comp_ptr = crear_hoja("<");
            }
            fprintf(orden_reglas, "comparador_2\n");
            printf(" es menor a ");
      }
      | COMP_EQ {
            if(boolNegativeCondition) {
                  comp_ptr = crear_hoja("<>");
                  boolNegativeCondition = false;
            } else { 
                  comp_ptr = crear_hoja("==");
            }
            fprintf(orden_reglas, "comparador_3\n");
            printf(" es igual a ");
      }
      | COMP_MAY_EQ {
            if(boolNegativeCondition) {
                  comp_ptr = crear_hoja("<");
                  boolNegativeCondition = false;
            } else { 
                  comp_ptr = crear_hoja(">="); 
            }
            fprintf(orden_reglas, "comparador_4\n");
            printf(" es mayor o igual a ");
      }
      | COMP_MEN_EQ {
            if(boolNegativeCondition) {
                  comp_ptr = crear_hoja(">");
                  boolNegativeCondition = false;
            } else {
                  comp_ptr = crear_hoja("<=");
            }
            fprintf(orden_reglas, "comparador_5\n");
            printf(" es menor o igual a ");
      }
      | COMP_DIST {
            if(boolNegativeCondition) {
                  comp_ptr = crear_hoja("==");
                  boolNegativeCondition = false;
            } else {
                  comp_ptr = crear_hoja("<>");
            }
            fprintf(orden_reglas, "comparador_6\n");
            printf(" es distinto a ");
      }
      ;

asignacion_aritmetica:
      ID OP_ARIT expresion {
            asig_arit_ptr = crear_nodo("=:", crear_hoja($1), expr_ptr);
            fprintf(orden_reglas, "asignacion_aritmetica_1\n");
      }
      ;

expresion:
      termino {
            expr_ptr = term_ptr;
            fprintf(orden_reglas, "expresion_1\n");
            printf("    Termino es Expresion\n");
      }
	| expresion OP_SUM {
            apilar(pila_asig_arit, expr_ptr);
      } termino {
            expr_ptr = crear_nodo("+", desapilar(pila_asig_arit), term_ptr);
            fprintf(orden_reglas, "expresion_2\n");
            printf("    Expresion+Termino es Expresion\n"); 
      }
	| expresion OP_RES {
            apilar(pila_asig_arit, expr_ptr);
      } termino {
            expr_ptr = crear_nodo("-", desapilar(pila_asig_arit), term_ptr);
            fprintf(orden_reglas, "expresion_3\n");
            printf("    Expresion-Termino es Expresion\n"); 
      }
      ;
 
termino: 
      factor {
            term_ptr = fact_ptr;
            fprintf(orden_reglas, "termino_1\n");
            printf("    Factor es Termino\n");
      }
      | termino OP_MUL {
            apilar(pila_asig_arit, term_ptr);
      } factor {
            term_ptr = crear_nodo("*", desapilar(pila_asig_arit), fact_ptr);
            fprintf(orden_reglas, "termino_2\n");
            printf("     Termino*Factor es Termino\n"); 
      }
      | termino OP_DIV {
            apilar(pila_asig_arit, term_ptr);
      } factor {
            term_ptr = crear_nodo("/", desapilar(pila_asig_arit), fact_ptr);
            fprintf(orden_reglas, "termino_3\n");
            printf("     Termino/Factor es Termino\n"); 
      }
      ;
 
factor: 
      variable_aritmetica {
            fact_ptr = var_arit_ptr;
            fprintf(orden_reglas, "factor_1\n");
            printf("    %s es Factor\n", yytext); 
      }
	| PAREN_A expresion PAREN_C {
            fact_ptr = expr_ptr;
            fprintf(orden_reglas, "factor_2\n");
            printf("    Expresion entre parentesis es Factor\n"); 
      }
     	;

variable_aritmetica:
      ID {
            var_arit_ptr = crear_hoja($1);
            fprintf(orden_reglas, "variable_aritmetica_1\n");
      }
      | CONST_FLOAT {
            var_arit_ptr = crear_hoja($1);
            fprintf(orden_reglas, "variable_aritmetica_2\n");
      }
      | CONST_INT {
            var_arit_ptr = crear_hoja($1);
            fprintf(orden_reglas, "variable_aritmetica_3\n");
      }
      ;

lectura:
      START_LECTURA PAREN_A ID PAREN_C {
            lect_ptr = crear_nodo("-LECTURA-", crear_hoja("read"), crear_hoja($3));
            fprintf(orden_reglas, "lectura_1\n");
            printf("Comienzo de lectura. Guardar resultado en ID.\n");
      }
      ;

escritura:
      START_ESCRITURA PAREN_A CONST_STRING PAREN_C  {
            escr_ptr = crear_nodo("-ESCRITURA-", crear_hoja("write"), crear_hoja($3));
            fprintf(orden_reglas, "escritura_1\n");
            printf("Comienzo de escritura de constante STRING.\n");
      }
      | START_ESCRITURA PAREN_A ID PAREN_C {
            escr_ptr = crear_nodo("-ESCRITURA-", crear_hoja("write"), crear_hoja($3));
            fprintf(orden_reglas, "escritura_2\n");
            printf("Comienzo de escritura de valor de ID.\n");
      }
      ;

get_penultimate_position:
      FUNCT_GPP PAREN_A gpp_vector_numerico PAREN_C {
            get_pen_pos_ptr = crear_nodo("-GET_PENULTIMATE_POSITION-", gpp_vec_num_ptr, NULL);
            fprintf(orden_reglas, "get_penultimate_position_1\n");
            printf("\nEjecutando get_penultimate_position\n");
      }
      ;

gpp_vector_numerico:
      CORCH_A gpp_lista_aritmetica CORCH_C {
            gpp_vec_num_ptr = gpp_list_arit_ptr;
            fprintf(orden_reglas, "gpp_vector_numerico_1\n");
            printf("\nVector numerico\n");
      }
      ;

gpp_lista_aritmetica:
      variable_aritmetica {
            struct Nodo *aux_hoja,
                        *yytext_hoja,
                        *res_hoja,
                        *aux_nodo,
                        *res_nodo,
                        *cuerpo_nodo;
            Simbolo     aux_simbolo = {"@aux", "", "-", 0},
                        res_simbolo = {"@res", "", "-", 0};

            //aux = yytext;
            write_symbol_table(aux_simbolo);
            aux_hoja = crear_hoja("@aux");
            yytext_hoja = crear_hoja(yytext);
            aux_nodo = crear_nodo(":=", aux_hoja, yytext_hoja);

            //res = NULL;
            write_symbol_table(res_simbolo);
            res_hoja = crear_hoja("@res");
            res_nodo = crear_nodo(":=", res_hoja, crear_hoja("NULL"));

            //gpp_list_arit_ptr = var_arit_ptr;
            cuerpo_nodo = crear_nodo("-CUERPO-", aux_nodo, res_nodo);

            gpp_list_arit_ptr = cuerpo_nodo;
            fprintf(orden_reglas, "gpp_lista_aritmetica_1\n");
      }
      | gpp_lista_aritmetica COMA variable_aritmetica {
            struct Nodo *aux_hoja,
                        *yytext_hoja,
                        *res_hoja,
                        *aux2_hoja,
                        *aux2_nodo,
                        *res_nodo,
                        *cuerpo_nodo;

            //res = aux;
            res_hoja = crear_hoja("@res");
            aux_hoja = crear_hoja("@aux");
            res_nodo = crear_nodo(":=", res_hoja, aux_hoja);

            //aux = yytext;
            aux2_hoja = crear_hoja("@aux");
            yytext_hoja = crear_hoja(yytext);
            aux2_nodo = crear_nodo(":=", aux2_hoja, yytext_hoja);

            cuerpo_nodo = crear_nodo("-CUERPO-", res_nodo, aux2_nodo);

            gpp_list_arit_ptr = crear_nodo(",", gpp_list_arit_ptr, cuerpo_nodo);
            fprintf(orden_reglas, "gpp_lista_aritmetica_2\n");
      }
      ;

binary_count:
      FUNCT_BC PAREN_A bc_vector_numerico PAREN_C {
            bin_count_ptr = crear_nodo("-BINARY_COUNT-", bc_vec_num_ptr, NULL);
            fprintf(orden_reglas, "binary_count_1\n");
            printf("\nEjecutando binary_count \n");
      }
      ;

bc_vector_numerico:
      CORCH_A bc_lista_aritmetica CORCH_C {
            bc_vec_num_ptr = bc_list_arit_ptr;
            fprintf(orden_reglas, "bc_vector_numerico_1\n");
            printf("\nVector numerico\n");
      }
      ;

bc_lista_aritmetica:
      variable_aritmetica {
            struct Nodo *asig_nodo,
                        *res_nodo,
                        *aux_nodo,
                        *aux2_nodo,
                        *flag_nodo,
                        *condwhile_nodo,
                        *condif1_nodo,
                        *condif2_nodo,
                        *condif3_nodo,
                        *if_nodo,
                        *cuerpo_res_nodo,
                        *cuerpo_if_nodo,
                        *cuerpo_asig_nodo,
                        *cuerpo_while_nodo,
                        *cuerpo_flag_nodo,
                        *flag_0_nodo,
                        *if_flag_nodo,
                        *cond_if_flag_nodo,
                        *cuerpo_if_flag_nodo,
                        *count_nodo,
                        *auxiliar_nodo;
            Simbolo     count_simbolo = {"@count", "", "-", 0},
                        aux_simbolo = {"@aux", "", "-", 0},
                        flag_simbolo = {"@flag", "", "-", 0};
            
            //bc_list_arit_ptr = var_arit_ptr;
            //count = 0;
            write_symbol_table(count_simbolo);
            auxiliar_nodo = crear_nodo(":=", crear_hoja("@count"), crear_hoja("0"));
            
            //aux = yytext;
            write_symbol_table(aux_simbolo);
            asig_nodo = crear_nodo(":=", crear_hoja("@aux"), crear_hoja(yytext));

            //flag = 0;
            write_symbol_table(flag_simbolo);
            flag_nodo = crear_nodo(":=", crear_hoja("@flag"), crear_hoja("1"));

            //      res := aux % 10;
            res_nodo = crear_nodo("%", crear_hoja("@aux"), crear_hoja("10"));
            res_nodo = crear_nodo(":=", crear_hoja("@res"), res_nodo);
            
            //      if(res <> 0 | res <> 1)
            condif1_nodo = crear_nodo("<>", crear_hoja("@res"), crear_hoja("0"));
            condif2_nodo = crear_nodo("<>", crear_hoja("@res"), crear_hoja("1"));
            condif3_nodo = crear_nodo("OR", condif1_nodo, condif2_nodo);

            //            flag := 0;
            flag_0_nodo = crear_nodo(":=", crear_hoja("@flag"), crear_hoja("0"));

            if_nodo = crear_nodo("-IF-", condif3_nodo, flag_0_nodo);

            //      aux := aux / 10;
            aux_nodo = crear_nodo("/", crear_hoja("@aux"), crear_hoja("10"));
            aux_nodo = crear_nodo(":=", crear_hoja("@aux"), aux_nodo);

            cuerpo_if_nodo = crear_nodo("-CUERPO-", if_nodo, aux_nodo);
            cuerpo_res_nodo = crear_nodo("-CUERPO-", res_nodo, cuerpo_if_nodo);

            //while(aux > 0):
            condwhile_nodo = crear_nodo(">", crear_hoja("@aux"), crear_hoja("0"));
            condwhile_nodo = crear_nodo("-WHILE-", condwhile_nodo, cuerpo_res_nodo);

            //aux := aux / 10;
            aux2_nodo = crear_nodo("/", crear_hoja("@aux"), crear_hoja("10"));
            aux2_nodo = crear_nodo(":=", crear_hoja("@aux"), aux2_nodo);

            //if(flag == 1)
            cond_if_flag_nodo = crear_nodo("==", crear_hoja("@flag"), crear_hoja("1"));

            //      count := count + 1;
            count_nodo = crear_nodo("+", crear_hoja("@count"), crear_hoja("1"));
            count_nodo = crear_nodo(":=", crear_hoja("@count"), count_nodo);

            if_flag_nodo = crear_nodo("-IF-", cond_if_flag_nodo, count_nodo);

            cuerpo_if_flag_nodo = crear_nodo("-CUERPO-", if_flag_nodo, aux2_nodo);
            cuerpo_while_nodo = crear_nodo("-CUERPO-", condwhile_nodo, cuerpo_if_flag_nodo);
            cuerpo_flag_nodo = crear_nodo("-CUERPO-", flag_nodo, cuerpo_while_nodo);
            cuerpo_asig_nodo = crear_nodo("-CUERPO-", asig_nodo, cuerpo_flag_nodo);

            bc_list_arit_ptr = cuerpo_asig_nodo;
            
            bc_list_arit_ptr = crear_nodo("-CUERPO-", auxiliar_nodo, bc_list_arit_ptr);
            fprintf(orden_reglas, "bc_lista_aritmetica_1\n");
      }
      | bc_lista_aritmetica COMA variable_aritmetica {
            struct Nodo *asig_nodo,
                        *res_nodo,
                        *aux_nodo,
                        *aux2_nodo,
                        *flag_nodo,
                        *condwhile_nodo,
                        *condif1_nodo,
                        *condif2_nodo,
                        *condif3_nodo,
                        *if_nodo,
                        *cuerpo_res_nodo,
                        *cuerpo_if_nodo,
                        *cuerpo_asig_nodo,
                        *cuerpo_while_nodo,
                        *cuerpo_flag_nodo,
                        *flag_0_nodo,
                        *if_flag_nodo,
                        *cond_if_flag_nodo,
                        *cuerpo_if_flag_nodo,
                        *count_nodo;
            
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
            condif3_nodo = crear_nodo("OR", condif1_nodo, condif2_nodo);

            //            flag := 0;
            flag_0_nodo = crear_nodo(":=", crear_hoja("@flag"), crear_hoja("0"));

            if_nodo = crear_nodo("-IF-", condif3_nodo, flag_0_nodo);

            //      aux := aux / 10;
            aux_nodo = crear_nodo("/", crear_hoja("@aux"), crear_hoja("10"));
            aux_nodo = crear_nodo(":=", crear_hoja("@aux"), aux_nodo);

            cuerpo_if_nodo = crear_nodo("-CUERPO-", if_nodo, aux_nodo);
            cuerpo_res_nodo = crear_nodo("-CUERPO-", res_nodo, cuerpo_if_nodo);

            //while(aux > 0):
            condwhile_nodo = crear_nodo(">", crear_hoja("@aux"), crear_hoja("0"));
            condwhile_nodo = crear_nodo("-WHILE-", condwhile_nodo, cuerpo_res_nodo);

            //aux := aux / 10;
            aux2_nodo = crear_nodo("/", crear_hoja("@aux"), crear_hoja("10"));
            aux2_nodo = crear_nodo(":=", crear_hoja("@aux"), aux2_nodo);

            //if(flag == 1)
            cond_if_flag_nodo = crear_nodo("==", crear_hoja("@flag"), crear_hoja("1"));

            //      count := count + 1;
            count_nodo = crear_nodo("+", crear_hoja("@count"), crear_hoja("1"));
            count_nodo = crear_nodo(":=", crear_hoja("@count"), count_nodo);

            if_flag_nodo = crear_nodo("-IF-", cond_if_flag_nodo, count_nodo);

            cuerpo_if_flag_nodo = crear_nodo("-CUERPO-", if_flag_nodo, aux2_nodo);
            cuerpo_while_nodo = crear_nodo("-CUERPO-", condwhile_nodo, cuerpo_if_flag_nodo);
            cuerpo_flag_nodo = crear_nodo("-CUERPO-", flag_nodo, cuerpo_while_nodo);
            cuerpo_asig_nodo = crear_nodo("-CUERPO-", asig_nodo, cuerpo_flag_nodo);

            bc_list_arit_ptr = crear_nodo(",", bc_list_arit_ptr, cuerpo_asig_nodo);
            fprintf(orden_reglas, "bc_lista_aritmetica_2\n");
      }
      ;

%%

int main(int argc, char *argv[])
{
      orden_reglas = fopen("outputs/orden-reglas.txt", "wt");
      pila_asig_arit = crear_pila();
      pila_bloq_cod = crear_pila();
      pila_cond_mult = crear_pila();
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
      fclose(orden_reglas);
      liberar_pila(pila_asig_arit);
      liberar_pila(pila_bloq_cod);
      liberar_pila(pila_cond_mult);

      return 0;
}

int yyerror(void) {
      printf("Error Sintactico\n");
      exit (1);
}