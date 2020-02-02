#include "lex.h"
#include "hashtable.h"
#include <stdio.h>
#include <ctype.h>
#include <string.h>


int isKeyWord(int val){
    if(val == IF || val == THEN || val == WHILE || val == DO || val == BEGIN 
        || val == END)
        {
            return 1;
        }
    return 0;
}

int isOperator(int val){
    if(val == PLUS || val == MINUS || val == MUL || val == DIV || val == LESS 
        || val == MORE || val == EQUAL || val == ASSIGN)
        {
            return 1;
        }
    return 0;
}

int isIdetifier(int val){
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
    }else if(isIdetifier(val)){
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




char* yytext = ""; /* Lexeme (not '\0'
                      terminated)              */
int yyleng   = 0;  /* Lexeme length.           */
int yylineno = 0;  /* Input line number        */

void tokenize();

int lex(void){

   static char input_buffer[1024];
   char        *current;

   current = yytext + yyleng; /* Skip current
                                 lexeme        */

   while(1){       /* Get the next one         */
      while(!*current ){
         /* Get new lines, skipping any leading
         * white space on the line,
         * until a nonblank line is found.
         */

         current = input_buffer;
         if(!gets(input_buffer)){
            *current = '\0' ;
            return EOI;
         }
         ++yylineno;
         while(isspace(*current))
            ++current;
      }
      for(; *current; ++current){
         /* Get the next token */
         yytext = current;
         yyleng = 1;
         switch( *current ){
            case ';':
               return SEMI;
            case ':':
               yytext = current;
               if((current+1) && *(current+1) == '='){
                  yyleng =2;
                  return ASSIGN;
               }
               else{
                  fprintf(stderr, "Invalid syntax. Expected '=' <%c>\n", *current);                 
                  return ERR;
               }
            case '>':
               return MORE;
            case '<':
               return LESS;
            case '=':
               return EQUAL;
            case '+':
               return PLUS;
            case '-':
               return MINUS;
            case '*':
               return MUL;
            case '/':
               return DIV;
            case '\n':
            case '\t':
            case ' ' :
            break;
            default:
               if(!isalnum(*current)){
                  yytext = current; yyleng = 1;
                  fprintf(stderr, "Not alphanumeric <%c>\n", *current);
                  return ERR;
               }
               else{
                  // To store the keyword/identifier
                  char temp[1000]="";
                  int alpha_seen = 0;
                  while(current && isalnum(*current)){
                      if(isalpha(*current)){
                         alpha_seen = 1;
                      }
                     strncat(temp, current,1);
                     ++current;
                  }
                  // fprintf(stderr, "current : %s yylength : %d yytext : %s temp : %s\n", current, yyleng, yytext, temp);
                  yyleng = current - yytext;
                  // yytext = current;
                  // fprintf(stderr, "current : %s yylength : %d yytext : %s temp : %s\n", current, yyleng, yytext, temp);
                  // if (!alpha_seen){
                  //    return CONST;
                  // }
                  if(!strcmp(temp, "if")){
                     return IF;
                  }
                  else if(!strcmp(temp, "then")){
                     return THEN;
                  }
                  else if(!strcmp(temp, "while")){
                     return WHILE;
                  }
                  else if(!strcmp(temp, "do")){
                     return DO;
                  }
                  else if(!strcmp(temp, "begin")){
                     return BEGIN;
                  }
                  else if(!strcmp(temp, "end")){
                     return END;
                  }
                  else{
                     return NUM_OR_ID;
                  }
               }
            break;
         }
      }
   }
}


static int Lookahead = -1; /* Lookahead token  */

int match(int token){
   /* Return true if "token" matches the
      current lookahead symbol.                */
   if(Lookahead == -1)
      Lookahead = lex();
   return token == Lookahead;
}

void advance(void){
/* Advance the lookahead to the next
   input symbol.                               */
    Lookahead = lex();

}

void tokenize(){

   FILE *fptr;

   // opening file in writing mode
    fptr = fopen("lex.txt", "a");
   
   char* temp=(char*)malloc(sizeof(char)*(yyleng+1));
   for(int i=0;i<yyleng;i++){
      *(temp+i)=*(yytext+i);
   }
   *(temp+yyleng)='\0';

   if(isSemi(Lookahead) || isConst(Lookahead) || isKeyWord(Lookahead) || isOperator(Lookahead)){
      // printf("%d %s %d %0.*s\n",Lookahead,temp,isConst(Lookahead),yyleng,yytext);
      fprintf(fptr, "<\"%0.*s\", %s>", yyleng,yytext,token_class(Lookahead));
   }else if(isIdetifier(Lookahead)){
      int idx=lookup(temp);
      if(idx==-1){
         insert(temp);
         idx=lookup(temp);
      }
      // printf("%s %d\n",temp,idx);
      fprintf(fptr, "<\"%0.*s\", %s, %d>", yyleng, yytext,token_class(Lookahead),idx);
   }else{
      fprintf(fptr, "<\"%0.*s\", %s>", yyleng,yytext,token_class(Lookahead));
   }

   // closing file
    fclose(fptr);
}

void lexically_analyse(void){
    while(!match(EOI)){
        tokenize();
        advance();
    }
}