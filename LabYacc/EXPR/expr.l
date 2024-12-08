%{
#include <stdio.h>
#include "expr.tab.h"
%}
%option noyywrap
%%
[0-9]+ {yylval=atoi(yytext); return NR;}
[ \t] ;     
\n {return 0;}  
. {return yytext[0];}  
