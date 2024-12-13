%{
#include <stdio.h>
#include "limbaj.tab.h"
%}
%option noyywrap
%%
"int"|"float"|"char"|"string"|"bool"|"vector" {yylval.string = strdup(yytext);return TYPE;}
"if"|"while" {return CTRL;}
"for" {return CTRL1;}
"return" {return RET;}
"==" | ">=" | "=<" | "!=" | "<" | ">" {return COMPARE;}
"true" {return ADEVARAT;}
"false" {return FALS;}
"begin_progr" {return BGIN;}
"end_progr" {return END;}
[0-9]*[a-zA-Z][a-zA-Z0-9]* {yylval.string = strdup(yytext); return ID;}
"=" {return ASSIGN;}
[0-9]+ {return NR;}

[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

 
