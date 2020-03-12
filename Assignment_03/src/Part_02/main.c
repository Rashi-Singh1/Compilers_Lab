#include<stdio.h>

extern int yylex();
extern int yylineno;
extern char* yytext;

int main(){
    int ntoken = yylex();
    while(ntoken){
        ntoken = yylex();
    }
    return 0;
}