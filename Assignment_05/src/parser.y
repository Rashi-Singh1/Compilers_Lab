%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdbool.h>
    #include <string.h>
    #include <assert.h>
    #define YYDEBUG 1
    #define INTERMEDIATE_VARIABLES_MAX_COUNT 32
    #define MAX_SYMBOL_TABLE_SIZE 100
    #define MAX_DECLARATIONS_PER_STATEMENT 10
    #define MAX_VAR_LEN 20
    #define MAX_ERROR_STRING_LEN 100
    #define MAX_ARG_LEN 50
    #define MAX_CODE_LEN 1024
    #define MAX_LABEL_COUNT 64
    void yyerror(const char *s);
    int yylex(); 


    /*
    TYPES:
     -1 unassigned
      0 int
      1 float
      2 void
      3 bool
    */
    char * type_names[] =   { "int", "float", "void", "bool" };
    char* names[] = { 
                    "t0" , "t1" , "t2" , "t3" , "t4" , "t5", "t6", "t7", 
                    "t8" , "t9" , "t10", "t11", "t12", "t13", "t14", "t15", 
                    "t16", "t17", "t18", "t19", "t20", "t21", "t22", "t23", 
                    "t24", "t25", "t26", "t27", "t28", "t29", "t30", "t31"
                    };
    int name_ptr = 0; 
    char * labels[] = { 
                    "L0" , "L1" , "L2" , "L3" , "L4" , "L5" , "L6" , "L7" , 
                    "L8" , "L9" , "L10", "L11", "L12", "L13", "L14", "L15", 
                    "L16", "L17", "L18", "L19", "L20", "L21", "L22", "L23", 
                    "L24", "L25", "L26", "L27", "L28", "L29", "L30", "L31",
                    "L32", "L33", "L34", "L35", "L36", "L37", "L38", "L39", 
                    "L40", "L41", "L42", "L43", "L44", "L45", "L46", "L47", 
                    "L48", "L49", "L50", "L51", "L52", "L53", "L54", "L55", 
                    "L56", "L57", "L58", "L59", "L60", "L61", "L62", "L63" 
                    };
    int label_ptr = 0;
    /* structures for intermediate code generation and buffer format output*/
    /* 
    ** symbol_table: Array of pointers to symbol_table_entry objects
    ** symbol_table_top: Index of topmost empty slot in table. 0 means empty stack.
     */
    typedef
    struct symbol_table_entry{
        int scope;
        int type;
        char* name;
    } symbol_table_entry;
    symbol_table_entry * symbol_table[MAX_SYMBOL_TABLE_SIZE];
    int symbol_table_top = 0;
    int curr_scope = 0;
    void symbol_table_append(int scope, int type , char* name);
    bool symbol_table_lookup(char * name);
    void print_symbol_table();

    /* var_declaration_list
    ** names: array of ids of declared variables
    ** assigned_types: array of ints denoting type of assigned value to var. Eg: int foo = 45.6 then names[i]="foo" and assigned_types[i]=1 for float. -1 for uninitialized
    ** index: number of elements in list
    */
    typedef
    struct var_declaration_list{
        char* names[MAX_DECLARATIONS_PER_STATEMENT];
        int assigned_types[MAX_DECLARATIONS_PER_STATEMENT];
        int index;
    } var_declaration_list;
    void var_declaration_list_append(var_declaration_list * list_ptr, char * name, int type);
    void var_declaration_list_union(var_declaration_list * dest_ptr, var_declaration_list * src_ptr);
    void print_var_declaration_list(var_declaration_list * list_ptr);


    /* struct to store quadruple code for current operation and concatenated code for the subtree */
    typedef
    struct buffer{
        char*    operation; /* denotes operation */
        char*    argument1;   /*  name of first argument */
        char*    argument2;   /*  name of second argumen */
        char*    result;    /*  name of the intermediate variable*/
        char *   code;       /*  code for the subtree contained */
    } buffer;
    buffer* create_buffer(char *oper , char *arg1 , char *arg2 , char* result , char* code); /* create a new buffer and return it's reference */
    void display_buffer(buffer* Q); /* display the intermediate code from the buffer format */
    buffer* combine_buffer(buffer *Q1 , buffer *Q2 , char *operation); /* combining two buffers*/
    char* get_next_name(); /*returns the next available variable. Works cyclically*/
    void print_code(buffer* Q); /*prints the code of the */


    /* special labelled nodes in syntax tree for boolean expressions and statements inside loops
       and if statements 
    */
    typedef
    struct labeled_node{
            char* true_label;  /* label to go in case of true boolean expression  */
            char* false_label; /* label to go in case of false boolean expression */ 
            char* next_label;  /* label to skip to for statements */
            char* code;        /* the code of the subtree in the syntax tree of the labeled_node*/
    } labeled_node;

    /* creates a new labeled node and returns it's address */
    labeled_node*
    create_labeled_node(char* true_label , char* false_label , char* next_label , char* code){
            labeled_node* new_node = (labeled_node *) malloc(sizeof(labeled_node));
            new_node->true_label = true_label;
            new_node->false_label = false_label;
            new_node->next_label = next_label;
            if(code == NULL){
                    new_node->code = NULL;
                    return new_node;
            }
            new_node->code = (char *) malloc(sizeof(char) * MAX_CODE_LEN);
            (new_node->code)[0] = '\0';
            strcpy(new_node->code , code);
            return new_node;
    }
    /* returns the name of the next label to be used */
    char* 
    get_new_label(){
            char* next_label = labels[label_ptr];
            ++label_ptr;
            if(label_ptr >= MAX_LABEL_COUNT){
                    yyerror("too many labels in use\n");
            }
            return next_label;
    }
    /* check label status -- only for debugging purpose */
    void check_label(labeled_node* L){
            if(L == NULL) {
                    printf("NULL");
                    return;
            }
            char* true_lbl  = "NULL";
            char* false_lbl = "NULL";
            char* next_lbl  = "NULL";
            if(L->true_label != NULL)  true_lbl  = L->true_label;
            if(L->false_label != NULL) false_lbl = L->false_label;  
            if(L->next_label != NULL)  next_lbl  = L->next_label;
            printf("Truelabel : %s , Falselabel : %s , next_lbl : %s\n" , true_lbl , false_lbl , next_lbl);  
    }
    typedef 
    struct test{
            int x;
            int y;
    } test;
