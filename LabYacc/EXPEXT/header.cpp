#include "header.h"
using namespace std;

List::List(int x) {
    add(x);
}

void List::add(int x) {
    list.push_back(x);
}

void List::print() {
    cout << "[ ";
    for (auto i : list)
        cout << i << " ";
    cout << " ]";
    cout << endl;
}

List::~List() {
    list.clear();
}




