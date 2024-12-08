%{
#include <iostream>
#include <vector>
#include "SymTable.h"
extern FILE* yyin;
extern char* yytext;
extern int yylineno;
extern int yylex();
void yyerror(const char * s);
class SymTable* current;
int errorCount = 0;
%}
%union {
     char* string;
}
%token  BGIN END ASSIGN NR 
%token<string> ID TYPE RET
%start progr


%left '+' '-' 
%left '*' '/'


%%
progr :  declarations main {if (errorCount == 0) cout<< "The program is correct!" << endl;}
      ;

declarations : decl           
	      |  declarations decl    
	      ;

decl       :  TYPE ID ';' { 
                              if(!current->existsId($2)) {
                                    current->addVar($1,$2);
                              } else {
                                   errorCount++; 
                                   yyerror("Variable already defined");
                              }
                          }
              | TYPE ID  '(' list_param ')' ';'
              | TYPE ID  '(' list_param ')' '{' list '}'
           ;

list_param : param
            | list_param ','  param 
            ;
            
param : TYPE ID 
      ; 
      

main : BGIN list END  
     ;
     

list :  statement ';' 
     | list statement ';'
     ;

statement: ID '(' call_list ')'
         | ID '('')'
         | ID ASSIGN e
         | TYPE ID ASSIGN e
         | RET ID
         | RET NR
         | type_list
         | array
         ;

type_list : type_list ',' tip
          | tip
          ;

tip : ID
    |param
    ;

array : TYPE ID '[' NR ']' ASSIGN '{' nr_list '}'
      | TYPE ID '['']' ASSIGN '{' nr_list '}'
      | TYPE '*' ID 
      ;

nr_list : nr_list ',' NR
        | NR
        ;

e : e '+' e   {  cout <<"e->e+e\n";}
  | e '*' e   {  cout << "e->e*e\n";}
  | NR { cout << "e->"<<endl; }
  | ID { cout << "e->"<<endl; }
  ;
           
        
call_list : call_list ',' e
           | e
           ;
%%
void yyerror(const char * s){
     cout << "error:" << s << " at line: " << yylineno << endl;
}

int main(int argc, char** argv){
     yyin=fopen(argv[1],"r");
     current = new SymTable("global");
     yyparse();
     cout << "Variables:" <<endl;
     current->printVars();
     delete current;
} 