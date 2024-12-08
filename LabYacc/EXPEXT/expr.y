%{
#include <iostream>
#include <cstring>
#include "header.h"

using namespace std;
extern int yylex();
void yyerror(const char* s);
%}

%start s

%union {
  int Int;
  class List * ListPtr;
  class Str* StrPtr;
  char* String;
}

%token<String> STRING
%token<Int> NR
%type<Int> e 
%type<ListPtr> list
%type<StrPtr> str

%left '+' '-' 
%left '*'
%%
s : e {cout << "valoare:"<< $1 << endl;}
  | str {cout << "valoare:" << $1->getStr() << endl;  delete $1;}
  | '[' list ']' {cout << "valori:"; $2->print(); cout << endl;  delete $2; }
  ;

list :  e {$$ = new List($1); }
     | list ',' e {
         $$ = $1; $$->add($3) ;
      }
      ;
  
e :  e '+' e  {$$ = $1 + $3; }
  |  e '*' e  {$$ = $1 * $3;}
  |  '(' e ')' {$$ = $2; }
  |  NR {$$ = $1;}
  ;

str : str '+' str {
                    $$ = new Str(*$1 + *$3);
                    delete $1; 
                    delete $3; 
                  }
       | STRING { $$ = new Str($1); }
    ;
%%

void yyerror(const char* s) {
  cout << "error:" << s;
}

int main(){
 yyparse();
}
