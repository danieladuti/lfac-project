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
%token<string> ID TYPE RET CTRL CTRL1 ADEVARAT FALS COMPARE 
%start progr

%left COMPARE
%left '+' '-' 
%left '*' '/' 


%%
progr :  declarations main {if (errorCount == 0) cout<< "The program is correct!" << endl;}
      ;

declarations : decl
           | decl_func
	      | declarations decl
           | declarations decl_func    
	      ;

decl       :  TYPE ID ';' { 
                              if(!current->existsId($2)) {
                                    current->addVar($1,$2);
                              } else {
                                   errorCount++; 
                                   yyerror("Variable already defined");
                              }
                          }
           ;

decl_func : TYPE ID  '(' list_param ')' '{' list '}'
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

statement: func_call
         | atribuire 
         | return_net
         | array
         | TYPE ID
         | control_s
         ;

return_net: RET ID
          | RET NR
          ;

func_call : ID '(' call_list ')'
          ;

atribuire : ID ASSIGN e
          | TYPE ID ASSIGN e
          ;  

control_s : CTRL '(' bool_e ')' '{' statement '}'
          | CTRL1 '(' atribuire ';' bool_e ';' atribuire ')' '{' statement '}'
          ;

array : TYPE ID '[' NR ']' ASSIGN '{' nr_list '}'
      | TYPE ID '['']' ASSIGN '{' nr_list '}'
      | TYPE '*' ID
      ;

nr_list : nr_list ',' NR
        | NR
        ;

e : e '+' e   
  | e '*' e   
  | e '/' e
  | e '-' e
  | e COMPARE e
  | NR 
  | ID 
  | bool_e
  ;

bool_e : ADEVARAT
       | FALS
       ;
           
call_list : call_list ',' e
           | e
           | /*epsilon*/
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