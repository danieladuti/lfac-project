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

void SymTable::addVar(string type, string name, int size) 
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
    else var.size = 0;
    ids[name] = var;
}

void SymTable::addFuncNoClass(string type, string name)
{
    nume = name;
    IdInfo func(type, name, "func");
    ids[name] = func;
}

void SymTable::addFunc(string type, string name, string class_name)
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

bool SymTable::existsId(string name, string idType)
{
    map<string, IdInfo>::iterator it;
    for(it = ids.begin(); it != ids.end(); ++it)
        if(it->first == name && it->second.idType == idType)
            return true;
    return false;
}

string SymTable::getType(string name, string idType)
{
    map<string, IdInfo>::iterator it;
    string tip;
    for(it = ids.begin(); it != ids.end(); ++it)
        if(it->first == name && it->second.idType == idType)
            tip = it->second.type;
    return tip;
}

Value Value::Adunare(Value A, Value B, string type)
{
    Value C;
    if(type == "int")
        C.int_value = A.int_value + B.int_value;
    else if(type == "float")
        C.float_value = A.float_value + B.float_value;
    else if(type == "string" || type == "char")
        C.string_value = "Eroare! Adunare intre string-uri!";
    else C.string_value = "Eroare! Adunare intre bool";
    return C;
}

Value ASTNode::EvalTree()
{
    if(root == "+")
        return value.Adunare(stanga->EvalTree(), dreapta->EvalTree(), type);
}

bool VerifId(string name, string idType, SymTable* current)
{
    SymTable* copy_current = current; 
    while(!copy_current->existsId(name, idType)) 
    {
        if(copy_current->name == "global")
            return false;
        copy_current = copy_current->prev;
    } 
    return true;
}

string GetType(string name, string idType, SymTable* current)
{
    SymTable* copy_current = current;
    while(!copy_current->existsId(name, idType)) 
        copy_current = copy_current->prev;
    return copy_current->getType(name, idType);
}

SymTable::~SymTable() 
{
    ids.clear();
}











