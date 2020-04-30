%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdbool.h>
    #include <string.h>
    #include <assert.h>

    #define INTERMEDIATE_VARIABLES_MAX_COUNT 32
    #define MAX_SYMBOL_TABLE_SIZE 100
    #define MAX_DECLARATIONS_PER_STATEMENT 10
    #define MAX_VAR_LEN 20

    int yylex(); 
    void yyerror(const char *s);
    #define YYDEBUG 1

    void string_copy(char *dest , char* src);

    char* names[] = { 
                    "t0" , "t1" , "t2" , "t3" , "t4" , "t5", "t6", "t7", 
                    "t8" , "t9" , "t10", "t11", "t12", "t13", "t14", "t15", 
                    "t16", "t17", "t18", "t19", "t20", "t21", "t22", "t23", 
                    "t24", "t25", "t26", "t27", "t28", "t29", "t30", "t31"
                    };
    int name_ptr = 0;

    /* 
    ** symbol_table: Array of pointers to symbol_table_entry objects
    ** symbol_table_top: Index of topmost empty slot in table. 0 means empty stack.
     */
    typedef
    struct symbol_table_entry{
        int scope;
        char* type;
        char* name;
    } symbol_table_entry;
    symbol_table_entry * symbol_table[MAX_SYMBOL_TABLE_SIZE];
    int symbol_table_top = 0;
    int curr_scope = 0;

    /* var_declaration_list */
    typedef
    struct var_declaration_list{
        char* names[MAX_DECLARATIONS_PER_STATEMENT];
        int index;
    } var_declaration_list;

    void var_declaration_list_append(var_declaration_list * list_ptr, char * name) {
        if(list_ptr->index == MAX_DECLARATIONS_PER_STATEMENT) yyerror("MAX_DECLARATIONS_PER_STATEMENT limit broken.");
        else {
            int name_len = strlen(name);
            // printf("appending id %s at index %d\n", name, list_ptr->index);
            char * new_name = malloc(name_len+1);
            strcpy(new_name, name);
            list_ptr->names[list_ptr->index] = new_name;
            list_ptr->index++;
            return;
        }
    }

    void var_declaration_list_union(var_declaration_list * dest_ptr, var_declaration_list * src_ptr) {
        // Append all elements of src_ptr into dest_ptr
        // printf("unioning\n");
        for(int i = 0 ; i < src_ptr->index ; i++) {
            var_declaration_list_append(dest_ptr, src_ptr->names[i]);
        }
        return;
    }

    void print_var_declaration_list(var_declaration_list * list_ptr) {
        printf("var_declaration_list: ");
        
        if(list_ptr == NULL) {
            printf("NULL\n");
            return;
        }
        else {
            printf("index = %d, names = ", list_ptr->index);
            for(int i = 0 ; i < list_ptr->index ; i++) {
                assert(i < MAX_DECLARATIONS_PER_STATEMENT);
                assert(list_ptr->names[i] != NULL);
                printf("%s, ", list_ptr->names[i]);
            }
            printf("\n");
        }
    }

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
        float val;
        void* var_declaration_list;
       }


%start PROGRAM
// %start START

%token DOT
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
%token DEFAULT
%token BREAK
%token <val> NUM
%token <str> ID 

%type <var_declaration_list> DECLARATION MULTI_DECLARATION
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
        : INT MULTI_DECLARATION SEMI                                { 
                                                                        printf("matched int declaration\n\n");
                                                                        print_var_declaration_list((var_declaration_list *)$2);
                                                                    }
        | FLOAT MULTI_DECLARATION SEMI                              {
                                                                        printf("matched float declaration\n\n");
                                                                        print_var_declaration_list((var_declaration_list *)$2);
                                                                    }
        ;

MULTI_DECLARATION 
        : DECLARATION COMMA MULTI_DECLARATION                       {
                                                                        var_declaration_list_union((var_declaration_list *)$$, (var_declaration_list *)$3);
                                                                        // print_var_declaration_list((var_declaration_list *)$$);
                                                                    }
        | DECLARATION                                               {
                                                                        $$ = $1;
                                                                        // print_var_declaration_list((var_declaration_list *)$$);
                                                                    }
        ;

DECLARATION 
        : ID                                                        {
                                                                        printf("id matched in declaration %s\n", $1);
                                                                        var_declaration_list_append((var_declaration_list *)$$, $1);
                                                                    }
        | ID ASSIGN TYPECAST CONST_OR_ID                            {}
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
        | EXP SEMI                                                  { printf("expression matched\n"); }
        | IF_AND_SWICH_STATEMENTS                                   { printf("if/switch statement matched\n"); }
        | BREAK SEMI                                                { printf("break statement matched\n"); }
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
        : ID                                                    { printf("id matched %s \n", $1); }
        | NUM                                                   { printf("num matched %f\n", $1); }
        | QUOTE ID QUOTE
        | LP EXP RP
        ;

CONST_OR_ID 
        : ID {}
        | QUOTE ID QUOTE {}
        | NUM
        ;

IF_AND_SWICH_STATEMENTS
        : IF LP EXP RP BODY ELSE_OR_ELSE_IF
        | SWITCH LP EXP RP CLP CASE_STMTS CRP
        ;

ELSE_OR_ELSE_IF
        :
        | ELSE BODY
        ;

CASE_STMTS
        :
        | CASE NUM COLON STMT_LIST CASE_STMTS
        | DEFAULT COLON STMT_LIST
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

char* 
get_next_name(){
        assert(name_ptr < INTERMEDIATE_VARIABLES_MAX_COUNT);
        char * next_name = names[name_ptr];
        ++name_ptr;
        if(name_ptr >= INTERMEDIATE_VARIABLES_MAX_COUNT) name_ptr = 0;
        return next_name;
}

void string_copy(char *dest , char* src){
        if(src == NULL) return; // don't modify dest in case of null
        char *temp_dest = dest;
        char *temp_src  = src;
        while(*temp_dest != '\0') ++temp_dest;
        do{
                *temp_dest = *temp_src , temp_src++ , temp_dest++;
        } while(*temp_src != '\0');
        assert(*temp_src == '\0'); 
}