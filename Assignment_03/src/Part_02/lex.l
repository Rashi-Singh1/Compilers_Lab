%{
     #include "parser.tab.h++"
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
[0-9]+                                                  { return NUM; }
[']                                                     { return QUOTE; }
[.]                                                     { return DOT; }
;                                                       { return SEMI; }
(?i:AND)                                                { return AND; }
(?i:OR)                                                      { return OR; }  
(?i:NOT)                                                   { return NOT; }  
(?i:SELECT)                                                { return SELECT; }
(?i:PROJECT)                                              { printf("Projection operation\n"); return PROJECT; }
(?i:CARTESIAN_PRODUCT)                                     { return CARTESIAN_PRODUCT; }
(?i:EQUI_JOIN)                                             { return EQUI_JOIN; }
[a-zA-Z][a-zA-Z0-9]*                                    { return ID; }
%%

int yywrap()
{  
    return 1; 
}
