#include "SymTable.h"
using namespace std;

vector<SymTable*> tabels;

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

void SymTable::addVar(string type, string name, string domain_name) {
    name += " ";
    name += domain_name;
    IdInfo var(type, name, "var");
    ids[name] = var;
}

void SymTable::addFuncNoClass(string type, string name, string domain_name)
{
    name += " ";
    name += domain_name;
    IdInfo func(type, name, "func");
    ids[name] = func;
}

void SymTable::addFunc(string type, string name, string class_name, string domain_name)
{
    name += " ";
    name += domain_name;
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

void SymTable::printVars() {
    for (pair<string, IdInfo> v : ids) {
        cout << v.second.idType << " name: " << v.first << " type:" << v.second.type << endl;
        if(v.second.idType == "func")
        {
            cout << "Parametri:\n";
            for(pair<string, string> x : v.second.params.parametri)
                cout << x.first << " " << x.second << " ";
            cout << "\n";
        } 
     }
}

SymTable::~SymTable() {
    ids.clear();
}











