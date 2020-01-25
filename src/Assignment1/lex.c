#include "lex.h"
#include <stdio.h>
#include <ctype.h>
#include <string.h>


char* yytext = ""; /* Lexeme (not '\0'
                      terminated)              */
int yyleng   = 0;  /* Lexeme length.           */
int yylineno = 0;  /* Input line number        */

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
               current++;
               yytext = current;
               if(current && *current == '='){
                  return ASSIGN;
               }
               else{
                  fprintf(stderr, "Invalid syntax. Expected '=' <%c>\n", *current);
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
               if(!isalnum(*current))
                  fprintf(stderr, "Not alphanumeric <%c>\n", *current);
               else{

                  // To store the keyword/identifier
                  char temp[1000]="";

                  while(current && isalnum(*current)){
                     strncat(temp, current,1);
                     ++current;
                  }
                  // fprintf(stderr, "current : %s yylength : %d yytext : %s temp : %s\n", current, yyleng, yytext, temp);
                  yyleng = current - yytext;
                  // yytext = current;
                  // fprintf(stderr, "current : %s yylength : %d yytext : %s temp : %s\n", current, yyleng, yytext, temp);

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