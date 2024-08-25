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

CTE		        {DIGITO}+
CONST_FLOAT     ({DIGITO}+"."|"."{DIGITO}+|{DIGITO}+"."{DIGITO}+)
CONST_STRING    \"({LETRA}|{DIGITO}|[ \t\n])*\"
CONST_INT       {DIGITO}+
CONST_GEN       {CONST_FLOAT}|{CONST_STRING}|{CONST_INT}

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

DECL_VAR_INIT   "i""n""i""t"" "?{KA}
START_DECL      {ID}(","{ID})*":"
DECL_STRING     {START_DECL}"S""t""r""i""n""g"
DECL_FLOAT      {START_DECL}"F""l""o""a""t"
DECL_INT        {START_DECL}"I""n""t"

COND_GEN	({ID}|{CONST_GEN})" "{COMP_GEN}" "({ID}|{CONST_GEN})
COND_OP_NOT	"N""O""T"" "
COND_OP_AND	" ""A""N""D"" "
COND_OP_OR	" ""O""R"" "
CONDICION	{PA}{COND_OP_NOT}?{COND_GEN}(({COND_OP_AND}|{COND_OP_OR}){COND_OP_NOT}?{COND_GEN})*{PC}

START_WHILE	"m""i""e""n""t""r""a""s"" "{CONDICION}{KA}

START_IF	"s""i"" "{CONDICION}"" "?{KA}
START_ELSE	{KC}" ""s""i""n"o"" "?{KA}

COMENTARIO	"*""-"({LETRA}|{DIGITO})*"-""*"

%%
      
{CTE}			{printf("\nConstante: %s\n", yytext);return CTE;}
{CONST_STRING}  {printf("\nString: %s\n", yytext);return CONST_STRING;}
{ID}			{printf("\nIdentificador: %s\n", yytext);return ID;}
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
.			 { printf( "ERROR LEXICO : Caracter no reconocido: %s\n", yytext ); exit (0);}

%%