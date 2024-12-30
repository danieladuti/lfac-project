#include <iostream>
#include <map>
#include <string>
#include <list>
#include <vector>

using namespace std;

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
    string class_name; //pentru functii
    ParamList params; //pentru functii
    IdInfo() {}
    //constructor variabile si functii fara clasa in care apartin
    IdInfo(string type, string name, string idType) : type(type),name(name), idType(idType) {}
    //constructor functii
    IdInfo(string type, string name, string idType, string class_name) : type(type),name(name),idType(idType),class_name(class_name) {}
    //constructor clase
    IdInfo(string name, string idType) : name(name), idType(idType) {}
};



class SymTable {
    public:
    map<string, IdInfo> ids; //salvam informatii despre simboluri
    string name; //numele scopului
    SymTable* prev;
    SymTable(string name); //pentru global scope
    SymTable(string name, SymTable* prev); //restul
    //bool existsId(string s);
    void addVar(string type, string name, string domain_name);
    void addFuncNoClass(string type, string name, string domain_name);
    void addFunc(string type, string name, string class_name, string domain_name);
    void addClass(string name);
    void printVars();
    ~SymTable();
};

extern vector<SymTable*> tabels;



