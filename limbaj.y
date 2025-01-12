
%{
#include <iostream>
#include <string>
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
     ASTNode* ptrASTNode;
}
%token BGIN ASSIGN COMPARE SI SAU CARACTER
%token<string> ID TYPE RET CTRL CTRL1 ADEVARAT FALS CLASS TYPE_CLASS NR NR_FLOAT TEXT 
%type<ptrASTNode> e func_call
%start progr

%left SAU
%left SI
%left COMPARE
%left '+' '-' 
%left '*' '/' 


%%
progr :  declarations main {if (errorCount == 0) cout<< "The program is correct!" << endl;}
      ;

declarations : decl
           | decl_func
           | decl_class
	      | declarations decl
           | declarations decl_func   
           | declarations decl_class
	      ;

decl       :  TYPE ID ';' { 
                              current->addVar($1, $2, 1);
                          }
           ;

decl_func : TYPE ID {
                         if(current->name != "global")
                              current->addFunc($1, $2, current->name);
                         else
                              current->addFuncNoClass($1, $2);
                    }  '(' list_param ')' { nume = ""; current = new SymTable($2, current); } 
                    '{' list '}' { current = current->prev; }
          ;

decl_class : CLASS ID { current->addClass($2); current = new SymTable($2, current); } '{' list_c '}' { current = current->prev; }
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

statement_class : TYPE ID ASSIGN e { current->addVar($1, $2, 1); }
                | array
                | TYPE ID { current->addVar($1, $2, 1); }
                | ID '[' NR ']' ASSIGN e
                ;

list_param : param
            | list_param ','  param 
            | /*epsilon*/
            ;
            
param : TYPE ID { current->ids[nume].params.addParam($1, $2); }
      ; 

main : BGIN { current->addFuncNoClass("int", "main"); }  
       '(' list_param ')' { nume = ""; current = new SymTable("main", current); } 
       '{' list '}' { current = current->prev; } 
     ;
     

list :  statement ';' 
     | list statement ';'
     | control_s
     | list control_s
     ;

statement: func_call
         | ID ASSIGN e { 
                         if(!VerifId($1, "var", current))
                         {
                              errorCount++;
                              yyerror("Variable is not defined");
                         }
                         else
                         {
                              string tip = GetASTType($3);
                              if(tip == "Error: Types do not coincide in tree")
                              {
                                   errorCount++;
                                   yyerror("Error: Types do not coincide in tree");
                              }
                              else
                              {
                                   Value v = GetASTValue($3);
                                   if(v.string_value == "Eroare")
                                   {
                                        errorCount++;
                                        if(tip == "int")
                                             yyerror("Error: Operation not supported by type int");
                                        else if(tip == "float")
                                             yyerror("Error: Operation not supported by type float");
                                        else if(tip == "string")
                                             yyerror("Error: Operation not supported by type string");
                                        else if(tip == "char")
                                             yyerror("Error: Operation not supported by type char");
                                        else if(tip == "bool")
                                             yyerror("Error: Operation not supported by type bool");
                                   }
                                   else
                                   {
                                        string tip_variabila = GetType($1, "var", current);
                                        if(tip_variabila != tip)
                                        {
                                             errorCount++;
                                             yyerror("Error: Left and right operand types do not match");
                                        }
                                        else AssignValue($1, v, current);
                                   }
                              }
                         }
                       }
         | TYPE ID ASSIGN e { 
                              if(!current->existsId($2, "var")) 
                                   current->addVar($1, $2, 1); 
                              else 
                              {
                                   errorCount++;
                                   yyerror("Variable already defined");
                              }     
                            }
         | TYPE ID ASSIGN bool_e { 
                                   if(!current->existsId($2, "var")) 
                                        current->addVar($1, $2, 1); 
                                   else 
                                   {
                                        errorCount++;
                                        yyerror("Variable already defined");
                                   }  
                                 }
         | TYPE ID ASSIGN TEXT { 
                                   if(!current->existsId($2, "var")) 
                                        current->addVar($1, $2, 1); 
                                   else 
                                   {
                                        errorCount++;
                                        yyerror("Variable already defined");
                                   } 
                               }
         | TYPE ID ASSIGN CARACTER { 
                                        if(!current->existsId($2, "var")) 
                                             current->addVar($1, $2, 1); 
                                        else 
                                        {
                                             errorCount++;
                                             yyerror("Variable already defined");
                                        } 
                                   }
         | ID '[' NR ']' ASSIGN e { 
                                   if(!VerifId($1, "var", current))
                                   {
                                        errorCount++;
                                        yyerror("Variable is not defined");
                                   }
                                  }
         | ID '[' NR ']' ASSIGN bool_e {
                                        if(!VerifId($1, "var", current))
                                        {
                                             errorCount++;
                                             yyerror("Variable is not defined");
                                        }
                                       }
         | ID '[' NR ']' ASSIGN TEXT {  
                                        if(!VerifId($1, "var", current))
                                        {
                                             errorCount++;
                                             yyerror("Variable is not defined");
                                        }
                                     }
         | ID '[' NR ']' ASSIGN CARACTER { 
                                           if(!VerifId($1, "var", current))
                                           {
                                                errorCount++;
                                                yyerror("Variable is not defined");
                                           }
                                        }
         | ID ASSIGN TEXT { 
                            if(!VerifId($1, "var", current))
                            {
                                 errorCount++;
                                 yyerror("Variable is not defined");
                            }
                          }
         | ID ASSIGN CARACTER { 
                                if(!VerifId($1, "var", current))
                                {
                                     errorCount++;
                                     yyerror("Variable is not defined");
                                }
                              }
         | return_net
         | array
         | TYPE ID { 
                    if(!current->existsId($2, "var")) 
                        current->addVar($1, $2, 1); 
                    else 
                    {
                         errorCount++;
                         yyerror("Variable already defined");
                    }  
                   }
         | ID ID { 
                    if(!current->existsId($2, "var")) 
                         current->addVar($1, $2, 1); 
                    else 
                    {
                         errorCount++;
                         yyerror("Variable already defined");
                    }  
                 }
         | ID'.'ID ASSIGN e { 
                              if(!VerifId($1, "var", current))
                              {
                                   errorCount++;
                                   yyerror("Variable is not defined");
                              }
                              else
                              {
                                   string clasa_origine = GetType($1, "var", current);
                                   SymTable* copy_current = current;
                                   for(auto x : tabels)
                                        if(x->name == clasa_origine)
                                        {
                                             copy_current = x;
                                             break;
                                        }
                                   if(!copy_current->existsId($3, "var"))
                                   {
                                        errorCount++;
                                        yyerror("Variable is not defined");
                                   }
                              }
                            }
         ;

