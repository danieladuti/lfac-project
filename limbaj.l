%{
#include <stdio.h>
#include "limbaj.tab.h"
%}
%option noyywrap
%%
"int"|"float"|"char"|"string"|"bool"|"vector" {yylval.string = strdup(yytext);return TYPE;}
"=="|">="|"<="|"!="|"<"|">" {return COMPARE;}
"||" {return COMPARE_SAU;}
"&&" {return COMPARE_SI;}
"class" {return CLASS;}
"private"|"protected"|"public" {return TYPE_CLASS;}
"if"|"while" {return CTRL;}
"for" {return CTRL1;}
"return" {return RET;}
"true" {return ADEVARAT;}
"false" {return FALS;}
"int main" {return BGIN;}
[0-9]*[a-zA-Z][a-zA-Z0-9]* {yylval.string = strdup(yytext); return ID;}
"=" {return ASSIGN;}
[0-9]+ {return NR;}

[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

 