%{
#include <iostream>
extern int yylex();
void yyerror(const char* s);
using namespace std;
%}

%start s
%token NR

%left '+' '-' 
%left '*'

%%                                  
s : e  {$$=$1; cout << "s->e\n valoarea expresiei:" << $$ << endl;}
  ;
e : e '+' e   {$$=$1+$3;  cout <<"e->e+e\n";}
  | e '*' e   {$$=$1*$3;  cout << "e->e*e\n";}
  |'(' e ')' {$$= $2;  cout << "e->(e)\n";  }
  | NR {$$=$1; cout << "e->"<<$1<<endl; }
  ;
  
%%
void yyerror(const char* s) {
 cout << "error: "<< s << endl;
}

int main(){
 yyparse();
}