return_net: RET ID { 
                     if(!VerifId($2, "var", current))
                     {
                          errorCount++;
                          yyerror("Variable is not defined");
                     }
                   }
          | RET NR
          ;

func_call : ID '(' call_list ')' { 
                                   if(!VerifId($1, "func", current))
                                   {
                                        errorCount++;
                                        yyerror("Function is not defined");
                                   }
                                   //else nume = $1;
                                 }
          | ID'.'ID '(' call_list ')' {
                              if(!VerifId($1, "var", current))
                              {
                                   errorCount++;
                                   yyerror("Variable is not defined");
                              }
                              else
                              {
                                   string clasa_origine = GetType($1, "var", current);
                                   SymTable* copy_current = current;
                                   for(auto x : tabels)
                                        if(x->name == clasa_origine)
                                        {
                                             copy_current = x;
                                             break;
                                        }
                                   if(!copy_current->existsId($3, "func"))
                                   {
                                        errorCount++;
                                        yyerror("Function is not defined");
                                   }
                              }
                         }
          ;

control_s : CTRL '(' bool_e ')' { current = new SymTable("block", current); } '{' list '}' { current = current->prev; }
          | CTRL1 '(' ID ASSIGN e ';' bool_e ';' ID ASSIGN e ')' 
          { 
               if(!VerifId($3, "var", current))
               {
                    errorCount++;
                    yyerror("Variable is not defined");
               }
               current = new SymTable("block", current); 
          } 
          '{' list '}' { current = current->prev; }
          | CTRL1 '(' TYPE ID ASSIGN e ';' bool_e ';' ID ASSIGN e ')' { current = new SymTable("block", current); current->addVar($3, $4, 1); } '{' list '}' { current = current->prev; }
          | CTRL1 '(' ';' bool_e ';' ID ASSIGN e ')' 
          {
               if(!VerifId($6, "var", current))
               {
                    errorCount++;
                    yyerror("Variable is not defined");
               } 
               current = new SymTable("block", current); 
          } 
          '{' list '}' { current = current->prev; }
          | CTRL1 '(' ID ASSIGN e ';' bool_e ';' ')' 
          { 
               if(!VerifId($3, "var", current))
               {
                    errorCount++;
                    yyerror("Variable is not defined");
               } 
               current = new SymTable("block", current); 
          } 
          '{' list '}' { current = current->prev; }
          | CTRL1 '(' TYPE ID ASSIGN e ';' bool_e ';' ')' { current = new SymTable("block", current); current->addVar($3, $4, 1); } '{' list '}' { current = current->prev; }
          | CTRL1 '(' ';' bool_e ';'')' { current = new SymTable("block", current); } '{' list '}' { current = current->prev; }
          ;

