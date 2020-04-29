%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdbool.h>
    #include <string.h>
    int yylex(); 
    void yyerror(const char *s);
    #define YYDEBUG 1

    typedef
    struct quadruple{
        int    operation;
        char*  argument1;
        char*  argument2;
        char*  result;
    } quadruple;
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

PROGRAM 
        : 
        | VAR PROGRAM              
        | FUNC_DECLARATION PROGRAM 
        | FUNC_DEFINITION PROGRAM  
        | EXP SEMI PROGRAM
        ;

VAR
        : INT MULTI_DECLARATION SEMI                               { printf("matched int declaration\n\n");   }
        | FLOAT MULTI_DECLARATION SEMI                             { printf("matched float declaration\n\n"); }
        ;

MULTI_DECLARATION 
        : DECLARATION COMMA MULTI_DECLARATION                      {} 
        | DECLARATION 
        ;

DECLARATION 
        : ID
        | ID ASSIGN TYPECAST CONST_OR_ID                           {}
        ;

TYPECAST 
        :
        | LP INT RP 
        | LP FLOAT RP
        ;

DATA_TYPE 
        : VOID 
        | INT
        | FLOAT
        ;

FUNC_DECLARATION 
        : INT ID LP PARAM_LIST_WITH_DATATYPE RP SEMI             { printf("matched int function declaration\n");}
        | FLOAT ID LP PARAM_LIST_WITH_DATATYPE RP SEMI           { printf("matched float function declaration\n");}
        | VOID ID LP PARAM_LIST_WITH_DATATYPE RP SEMI            { printf("matched void function declaration\n");}
        ;

PARAM_LIST_WITH_DATATYPE
        : 
        | PARAM_WITH_DATATYPE COMMA PARAM_LIST_WITH_DATATYPE 
        | PARAM_WITH_DATATYPE                                    {}
        ;

PARAM_WITH_DATATYPE 
        : DATA_TYPE ID                                           {}
        ;

FUNC_DEFINITION 
        : INT ID LP PARAM_LIST_WITH_DATATYPE RP CLP STMT_LIST CRP   { printf("matched int   function definition\n");}
        | FLOAT ID LP PARAM_LIST_WITH_DATATYPE RP CLP STMT_LIST CRP { printf("matched float function definition\n");}
        | VOID ID LP PARAM_LIST_WITH_DATATYPE RP CLP STMT_LIST CRP  { printf("matched void  function definition\n"); }
        ;

STMT_LIST 
        : STMT STMT_LIST{} 
        | STMT{}
        ;

STMT 
        :
        | VAR                                                       { printf("variable declaration matched\n"); }
        | FUNC_CALL                                                 { printf("function call statement matched\n"); }
        | LOOP                                                      { printf("loop statement matched\n"); }
        ;

FUNC_CALL 
        : ID LP PARAM_LIST_WO_DATATYPE RP SEMI                      { printf("matched function call\n"); }
        ;

PARAM_LIST_WO_DATATYPE 
        : PARAM_WO_DATATYPE COMMA PARAM_LIST_WO_DATATYPE 
        | PARAM_WO_DATATYPE                                         {}
        ;

PARAM_WO_DATATYPE 
        :
        | EXP 
        ;

LOOP 
        : FOR FORLOOP BODY                                          { printf("for loop matched\n"); }
        | WHILE LP CONDITION RP BODY                                { printf("while loop matched\n"); }
        ;

BODY 
        : CLP STMT_LIST CRP 
        | STMT
        ;

FORLOOP 
        : LP COMMA_SEP_INIT SEMI CONDITION SEMI COMMA_SEP_INCR RP  
        ;

COMMA_SEP_INIT 
        : 
        | ID ASSIGN EXP COMMA COMMA_SEP_INIT 
        | COMMA_SEP_DATATYPE_INIT
        ;

COMMA_SEP_DATATYPE_INIT
        : ID ASSIGN EXP 
        | DATA_TYPE COMMA_SEP_INIT_PRIME
        ;

COMMA_SEP_INIT_PRIME
        : ID ASSIGN EXP COMMA COMMA_SEP_INIT_PRIME 
        | ID ASSIGN EXP
        ;

CONDITION 
        : 
        | EXP
        ;

COMMA_SEP_INCR 
        :
        | ADD ADD ID 
        | MINUS MINUS ID 
        | ID ADD ADD 
        | ID MINUS MINUS 
        | ID ASSIGN EXP 
        | ID OTHER ASSIGN EXP
        ;

OTHER 
        : MOD
        | ADD 
        | MINUS 
        | MUL
        | DIV 
        | BITAND
        | BITOR 
        | BITXOR 
        ;

EXP 
        : ASSIGNMENT_EXPR                                       { printf("expression matched\n");}
        | EXP COMMA ASSIGNMENT_EXPR                             { printf("expression matched\n");}
        ;

ASSIGNMENT_EXPR 
        : CONDITIONAL_EXPR
        | ID ASSIGN ASSIGNMENT_EXPR
        ;

CONDITIONAL_EXPR 
        : LOGICAL_OR_EXPR
        ;

LOGICAL_OR_EXPR 
        : LOGICAL_AND_EXPR
        | LOGICAL_OR_EXPR OR LOGICAL_AND_EXPR
        ;
LOGICAL_AND_EXPR 
        : INCLUSIVE_OR_EXPR
        | LOGICAL_AND_EXPR AND INCLUSIVE_OR_EXPR
        ;

INCLUSIVE_OR_EXPR 
        : EXCLUSIVE_OR_EXPR
        | INCLUSIVE_OR_EXPR BITOR EXCLUSIVE_OR_EXPR
        ;

EXCLUSIVE_OR_EXPR
        : AND_EXPR
        | EXCLUSIVE_OR_EXPR BITXOR AND_EXPR
        ;

AND_EXPR 
        : EQUALITY_EXPR
        | AND_EXPR BITAND EQUALITY_EXPR
        ;

EQUALITY_EXPR 
        : RELATIONAL_EXPR
        | EQUALITY_EXPR EQUAL RELATIONAL_EXPR
        | EQUALITY_EXPR NOTEQUAL RELATIONAL_EXPR
        ;

RELATIONAL_EXPR 
        : ADDITION_EXPR
        | RELATIONAL_EXPR LESS ADDITION_EXPR
        | RELATIONAL_EXPR MORE ADDITION_EXPR
        | RELATIONAL_EXPR MOREEQUAL ADDITION_EXPR
        | RELATIONAL_EXPR LESSEQUAL ADDITION_EXPR
        ;

ADDITION_EXPR 
        : MULTIPLICATION_EXPR
        | ADDITION_EXPR ADD MULTIPLICATION_EXPR
        | ADDITION_EXPR MINUS MULTIPLICATION_EXPR
        ;

MULTIPLICATION_EXPR
        : BASIC_EXPR
        | MULTIPLICATION_EXPR MUL BASIC_EXPR
        | MULTIPLICATION_EXPR DIV BASIC_EXPR
        | MULTIPLICATION_EXPR MOD BASIC_EXPR
        ;

BASIC_EXPR 
        : ID
        | NUM
        | QUOTE ID QUOTE
        | LP EXP RP
        ;

CONST_OR_ID 
        : ID {}
        | QUOTE ID QUOTE {}
        | NUM {}
        ;

%%


                // functions 
int main(void){
    // //yydebug = 1;
    return yyparse();
}

void yyerror(const char *s){
    fprintf(stderr, "ERROR: %s\n", s);
    exit(1);
}