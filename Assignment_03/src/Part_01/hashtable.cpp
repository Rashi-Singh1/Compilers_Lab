#include "hashtable.h"
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <iostream>
using namespace std;
struct HashNode{
    char* str;
    int idx;
};

struct HashNode arr[MAX];
static int cntt=0;

void insert(char* str){
    struct HashNode x;
    cout<<str<<" is being inserted in INSERT **********"<<endl<<endl;
    string temp(str);
    x.str=temp;
    x.idx=cntt;
    arr[cntt]=x;
    cntt++;
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
    for(int i = 0;i<cntt;i++)
    {
        fprintf(fptr2,"\t%d, %s\n",arr[i].idx,arr[i].str);
        fprintf(fptr,"\t%d, %s\n",arr[i].idx,arr[i].str);
    }

   // closing file
    fclose(fptr2);
    fclose(fptr);
}

int lookup(char* str){
    cout<<"Lookup of "<<str<<" is happeneing"<<endl;
    for(int i=0;i<cntt;i++){
        cout<<arr[i].str<<" at index "<<i<<endl;
        if(strcmp(arr[i].str,str)==0){
            // printf("%s %s %d %d\n",arr[i].str,str,arr[i].idx,cntt);
            return arr[i].idx;
        }
    }cout<<endl<<endl;
    return -1;
}