array : TYPE ID '[' NR ']' ASSIGN '{' nr_list '}' 
          {
               if(!current->existsId($2, "var")) 
                    current->addVar($1, $2, stoi($4));
               else 
               {
                    errorCount++;
                    yyerror("Variable already defined");
               }  
          } 
      | TYPE ID '['']' ASSIGN '{' nr_list '}' 
      { 
          if(!current->existsId($2, "var")) 
          {
               current->addVar($1, $2, 0);
               current->ids[nume].size = current->ids[nume].int_val.size();
          } 
          else 
          {
               errorCount++;
               yyerror("Variable already defined");
          }  
      }
      | TYPE ID '[' NR ']' 
      { 
          if(!current->existsId($2, "var")) 
               current->addVar($1, $2, stoi($4));
          else 
          {
               errorCount++;
               yyerror("Variable already defined");
          }  
      }
      | TYPE '*' ID 
      { 
          if(!current->existsId($3, "var")) 
               current->addVar($1, $3, 0); 
          else 
          {
               errorCount++;
               yyerror("Variable already defined");
          } 
      }
      ;

nr_list : nr_list ',' NR { current->ids[nume].int_val.push_back(stoi($3)); }
        | NR { current->ids[nume].int_val.push_back(stoi($1)); }
        ;

e : e '+' e { $$ = new ASTNode("+", $1, $3); }
  | e '-' e { $$ = new ASTNode("-", $1, $3); }
  | e '*' e { $$ = new ASTNode("*", $1, $3); } 
  | e '/' e { $$ = new ASTNode("/", $1, $3); }
  | e '+' func_call { $$ = new ASTNode("+", $1, $3); }
  | func_call '+' e { $$ = new ASTNode("+", $1, $3); }
  | e '-' func_call { $$ = new ASTNode("-", $1, $3); }
  | func_call '-' e { $$ = new ASTNode("-", $1, $3); }
  | e '*' func_call { $$ = new ASTNode("*", $1, $3); }
  | func_call '*' e { $$ = new ASTNode("*", $1, $3); }
  | e '/' func_call { $$ = new ASTNode("/", $1, $3); }   
  | func_call '/' e { $$ = new ASTNode("/", $1, $3); }
  | '(' e ')'
  | ID '[' NR ']' 
          {  
               if(VerifId($1, "var", current))
               {
                    string type = GetType($1, "var", current);
                    Value v;
                    if(type == "int")
                         v.int_value = 2;
                    else if(type == "float")
                         v.float_value = 2.0;
                    else if(type == "string" || type == "char")
                         v.string_value = "2";
                    else if(type == "bool")
                         v.bool_value = true;
                    $$ = new ASTNode($1, v, type);
               }
               else
               {
                    errorCount++;
                    yyerror("Variable is not defined");
               }
          }
  | NR {
          Value v;
          v.int_value = stoi($1); 
          $$ = new ASTNode($1, v, "int"); 
       }
  | NR_FLOAT { 
               Value v;
               v.float_value = stof($1); 
               $$ = new ASTNode($1, v, "float"); 
             }
  | ID    { 
              if(VerifId($1, "var", current))
               {
                    string type = GetType($1, "var", current);
                    Value v = GetValue($1, "var", current);
                    $$ = new ASTNode($1, v, type);
               }
               else
               {
                    errorCount++;
                    yyerror("Variable is not defined");
               }
          }
  | ADEVARAT {
                    Value v;
                    v.bool_value = true;
                    $$ = new ASTNode($1, v, "bool");
             }
  | FALS {
              Value v;
              v.bool_value = false;
              $$ = new ASTNode($1, v, "bool"); 
         }
  | ID'.'ID {
               if(!VerifId($1, "var", current))
               {
                    errorCount++;
                    yyerror("Variable is not defined");
               }
               else
               {
                    string clasa_origine = GetType($1, "var", current);
                    SymTable* copy_current = current;
                    for(auto x : tabels)
                         if(x->name == clasa_origine)
                         {
                              copy_current = x;
                              break;
                         }
                    if(!copy_current->existsId($3, "var"))
                    {
                         errorCount++;
                         yyerror("Variable is not defined");
                    }

                    Value v = copy_current->getValue($3, "var");
                    string tip = copy_current->getType($3, "var");
                    string nume_var = $1;
                    nume_var += ".";
                    nume_var += $3;
                    $$ = new ASTNode(nume_var, v, tip);
               }
            }
  ;

bool_e : e COMPARE e
       | bool_e SI bool_e
       | bool_e SAU bool_e
       | '(' bool_e ')'
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
     cout << "Variables:" << endl;
     for(auto x : tabels)
     {
          cout << "Nume scop:" << x->name << "\n";
          x->printVars();
          cout << "\n";
          if(x->name != "block")
          {
               fout << "Nume scop:" << x->name << "\n";
               x->printVarstoFile();
               fout << "\n";
          }
     }

     delete current;
} 