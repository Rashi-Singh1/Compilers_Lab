#include "hashtable.h"

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

int lookup(char* str){
    for(int i=0;i<cntt;i++){
        if(strcmp(arr[i].str,str)==0){
            // printf("%s %s %d %d\n",arr[i].str,str,arr[i].idx,cntt);
            return arr[i].idx;
        }
    }
    return -1;
}





