%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdbool.h>
    #include <string.h>
    int yylex(); 
    void yyerror(const char *s);
    #define YYDEBUG 1

%}

%union {
        char* str;
       }


%start PROGRAM
// %start START

%token RP
%token LP
%token CRP
%token CLP
%token ASSIGN
%token ADD
%token MINUS
%token MUL
%token DIV
%token MOD
%token QUES
%token AND
%token OR
%token NOT
%token BITAND
%token BITOR
%token BITNOT
%token BITXOR
%token COMMA
%token MORE
%token LESS
%token LESSEQUAL
%token MOREEQUAL
%token EQUAL
%token NOTEQUAL
%token QUOTE
%token DOT
%token SEMI
%token COLON
%token null
%token FALSE
%token TRUE
%token FOR
%token WHILE
%token INT
%token FLOAT
%token VOID
%token MAIN
%token IF
%token ELSE
%token SWITCH
%token CASE
%token <str>NUM
%token <str> ID 

/* actual grammar implementation in C*/
%%

PROGRAM : 
        | VAR PROGRAM
        | FUNC_DECLARATION PROGRAM
        | FUNC_DEFINITION PROGRAM
;


VAR: INT MULTI_DECLARATION SEMI{ printf("matched int declaration\n");}
    | FLOAT MULTI_DECLARATION SEMI{printf("matched float declaration\n");}
;

MULTI_DECLARATION : DECLARATION COMMA MULTI_DECLARATION{} 
                  | DECLARATION {printf("matched declaration\n");}
;


DECLARATION : ID
            | ID ASSIGN TYPECAST ID{} 
            | ID ASSIGN TYPECAST CONST_OR_ID{}
;

TYPECAST :
         | LP DATA_TYPE RP {}
;


DATA_TYPE : VOID 
          | INT
          | FLOAT
;

FUNC_DECLARATION : INT ID LP PARAM_LIST_WITH_DATATYPE RP SEMI{printf("matched function declaration\n");}
                 | FLOAT ID LP PARAM_LIST_WITH_DATATYPE RP SEMI{printf("matched function declaration\n");}
                 | VOID ID LP PARAM_LIST_WITH_DATATYPE RP SEMI{printf("matched function declaration\n");}
;

PARAM_LIST_WITH_DATATYPE : 
                         | PARAM_WITH_DATATYPE COMMA PARAM_LIST_WITH_DATATYPE 
                         | PARAM_WITH_DATATYPE{}
;

PARAM_WITH_DATATYPE : DATA_TYPE ID{}
;

FUNC_DEFINITION : DATA_TYPE ID LP PARAM_LIST_WITH_DATATYPE RP CLP STMT_LIST CRP{printf("matched function definition\n");}
;

STMT_LIST : STMT STMT_LIST{} 
          | STMT{}
;

//more additions needed here
STMT : VAR 
     | FUNC_CALL{}
;

FUNC_CALL : ID LP PARAM_LIST_WO_DATATYPE RP SEMI{}
;

//WO : WITHOUT
PARAM_LIST_WO_DATATYPE : PARAM_WO_DATATYPE COMMA PARAM_LIST_WO_DATATYPE 
                       | PARAM_WO_DATATYPE{}
;

//EXP is for part 2 (grammar written by Sparsh Sinha)
PARAM_WO_DATATYPE : null 
                  | BITAND EXP 
                  | BITAND LP EXP RP 
                  | EXP
;

LOOP : FOR FORLOOP BODY 
     | WHILE LP EXP RP BODY 
;

BODY : CLP STMT_LIST CRP 
     | STMT
;

FORLOOP : LP COMMA_SEP_INIT SEMI CONDITION SEMI COMMA_SEP_INCR RP  
;

COMMA_SEP_INIT : 
               | ID ASSIGN EXP COMMA COMMA_SEP_INIT 
               | COMMA_SEP_DATATYPE_INIT
;

COMMA_SEP_DATATYPE_INIT : ID ASSIGN EXP 
                        | DATA_TYPE COMMA_SEP_INIT_PRIME
;

COMMA_SEP_INIT_PRIME : ID ASSIGN EXP COMMA COMMA_SEP_INIT_PRIME 
                     | ID ASSIGN EXP
;

//change this later to the logical part of EXP (yet to be written)
CONDITION : EXP
;

COMMA_SEP_INCR : ADD ADD ID 
               | MINUS MINUS ID 
               | ID ADD ADD 
               | ID MINUS MINUS 
               | ID ASSIGN EXP 
               | ID OTHER ASSIGN EXP
;

OTHER : MOD
      | ADD 
      | MINUS 
      | MUL
      | DIV 
      | BITAND 
      | BITOR 
      | BITXOR 
;

//more additions for part 2 of question
EXP : CONST_OR_ID 
;

OP : EQUAL {}
    | LESS {}
    | MORE {}
    | LESSEQUAL {}
    | MOREEQUAL {}
    | NOTEQUAL {}
;


CONST_OR_ID : ID {}
            | QUOTE ID QUOTE {}
            | NUM {}
;

%%
int main(void){
    // //yydebug = 1;
    return yyparse();
}

void yyerror(const char *s){
    fprintf(stderr, "ERROR: %s\n", s);
    exit(1);
}