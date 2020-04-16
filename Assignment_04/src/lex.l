%{
     #include "parser.tab.h"
     #define MAX_LEN 1024
%}


%%
>                                                       { return MORE; } 
[)]                                                     { return RP; } 
[(]                                                     { return LP; } 
=                                                       { return EQUAL; } 
[,]                                                     { return COMMA; }
[<]                                                     { return LESS; }
"<="                                                    { return LESSEQUAL; }
">="                                                    { return MOREEQUAL; }
"<>"                                                    { return NOTEQUAL; }
[ \n\t]                                                 ; 
[0-9]+                                                  { 
                                                          char *new_str = (char*) malloc(sizeof(char) * MAX_LEN);
                                                          strcpy(new_str , yytext);
                                                          yylval.str = new_str;
                                                          return NUM; 
                                                        }
[']                                                     { return QUOTE; }
[.]                                                     { return DOT; }
;                                                       { return SEMI; }
(?i:AND)                                                { return AND; }
(?i:OR)                                                      { return OR; }  
(?i:NOT)                                                   { return NOT; }  
(?i:SELECT)                                                { return SELECT; }
(?i:PROJECT)                                              { return PROJECT; }
(?i:CARTESIAN_PRODUCT)                                     { return CARTESIAN_PRODUCT; }
(?i:EQUI_JOIN)                                             { return EQUI_JOIN; }
[a-zA-Z][a-zA-Z0-9_]*                                    {
                                                          char *new_str = (char*) malloc(sizeof(char) * MAX_LEN);
                                                          strcpy(new_str , yytext);
                                                          yylval.str = new_str;
                                                          return ID; 
                                                        }
%%

int yywrap()
{  
    return 1; 
}
