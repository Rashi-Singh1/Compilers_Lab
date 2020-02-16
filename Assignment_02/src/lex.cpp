#include<bits/stdc++.h>
#include "lex.h"
#include <iostream>
#include <fstream>
#include "hashtable.h"

using namespace std;
int isKeyWord(int val){
    if(val == IF || val == THEN || val == WHILE || val == DO || val == BEGIN || val == CLASS || val == MODE || val == OPERATOR
        || val == END || val == DATA_TYPE)
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
         // if(!fgets(input_buffer)){
         // if(!scanf("%s",input_buffer)){
         if(!fgets(input_buffer, 1024,stdin)){
           
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
            // case ':':
            //    yytext = current;
            //    if((current+1) && *(current+1) == '='){
            //       yyleng =2;
            //       return ASSIGN;
            //    }
            //    else{
            //       fprintf(stderr, "Invalid syntax. Expected '=' <%c>\n", *current);                 
            //       return ERR;
            //    }
            case '>':
               return MORE;
            case '<':
               return LESS;
            case '{':
               return CLP;
            case '}':
               return CRP;
            case '(':
               return LP;
            case ')':
               return RP;
            case '=':
               return EQUAL;
            case ':':
               return COLON;
            case '+':
               return PLUS;
            case '-':
               return MINUS;
            case '*':
               return MUL;
            case '/':
               return DIV;
            case ',':
               return COMMA;
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
                  else if(!strcmp(temp, "class")){
                     return CLASS;
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
                  else if(!strcmp(temp, "int") || !strcmp(temp, "char") || !strcmp(temp, "string") || !strcmp(temp, "double") || !strcmp(temp, "float") || !strcmp(temp, "bool") || !strcmp(temp, "void")){
                     return DATA_TYPE;
                  }
                   else if(!strcmp(temp, "operator")){
                     return OPERATOR;
                  }
                  else if(!strcmp(temp, "private") || !strcmp(temp, "public") || !strcmp(temp, "protected"))
                     return MODE;
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
   string temp(yytext);
   // if(token == Lookahead) cout<<"Matched : "<<temp.substr(yyleng)<<endl;
   return token == Lookahead;
}


void advance(void){
/* Advance the lookahead to the next
   input symbol.  */
   ofstream debugFile;
   debugFile.open("output/debug_file.txt",std::ios_base::app);
   debugFile<<"advance called"<< endl;  
   string temp(yytext);
   debugFile<<temp.substr(yyleng)<<endl;      
   debugFile.close();
   Lookahead = lex();
   

}

void tokenize(){

   FILE *fptr;
   FILE *fptr2;

   // opening file in writing mode
    fptr = fopen("lex_output.txt", "a");
    fptr2 = fopen("token_stream.txt", "a");
   
   char* temp=(char*)malloc(sizeof(char)*(yyleng+1));
   for(int i=0;i<yyleng;i++){
      *(temp+i)=*(yytext+i);
   }
   *(temp+yyleng)='\0';

   if(isSemi(Lookahead) || isConst(Lookahead) || isKeyWord(Lookahead) || isOperator(Lookahead)){
      // printf("%d %s %d %0.*s\n",Lookahead,temp,isConst(Lookahead),yyleng,yytext);
      // fprintf(fptr, "<\"%0.*s\", %s>", yyleng,yytext,token_class(Lookahead));
      fprintf(fptr, "<%s,\"%0.*s\">",token_class(Lookahead), yyleng,yytext);
      fprintf(fptr2, "<%s,\"%0.*s\">",token_class(Lookahead), yyleng,yytext);
   }else if(isIdentifier(Lookahead)){
      int idx=lookup(temp);
      if(idx==-1){
         insert(temp);
         idx=lookup(temp);
      }
      // printf("%s %d\n",temp,idx);
      fprintf(fptr, "<%s, %d>", token_class(Lookahead),idx);
      fprintf(fptr2, "<%s, %d>", token_class(Lookahead),idx);
   }else{
      fprintf(fptr, "<%s,\"%0.*s\">",token_class(Lookahead), yyleng,yytext);
      fprintf(fptr2, "<%s,\"%0.*s\">",token_class(Lookahead), yyleng,yytext);
   }

   // closing file
    fclose(fptr);
    fclose(fptr2);
}

void lexically_analyse(void){
    FILE *fptr;

   // opening file in writing mode
    fptr = fopen("lex_output.txt", "a");
    fprintf(fptr,"Token Stream : <Token-class, lexeme>\n\n\t");
    fclose(fptr);
    while(!match(EOI)){
        tokenize();
        advance();
    }

   // opening file in writing mode
    fptr = fopen("lex_output.txt", "a");
    fprintf(fptr,"\n");
    fclose(fptr);

    //print the symbol table
    print();
}