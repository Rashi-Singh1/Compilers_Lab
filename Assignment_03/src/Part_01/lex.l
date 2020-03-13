%{
#include "lex.h"
#include "hashtable.h"
#include <string.h>
#include <fstream>
extern int Lookahead = -1;
%}

%%
;                                                       return SEMI; 
>                                                       return MORE; 
[)]                                                     return RP; 
[(]                                                     return LP; 
=                                                       return ASSIGN; 
==                                                      return EQUAL;
:                                                       return COLON; 
[{]                                                     return CLP;
[}]                                                     return CRP;
[+]                                                     return PLUS;
[-]                                                     return MINUS;
[*]                                                     return MUL;
[/]                                                     return DIV;
[,]                                                     return COMMA;
[<]                                                     return LESS;
[ \n\t]                                                 ;
"if"                                                    return IF;
"else"                                                  return ELSE;
"main"                                                  return MAIN;
"class"                                                 return CLASS;
"then"                                                  return THEN;
"const"                                                 return CONST;
"while"                                                 return WHILE;
"do"                                                    return DO;
(int|char|string|double|float|bool|void)                return DATA_TYPE;
"begin"                                                 return START;
"end"                                                   return FIN;
"operator"                                              return OPERATOR;
"return"                                                return RETURN;
::                                                      return SCOPE;
(private|public|protected)                              return MOD;
(true|false)                                            return BOOLEAN;
[A-z][A-z0-9_]*                                         return NUM_OR_ID;
.                                                       return ERR;
%%

int yywrap()
{
    return 1;
}


int isKeyWord(int val){
    if(val == IF || val == THEN || val == WHILE || val == DO || val == START || val == CLASS || val == MOD || val == OPERATOR || val == ELSE || val == MAIN || val == RETURN
        || val == FIN || val == BOOLEAN || val == DATA_TYPE)
        {
            return 1;
        }
    return 0;
}

int isOperator(int val){
    if(val == PLUS || val == MINUS || val == MUL || val == DIV || val == LESS || val == CLP || val == CRP || val == LP || val == RP || val == COLON || val == COMMA || val == MORE || val == EQUAL || val == ASSIGN)
        {
            return 1;
        }
    return 0;
}

int isIdentifier(int val){
    if(val == NUM_OR_ID)
   {
            return 1;
   }
    return 0;
}

int isConst(int val){
   //  if(val == CONST){
   //      return 1;
   //  }
   for(int i = 0; i < yyleng; i++){
      if((yytext+i)){
         char ch=*(yytext+i);
         if(!(ch<='9' && ch>='0')){
            return 0;
         }
      }
   }
   return 1;
}

int isSemi(int val){
    if(val == SEMI){
        return 1;
    }
    return 0;
}

char * token_class(int val){
    if(isKeyWord(val)){
        return "kw";
    }
    else if(isOperator(val)){
        return "op";
    }else if(isIdentifier(val)){
       if(isConst(val)){
         //  printf("%0.*s\n",yyleng,yytext);
         return "const";
      }
        return "id";
    }
    else if(isSemi(val)){
        return "semi";
    } 
    else{
        return "err";
    }
}


void advance()
{
    // ofstream debugFile;
    // debugFile.open("output/debug_file.txt",std::ios_base::app);
    // debugFile<<"advance called"<< endl;  
    // debugFile<<yytext<<endl;      
    // debugFile.close();
    Lookahead = yylex();
}

int match(int token)
{
    if(Lookahead == -1)
        Lookahead = yylex();
    return token == Lookahead;
}


void lexically_analyse(void){
    printf("lex.l wala lexically analyse\n");
    FILE *fptr;

   // opening file in writing mode
    fptr = fopen("lex_output.txt", "a");
    fprintf(fptr,"Token Stream : <Token-class, lexeme>\n\n\t");
    fclose(fptr);

    Lookahead = yylex();
    FILE *fptr2;

   // opening file in writing mode
    fptr = fopen("lex_output.txt", "a");
    fptr2 = fopen("token_stream.txt", "a");
    while(Lookahead){
        if(isIdentifier(Lookahead)){
            int idx=lookup(yytext);
            if(idx==-1){
                // printf("%s is being inserted\n",yytext);
                insert(yytext);
                idx=lookup(yytext);
            }
            // printf("%s %d\n",yytext,idx);
            fprintf(fptr, "<%s,%d>  ", token_class(Lookahead),idx);
            fprintf(fptr2, "<%s,%d>  ", token_class(Lookahead),idx);
        }else{
            fprintf(fptr, "<%s,%s>  ",token_class(Lookahead),yytext);
            fprintf(fptr2, "<%s,%s>  ",token_class(Lookahead),yytext);
        }
        Lookahead = yylex();
    }
 // closing file
    fclose(fptr);
    fclose(fptr2);
   // opening file in writing mode
    fptr = fopen("lex_output.txt", "a");
    fprintf(fptr,"\n");
    fclose(fptr);

    //print the symbol table
    print();

}