%}

%union {
        char* str;
        float val;
        void* var_declaration_list;
        int type;
        void* three_addr_code;
        void* labeled_node_ptr;
        void* test_ptr;
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
%left OR
%left AND
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
// %type<str> INT
%token <str> NUM
%token <str> ID
%type <three_addr_code> EXP
%type <three_addr_code> ASSIGNMENT_EXPR
%type <three_addr_code> CONDITIONAL_EXPR
%type <three_addr_code> LOGICAL_OR_EXPR
%type <three_addr_code> LOGICAL_AND_EXPR
%type <three_addr_code> INCLUSIVE_OR_EXPR
%type <three_addr_code> EXCLUSIVE_OR_EXPR
%type <three_addr_code> AND_EXPR
%type <three_addr_code> EQUALITY_EXPR
%type <three_addr_code> RELATIONAL_EXPR
%type <three_addr_code> ADDITION_EXPR
%type <three_addr_code> MULTIPLICATION_EXPR
%type <three_addr_code> BASIC_EXPR

%type <labeled_node_ptr> BODY
%type <labeled_node_ptr> STMT_LIST
%type <labeled_node_ptr> STMT
%type <labeled_node_ptr> IF_AND_SWICH_STATEMENTS
%type <labeled_node_ptr> LABELED_BOOLEAN_EXPR

// markers for handling preorder traversal of syntax tree
%type <labeled_node_ptr> MARKER1
%type <labeled_node_ptr> MARKER2
%type <labeled_node_ptr> MARKER3
%type <labeled_node_ptr> MARKER4
%type <labeled_node_ptr> MARKER5
%type <labeled_node_ptr> MARKER6
%type <labeled_node_ptr> MARKER7
%type <labeled_node_ptr> MARKER8
%type <labeled_node_ptr> MARKER9
%type <labeled_node_ptr> MARKER10
%type <labeled_node_ptr> MARKER11

%type <var_declaration_list> DECLARATION MULTI_DECLARATION
%type <val> TYPECAST
/* actual grammar implementation in C*/
%%

PROGRAM 
        : 
         MARKER11{
                 labeled_node * pre = (labeled_node *) malloc(sizeof(labeled_node));
                 pre->true_label = get_new_label();
                 pre->false_label = get_new_label();
                 $1 = (void* )pre;
                 printf("matched marker11\n");
         } LABELED_BOOLEAN_EXPR SEMI {
                 printf("---matched labeled boolean expression---\n");
                 printf("---testing the code for the labeled expression---\n");
                 printf("---------------XXXX-----------------\n");
                 printf("%s\n", ((labeled_node *) $3)->code);
                 printf("---------------XXXX-----------------\n");
         }
        // | VAR PROGRAM              
        // | FUNC_DECLARATION PROGRAM 
        // | FUNC_DEFINITION PROGRAM  
        // | EXP { 
        //         printf("expression matched in program\n");
        //         print_code((buffer*) $1);
        //       }
        //   SEMI PROGRAM   
        ;


VAR
        : INT MULTI_DECLARATION SEMI                                {
                                                                        printf("matched int declaration\n\n");
                                                                        var_declaration_list * list_ptr = (var_declaration_list *) $2;
                                                                        print_var_declaration_list(list_ptr);
                                                                        for(int i = 0 ; i < list_ptr->index ; i++) {
                                                                            // check var is not already declared in current scope
                                                                            if(symbol_table_lookup(list_ptr->names[i])) {
                                                                                char error_str[MAX_ERROR_STRING_LEN];
                                                                                sprintf(error_str, "Redeclaration of variable '%s'.", list_ptr->names[i]);
                                                                                yyerror(error_str);
                                                                            }
                                                                            // insert into symbol table
                                                                            symbol_table_append(curr_scope, 0, list_ptr->names[i]);

                                                                            // TODO : convert from assigned type to int
                                                                        }
                                                                        print_symbol_table();
                                                                    }
        | FLOAT MULTI_DECLARATION SEMI                              {
                                                                        printf("matched float declaration\n\n");
                                                                        var_declaration_list * list_ptr = (var_declaration_list *) $2;
                                                                        print_var_declaration_list(list_ptr);
                                                                        for(int i = 0 ; i < list_ptr->index ; i++) {
                                                                            // check var is not already declared in current scope
                                                                            if(symbol_table_lookup(list_ptr->names[i])) {
                                                                                char error_str[MAX_ERROR_STRING_LEN];
                                                                                sprintf(error_str, "Redeclaration of variable '%s'.", list_ptr->names[i]);
                                                                                yyerror(error_str);
                                                                            }
                                                                            // insert into symbol table
                                                                            symbol_table_append(curr_scope, 1, list_ptr->names[i]);

                                                                            // TODO : convert from assigned type to int
                                                                        }
                                                                        print_symbol_table();
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
                                                                        var_declaration_list_append((var_declaration_list *)$$, $1, -1);
                                                                    }
        | ID ASSIGN TYPECAST ASSIGNMENT_EXPR                        {
                                                                        printf("id matched in declaration %s\n", $1);
                                                                        int type;
                                                                        if($3 == -1) {
                                                                            type = 0; // TODO: type from expr
                                                                        }
                                                                        else {
                                                                            // TODO: convert expr to $3 type.
                                                                            type = $3;
                                                                        }
                                                                        var_declaration_list_append((var_declaration_list *)$$, $1, type);
                                                                    }
        ;

TYPECAST 
        :                                                           {
                                                                        $$ = -1;
                                                                    }
        | LP INT RP                                                 {
                                                                        $$ = 0;
                                                                    }
        | LP FLOAT RP                                               {
                                                                        $$ = 1;
                                                                    }
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
        : INT ID LP PARAM_LIST_WITH_DATATYPE RP CLP STMT_LIST CRP   { 
                                                                        printf("matched int   function definition\n");
                                                                        printf("-------------------testing----------------------\n");
                                                                        printf("------ code for stmt list of this function -----\n");
                                                                        char * cd = ((labeled_node *) $7)->code;
                                                                        printf("%s", cd);
                                                                        char * lbl = ((labeled_node *)$7)->next_label;
                                                                        printf("label for stmt_list = %s\n", lbl);
                                                                    }
        | FLOAT ID LP PARAM_LIST_WITH_DATATYPE RP CLP STMT_LIST CRP { printf("matched float function definition\n");}
        | VOID ID LP PARAM_LIST_WITH_DATATYPE RP CLP STMT_LIST CRP  { printf("matched void  function definition\n"); }
        ;

STMT_LIST 
        : STMT STMT_LIST                                            { 
                                                                        // use  the label name from statement list
                                                                        char* concatenated_code = (char *) malloc(sizeof(char) * MAX_CODE_LEN);
                                                                        concatenated_code[0] = '\0';
                                                                        char* stmt_list_code = ((labeled_node *)$2)->code;
                                                                        char* stmt_code = ((labeled_node *)$1)->code;
                                                                        if(stmt_code != NULL){
                                                                            strcat(concatenated_code , stmt_code); 
                                                                        }
                                                                        if( stmt_list_code != NULL)
                                                                            strcat(concatenated_code , stmt_list_code);
                                                                        $$ = (void *) create_labeled_node(
                                                                                NULL,
                                                                                NULL,
                                                                                ((labeled_node*) $2)->next_label,
                                                                                concatenated_code
                                                                        );
                                                                    }      
        | STMT                                                      { 
                                                                         labeled_node * lbl = (labeled_node *) $1;
                                                                         lbl->next_label = get_new_label();
                                                                         $$ = (void *) lbl;
                                                                    }
        ;

STMT 
        :                                                           {
                                                                        labeled_node* new_labeled_node = create_labeled_node(
                                                                                NULL, 
                                                                                NULL,
                                                                                NULL,
                                                                                "empty code\n"
                                                                        );
                                                                        $$ = (void *) new_labeled_node;
                                                                    }
        | VAR                                                       {
                                                                        //create a new_labeled_node
                                                                        labeled_node* new_labeled_node = create_labeled_node(
                                                                                NULL, 
                                                                                NULL,
                                                                                NULL,
                                                                                "var_declaration\n"
                                                                        );
                                                                        $$ = (void *) new_labeled_node;
                                                                    }
        | FUNC_CALL                                                 { 
                                                                        //create a new_labeled_node
                                                                        labeled_node* new_labeled_node = create_labeled_node(
                                                                                NULL, 
                                                                                NULL,
                                                                                NULL,
                                                                                "func_call\n"
                                                                        );
                                                                        $$ = (void *) new_labeled_node;
                                                                    }
        | LOOP                                                      { 
                                                                        labeled_node* new_labeled_node = create_labeled_node(
                                                                                NULL, 
                                                                                NULL,
                                                                                NULL,
                                                                                "loop matched\n"
                                                                        );
                                                                        $$ = (void *) new_labeled_node;
                                                                    }
        | EXP SEMI                                                  { 
                                                                        labeled_node* new_labeled_node = create_labeled_node(
                                                                                NULL, 
                                                                                NULL,
                                                                                NULL,
                                                                                ((buffer*)$1)->code
                                                                        );
                                                                        $$ = (void *) new_labeled_node;
                                                                        // print_code((buffer *) $1);
                                                                    }
        | IF_AND_SWICH_STATEMENTS                                   { 
                                                                        labeled_node* new_labeled_node = create_labeled_node(
                                                                                NULL, 
                                                                                NULL,
                                                                                NULL,
                                                                                ((labeled_node *)$1)->code
                                                                        );
                                                                        $$ = (void *) new_labeled_node;
                                                                    }
        | BREAK SEMI                                                { 
                                                                        labeled_node* new_labeled_node = create_labeled_node(
                                                                                NULL, 
                                                                                NULL,
                                                                                NULL,
                                                                                "break\n"
                                                                        );
                                                                        $$ = (void *) new_labeled_node;
                                                                    }
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
        : CLP STMT_LIST CRP                                         {
                                                                        // in case we match a statement list
                                                                        $$ = $2;
                                                                    }
        | STMT                                                      {
                                                                        // if we match a single statement
                                                                         labeled_node * lbl = (labeled_node *) $1;
                                                                         lbl->next_label = get_new_label();
                                                                         $$ = (void *) lbl;    
                                                                    }
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
        : ASSIGNMENT_EXPR                                       { 
                                                                        $$ = $1;
                                                                }
        | EXP COMMA ASSIGNMENT_EXPR                             {   
                                                                       printf("second\n");
                                                                        $$ = $3; // all assignment expressions already handled by children
                                                                        print_code( (buffer *) $3);
                                                                }
        ;

ASSIGNMENT_EXPR 
        : CONDITIONAL_EXPR                                          {
                                                                        $$ = $1;
                                                                    }
        | ID ASSIGN ASSIGNMENT_EXPR                                 {   // combine assignment expressions using assign
                                                                        char* variable_name = $1;
                                                                        buffer* assign_expr = (buffer*) $3;
                                                                        // result goes directly into the variable_name
                                                                        char * assignment_code = (char *) malloc(sizeof(char) * MAX_CODE_LEN);
                                                                        assignment_code[0] = '\0';
                                                                        strcat(assignment_code , assign_expr->code);
                                                                        strcat(assignment_code , variable_name);
                                                                        strcat(assignment_code , " = ");
                                                                        strcat(assignment_code , assign_expr->result);
                                                                        strcat(assignment_code , "\n");
                                                                        $$ = (void *) create_buffer("=" , assign_expr->result , NULL , variable_name , assignment_code);
                                                                        // display_buffer((buffer *) $$);
                                                                    }
        ;

CONDITIONAL_EXPR 
        : LOGICAL_OR_EXPR                                           {
                                                                        $$ = $1;
                                                                    }
        ;

LOGICAL_OR_EXPR 
        : LOGICAL_AND_EXPR                                          {
                                                                        $$ = $1;
                                                                    }
        | LOGICAL_OR_EXPR OR LOGICAL_AND_EXPR                       {  // combine logical and expressions using or
                                                                       buffer * logical_or  = (buffer *) $1;
                                                                       buffer * logical_and = (buffer *) $3;
                                                                       $$ = (void *) combine_buffer(logical_or , logical_and , "||");
                                                                //        display_buffer((buffer *) $$);
                                                                    }
        ;
LOGICAL_AND_EXPR 
        : INCLUSIVE_OR_EXPR                                         {
                                                                        $$ = $1;
                                                                    }
        | LOGICAL_AND_EXPR AND INCLUSIVE_OR_EXPR                    {  // combine inclusive or expressions using and
                                                                       buffer * Q_logical_and  = (buffer *) $1;
                                                                       buffer * Q_inclusive_or = (buffer *) $3;
                                                                       $$ = (void *) combine_buffer(Q_logical_and , Q_inclusive_or , "&&");
                                                                //        display_buffer((buffer *)$$);
                                                                    }
        ;

INCLUSIVE_OR_EXPR 
        : EXCLUSIVE_OR_EXPR                                         {
                                                                        $$ = $1;
                                                                    }
        | INCLUSIVE_OR_EXPR BITOR EXCLUSIVE_OR_EXPR                 {   // combine exclusive or expressions using bit or
                                                                        buffer * Q_inclusive_or = (buffer *) $1;
                                                                        buffer * Q_exclusive_or = (buffer *) $3;
                                                                        $$ = (void *)combine_buffer(Q_inclusive_or , Q_exclusive_or , "|");
                                                                        // display_buffer((buffer *)$$);
                                                                    }
        ;

EXCLUSIVE_OR_EXPR
        : AND_EXPR                                                  {
                                                                        $$ = $1;
                                                                    }
        | EXCLUSIVE_OR_EXPR BITXOR AND_EXPR                         {   // combine and expresssions using bit xor operation
                                                                        buffer * Q_exclusive_or = (buffer *) $1;
                                                                        buffer * Q_and          = (buffer *) $3;
                                                                        $$ = (void *)combine_buffer(Q_exclusive_or , Q_and , "^");
                                                                        // display_buffer((buffer *) $$);
                                                                    }
        ;

AND_EXPR 
        : EQUALITY_EXPR                                            { 
                                                                       $$ = $1;
                                                                   }
        | AND_EXPR BITAND EQUALITY_EXPR                            {    // combine equality_expressions using bitand
                                                                        buffer * Q_and = (buffer *) $1;
                                                                        buffer * Q_equality = (buffer *) $3;
                                                                        $$ = (void *) combine_buffer(Q_and , Q_equality , "&");
                                                                        // display_buffer((buffer *) $$);
                                                                   }
        ;

EQUALITY_EXPR 
        : RELATIONAL_EXPR                                          {
                                                                        $$ = $1;
                                                                   }
        | EQUALITY_EXPR EQUAL RELATIONAL_EXPR                      {   // combine relational operations using equal
                                                                       buffer * Q_equality = (buffer *) $1;
                                                                       buffer * Q_relation = (buffer *) $3;
                                                                       $$ = (void *) combine_buffer(Q_equality , Q_relation , "==");
                                                                //        display_buffer((buffer *) $$); 
                                                                   }
        | EQUALITY_EXPR NOTEQUAL RELATIONAL_EXPR                   {  // combine relational operations using equal
                                                                       buffer * Q_equality = (buffer *) $1;
                                                                       buffer * Q_relation = (buffer *) $3;
                                                                       $$ = (void *) combine_buffer(Q_equality , Q_relation , "!=");
                                                                //        display_buffer((buffer *) $$); 
                                                                   }
        ;

RELATIONAL_EXPR 
        : ADDITION_EXPR                                            {
                                                                        $$ = $1;
                                                                   }
        | RELATIONAL_EXPR LESS ADDITION_EXPR                       {    // combine addition expressions using less
                                                                        buffer * Q_relation = (buffer *) $1;
                                                                        buffer * Q_addition = (buffer *) $3;
                                                                        $$ = (void *) combine_buffer(Q_relation , Q_addition , "<");
                                                                        // display_buffer((buffer *)$$);
                                                                   }
        | RELATIONAL_EXPR MORE ADDITION_EXPR                       {    // combine addition expressions using more
                                                                        buffer * Q_relation = (buffer *) $1;
                                                                        buffer * Q_addition = (buffer *) $3;
                                                                        $$ = (void *) combine_buffer(Q_relation , Q_addition , ">");
                                                                        // display_buffer((buffer *)$$);

                                                                   }
        | RELATIONAL_EXPR MOREEQUAL ADDITION_EXPR                  {    // combine addition expressions using more equals
                                                                        buffer * Q_relation = (buffer *) $1;
                                                                        buffer * Q_addition = (buffer *) $3;
                                                                        $$ = (void *) combine_buffer(Q_relation , Q_addition , ">=");
                                                                        // display_buffer((buffer *)$$);
                                                                   }
        | RELATIONAL_EXPR LESSEQUAL ADDITION_EXPR                  {
                                                                        // combine addition expressions using less equals
                                                                        buffer * Q_relation = (buffer *) $1;
                                                                        buffer * Q_addition = (buffer *) $3;
                                                                        $$ = (void *) combine_buffer(Q_relation , Q_addition , "<=");
                                                                        // display_buffer((buffer *)$$);
                                                                   }                  
        ;

ADDITION_EXPR 
        : MULTIPLICATION_EXPR                                      {
                                                                        $$ = $1;
                                                                   }
        | ADDITION_EXPR ADD MULTIPLICATION_EXPR                    {   // combine multiplication expressions using add
                                                                       buffer * Q_addition = (buffer *) $1;
                                                                       buffer * Q_multi = (buffer *) $3;
                                                                       $$ = (void *) combine_buffer(Q_addition , Q_multi , "+");
                                                                //        display_buffer((buffer *) $$);
                                                                   }
        | ADDITION_EXPR MINUS MULTIPLICATION_EXPR                  {   // combine multiplication expressions using minus
                                                                       buffer * Q_addition = (buffer *) $1;
                                                                       buffer * Q_multi =    (buffer *) $3;
                                                                       $$ = (void *) combine_buffer(Q_addition , Q_multi , "-");
                                                                //        display_buffer((buffer *) $$);
                                                                   }
        ;

MULTIPLICATION_EXPR
        : BASIC_EXPR                                               {
                                                                        $$ = $1;
                                                                   }
        | MULTIPLICATION_EXPR MUL BASIC_EXPR                       {
                                                                       // combine basic operation with multiplication operation
                                                                       buffer * Q_multi = (buffer *) $1;
                                                                       buffer * Q_basic = (buffer *) $3;
                                                                       $$ = (void *) combine_buffer(Q_multi , Q_basic , "*");
                                                                //        display_buffer((buffer *) $$);
                                                                   }
        | MULTIPLICATION_EXPR DIV BASIC_EXPR                       {
                                                                       // combine basic expr with division operation
                                                                       buffer * Q_multi = (buffer *) $1;
                                                                       buffer * Q_basic = (buffer *) $3;
                                                                       $$ = (void *) combine_buffer(Q_multi , Q_basic , "/");
                                                                //        display_buffer((buffer *) $$);
                                                                   }
        | MULTIPLICATION_EXPR MOD BASIC_EXPR                       {   
                                                                       // combine basic expr with modulo operation
                                                                       buffer * Q_multi = (buffer *) $1;
                                                                       buffer * Q_basic = (buffer *) $3;
                                                                       $$ = (void *) combine_buffer(Q_multi , Q_basic , "%");
                                                                //        display_buffer((buffer *) $$);
                                                                   }
        ;

BASIC_EXPR 
        : ID                                                       {
                                                                        char* intermediate_var = get_next_name();
                                                                        $$ = (void *)create_buffer("=" , $1 , NULL , $1 , "");
                                                                        // display_buffer((buffer *) $$);
                                                                   }                                                   
        | NUM                                                      {
                                                                        char* intermediate_var = get_next_name();
                                                                        $$ = (void *)create_buffer("=" , $1 , NULL , $1 , "");
                                                                        // display_buffer((buffer *) $$);
                                                                   }
        | LP EXP RP                                                {
                                                                        $$ = $2; // use code for expression
                                                                        // display_buffer((buffer *) $$); // may be redundant here
                                                                   }
        ;

// involves a marker 
IF_AND_SWICH_STATEMENTS
        : IF LP MARKER1                                          {
                                                                         labeled_node* pre = (labeled_node *)malloc(sizeof(labeled_node));
                                                                         pre->true_label = get_new_label();
                                                                         pre->true_label = get_new_label();
                                                                         $3 = (void *) pre; // store value in the previous node
                                                                 }
          LABELED_BOOLEAN_EXPR RP BODY ELSE_OR_ELSE_IF           {     
                                                                        printf("matched labeled boolean expression\n");
                                                                        printf("code -> \n");
                                                                        printf("%s\n" , ((labeled_node *)$5)->code);
                                                                        check_label((labeled_node *) $5);
                                                                  }
        | SWITCH LP EXP RP CLP CASE_STMTS CRP                     {
                                                                        // printf("matched switch case :\n");
                                                                        print_code((buffer *) $3);
                                                                  }
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



// special grammar (involves pre order traversal of syntax tree using markers)
// LABELED_BOOLEAN_EXPR 
//         : MARKER1 {
//              labeled_node* pre = (labeled_node *) malloc(sizeof(labeled_node));
//              pre->true_label = (char *) malloc(MAX_CODE_LEN);
//              // B1.true = B.true
//              strcpy(pre->true_label  , ((labeled_node *)$<labeled_node_ptr>-1)->true_label);
//              // B1.false = newlabel()
//              strcpy(pre->false_label , get_new_label());
//              $1 = (void *) pre;
//              printf("matched marker 1\n");
//           }
//           LABELED_BOOLEAN_EXPR OR  
//           MARKER2{
//              labeled_node* pre = (labeled_node *) malloc(sizeof(labeled_node));
//              pre->true_label  = (char *) malloc(MAX_CODE_LEN);
//              pre->false_label = (char *) malloc(MAX_CODE_LEN);
//              // B2.true = B.true
//              strcpy(pre->true_label  , ((labeled_node *)$<labeled_node_ptr>-1)->true_label);
//              // B2.false = B.false
//              strcpy(pre->false_label , ((labeled_node *)$<labeled_node_ptr>-1)->false_label);
//              $5 = (void *) pre;
//              printf("matched marker2\n");
//           }
//           LABELED_BOOLEAN_EXPR                                          
//           {                                                  
//              char *final_code = (char *) malloc(MAX_CODE_LEN);
//              final_code[0] = '\0';
//              // B.code = B1.code || label(B1.false) || B2.code
//              strcat(final_code , ((labeled_node *) $3)->code);
//              strcat(final_code , ((labeled_node *) $3)->false_label);
//              strcat(final_code , ": \n");
//              strcat(final_code , ((labeled_node *) $<labeled_node_ptr>6)->code);
//              ((labeled_node *) $$)->code = final_code;
//           }
//         |
//          MARKER4{
//            labeled_node * pre = (labeled_node *) malloc(sizeof(labeled_node));
//            // B1.true = newlabel()
//            pre->true_label = get_new_label();
//            // B1.false = B.false
//            pre->false_label = ((labeled_node *)$<labeled_node_ptr>-1)->false_label;
//            $1 = (void *) pre;
//          } 
//          LABELED_BOOLEAN_EXPR AND 
//          MARKER5{
//            labeled_node * pre = (labeled_node *) malloc(sizeof(labeled_node));
//            pre->true_label = (char *) malloc(MAX_CODE_LEN);
//            // B2.true = B.true
//            strcpy(pre->true_label , ((labeled_node *)$<labeled_node_ptr>-1)->true_label);
//            pre->false_label = (char *) malloc(MAX_CODE_LEN);
//            // B2.false = B.false
//            strcpy(pre->false_label , ((labeled_node *)$<labeled_node_ptr>-1)->false_label);
//            $5 = (void * )pre;
//          }
//          LABELED_BOOLEAN_EXPR                 
//          {
//            char *final_code = (char *) malloc(MAX_CODE_LEN);
//            final_code[0] = '\0';
//            // B.code = B1.code || label(B1.true) || B2.code
//            strcat(final_code , ((labeled_node *) $3)->code);
//            strcat(final_code , ((labeled_node *) $3)->true_label);
//            strcat(final_code , "\n");
//            strcat(final_code , ((labeled_node *) $<labeled_node_ptr>6)->code);
//            ((labeled_node *) $$)->code = final_code;
//         }
//         | NOT 
//          MARKER6{
//           labeled_node * pre = (labeled_node *) malloc(sizeof(labeled_node));
//           pre->true_label = (char *) malloc(MAX_CODE_LEN);
//           // B1.true = B.false
//           strcpy(pre->true_label , ((labeled_node *) $<labeled_node_ptr>-1)->false_label);
//           pre->false_label = (char *) malloc(MAX_CODE_LEN);
//           // B1.false = B.true 
//           strcpy(pre->false_label , ((labeled_node *) $<labeled_node_ptr>-1)->true_label);
//           $2 = (void *) pre;
//          }
//          LABELED_BOOLEAN_EXPR                                          
//          {     
//            // B.code = B1.code
//            ((labeled_node *) $$)->code = ((labeled_node*) $<labeled_node_ptr>3)->code;
//          }
//          | ADDITION_EXPR RELOP ADDITION_EXPR                             {
//                                                                                 char * final_code = (char *) malloc(MAX_CODE_LEN);
//                                                                                 strcat(final_code , ((buffer *) $1)->code);
//                                                                                 strcat(final_code , ((buffer *) $3)->code);
//                                                                                 strcat(final_code , "if ");
//                                                                                 strcat(final_code , ((buffer *)$1)->result);
//                                                                                 strcat(final_code , " relop ");
//                                                                                 strcat(final_code , ((buffer *)$3)->result);
//                                                                                 strcat(final_code , " goto ");
//                                                                                 strcat(final_code , ((labeled_node *) $<labeled_node_ptr>-1)->true_label);
//                                                                                 strcat(final_code , "\n goto ");
//                                                                                 strcat(final_code , ((labeled_node *) $<labeled_node_ptr>-1)->false_label);
//                                                                                 strcat(final_code , "\n");
//                                                                                 ((labeled_node *) $$)->code = final_code;
//                                                                         }
//         | TRUE                                                          {       
//                                                                                 char * final_code = (char *) malloc(MAX_CODE_LEN);
//                                                                                 strcat(final_code , " goto ");
//                                                                                 strcat(final_code , ((labeled_node *) $<labeled_node_ptr>-1)->true_label);
//                                                                                 ((labeled_node *) $$)->code = final_code;
//                                                                         }
//         | FALSE                                                         {      
//                                                                                 char * final_code = (char *) malloc(MAX_CODE_LEN);
//                                                                                 strcat(final_code , " goto ");
//                                                                                 strcat(final_code , ((labeled_node *) $<labeled_node_ptr>-1)->false_label);
//                                                                                 ((labeled_node *) $$)->code = final_code;
//                                                                         }
//         ;
// RELOP   
//         : MORE    {printf("more\n");}
//         | LESS    {printf("less\n");}
//         | EQUAL{printf("eq\n");}
//         | NOTEQUAL{printf("neq\n");}
//         | LESSEQUAL{printf("leq\n");}
//         | MOREEQUAL{printf("meq\n");}
//         ;


LABELED_BOOLEAN_EXPR 
        : MARKER1 LABELED_BOOLEAN_EXPR OR MARKER2 LABELED_BOOLEAN_EXPR                                          
        | MARKER4 LABELED_BOOLEAN_EXPR AND MARKER5 LABELED_BOOLEAN_EXPR                 
        | NOT MARKER6 LABELED_BOOLEAN_EXPR                                          
        | ADDITION_EXPR RELOP ADDITION_EXPR  {
                printf("reduced\n");
        }                           
        | TRUE                                                          
        | FALSE                                                         
        ;
RELOP   
        : MORE    {printf("more\n");}
        | LESS    {printf("less\n");}
        | EQUAL{printf("eq\n");}
        | NOTEQUAL{printf("neq\n");}
        | LESSEQUAL{printf("leq\n");}
        | MOREEQUAL{printf("meq\n");}
        ;



MARKER1 :
        ;
MARKER2 :
        ;
MARKER3 :
        ;
MARKER4 :
        ;
MARKER5 :
        ;
MARKER6 :
        ;
MARKER7 :
        ;
MARKER8 :
        ;
MARKER9 :
        ;
MARKER10
        :
        ;
MARKER11 
        :
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

/*custom string copy function*/
void 
string_copy(char *dest , char* src){
        if(src == NULL) return; // don't modify dest in case of null
        char *temp_dest = dest;
        char *temp_src  = src;
        do{
                *temp_dest = *temp_src , temp_src++ , temp_dest++;
        } while(*temp_src != '\0');
        assert(*temp_src == '\0'); 

}

          /* operations on buffer struct */
/* create a new buffer and return it's reference */
buffer* 
create_buffer(char *oper , char *arg1 , char *arg2 , char* result , char* code){
        buffer* Q    = (buffer*) malloc(sizeof(buffer));
        Q->operation = (char*) malloc(MAX_ARG_LEN);
        Q->argument1 = (char*) malloc(MAX_ARG_LEN);
        Q->argument2 = (char*) malloc(MAX_ARG_LEN);
        Q->result    = (char*) malloc(MAX_ARG_LEN);
        Q->code      = (char*) malloc(MAX_CODE_LEN); 
     
        

        // Q->operation = oper;
        // Q->argument1 = arg1;
        // Q->argument2 = arg2;
        // Q->result    = result;
        // Q->code      = (char*) malloc(MAX_CODE_LEN); 
     
     
        string_copy(Q->operation , oper);
        string_copy(Q->argument1 , arg1);
        string_copy(Q->argument2 , arg2);
        string_copy(Q->result  , result);
        string_copy(Q->code , code);
        assert(Q != NULL);
        return Q;
}

/* display the intermediate code from the buffer format */
void
display_buffer(buffer* Q){
        assert(Q != NULL);
        assert(Q->operation != NULL);
        char *assign = "=";
        if(strcmp(Q->operation , assign) == 0){
                assert(Q->result != NULL);
                assert(Q->argument1 != NULL);
                printf("%s = %s\n", Q->result , Q->argument1);
        } else{
                assert(Q->argument1 != NULL);
                assert(Q->argument2 != NULL);
                assert(Q->operation != NULL);
                assert(Q->result    != NULL);
                printf("%s = %s %s %s\n", Q->result , Q->argument1 , Q->operation , Q->argument2);
        }
}
/*  combine two buffers to obtain a new buffer */
buffer*
combine_buffer(buffer *Q1 , buffer *Q2 , char *operation){
        char * result_variable = get_next_name();
        char * concatenated_code = (char *) malloc(sizeof(char) * MAX_CODE_LEN);
        concatenated_code[0] = '\0';
        if(Q1->code) strcat(concatenated_code , Q1->code);
        if(Q2->code) strcat(concatenated_code , Q2->code);
        strcat(concatenated_code , result_variable);
        strcat(concatenated_code , " = ");
        strcat(concatenated_code , Q1->result);
        strcat(concatenated_code , " ");
        strcat(concatenated_code , operation);
        strcat(concatenated_code , " ");
        strcat(concatenated_code , Q2->result);
        strcat(concatenated_code , "\n");
        buffer * combination = create_buffer(
                operation ,
                Q1->result,              
                Q2->result,
                result_variable,
                concatenated_code
        );
        return combination;
}

void print_code(buffer * buff){
        assert(buff != NULL);
        printf("code:\n");
        printf("%s" , buff->code); 
}
/* returns the next intermediate variable name to be used */
char* 
get_next_name(){
        assert(name_ptr < INTERMEDIATE_VARIABLES_MAX_COUNT);
        char * next_name = names[name_ptr];
        ++name_ptr;
        if(name_ptr >= INTERMEDIATE_VARIABLES_MAX_COUNT) name_ptr = 0;
        return next_name;
}


void symbol_table_append(int scope, int type, char * name) {
        symbol_table_entry * entry_ptr = (symbol_table_entry *)malloc(sizeof(symbol_table_entry));
        entry_ptr->scope = scope;
        entry_ptr->type = type;
        entry_ptr->name = name;

        if(symbol_table_top >= MAX_SYMBOL_TABLE_SIZE) yyerror("MAX_SYMBOL_TABLE_SIZE limit exceeded.");
        else {
            symbol_table[symbol_table_top] = entry_ptr;
            symbol_table_top++;
            return;
        }
}

bool symbol_table_lookup(char * name) {
        for(int i = 0 ; i < symbol_table_top ; i++) {
            if(strcmp(symbol_table[i]->name, name) == 0) return true;
        }
        return false;
}

void print_symbol_table() {
        printf("symbol_table (stack top to bottom) : ");
        for(int i = symbol_table_top-1 ; i >= 0 ; i--) {
            printf("(%d, %s, %s), ", symbol_table[i]->scope, type_names[symbol_table[i]->type], symbol_table[i]->name);
        }
        printf("\n");
        return;
}


void var_declaration_list_append(var_declaration_list * list_ptr, char * name, int type) {
        if(list_ptr->index >= MAX_DECLARATIONS_PER_STATEMENT) yyerror("MAX_DECLARATIONS_PER_STATEMENT limit exceeded.");
        else {
            int name_len = strlen(name);
            // printf("appending id %s at index %d\n", name, list_ptr->index);
            char * new_name = malloc(name_len+1);
            strcpy(new_name, name);
            list_ptr->names[list_ptr->index] = new_name;
            list_ptr->assigned_types[list_ptr->index] = type;
            list_ptr->index++;
            return;
        }
}

void var_declaration_list_union(var_declaration_list * dest_ptr, var_declaration_list * src_ptr) {
        // Append all elements of src_ptr into dest_ptr
        // printf("unioning\n");
        for(int i = 0 ; i < src_ptr->index ; i++) {
            var_declaration_list_append(dest_ptr, src_ptr->names[i], src_ptr->assigned_types[i]);
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

                printf("(%s, %s)", list_ptr->names[i], list_ptr->assigned_types[i] == -1 ? "uninitialized" : type_names[list_ptr->assigned_types[i]]);
            }
            printf("\n");
        }
}
