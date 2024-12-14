
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
%token  BGIN ASSIGN NR COMPARE
%token<string> ID TYPE RET CTRL CTRL1 ADEVARAT FALS CLASS TYPE_CLASS
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
           | declarations decl_class
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
            | /*epsilon*/
            ;
            
param : TYPE ID 
      ; 
      
decl_class : CLASS ID '{' list_c '}'
           ;

list_c : list_c TYPE_CLASS ':' 
       | list_c statement_class ';'
       | statement_class ';'
       | decl_func
       | list_c decl_func
       | ID'('')' '{' list '}'
       | list_c ID'('')' '{' list '}'
       | list_c '~'ID'('')' '{' list '}'
       | '~'ID'('')' '{' list '}'
       ;

statement_class : TYPE ID ASSIGN e
                | array
                | TYPE ID 
                | ID '[' NR ']' ASSIGN e
                ;

main : BGIN '(' list_param ')' '{' list '}' 
     ;
     

list :  statement ';' 
     | list statement ';'
     | control_s
     | list control_s
     ;

statement: func_call
         | ID ASSIGN e
         | TYPE ID ASSIGN e
         | ID '[' NR ']' ASSIGN e
         | return_net
         | array
         | TYPE ID
         | ID ID
         | ID'.'ID ASSIGN e
         | ID'.'func_call
         ;

return_net: RET ID
          | RET NR
          ;

func_call : ID '(' call_list ')'
          ;

control_s : CTRL '(' bool_e ')' '{' list '}' 
          | CTRL1 '(' ID ASSIGN e ';' bool_e ';' ID ASSIGN e ')' '{' list '}'
          | CTRL1 '(' TYPE ID ASSIGN e ';' bool_e ';' ID ASSIGN e ')' '{' list '}'
          | CTRL1 '(' ';' bool_e ';' ID ASSIGN e ')' '{' list '}'
          | CTRL1 '(' ID ASSIGN e ';' bool_e ';' ')' '{' list '}'
          | CTRL1 '(' TYPE ID ASSIGN e ';' bool_e ';' ')' '{' list '}'
          | CTRL1 '(' ';' bool_e ';'')' '{' list '}'
          ;

array : TYPE ID '[' NR ']' ASSIGN '{' nr_list '}'
      | TYPE ID '['']' ASSIGN '{' nr_list '}'
      | TYPE ID '[' NR ']'
      | TYPE '*' ID
      ;

nr_list : nr_list ',' NR
        | NR
        ;

e : e '+' e   
  | e '*' e   
  | e '/' e
  | e '-' e
  | ID '[' NR ']'
  | NR 
  | ID 
  | ADEVARAT
  | FALS
  | ID'.'ID
  ;

bool_e : e COMPARE e
       ;
           
call_list : call_list ',' e
           | e
           | func_call
           | call_list ',' func_call
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
