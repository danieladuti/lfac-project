
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
%type<ptrASTNode> e
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

e : e '+' e 
  | e '-' e 
  | e '*' e   
  | e '/' e
  | e '+' func_call
  | func_call '+' e
  | e '-' func_call
  | func_call '-' e 
  | e '*' func_call 
  | func_call '*' e  
  | e '/' func_call    
  | func_call '/' e
  | '(' e ')'
  | ID '[' NR ']'
  | NR { /*current->ids[nume].int_val[0] = stoi($1);*/ }
  | NR_FLOAT { /*current->ids[nume].float_val[0] = stof($1);*/ }
  | ID    { 
               /*SymTable* search = current;
               while(search->ids[$1].idType == "" || search->name == "global")
                    search = search->prev;
               //daca nu e nici in global de adaugat eroare sintactica
               if(current->ids[nume].idType == "int")
                    current->ids[nume].int_val = search->ids[$1].int_val;
               else if(current->ids[nume].idType == "string" || current->ids[nume].idType == "char")
                    current->ids[nume].text = search->ids[$1].text;
               else if(current->ids[nume].idType == "bool")
                    current->ids[nume].bool_val = search->ids[$1].bool_val;
               else if(current->ids[nume].idType == "float")
                    current->ids[nume].float_val = search->ids[$1].float_val;
               //else current->ids[nume].params.parametri = search->ids[$1].params.parametri;*/
          }
  | ADEVARAT
  | FALS
  | ID'.'ID
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