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
"mientras"          {printf("\nSentencia WHILE. Mientras "); return START_WHILE;}
"si"                {printf("\nSentencia IF. Si "); return START_IF;}
"sino"              {printf("\nExtension IF ELSE...\n"); return START_ELSE;}
"leer"              {return START_LECTURA;}
"escribir"          {return START_ESCRITURA;}
"NOT"               {printf(" <NOT> "); return COND_OP_NOT;}
"AND"               {printf(" <Y> "); return COND_OP_AND;}
"OR"                 {printf(" <O> "); return COND_OP_OR;}
"binaryCount"        {return FUNCT_BC;}
"getPenultimatePosition"    {return FUNCT_GPP;}

"*-"([^*]*|\*[^-])*?"-*"    {printf("\nComentario: %s\n",yytext);}

{CONST_FLOAT}       {return CONST_FLOAT;}
{CONST_STRING}      {return CONST_STRING;}
{CONST_INT}         {return CONST_INT;}

{ID}                {return ID; }

{OP_SUM}		{return OP_SUM;}
{OP_AS}			{return OP_AS;}
{OP_MUL}		{return OP_MUL;}
{OP_RES}		{return OP_RES;}
{OP_DIV}		{return OP_DIV;}
{OP_ARIT}       {return OP_ARIT;}
{PA}			{return PA;}
{PC}			{return PC;}
{KA}            {return KA;}
{KC}            {return KC;}
{COMA}          {return COMA;}
{DOS_PUNTOS}    {return DOS_PUNTOS;}

{COMP_MAY}          { return COMP_MAY;}
{COMP_MEN}          { return COMP_MEN;}
{COMP_MEN_EQ}       { return COMP_MEN_EQ;}
{COMP_MAY_EQ}       { return COMP_MAY_EQ;}
{COMP_EQ}           { return COMP_EQ;}
{COMP_DIST}         { return COMP_DIST;}

"\n"      		
"\t"
"\n\t"
" "             		
"\r\n"  

.			 { printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}

%%