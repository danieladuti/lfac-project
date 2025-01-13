#include "SymTable.h"
using namespace std;

ofstream fout("SymTables.txt");

vector<SymTable*> tabels;
string nume;

ASTNode::ASTNode(string root, Value value, string type)
{
    stanga = NULL;
    dreapta = NULL;
    this->root = root;
    this->value = value;
    this->type = type;
}

ASTNode::ASTNode(string op, ASTNode* st)
{
    this->root = op;
    stanga = st;
    dreapta = NULL;
}

Value Value::CalcResult(Value A, Value B, string st_type, string root)
{
    Value C;
    if((root == "+" || root == "-" || root == "*" || root == "/" || root == ">=" || root == "<=" || root == ">" || root == "<" ||
        root == "&&" || root == "||") && (st_type == "string" || st_type == "char"))
        C.string_value = "Eroare";
    if((root == "+" || root == "-" || root == "*" || root == "/" || root == ">=" || root == "<=" || root == ">" || root == "<") && (st_type == "bool"))
        C.string_value = "Eroare";
    if((root == "&&" || root == "||") && (st_type == "int" || st_type == "float"))
        C.string_value = "Eroare";
    if(root == "+")
    {
        if(st_type == "int")
            C.int_value = A.int_value + B.int_value;
        else if(st_type == "float")
            C.float_value = A.float_value + B.float_value;
    }
    else if(root == "-")
    {
        if(st_type == "int")
            C.int_value = A.int_value - B.int_value;
        else if(st_type == "float")
            C.float_value = A.float_value - B.float_value;
    }
    else if(root == "*")
    {
        if(st_type == "int")
            C.int_value = A.int_value * B.int_value;
        else if(st_type == "float")
            C.float_value = A.float_value * B.float_value;
    }
    else if(root == "/")
    {
        if(st_type == "int")
            C.int_value = A.int_value / B.int_value;
        else if(st_type == "float")
            C.float_value = A.float_value / B.float_value;
    }
    else if(root == ">=")
    {
        if(st_type == "int")
            C.bool_value = (A.int_value >= B.int_value);
        else if(st_type == "float")
            C.bool_value = (A.float_value >= B.float_value);
    }
    else if(root == "<=")
    {
        if(st_type == "int")
            C.bool_value = (A.int_value <= B.int_value);
        else if(st_type == "float")
            C.bool_value = (A.float_value <= B.float_value);
    }
    else if(root == ">")
    {
        if(st_type == "int")
            C.bool_value = (A.int_value > B.int_value);
        else if(st_type == "float")
            C.bool_value = (A.float_value > B.float_value);
    }
    else if(root == "<")
    {
        if(st_type == "int")
            C.bool_value = (A.int_value < B.int_value);
        else if(st_type == "float")
            C.bool_value = (A.float_value < B.float_value);
    }
    else if(root == "==")
    {
        if(st_type == "int")
            C.bool_value = (A.int_value == B.int_value);
        else if(st_type == "float")
            C.bool_value = (A.float_value == B.float_value);
        else if(st_type == "string" || st_type == "char")
            C.bool_value = (A.string_value == B.string_value);
        else if(st_type == "bool")
            C.bool_value = (A.bool_value == B.bool_value);
    }
    else if(root == "!=")
    {
        if(st_type == "int")
            C.bool_value = (A.int_value != B.int_value);
        else if(st_type == "float")
            C.bool_value = (A.float_value != B.float_value);
        else if(st_type == "string" || st_type == "char")
            C.bool_value = (A.string_value != B.string_value);
        else if(st_type == "bool")
            C.bool_value = (A.bool_value != B.bool_value);
    }
    else if(root == "&&")
        if(st_type == "bool")
            C.bool_value = (A.bool_value && B.bool_value);
    else if(root == "||")
        if(st_type == "bool")
            C.bool_value = (A.bool_value || B.bool_value);
    return C;  
}

Value Value::Negate(Value A)
{
    Value C;
    C.bool_value = (!A.bool_value);
    return C;
}

string ASTNode::VerifType()
{
    if(root == "+" || root == "-" || root == "*" || root == "/" || root == ">=" || root == "<=" || root == "==" || root == ">" 
        || root == "<" || root == "!=" || root == "==" || root == "&&" || root == "||")
    {
        if(stanga->VerifType() == dreapta->VerifType())
        {
            type = stanga->type;
            return stanga->type;
        }
        return "Erorr: Types do not coincide in tree";
    }
    else if(root == "!")
    {
        if(stanga->VerifType() == "bool")
        {
            type = stanga->type;
            return stanga->type;
        }
        return "Error: Types do not coincide";
    }
    return type;
}

