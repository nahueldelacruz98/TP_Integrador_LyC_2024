%{
#include <stdio.h>
#include <stdlib.h>

#include "y.tab.h"
FILE  *yyin;
int yylval;
char *yyltext;


int yyerror(void);

%}

%option noyywrap  
%option yylineno 

DIGITO			[0-9]
LETRA			[a-zA-Z]

CONST_FLOAT     ({DIGITO}+"."|"."{DIGITO}+|{DIGITO}+"."{DIGITO}+)
CONST_STRING    \"({LETRA}|{DIGITO}|[ \t\n])*\"
CONST_INT       {DIGITO}+
CONST_GEN       {CONST_FLOAT}|{CONST_STRING}|{CONST_INT}
CONST_NUMERO    "-"?({CONST_FLOAT}|{CONST_INT})

ID			    {LETRA}({LETRA}|{DIGITO})*
OP_AS   		":""="
OP_SUM		    "+"
OP_MUL          "*"
OP_RES		    "-"
OP_DIV          "/"
PA			    "("
PC			    ")"
KA              "{"
KC              "}"
COMP_MAY        ">"
COMP_MEN        "<"
COMP_MAY_EQ     ">="
COMP_MEN_EQ     "<="
COMP_EQ         "=="
COMP_DIST	    "<>"
COMP_GEN	    {COMP_MAY}|{COMP_MEN}|{COMP_MAY_EQ}|{COMP_MEN_EQ}|{COMP_EQ}|{COMP_DIST}

DECL_VAR_INIT   "init"" "?{KA}
START_DECL      {ID}(","{ID})*":"
DECL_STRING     {START_DECL}"String"
DECL_FLOAT      {START_DECL}"Float"
DECL_INT        {START_DECL}"Int"

COND_GEN	({ID}|{CONST_GEN})" "{COMP_GEN}" "({ID}|{CONST_GEN})
COND_OP_NOT	"NOT "
COND_OP_AND	" AND "
COND_OP_OR	" OR "
CONDICION	{PA}{COND_OP_NOT}?{COND_GEN}(({COND_OP_AND}|{COND_OP_OR}){COND_OP_NOT}?{COND_GEN})*{PC}

START_WHILE	"mientras"" "{CONDICION}{KA}

START_IF	"si"" "{CONDICION}"" "?{KA}
START_ELSE	{KC}" sino"" "?{KA}

COMENTARIO	"*-"({LETRA}|{DIGITO})*"-*"

LISTA_NUM	    "["{CONST_NUMERO}(","{CONST_NUMERO})*"]"
FUNCT_GPP       "getPenultimatePosition"{PA}{CONST_INT}";"{LISTA_NUM}{PC}

CONST_BINARY        ("0"|"1")+
TIPO_ELEM_LISTA     ({CONST_BINARY}|{CONST_NUMERO}|{ID})
LISTA_NUM_ID        "["{TIPO_ELEM_LISTA}(","{TIPO_ELEM_LISTA})*"]"
FUNCT_BC            "binaryCount"{PA}{LISTA_NUM_ID}{PC}

%%

"DECVAR"        {printf("\Palabra reservada: %s\n", yytext);return CONST_STRING;}

{CONST_STRING}  {printf("\nString: %s\n", yytext);return CONST_STRING;}
{ID}            {printf("\nID identificado: %s\n", yytext);}
{OP_SUM}		{printf("\nSuma: %s\n", yytext);return OP_SUM;}
{OP_AS}			{printf("\nAsignacion: %s\n", yytext);return OP_AS;}
{OP_MUL}		{printf("\nMultiplicacion: %s\n", yytext);return OP_MUL;}
{OP_RES}		{printf("\nResta: %s\n", yytext);return OP_RES;}
{OP_DIV}		{printf("\nDivision: %s\n", yytext);return OP_DIV;}
{PA}			{printf("\nParAbre: %s\n", yytext);return PA;}
{PC}			{printf("\nParCierra: %s\n", yytext);return PC;}

"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"  

{DECL_VAR_INIT}     {printf("\nComienzo de declaracion de variables...\n");}
{DECL_STRING}       {printf("\nLista de variables de tipo String: %s\n", yytext);}
{DECL_INT}          {printf("\nLista de variables de tipo Integer: %s\n", yytext);}
{DECL_FLOAT}        {printf("\nLista de variables de tipo Float: %s\n", yytext);}
{KC}                

.			 { printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}

%%