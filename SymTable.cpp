#include "SymTable.h"
using namespace std;

ofstream fout("SymTables.txt");

vector<SymTable*> tabels;
string nume;

SymTable::SymTable(string name)
{
    this->name = name;
    tabels.push_back(this);
}

SymTable::SymTable(string name, SymTable* prev)
{
    this->name = name;
    tabels.push_back(this);
    this->prev = prev;
}

void ParamList::addParam(string type, string name)
{
    parametri.push_back({type, name});
}

void SymTable::addVar(string type, string name, int size, string domain_name) 
{
    nume = name;
    IdInfo var(type, name, "var");
    if(size != 0)
    {
        var.size = size;
        if(type == "bool")
            var.bool_val.resize(size);
        else if(type == "char" || type == "string")
            var.text.resize(size);
        else if(type == "int")
            var.int_val.resize(size);
        else if(type == "float")
            var.float_val.resize(size);
    }
    ids[name] = var;
}

void SymTable::addFuncNoClass(string type, string name, string domain_name)
{
    nume = name;
    IdInfo func(type, name, "func");
    ids[name] = func;
}

void SymTable::addFunc(string type, string name, string class_name, string domain_name)
{
    nume = name;
    IdInfo func(type, name, "func", class_name);
    ids[name] = func;
}

void SymTable::addClass(string name)
{
    IdInfo clasa(name, "clasa");
    ids[name] = clasa;
}


/*bool SymTable::existsId(string var) {
    return ids.find(var)!= ids.end();  
}*/

void SymTable::printVars() 
{
    for (pair<string, IdInfo> v : ids) {
        cout << v.second.idType << " name: " << v.first << " type:" << v.second.type;
        if(v.second.idType != "func" && v.second.idType != "clasa")
            cout << " " << v.second.size; 
        cout << "\n";
        if(v.second.idType == "func")
        {
            cout << "Parametri:\n";
            for(pair<string, string> x : v.second.params.parametri)
                cout << x.first << " " << x.second << " ";
            cout << "\n";
        } 
     }
}

void SymTable::printVarstoFile()
{
    for (pair<string, IdInfo> v : ids) {
        fout << v.second.idType << " name: " << v.first << " type:" << v.second.type;
        if(v.second.idType != "func" && v.second.idType != "clasa")
            fout << " " << v.second.size; 
        fout << "\n";
        if(v.second.idType == "func")
        {
            fout << "Parametri:\n";
            for(pair<string, string> x : v.second.params.parametri)
                fout << x.first << " " << x.second << " ";
            fout << "\n";
        } 
     }
}

SymTable::~SymTable() 
{
    ids.clear();
}











