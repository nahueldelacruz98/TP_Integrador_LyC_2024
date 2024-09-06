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
COMENTARIO  	"*-"([^*]*|\*[^-])*?"-*"

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

"init"              {printf("\nInicializacion de variables...\n"); return INIT_VAR;}
"String"            {return DECL_STRING;}
"Float"             {return DECL_FLOAT;}
"Int"               {return DECL_INT;}
"mientras"          {printf("\nComienzo del ciclo WHILE. Mientras "); return START_WHILE;}
"si"                {printf("\nComienzo de sentencia IF. Si "); return START_IF;}
"sino"              {printf("\nExtension IF ELSE...\n"); return START_ELSE;}
"leer"              {printf("\nEmpieza lectura\n");return START_LECTURA;}
"escribir"          {printf("\nEmpieza escritura\n");return START_ESCRITURA;}
"NOT"               {printf(" <NOT> "); return COND_OP_NOT;}
"AND"               {printf(" <Y> "); return COND_OP_AND;}
"OR"                 {printf(" <O> "); return COND_OP_OR;}
"binaryCount"        {return FUNCT_BC;}
"getPenultimatePosition"    {return FUNCT_GPP;}

{CONST_FLOAT}       {printf("constante FLOAT %s",yytext); return CONST_FLOAT;}
{CONST_STRING}      {printf("constante STRING %s",yytext); return CONST_STRING;}
{CONST_INT}         {printf("constante INT %s",yytext); return CONST_INT;}

{ID}                {printf("Variable '%s'",yytext); return ID; }

{COMENTARIO}    {return COMENTARIO;}

{OP_SUM}		{printf(" suma ");return OP_SUM;}
{OP_AS}			{printf(" se le asigna el valor: "); return OP_AS;}
{OP_MUL}		{printf(" multiplica ");return OP_MUL;}
{OP_RES}		{printf(" resta ");return OP_RES;}
{OP_DIV}		{printf(" divide ");return OP_DIV;}
{OP_ARIT}       {printf(". Inicio operacion aritmetica. "); return OP_ARIT;}
{PA}			{return PA;}
{PC}			{return PC;}
{KA}            {return KA;}
{KC}            {return KC;}
{CORCH_A}       {return CORCH_A;}
{CORCH_C}       {return CORCH_C;}
{COMA}          {return COMA;}
{DOS_PUNTOS}    {return DOS_PUNTOS;}

{COMP_MAY}          { printf(" es mayor a "); return COMP_MAY;}
{COMP_MEN}          { printf(" es menor a "); return COMP_MEN;}
{COMP_MEN_EQ}       { printf(" es menor o igual a "); return COMP_MEN_EQ;}
{COMP_MAY_EQ}       { printf(" es mayor o igual a "); return COMP_MAY_EQ;}
{COMP_EQ}           { printf(" es igual a "); return COMP_EQ;}
{COMP_DIST}         { printf(" es distinto a "); return COMP_DIST;}

"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"  

.			 { printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}

%%