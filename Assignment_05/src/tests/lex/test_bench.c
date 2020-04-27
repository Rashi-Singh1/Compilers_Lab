#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "../../parser.tab.h"

extern int yylex();
extern int yylineno;
extern char* yytext;
extern YYSTYPE yylval;
void yyerror(const char *s);

void yyerror(const char *s){
    fprintf(stderr, "ERROR: %s\n", s);
    exit(1);
}

YYSTYPE yylval;

int main(int argc, char const *argv[])
{
    printf("Find token_no to token name mappings in ../../parser.tab.h\n");
    printf("yylineno|  token_no,yytext    token_no,yytext    ...\n");
    int token;
    int prv_lineno = 0;
    while(token = yylex()){
        if(yylineno != prv_lineno) {
            printf("\n%d|  ", yylineno);
            prv_lineno = yylineno;
        }

        char *s = yytext;
        printf("%d,%d,%s    ", yylineno, token, s);
    }
    printf("\n");
    return 0;
}