Value ASTNode::EvalTree()
{
    if(root == "+" || root == "-" || root == "*" || root == "/" || root == ">=" || root == "<=" || root == "==" || root == ">" 
        || root == "<" || root == "!=" || root == "&&" || root == "||")
        return value.CalcResult(stanga->EvalTree(), dreapta->EvalTree(), stanga->type, root);
    else if(root == "!")
        return value.Negate(stanga->EvalTree());
    return value;
}

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

ParamList::ParamList(string type, string name)
{
    this->addParam(type, name);
}

ParamList::ParamList(string type, string name, ASTNode* e)
{
    this->addParam(type, name);
    expr = e;
}

ParamList::ParamList(ParamList* p, string type, string name)
{
    this->parametri = p->parametri;
    this->addParam(type, name);
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

void SymTable::printVars() 
{
    for (pair<string, IdInfo> v : ids) {
        cout << v.second.idType << " name: " << v.first << " type:" << v.second.type << " valoare:";
        if(v.second.idType != "func" && v.second.idType != "clasa")
        {
            if(v.second.type == "int")
                cout << v.second.int_val[0];
            else if(v.second.type == "float")
                cout << v.second.float_val[0];
            else if(v.second.type == "string" || v.second.type == "char")
                cout << v.second.text[0];
            else if(v.second.type == "bool")
                cout << v.second.bool_val[0];
            cout << " " << v.second.size;
        } 
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
        fout << v.second.idType << " name: " << v.first << " type:" << v.second.type << " valoare:";
        if(v.second.idType != "func" && v.second.idType != "clasa")
        {
            if(v.second.type == "int")
                fout << v.second.int_val[0];
            else if(v.second.type == "float")
                fout << v.second.float_val[0];
            else if(v.second.type == "string" || v.second.type == "char")
                fout << v.second.text[0];
            else if(v.second.type == "bool")
                fout << v.second.bool_val[0];
            fout << " " << v.second.size; 
        }
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
        {
            tip = it->second.type;
            break;
        }
    return tip;
}

Value SymTable::getValue(string name, string idType)
{
    map<string, IdInfo>::iterator it;
    Value valoare;
    for(it = ids.begin(); it != ids.end(); ++it)
        if(it->first == name && it->second.idType == idType)
        {
            if(it->second.type == "int")
                valoare.int_value = it->second.int_val[0];
            else if(it->second.type == "float")
                valoare.float_value = it->second.float_val[0];
            else if(it->second.type == "string" || it->second.type == "char")
                valoare.string_value = it->second.text[0];
            else if(it->second.type == "bool")
                valoare.bool_value = it->second.bool_val[0];
            break;
        }
    return valoare;
}

void SymTable::assignValue(string name, Value v)
{
    map<string, IdInfo>::iterator it;
    string tip;
    for(it = ids.begin(); it != ids.end(); ++it)
        if(it->first == name && it->second.idType == "var")
        {
            if(it->second.type == "int")
                it->second.int_val[0] = v.int_value;
            else if(it->second.type == "float")
                it->second.float_val[0] = v.float_value;
            else if(it->second.type == "string" || it->second.type == "char")
                it->second.text[0] = v.string_value;
            else if(it->second.type == "bool")
                it->second.bool_val[0] = v.bool_value;
            break;
        }
}

ParamList* SymTable::getParams(string name)
{
    map<string, IdInfo>::iterator it;
    ParamList *p = new ParamList();
    for(it = ids.begin(); it != ids.end(); ++it)
        if(it->first == name && it->second.idType == "func")
        {
            p->parametri = it->second.params.parametri;
            break;
        }
    return p;
}

int SymTable::getSize(string name)
{
    map<string, IdInfo>::iterator it;
    int var_size = 0;
    for(it = ids.begin(); it != ids.end(); ++it)
        if(it->first == name && it->second.idType == "var")
        {
            var_size = it->second.size;
            break;
        }
    return var_size;
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

Value GetValue(string name, string idType, SymTable* current)
{
    SymTable* copy_current = current;
    while(!copy_current->existsId(name, idType)) 
        copy_current = copy_current->prev;
    return copy_current->getValue(name, idType);
}

void AssignValue(string name, Value v, SymTable* current)
{
    SymTable* copy_current = current;
    while(!copy_current->existsId(name, "var")) 
        copy_current = copy_current->prev;
    copy_current->assignValue(name, v);
}

ParamList* GetParams(string name, SymTable* current)
{
    SymTable* copy_current = current;
    while(!copy_current->existsId(name, "func")) 
        copy_current = copy_current->prev;
    return copy_current->getParams(name);
}

int GetSize(string name, SymTable* current)
{
    SymTable* copy_current = current;
    while(!copy_current->existsId(name, "var")) 
        copy_current = copy_current->prev;
    return copy_current->getSize(name);
}

string GetASTType(ASTNode* arbore)
{
    return arbore->VerifType();
}

Value GetASTValue(ASTNode* arbore)
{
    return arbore->EvalTree();
}

SymTable::~SymTable() 
{
    ids.clear();
}











