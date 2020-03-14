#include "hashtable.h"
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <iostream>
#include <fstream>
#include <bits/stdc++.h>
using namespace std;

static int cntt=0;

ofstream symbolTableFile;
ofstream lexOutputFile;

unordered_map<string,int> symbols;

void insert(char* str){
    string temp(str);
    // cout<<temp<<" is being inserted in INSERT ******"<<endl<<endl;
    if(symbols.count(temp) == 0) symbols[str] = cntt++;
}

//To print symbol table
void print()
{
    symbolTableFile.open("symbol_table.txt",std::ios_base::app);
    lexOutputFile.open("lex_output.txt",std::ios_base::app);

    lexOutputFile<<"\nSymbol Table : \n<Token_id\t lexeme>"<< endl;    
    symbolTableFile<<"\n<Token_id\t lexeme>"<< endl;    
    for(auto x : symbols)
    {
        lexOutputFile<<"\t"<<x.second<<"\t "<<x.first<<endl;
        symbolTableFile<<"\t"<<x.second<<"\t "<<x.first<<endl;
    }
   // closing file
    symbolTableFile.close();
    lexOutputFile.close();
}

int lookup(char* str){
    string temp(str);
    // cout<<temp<<" is being looked up"<<endl;
    if(symbols.count(temp) > 0) return symbols[temp];
    return -1;
}





