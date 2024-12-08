%{
#include "expr.tab.h"
#include "header.h"
%}
%option noyywrap
%%
[0-9]+ {yylval.Int = atoi(yytext); return NR;}
[a-zA-Z]+ {yylval.String = strdup(yytext); return STRING;}
[ \t] ;
\n {return 0;}
. {return yytext[0];}
