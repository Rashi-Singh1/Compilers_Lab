%{
     #include "parser.tab.h"
     #define MAX_LEN 1024
%}


%%
[)]                                                     { return RP; } 
[(]                                                     { return LP; } 
[}]                                                     { return CRP; } 
[{]                                                     { return CLP; } 
[=]                                                     { return ASSIGN; } 
[+]                                                     { return ADD; } 
[-]                                                     { return MINUS; } 
[*]                                                     { return MUL; } 
[/]                                                     { return DIV; } 
[%]                                                     { return MOD; } 
[&]                                                     { return BITAND; } 
[|]                                                     { return BITOR; } 
[~]                                                     { return BITNOT; } 
"^"                                                     { return BITXOR; } 
[?]                                                     { return QUES; } 
"&&"                                                    { return AND; } 
"||"                                                    { return OR; } 
[!]                                                     { return NOT; } 
[,]                                                     { return COMMA; }
[>]                                                     { return MORE; } 
[<]                                                     { return LESS; }
"<="                                                    { return LESSEQUAL; }
">="                                                    { return MOREEQUAL; }
"=="                                                    { return EQUAL; }
"!="                                                    { return NOTEQUAL; }
[\n]                                                    { yylineno++; } 
[ \t]                                                    ;
[0-9]+                                                  { 
                                                          char *new_str = (char*) malloc(sizeof(char) * MAX_LEN);
                                                          strcpy(new_str , yytext);
                                                          yylval.str = new_str;
                                                          return NUM; 
                                                        }
[']                                                     { return QUOTE; }
[.]                                                     { return DOT; }
[;]                                                     { return SEMI; }
[:]                                                     { return COLON; }
(NULL)                                                  { return null; }
(false)                                                 { return FALSE; }
(true)                                                  { return TRUE; }
(for)                                                   { return FOR; }
(while)                                                 { return WHILE; }
(int)                                                   { return INT; }
(float)                                                 { return FLOAT; }
(void)                                                  { return VOID; }
(main)                                                  { return MAIN; }
(if)                                                    { return IF; }
(else)                                                  { return ELSE; }
(switch)                                                { return SWITCH; }
(case)                                                  { return CASE; }
(default)                                               { return DEFAULT; }
(break)                                               { return BREAK; }
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
