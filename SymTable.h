#include <iostream>
#include <map>
#include <string>
#include <list>
#include <vector>
#include <fstream>

using namespace std;

extern ofstream fout;

class ParamList {
    public:
    //          type   name
    vector<pair<string,string>> parametri;
    ParamList() {}
    void addParam(string type, string name);
};

class IdInfo {
    public:
    string idType; //variabila/functie/clasa
    string type;
    string name;
    vector<bool> bool_val; //pentru variabile bool
    vector<int> int_val; //pentru variabile int
    vector<string> text; //pentru stringuri
    vector<float> float_val; //pentru float
    int size; //pentru vectori
    string class_name; //pentru functii
    ParamList params; //pentru functii si clase
    IdInfo() {}
    //constructor variabile si functii fara clasa in care apartin
    IdInfo(string type, string name, string idType) : type(type),name(name), idType(idType) {}
    //constructor functii
    IdInfo(string type, string name, string idType, string class_name) : type(type),name(name),idType(idType),class_name(class_name) {}
    //constructor clase
    IdInfo(string name, string idType) : name(name), idType(idType) {}
};

class Value
{
    public:
    string string_value;
    int int_value;
    float float_value;
    bool bool_value;
    public:
    Value CalcResult(Value A, Value B, string st_type, string root);
    Value Negate(Value A);
};

class ASTNode
{
    public:
    string root; //nume variabila/functie
    Value value;
    string type;
    ASTNode* stanga, *dreapta;

    ASTNode(string op, ASTNode* st, ASTNode* dr) : root(op), stanga(st), dreapta(dr) {}
    ASTNode(string op, ASTNode* st);
    ASTNode(string root, Value value, string type);

    Value EvalTree();
    string VerifType();
};

class SymTable {
    public:
    map<string, IdInfo> ids; //salvam informatii despre simboluri
    string name; //numele scopului
    SymTable* prev;
    SymTable(string name); //pentru global scope
    SymTable(string name, SymTable* prev); //restul
    //bool existsId(string s);
    void addVar(string type, string name, int size);
    void addFuncNoClass(string type, string name);
    void addFunc(string type, string name, string class_name);
    void addClass(string name);
    void printVars();
    void printVarstoFile();
    bool existsId(string name, string idType);
    string getType(string name, string idType);
    Value getValue(string name, string idType);
    void assignValue(string name, Value v);
    ~SymTable();
};

extern vector<SymTable*> tabels;
extern string nume;

bool VerifId(string name, string idType, SymTable* current);
string GetType(string name, string idType, SymTable* current);
Value GetValue(string name, string idType, SymTable* current);
void AssignValue(string name, Value v, SymTable* current);
string GetASTType(ASTNode* arbore);
Value GetASTValue(ASTNode* arbore);

