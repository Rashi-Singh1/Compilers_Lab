#include "hashtable.h"
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <iostream>
#include <bits/stdc++.h>
using namespace std;
static int cntt=0;

unordered_map<string,int> symbols;

void insert(char* str){
    string temp(str);
    cout<<temp<<" is being inserted in INSERT ******"<<endl<<endl;
    if(symbols.count(temp) == 0) symbols[str] = cntt++;
}

//To print symbol table
void print()
{
    FILE *fptr,*fptr2;

   // opening file in writing mode
    fptr = fopen("symbol_table.txt", "a");
    fptr2 = fopen("lex_output.txt", "a");

    fprintf(fptr2,"\nSymbol Table : \n<Token_id, lexeme>\n");
    fprintf(fptr,"\n<Token_id, lexeme>\n");
    for(auto x : symbols)
    {
        // fprintf(fptr2,"\t%d, %s\n",x.second,x.first);
        // fprintf(fptr,"\t%d, %s\n",x.second,x.first);
        cout<<x.second<<"\t"<<x.first<<endl;
    }cout<<endl;
   // closing file
    fclose(fptr2);
    fclose(fptr);
}

int lookup(char* str){
    string temp(str);
    cout<<temp<<" is being looked up"<<endl;
    if(symbols.count(temp) > 0) return symbols[temp];
    return -1;
}





