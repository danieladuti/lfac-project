
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
     ParamList* ptrParamList;
}
%token BGIN ASSIGN
%token<string> ID TYPE RET CTRL CTRL1 ADEVARAT FALS CLASS TYPE_CLASS NR NR_FLOAT TEXT CARACTER COMPARE SI SAU
%type<ptrASTNode> e func_call bool_e
%type<ptrParamList> call_list
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
                    }  
                    '(' list_param ')' 
                    { 
                         nume = ""; 
                         current = new SymTable($2, current);
                         SymTable* copy_current = current->prev;
                         ParamList* plist = copy_current->getParams($2);
                         for(int i = 0; i < plist->parametri.size(); i++)
                              current->addVar(plist->parametri[i].first, plist->parametri[i].second, 1);
                    } 
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

statement_class : TYPE ID ASSIGN e 
                                   { 
                                        if(!current->existsId($2, "var")) 
                                        {
                                             current->addVar($1, $2, 1);
                                             Value v;
                                             string tip_variabila = $1;
                                             if(tip_variabila == "int")
                                                  v.int_value = 2;
                                             else if(tip_variabila == "float")
                                                  v.float_value = 2.0;
                                             else if(tip_variabila == "string" || tip_variabila == "char")
                                                  v.string_value = "2";
                                             else if(tip_variabila == "bool")
                                                  v.bool_value = true;
                                             current->assignValue($2, v);
                                        } 
                                        else 
                                        {
                                             errorCount++;
                                             yyerror("Variable already defined");
                                        }   
                                   }
                | array
                | TYPE ID 
                         { 
                              if(!current->existsId($2, "var")) 
                              {
                                   current->addVar($1, $2, 1);
                                   Value v;
                                   string tip_variabila = $1;
                                   if(tip_variabila == "int")
                                        v.int_value = 2;
                                   else if(tip_variabila == "float")
                                        v.float_value = 2.0;
                                   else if(tip_variabila == "string" || tip_variabila == "char")
                                        v.string_value = "2";
                                   else if(tip_variabila == "bool")
                                        v.bool_value = true;
                                   current->assignValue($2, v); 
                              }
                              else 
                              {
                                   errorCount++;
                                   yyerror("Variable already defined");
                              }
                         }
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
                              {
                                   current->addVar($1, $2, 1);
                                   string tip = GetASTType($4);
                                   Value v = GetASTValue($4);
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
                                        string tip_variabila = $1;
                                        if(tip_variabila != tip)
                                        {
                                             errorCount++;
                                             yyerror("Error: Left and right operand types do not match");
                                        }
                                        else AssignValue($2, v, current);
                                   }
                              } 
                              else 
                              {
                                   errorCount++;
                                   yyerror("Variable already defined");
                              }     
                            }
         | TYPE ID ASSIGN bool_e { 
                                   if(!current->existsId($2, "var")) 
                                   {
                                        current->addVar($1, $2, 1);
                                        string tip = GetASTType($4);
                                        Value v = GetASTValue($4);
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
                                             string tip_variabila = $1;
                                             if(tip_variabila != tip)
                                             {
                                                  errorCount++;
                                                  yyerror("Error: Left and right operand types do not match");
                                             }
                                             else AssignValue($2, v, current);
                                        }
                                   } 
                                   else 
                                   {
                                        errorCount++;
                                        yyerror("Variable already defined");
                                   }  
                                 }
         | TYPE ID ASSIGN TEXT { 
                                   if(!current->existsId($2, "var")) 
                                   {
                                        current->addVar($1, $2, 1);
                                        Value v;
                                        v.string_value = $4;
                                        string tip_variabila = $1;
                                        if(tip_variabila != "string")
                                        {
                                             errorCount++;
                                             yyerror("Error: Left and right operand types do not match");
                                        }
                                        else AssignValue($2, v, current);
                                   } 
                                   else 
                                   {
                                        errorCount++;
                                        yyerror("Variable already defined");
                                   } 
                               }
         | TYPE ID ASSIGN CARACTER { 
                                        if(!current->existsId($2, "var")) 
                                        {
                                             current->addVar($1, $2, 1);
                                             Value v;
                                             v.string_value = $4;
                                             string tip_variabila = $1;
                                             if(tip_variabila != "char")
                                             {
                                                  errorCount++;
                                                  yyerror("Error: Left and right operand types do not match");
                                             }
                                             else AssignValue($2, v, current);
                                        } 
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
                            else
                            {
                                   Value v;
                                   v.string_value = $3;
                                   string tip_variabila = GetType($1, "var", current);
                                   if(tip_variabila != "string")
                                   {
                                        errorCount++;
                                        yyerror("Error: Left and right operand types do not match");
                                   }
                                   else AssignValue($1, v, current);
                            }
                          }
         | ID ASSIGN CARACTER { 
                                if(!VerifId($1, "var", current))
                                {
                                     errorCount++;
                                     yyerror("Variable is not defined");
                                }
                                else
                                {
                                     Value v;
                                     v.string_value = $3;
                                     string tip_variabila = GetType($1, "var", current);
                                     if(tip_variabila != "char")
                                     {
                                          errorCount++;
                                          yyerror("Error: Left and right operand types do not match");
                                     }
                                     else AssignValue($1, v, current);
                                }
                              }
         | return_net
         | array
         | TYPE ID { 
                    if(!current->existsId($2, "var")) 
                    {
                         current->addVar($1, $2, 1);
                         Value v;
                         string tip_variabila = $1;
                         if(tip_variabila == "int")
                              v.int_value = 2;
                         else if(tip_variabila == "float")
                              v.float_value = 2.0;
                         else if(tip_variabila == "string" || tip_variabila == "char")
                              v.string_value = "2";
                         else if(tip_variabila == "bool")
                              v.bool_value = true;
                         current->assignValue($2, v); 
                    }
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
                                   string nume_functie = $1;
                                   if(nume_functie == "Print")
                                   {
                                        if($3->parametri.size() > 1)
                                        {
                                             errorCount++;
                                             yyerror("Function parameters do not match");
                                        }
                                        else
                                        {
                                             string tip = GetASTType($3->expr);
                                             if(tip == "Error: Types do not coincide in tree")
                                             {
                                                  errorCount++;
                                                  yyerror("Error: Types do not coincide in tree");
                                             }
                                             else
                                             {
                                                  Value v = GetASTValue($3->expr);
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
                                                       cout << "Print: Tip:" << tip << " Valoare:";
                                                       if(tip == "int")
                                                            cout << v.int_value;
                                                       else if(tip == "float")
                                                            cout << v.float_value;
                                                       else if(tip == "string" || tip == "char")
                                                            cout << v.string_value;
                                                       else if(tip == "bool")
                                                            cout << v.bool_value;
                                                       cout << "\n";
                                                  }
                                             }
                                        }
                                   }
                                   else if(nume_functie == "TypeOf")
                                   {
                                        if($3->parametri.size() > 1)
                                        {
                                             errorCount++;
                                             yyerror("Function parameters do not match");
                                        }
                                        else
                                        {
                                             string tip = GetASTType($3->expr);
                                             if(tip == "Error: Types do not coincide in tree")
                                             {
                                                  errorCount++;
                                                  yyerror("Error: Types do not coincide in tree");
                                             }
                                             else cout << "TypeOf: Tip: " << tip << "\n";
                                        }
                                   }
                                   else if(!VerifId($1, "func", current))
                                   {
                                        Value v;
                                        v.string_value = "Eroare";
                                        $$ = new ASTNode($1, v, "eroare");
                                        errorCount++;
                                        yyerror("Function is not defined");
                                   }
                                   else
                                   {
                                        Value v;     
                                        string tip_variabila = GetType($1, "func", current);
                                        ParamList* plist = GetParams($1, current);
                                        if($3->parametri.size() != plist->parametri.size())
                                        {
                                             errorCount++;
                                             yyerror("Function parameters do not match");
                                        }
                                        else
                                        {
                                             for(int i = 0; i < $3->parametri.size(); i++)
                                             {
                                                  if($3->parametri[i].first != plist->parametri[i].first)
                                                  {
                                                       errorCount++;
                                                       yyerror("Function parameters do not match");
                                                       break;
                                                  }
                                             }
                                        }
                                        if(tip_variabila == "int")
                                             v.int_value = 2;
                                        else if(tip_variabila == "float")
                                             v.float_value = 2.0;
                                        else if(tip_variabila == "string" || tip_variabila == "char")
                                             v.string_value = "2";
                                        else if(tip_variabila == "bool")
                                             v.bool_value = true;
                                        $$ = new ASTNode($1, v, tip_variabila);
                                   }
                                 }
          | ID'.'ID '(' call_list ')' {
                              if(!VerifId($1, "var", current))
                              {
                                   Value v;
                                   v.string_value = "Eroare";
                                   $$ = new ASTNode($1, v, "eroare");
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
                                        Value v;
                                        v.string_value = "Eroare";
                                        $$ = new ASTNode($1, v, "eroare");
                                        errorCount++;
                                        yyerror("Function is not defined");
                                   }
                                   else
                                   {
                                        Value v;
                                        string tip_variabila = GetType($3, "func", copy_current);
                                        ParamList* plist = GetParams($3, copy_current);
                                        if($5->parametri.size() != plist->parametri.size())
                                        {
                                             errorCount++;
                                             yyerror("Function parameters do not match");
                                        }
                                        else
                                        {
                                             for(int i = 0; i < $5->parametri.size(); i++)
                                             {
                                                  if($5->parametri[i].first != plist->parametri[i].first)
                                                  {
                                                       errorCount++;
                                                       yyerror("Function parameters do not match");
                                                  }
                                             }
                                        }
                                        if(tip_variabila == "int")
                                             v.int_value = 2;
                                        else if(tip_variabila == "float")
                                             v.float_value = 2.0;
                                        else if(tip_variabila == "string" || tip_variabila == "char")
                                             v.string_value = "2";
                                        else if(tip_variabila == "bool")
                                             v.bool_value = true;
                                        $$ = new ASTNode($1, v, tip_variabila);
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
               else
               {
                    string tip = GetASTType($5);
                    if(tip == "Error: Types do not coincide in tree")
                    {
                         errorCount++;
                         yyerror("Error: Types do not coincide in tree");
                    }
                    else
                    {
                         Value v = GetASTValue($5);
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
                              string tip_variabila = GetType($3, "var", current);
                              if(tip_variabila != tip)
                              {
                                   errorCount++;
                                   yyerror("Error: Left and right operand types do not match");
                              }
                              else AssignValue($3, v, current);
                         }
                    }
               }
               current = new SymTable("block", current); 
          } 
          '{' list '}' { current = current->prev; }
          | CTRL1 '(' TYPE ID ASSIGN e ';' bool_e ';' ID ASSIGN e ')' 
          { 
               current = new SymTable("block", current); 
               current->addVar($3, $4, 1);
               string tip = GetASTType($6);
               Value v = GetASTValue($6);
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
                    string tip_variabila = $3;
                    if(tip_variabila != tip)
                    {
                         errorCount++;
                         yyerror("Error: Left and right operand types do not match");
                    }
                    else AssignValue($4, v, current);
               }
          } '{' list '}' { current = current->prev; }
          | CTRL1 '(' ';' bool_e ';' ID ASSIGN e ')' 
          {
               if(!VerifId($6, "var", current))
               {
                    errorCount++;
                    yyerror("Variable is not defined");
               }
               else
               {
                    string tip = GetASTType($8);
                    if(tip == "Error: Types do not coincide in tree")
                    {
                         errorCount++;
                         yyerror("Error: Types do not coincide in tree");
                    }
                    else
                    {
                         Value v = GetASTValue($8);
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
                              string tip_variabila = GetType($6, "var", current);
                              if(tip_variabila != tip)
                              {
                                   errorCount++;
                                   yyerror("Error: Left and right operand types do not match");
                              }
                              else AssignValue($6, v, current);
                         }
                    }
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
               else
               {
                    string tip = GetASTType($5);
                    if(tip == "Error: Types do not coincide in tree")
                    {
                         errorCount++;
                         yyerror("Error: Types do not coincide in tree");
                    }
                    else
                    {
                         Value v = GetASTValue($5);
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
                              string tip_variabila = GetType($3, "var", current);
                              if(tip_variabila != tip)
                              {
                                   errorCount++;
                                   yyerror("Error: Left and right operand types do not match");
                              }
                              else AssignValue($3, v, current);
                         }
                    } 
               }
               current = new SymTable("block", current); 
          } 
          '{' list '}' { current = current->prev; }
          | CTRL1 '(' TYPE ID ASSIGN e ';' bool_e ';' ')' 
          { 
               current = new SymTable("block", current); 
               current->addVar($3, $4, 1); 
               string tip = GetASTType($6);
               Value v = GetASTValue($6);
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
                    string tip_variabila = $3;
                    if(tip_variabila != tip)
                    {
                         errorCount++;
                         yyerror("Error: Left and right operand types do not match");
                    }
                    else AssignValue($4, v, current);
               }
          } '{' list '}' { current = current->prev; }
          | CTRL1 '(' ';' bool_e ';'')' { current = new SymTable("block", current); } '{' list '}' { current = current->prev; }
          ;

