#include "hashtable.h"
#include <stdio.h>
#include <ctype.h>
#include <string.h>
struct HashNode{
    char* str;
    int idx;
};

struct HashNode arr[MAX];
static int cntt=0;

void insert(char* str){
    struct HashNode x;
    x.str=str;
    x.idx=cntt;
    arr[cntt]=x;
    cntt++;
}

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
    for(int i=0;i<cntt;i++){
        if(strcmp(arr[i].str,str)==0){
            // printf("%s %s %d %d\n",arr[i].str,str,arr[i].idx,cntt);
            return arr[i].idx;
        }
    }
    return -1;
}





