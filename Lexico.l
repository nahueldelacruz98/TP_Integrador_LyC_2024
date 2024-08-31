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

ID			    {LETRA}({LETRA}|{DIGITO})*
OP_AS   		":="
OP_ARIT         "=:"
OP_SUM		    "+"
OP_MUL          "*"
OP_RES		    "-"
OP_DIV          "/"
PA			    "("
PC			    ")"
KA              "{"
KC              "}"
CORCH_A         "["
CORCH_C         "]"
DOS_PUNTOS      ":"
COMA            ","
COMILLA         \"
COMENTARIO_INIT	"*-"
COMENTARIO_FIN  "-*"

COMP_MAY        ">"
COMP_MEN        "<"
COMP_MAY_EQ     ">="
COMP_MEN_EQ     "<="
COMP_EQ         "=="
COMP_DIST	    "<>"

INIT_VAR        "init"
DECL_STRING     "String"
DECL_FLOAT      "Float"
DECL_INT        "Int"

START_WHILE	        "mientras"
START_IF	        "si"
START_ELSE	        "sino"
START_LECTURA       "leer"
START_ESCRITURA     "escribir"

CONST_FLOAT         "-"?({DIGITO}+"."{DIGITO}+|{DIGITO}+"."|"."{DIGITO}+)
CONST_STRING        {COMILLA}[^\"]*{COMILLA}
CONST_INT           "-"?{DIGITO}+

COND_OP_NOT	        "NOT"
COND_OP_AND	        "AND"
COND_OP_OR	        "OR"

CONST_BINARY        ("0"|"1")+
FUNCT_BC            "binaryCount"
FUNCT_GPP           "getPenultimatePosition"

%%

"init"              {printf("\nInicializacion de variables\n"); return INIT_VAR;}
"String"            {return DECL_STRING;}
"Float"             {return DECL_FLOAT;}
"Int"               {return DECL_INT;}
"mientras"          {printf("\nComienzo ciclo while:\n"); return START_WHILE;}
"si"                {return START_IF;}
"sino"              {return START_ELSE;}
"leer"              {return START_LECTURA;}
"escribir"          {return START_ESCRITURA;}
"NOT"               {return COND_OP_NOT;}
"AND"               {return COND_OP_AND;}
"OR"                 {return COND_OP_OR;}
"binaryCount"        {return FUNCT_BC;}
"getPenultimatePosition"    {return FUNCT_GPP;}

{CONST_FLOAT}       {return CONST_FLOAT;}
{CONST_STRING}      {printf("\nString: %s\n", yytext); return CONST_STRING;}
{CONST_INT}         {return CONST_INT;}

{ID}            {printf("\nID identificado: %s\n", yytext); return ID;}

{OP_SUM}		{printf(" suma ");return OP_SUM;}
{OP_AS}			{printf(" asignacion ");return OP_AS;}
{OP_MUL}		{printf("\nMultiplicacion: %s\n", yytext);return OP_MUL;}
{OP_RES}		{printf("\nResta: %s\n", yytext);return OP_RES;}
{OP_DIV}		{printf("\nDivision: %s\n", yytext);return OP_DIV;}
{PA}			{printf("\nParAbre: %s\n", yytext);return PA;}
{PC}			{printf("\nParCierra: %s\n", yytext);return PC;}
{KA}            {printf("\nAbre llave: %s\n", yytext);return KA;}
{KC}            {printf("\nCierra llave: %s\n", yytext);return KC;}
{COMA}          {return COMA;}
{DOS_PUNTOS}    {return DOS_PUNTOS;}

"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"  

.			 { printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}

%%