array : TYPE ID '[' NR ']' ASSIGN '{' nr_list '}' 
          {
               if(!current->existsId($2, "var")) 
               {
                    current->addVar($1, $2, 1);
                    Value v;
                    string tip_variabila = $1;
                    if(tip_variabila == "int")
                         v.int_value = 2;
                    else if(tip_variabila == "float")
                         v.float_value = 2.0;
                    else if(tip_variabila == "string" || tip_variabila == "char")
                         v.string_value = "2";
                    else if(tip_variabila == "bool")
                         v.bool_value = true;
                    current->assignValue($2, v); 
               }
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
               Value v;
               string tip_variabila = $1;
               if(tip_variabila == "int")
                    v.int_value = 2;
               else if(tip_variabila == "float")
                    v.float_value = 2.0;
               else if(tip_variabila == "string" || tip_variabila == "char")
                    v.string_value = "2";
               else if(tip_variabila == "bool")
                    v.bool_value = true;
               current->assignValue($2, v);
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
          {
               current->addVar($1, $2, stoi($4));
               Value v;
               string tip_variabila = $1;
               if(tip_variabila == "int")
                    v.int_value = 2;
               else if(tip_variabila == "float")
                    v.float_value = 2.0;
               else if(tip_variabila == "string" || tip_variabila == "char")
                    v.string_value = "2";
               else if(tip_variabila == "bool")
                    v.bool_value = true;
               current->assignValue($2, v);
          }
          else 
          {
               errorCount++;
               yyerror("Variable already defined");
          }  
      }
      | TYPE '*' ID 
      { 
          if(!current->existsId($3, "var")) 
          {
               current->addVar($1, $3, 1);
               Value v;
               string tip_variabila = $1;
               if(tip_variabila == "int")
                    v.int_value = 2;
               else if(tip_variabila == "float")
                    v.float_value = 2.0;
               else if(tip_variabila == "string" || tip_variabila == "char")
                    v.string_value = "2";
               else if(tip_variabila == "bool")
                    v.bool_value = true;
               current->assignValue($3, v);
          } 
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
  | '(' e ')' { $$ = $2; }
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
                    Value v;
                    v.string_value = "Eroare";
                    $$ = new ASTNode($1, v, "eroare");
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
                    if(GetSize($1, current) > 1)
                    {
                         errorCount++;
                         yyerror("Array used as variable");
                    }
                    string type = GetType($1, "var", current);
                    Value v = GetValue($1, "var", current);
                    $$ = new ASTNode($1, v, type);
               }
               else
               {
                    Value v;
                    v.string_value = "Eroare";
                    $$ = new ASTNode($1, v, "eroare");
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
                    Value v;
                    v.string_value = "Eroare";
                    $$ = new ASTNode($1, v, "eroare");
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
                         Value v;
                         v.string_value = "Eroare";
                         $$ = new ASTNode($1, v, "eroare");
                         errorCount++;
                         yyerror("Variable is not defined");
                    }

                    Value v;
                    string tip = copy_current->getType($3, "var");
                    if(tip == "int")
                         v.int_value = 2;
                    else if(tip == "float")
                         v.float_value = 2.0;
                    else if(tip == "string" || tip == "char")
                         v.string_value = "2";
                    else if(tip == "bool")
                         v.bool_value = true;
                    $$ = new ASTNode($3, v, tip);
               }
            }
  ;

bool_e : e COMPARE e { $$ = new ASTNode($2, $1, $3); }
       | bool_e SI bool_e { $$ = new ASTNode($2, $1, $3); }
       | bool_e SAU bool_e { $$ = new ASTNode($2, $1, $3); }
       | '(' bool_e ')' { $$ = $2; }
       ;
           
call_list : call_list ',' e { $$ = new ParamList($1, $3->VerifType(), "nume_var"); }
           | e { $$ = new ParamList($1->VerifType(), "nume_var", $1); }
           | func_call { $$ = new ParamList($1->VerifType(), "nume_var"); }
           | call_list ',' func_call { $$ = new ParamList($1, $3->VerifType(), "nume_var"); }
           | /*epsilon*/ { $$ = NULL; }
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