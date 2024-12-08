#!/bin/bash

echo "compiling $1"
rm -f lex.yy.c
rm -f $1.tab.c
rm -f $1
bison -d $1.y     #o sa genereze si un header cu token(?)
lex $1.l
g++ lex.yy.c  $1.tab.c -o $1
