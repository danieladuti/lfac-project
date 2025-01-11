%{
#include <stdio.h>
#include "SymTable.h"
#include "limbaj.tab.h"
%}
%option noyywrap
%%
"int"|"float"|"char"|"string"|"bool"|"vector" {yylval.string = strdup(yytext);return TYPE;}
"=="|">="|"<="|"!="|"<"|">" {return COMPARE;}
"||" {return SAU;}
"&&" {return SI;}
"class" {return CLASS;}
"private"|"protected"|"public" {return TYPE_CLASS;}
"if"|"while" {return CTRL;}
"for" {return CTRL1;}
"return" {return RET;}
"true" {yylval.string = strdup(yytext); return ADEVARAT;}
"false" {yylval.string = strdup(yytext); return FALS;}
"int main" {return BGIN;}
[0-9]*[a-zA-Z][a-zA-Z0-9]* {yylval.string = strdup(yytext); return ID;}
\"(\\.|[^"\\])*\" {yylval.string = strdup(yytext); return TEXT;}
\'(\\.|[^"\\])\' {yylval.string = strdup(yytext); return CARACTER;}
"=" {return ASSIGN;}
[0-9]+ {yylval.string = strdup(yytext); return NR;}
[0-9]+[.][0-9]+ {yylval.string = strdup(yytext); return NR_FLOAT;}

[ \t] ;
\n {yylineno++;}
. {return yytext[0];}

 