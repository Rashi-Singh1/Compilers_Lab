%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdbool.h>
    #include <string.h>
    int yylex(); 
    void yyerror(const char *s);

    #define YYDEBUG 1
    #define MAX_ATTR_LIST 1024
    #define MAX_RECORD_LEN 1024
    #define MAX_COL_LIMIT 30
    #define MAX_RECORDS 30
    #define MAX_LEN 1024
    #define DB_PATH "data/"

    typedef
    struct custom_list{
        char * arr[MAX_ATTR_LIST];
        int last;
    } custom_list;

    void list_insert_string( custom_list* lst , char * str){
        // NULL check
        if(lst == NULL){
            yyerror("Inserting into NULL");
            return;
        }
        
        lst->arr[lst->last] = str;
        (lst->last)++;
        return; 
    }

    void copy_list( custom_list *list1 ,  custom_list list2){
        for(int i = 0; i < list2.last; ++i){
            list_insert_string(list1, (list2.arr)[i]);
        }
        return;
    }

    void list_show(const char * name, custom_list* lst){
        if(lst == NULL){
            yyerror("Inserting into NULL");
            return;
        }
        
        printf("%s : ", name);
        for(int i = 0; i < lst->last; ++i){
            printf("%s ", (lst->arr)[i]);
        }
        printf("\n");
        return;
    }

    enum TYPE{AND_op, OR_op, NOT_op, VAR, CONST};

    typedef
    struct node{
        struct node** children;
        int child_count;
        int type;
        char* attr_name;
    } node;

    bool is_leaf(node* leaf)
    {
        if(leaf == NULL) return false;
        return (leaf->type == VAR || leaf->type == CONST);
    }

    node* create_node(int Type, char* Attr_name)
    {
        node* new_node = (node*)malloc(sizeof(node));
        new_node->type = Type;
        new_node->attr_name = Attr_name;
        new_node->child_count = 0;
        return new_node;
    }

    void insert_child(node* parent,node* child)
    {
        if(parent == NULL || child == NULL) return;
        if(!parent->child_count) parent->children = (node**) malloc(sizeof(node*) * sizeof(MAX_LEN));
        parent->children[parent->child_count++] = child;
    }

    typedef
    struct string_pair{
            char *first_attr;
            char* second_attr;
            char *first_tbl;
            char* second_tbl;
    } string_pair;

    typedef
    struct list_pair{
        custom_list first_attr;
        custom_list second_attr;
        custom_list first_tbl;
        custom_list second_tbl;
    } list_pair;

    char** read_record(FILE* fptr);
    bool cartesian_product(char *table_1 , char * table_2);
    bool equi_join(char* table_1 , char * table_2 , list_pair * l);
    bool project(custom_list * c , char * tbl);
    bool perform_select_op(char* tbl_name,node* root);
    bool compare(node* parent, char** record, char** column_list);
%}

%union {
        char* str;
        void* attr_set;
        void* attr_pair;
        void* attr_pair_list;
        void* root;
       }
%start QUERY_LIST
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
%token SELECT
%token PROJECT
%token CARTESIAN_PRODUCT
%token EQUI_JOIN
%token <str> ID 
%type <str> TABLE
%type <attr_set> ATTR_LIST
%type <attr_pair> EQUI_COND 
%type <attr_pair_list> JOIN_COND 
%type <root> SELECT_COND 
%type <root> COND 
%type <root> OP 
%type <root> NOT_COND 
%type <root> OR_NOT_COND
%type <root> CONST_OR_ID

/* actual grammar implementation in C*/
%%

QUERY_LIST : QUERY SEMI | QUERY SEMI QUERY_LIST
;

VAR: INT MULTI_DECLARATION SEMI{}
    | FLOAT MULTI_DECLARATION SEMI{}
;

MULTI_DECLARATION : DECLARATION COMMA MULTI_DECLARATION{} 
            | DECLARATION {}
;

DECLARATION : ID ASSIGN TYPECAST ID{} | ID ASSIGN TYPECAST CONST_OR_ID{}
;

// add epsilon part
TYPECAST : LP DATA_TYPE RP {}
;

DATA_TYPE : VOID | INT | FLOAT
; 

FUNC_DECLARATION : DATA_TYPE ID LP PARAM_LIST_WITH_DATATYPE RP SEMI{}
;

PARAM_LIST_WITH_DATATYPE : PARAM_WITH_DATATYPE COMMA PARAM_LIST_WITH_DATATYPE | PARAM_WITH_DATATYPE{}
;

PARAM_WITH_DATATYPE : DATA_TYPE ID{}
;

FUNC_DEFINITION : DATA_TYPE ID LP PARAM_LIST_WITH_DATATYPE RP CLP STMT_LIST CRP{}
;

STMT_LIST : STMT STMT_LIST | STMT{}
;

//more additions needed here
STMT : VAR | FUNC_CALL{}
;

FUNC_CALL : ID LP PARAM_LIST_WO_DATATYPE RP SEMI{}
;

//WO : WITHOUT
PARAM_LIST_WO_DATATYPE : PARAM_WO_DATATYPE COMMA PARAM_LIST_WO_DATATYPE | PARAM_WO_DATATYPE{}
;

//EXP is for part 2 (grammar written by Sparsh)
PARAM_WO_DATATYPE : null | BITAND EXP | BITAND LP EXP RP | EXP
;

LOOP : FOR FORLOOP BODY | WHILE LP EXP RP BODY 
;

BODY : CLP STMT_LIST CRP | STMT
;

FORLOOP : LP COMMA_SEP_INIT SEMI CONDITION SEMI COMMA_SEP_INCR RP  
;

//add the epsilon part
COMMA_SEP_INIT : ID ASSIGN EXP COMMA COMMA_SEP_INIT | COMMA_SEP_DATATYPE_INIT
;

COMMA_SEP_DATATYPE_INIT : ID ASSIGN EXP | DATA_TYPE COMMA_SEP_INIT_PRIME
;

COMMA_SEP_INIT_PRIME : ID ASSIGN EXP COMMA COMMA_SEP_INIT_PRIME | ID ASSIGN EXP
;

//change this later to the logical part of EXP (yet to be written)
CONDITION : EXP
;

COMMA_SEP_INCR : ADD ADD ID | MINUS MINUS ID | ID ADD ADD | ID MINUS MINUS | ID ASSIGN EXP | ID OTHER ASSIGN EXP
;

OTHER : MOD | ADD | MINUS | MUL | DIV | BITAND | BITOR | BITXOR 
;

//more additions for part 2 of question
EXP : CONST_OR_ID 
;

QUERY : SELECT LESS SELECT_COND MORE LP TABLE RP {
            if(!perform_select_op($6,(node*) $3)) yyerror("Select operation failed\n");
        }

       | PROJECT LESS ATTR_LIST MORE LP TABLE RP {
           if(!project((custom_list *)$3 , $6)){
               yyerror("unsuccessful project");
           }

           free($6);
           free($3);
        }

       | LP TABLE RP CARTESIAN_PRODUCT LP TABLE RP {
           if(!cartesian_product($2 , $6)){
               yyerror("Unsuccessful cartesian product\n");
           }

           free($2);
           free($6);
        }
       
       | LP TABLE RP EQUI_JOIN LESS JOIN_COND MORE LP TABLE RP{
            if(!equi_join($2 , $9, (list_pair *) $6)){
                yyerror("unsuccessful equi_join operation\n");
            }
         }
;


TABLE : ID {
        $$ = $1;
    }
;


ATTR_LIST : ID {
                custom_list * l_ptr = (custom_list *)malloc(sizeof(custom_list));
                list_insert_string(l_ptr, $1);
                $$ = (void *)(l_ptr);
            }
        | ID COMMA ATTR_LIST{
            list_insert_string((custom_list *) $3, $1);
            $$ = $3;
          }
;


SELECT_COND : OR_NOT_COND {
                node* and_node = create_node(AND_op,NULL);
                insert_child(and_node,(node*)$1);
                $$ = (void*) and_node;
            }

            | OR_NOT_COND AND SELECT_COND {
                insert_child((node*)$3,(node*)$1);
                $$ = $3;
            }
;


OR_NOT_COND : NOT_COND {
                node* or_node = create_node(OR_op,NULL);
                insert_child(or_node,(node*)$1);
                $$ = (void*) or_node;
            }

            | NOT_COND OR OR_NOT_COND {
                insert_child((node*)$3,(node*)$1);
                $$ = $3;
            }
;


NOT_COND : NOT COND {
            node* not_node = create_node(NOT_op,NULL);
            insert_child(not_node,$2);
            $$ = (void*) not_node;
        }

        | COND {
            $$ = $1;
        }
           
;


COND : CONST_OR_ID OP CONST_OR_ID {
    insert_child((node*)$2,(node*)$1);
    insert_child((node*)$2,(node*)$3);
    $$ = $2;
}
;


OP : EQUAL {
        $$ = (void*) create_node(EQUAL,NULL);
    }
    | LESS {
            $$ = (void*) create_node(LESS,NULL);
    }
    | MORE {
            $$ = (void*) create_node(MORE,NULL);
    }
    | LESSEQUAL {
            $$ = (void*) create_node(LESSEQUAL,NULL);
    }
    | MOREEQUAL {
            $$ = (void*) create_node(MOREEQUAL,NULL);
    }
    | NOTEQUAL {
            $$ = (void*) create_node(NOTEQUAL,NULL);
    }
;


CONST_OR_ID : ID {
        $$ = (void*)create_node(VAR,$1);
    }

    | QUOTE ID QUOTE {
        $$ = (void*)create_node(CONST,$2);
    }

    | NUM {
        $$ = (void*)create_node(CONST,$1);
    }
;


JOIN_COND : EQUI_COND{
                    list_pair *l = (list_pair *)malloc(sizeof(list_pair));
                    string_pair* equi_c = (string_pair *) $1;
                    list_insert_string(&(l->first_attr) ,  equi_c->first_attr);
                    list_insert_string(&(l->second_attr) , equi_c->second_attr);
                    list_insert_string(&(l->first_tbl) ,  equi_c->first_tbl);
                    list_insert_string(&(l->second_tbl) , equi_c->second_tbl);
                    $$ = (void *) l;
            }
           | EQUI_COND AND JOIN_COND{
                    list_pair *l = (list_pair *) $3;
                    string_pair* equi_c = (string_pair *) $1;
                    list_insert_string(&(l->first_attr) ,  equi_c->first_attr);
                    list_insert_string(&(l->second_attr) , equi_c->second_attr);
                    list_insert_string(&(l->first_tbl) ,  equi_c->first_tbl);
                    list_insert_string(&(l->second_tbl) , equi_c->second_tbl);
                    $$ = (void *)l;
             }
;


EQUI_COND : TABLE DOT ID EQUAL TABLE DOT ID{
                  string_pair *s = (string_pair*) malloc(sizeof(string_pair));
                  s->first_attr = $3;
                  s->second_attr = $7;
                  s->first_tbl = $1;
                  s->second_tbl = $5;
                  $$ = (void *) s;
            }
;


%%
void print_record(char** record)
{
    char * val;
    int index = 0;
    while((val = record[index++]) != NULL){
        printf(":%s:", val);
    }
    printf("\n");
    return;
}

int main(void){
    // FILE *fptr = fopen("data/t1.csv" , "r");
    // char ** record;
    // while((record = read_record(fptr))){
    
    // }
    // //yydebug = 1;
    return yyparse();
}

void yyerror(const char *s){
    fprintf(stderr, "ERROR: %s\n", s);
    exit(1);
}

char* is_valid_table(char* table)
{
    char* path = (char*) malloc(sizeof(char)*MAX_LEN);
    strcpy(path,DB_PATH);
    strcat(path,table);
    strcat(path,".csv");
    FILE *fptr1 = fopen(path,"r");
    if(fptr1 == NULL) {
        char error_string[MAX_LEN] = {'\0'};
        strcpy(error_string,path);
        strcat(error_string," not found. Table does not exist.\n");
        yyerror(error_string);
        return NULL;
    }
    return path;
}

char** read_record(FILE* fptr){
    char buff[MAX_RECORD_LEN + 1] = {'\0'};
    if(fgets(buff , MAX_RECORD_LEN , fptr)){
        buff[strlen(buff)-1]='\0';
        char ** output_str = malloc(sizeof(char *) * MAX_COL_LIMIT);
        const char delim[2] = ",";
        char *token = strtok(buff, delim);
        int index = 0;
        while( token != NULL ) {
            char *token_str = (char *)malloc(sizeof(char) * MAX_LEN);
            strcpy(token_str , token);
            output_str[index++] = token_str;
            token = strtok(NULL, delim);
        }
        return output_str;
    } else return NULL;
}

char** merge_arrays(char** array1 , char** array2){
        char ** output_str = malloc(sizeof(char *) * MAX_COL_LIMIT);
        char * val;
        int index = 0;
        int out = 0;
        while((val = array1[index++]) != NULL){
            output_str[out++] = val;
        }
        index = 0;
        while((val = array2[index++]) != NULL){
            output_str[out++] = val;
        }
        return output_str;
}

char* coma_separated_string(char ** arr){
    char * output_str = (char *) malloc(sizeof(char) * MAX_COL_LIMIT * MAX_LEN);
    int flag = 0;
    char* val;
    int index = 0;
    while((val = arr[index++]) != NULL){
            flag = 1;
            strcat(output_str , val);
            strcat(output_str , ",");
    }
    if(flag) output_str[strlen(output_str) - 1] = '\0';
    return output_str;
        
}

char*** read_all_records(FILE* fptr)
{
    char*** output = (char***) malloc(sizeof(char**) * MAX_RECORDS);
    char ** record;
    int index = 0;
    while((record = read_record(fptr))){
        output[index++] = record;
    }
    return output;
}

bool cartesian_product(char *table_1 , char * table_2){

    // Check tables exist
    char* path1 = is_valid_table(table_1);
    char* path2 = is_valid_table(table_2);
    if(path1 == NULL || path2 == NULL) return false;
    
    // Open files
    FILE* fptr1 = fopen(path1,"r");
    FILE* fptr2 = fopen(path2,"r");
    char output_path[MAX_LEN] = {'\0'};
    strcpy(output_path,"output/");
    strcat(output_path,table_1);
    strcat(output_path,"_");
    strcat(output_path,table_2);
    strcat(output_path,"_cart.csv");
    FILE* output = fopen(output_path,"w");
    printf("\nCartesian product of tables - %s and %s\n\n", table_1, table_2);
    
    // Write column names
    char** column_list1 = read_record(fptr1);
    int num_of_columns_1 = 0;
    char* val;
    while(val = column_list1[num_of_columns_1]) num_of_columns_1++;
    char** column_list2 = read_record(fptr2);
    int num_of_columns_2 = 0;
    while(val = column_list2[num_of_columns_2]) num_of_columns_2++;
    // printf("No. of columns in %s: %d\n", table_1, num_of_columns_1);
    // printf("No. of columns in %s: %d\n", table_2, num_of_columns_2);
    char** all_columns = merge_arrays(column_list1, column_list2);
    fprintf(output,"%s\n", coma_separated_string(all_columns));
    printf("%s\n", coma_separated_string(all_columns));
    
    // Read table 2 into memory
    char *** file2 = read_all_records(fptr2);
    
    // Print into output file
    char ** record1;
    // int record_1_index = 0;
    while((record1 = read_record(fptr1))){
        // record_1_index++;
        // int num_cells_1 = 0;
        // while(val = record1[num_cells_1]) num_cells_1++;
        // if(num_cells_1 != num_of_columns_1) {
        //     char error_string[MAX_LEN] = {'\0'};
        //     sprintf(error_string, "")
        //     strcpy(error_string,"Record ");
        //     strcat()
        //     strcat(error_string," not found. Table does not exist.\n");
        //     yyerror(error_string);
        // }

        char ** record2;
        int index = 0;
        while((record2 = file2[index++])){
          char** merged_record = merge_arrays(record1,record2);
          fprintf(output,"%s\n",coma_separated_string(merged_record));
          printf("%s\n",coma_separated_string(merged_record));
        }
    }

    // Close files
    fclose(fptr1);
    fclose(fptr2);
    fclose(output);

    // printf("cartesian_product successful\n");
    return true;
}

bool project(custom_list * c , char * tbl){
    if(c->last == 0) return true;
    char* path = is_valid_table(tbl);
    if(path == NULL) return false;
    int indexes[c->last + 1];
    for(int i = 0; i < c->last; ++i){
        indexes[i] = -1;
    }
    FILE* fptr = fopen(path,"r");
    char output_path[MAX_LEN];
    strcpy(output_path,"output/");
    strcat(output_path,tbl);
    strcat(output_path,"_proj.csv");
    FILE* output = fopen(output_path,"w");
    printf("\nProject fields (");
    for(int i = c->last-1 ; i >= 0 ; i--) {
        if(i == c->last-1) printf("%s", c->arr[i]);
        else printf(", %s", c->arr[i]);
    }
    printf(") on table %s\n\n", tbl);
    
    char ** column_list = read_record(fptr);
    for(int i = c->last-1; i >=0 ; i--){
        int index = 0;
        char * val;
        while((val = column_list[index++])){
            if(strcmp(val , (c->arr)[i]) == 0){
                indexes[i] = index - 1;
            }
        }
        if(indexes[i] == -1){
            char error_string[MAX_LEN];
            sprintf(error_string, "Field '%s' not found in table %s.", (c->arr)[i], tbl);
            yyerror(error_string);
            return false;
        }
    }
    char** record;
    for(int i = c->last-1;i>0;i--)
    {
        fprintf(output,"%s,",(c->arr)[i]);
        printf("%s,",(c->arr)[i]);
    }
    fprintf(output,"%s\n",(c->arr)[0]);
    printf("%s\n",(c->arr)[0]);
    while(record = read_record(fptr))
    {
        int index = 0;
        char newRecord[MAX_COL_LIMIT * MAX_LEN] = {'\0'};
        for(index = c->last-1;index >=0;index--){
            strcat(newRecord,record[indexes[index]]);
            strcat(newRecord,",");

        }
        if(c->last > 0) newRecord[strlen(newRecord) - 1] = '\n';
        fprintf(output,"%s",newRecord);
        printf("%s",newRecord);
    }
    fclose(fptr);
    fclose(output);

    // printf("project successful\n");
    return true;
}

bool equi_join(char* table_1 , char * table_2 , list_pair * l){
    char* path1 = is_valid_table(table_1);
    char* path2 = is_valid_table(table_2);
    if(path1 == NULL ||  path2 == NULL) return false;
    //first_tbl.first_attr
    for(int i = 0; i < (l->first_tbl).last; i++){ 
        char table_name1[MAX_LEN];
        char table_name2[MAX_LEN];
        strcpy(table_name1,(l->first_tbl).arr[i]);
        strcpy(table_name2,(l->second_tbl).arr[i]);
        if( (strcmp(table_name1, table_1) != 0 && strcmp(table_name1, table_2) != 0)
            || (strcmp(table_name2 , table_1) != 0 && strcmp(table_name2 , table_2) != 0)
        ) 
        { 
            yyerror("attribute list is not correct\n");
            return false;
        }
    }
    FILE* fptr1 = fopen(path1,"r");
    FILE* fptr2 = fopen(path2,"r");
    char ** column_list1 = read_record(fptr1);
    char ** column_list2 = read_record(fptr2);
    int indexes1[l->first_attr.last + 1][2];
    int indexes2[l->second_attr.last + 1][2];
    //indexes[][0] = index
    //indexes[][1] = table_id i.e 1 or 2
    for(int i = 0; i<l->first_attr.last;i++)
    {
        indexes1[i][0] = -1;
    }
    for(int i = 0; i<l->second_attr.last;i++)
    {
        indexes2[i][0] = -1;
    }
    for(int i = 0;i < (l->first_attr).last;i++)
    {
        char table_name1[MAX_LEN];
        strcpy(table_name1,(l->first_tbl).arr[i]);
        // printf("table_name1 : %s table_1 : %s\n",table_name1,table_1);
        if(strcmp(table_name1,table_1) == 0)
        {
            int index = 0;
            char* val;
            while(val = column_list1[index++])
            {
                // printf("column_list1[index] : %s; and first_attr[i] : %s;\n",val,(l->first_attr).arr[i]);
                if(strcmp(val,(l->first_attr).arr[i]) == 0) {
                    // printf("index : %d\n", index-1);
                    indexes1[i][0] = index - 1;
                    indexes1[i][1] = 1;
                }
            }
            // printf("indexes1[i] : %d and i : %d\n",indexes1[i],i);
            if(indexes1[i][0] == -1) {
                char error_string[MAX_LEN];
                strcpy(error_string,(l->first_attr).arr[i]);
                strcat(error_string," not found in ");
                strcat(error_string,table_1);
                yyerror(error_string);
                return false;
            }
        }
        else{
            int index = 0;
            char* val;
            while(val = column_list2[index++])
            {
                // printf("column_list2[index] : %s; and first_attr[i] : %s;\n",val,(l->first_attr).arr[i]);
                if(strcmp(val,(l->first_attr).arr[i]) == 0) indexes1[i][0] = index - 1;
                indexes1[i][1] = 2;
            }
            if(indexes1[i][0] == -1) {
                char error_string[MAX_LEN];
                strcpy(error_string,(l->first_attr).arr[i]);
                strcat(error_string," not found in ");
                strcat(error_string,table_2);
                yyerror(error_string);
                return false;
            }
        }
    }
    for(int i = 0;i < (l->second_attr).last;i++)
    {
        char table_name1[MAX_LEN];
        strcpy(table_name1,(l->second_attr).arr[i]);
        // printf("table_name1 : %s table_1 : %s\n",table_name1,table_1);
        if(strcmp(table_name1,table_1) == 0)
        {
            int index = 0;
            char* val;
            while(val = column_list1[index++])
            {
                // printf("column_list1[index] : %s; and second_attr[i] : %s;\n",val,(l->second_attr).arr[i]);
                if(strcmp(val,(l->second_attr).arr[i]) == 0) {
                    // printf("inside strcmp\n");
                    // printf("index : %d\n", index-1);
                    indexes2[i][0] = index - 1;
                    indexes2[i][1] = 1;
                }
            }
            if(indexes2[i][0] == -1) {
                char error_string[MAX_LEN];
                strcpy(error_string,(l->second_attr).arr[i]);
                strcat(error_string," not found in ");
                strcat(error_string,table_1);
                yyerror(error_string);
                return false;
            }
        }
        else{
            int index = 0;
            char* val;
            while(val = column_list2[index++])
            {
                // printf("column_list2[index] : %s; and second_attr[i] : %s;\n",val,(l->second_attr).arr[i]);
                if(strcmp(val,(l->second_attr).arr[i]) == 0) indexes2[i][0] = index - 1;
                indexes2[i][1] = 2;

            }
            if(indexes2[i][0] == -1) {
                char error_string[MAX_LEN];
                strcpy(error_string,(l->second_attr).arr[i]);
                strcat(error_string," not found in ");
                strcat(error_string,table_2);
                yyerror(error_string);
                return false;
            }
        }
    }
    // for(int i = 0;i<l->first_attr.last;i++)
    // {
    //     // printf("index : %d and indexes for first attr[0] : %d\n",i,indexes1[i][0]);
    // } for(int i = 0;i<l->second_attr.last;i++)
    // {
    //     // printf("index : %d and indexes for second attr[0] : %d\n",i,indexes2[i][0]);
    // }
    char output_file[MAX_LEN];
    strcpy(output_file,"output/");
    strcat(output_file,table_1);
    strcat(output_file,"_");
    strcat(output_file,table_2);
    strcat(output_file,"_equi_join.csv");
    FILE* output = fopen(output_file,"w");
    printf("\nEqui Join of tables - %s and %s\n\n", table_1, table_2);
    char ** record1 , **record2;
    fprintf(output,"%s,%s\n",coma_separated_string(column_list1),coma_separated_string(column_list2));
    printf("%s,%s\n",coma_separated_string(column_list1),coma_separated_string(column_list2));
    char*** file2 = read_all_records(fptr2);
    while(record1 = read_record(fptr1)){
        int idx = 0;
        while(record2 = file2[idx++]){
            // printf("record1 : %s\n record2 : %s\n",coma_separated_string(record1),coma_separated_string(record2));


            bool result = true;
            for(int i = 0 ; i < (l->first_attr.last) ; i++){
                char * left_val, *right_val;
                if(indexes1[i][1] == 1){
                    left_val = record1[indexes1[i][0]];
                    right_val = record2[indexes2[i][0]];
                }else{
                    left_val = record2[indexes1[i][0]];
                    right_val = record1[indexes2[i][0]];
                }
                // printf("leftval : %s and rightval : %s\n",left_val,right_val);
                if(strcmp(left_val, right_val) != 0){
                    result = false;
                    break;
                }
            }
            if(result){
                fprintf(output,"%s,%s\n",coma_separated_string(record1),coma_separated_string(record2));
                printf("%s,%s\n",coma_separated_string(record1),coma_separated_string(record2));
            }
        }
        
    }
    // printf("equi_join successful\n");
    return true;
}

//DFS
void traverse_root(node* root)
{
    if(root == NULL) return;
    printf("type %d : ",root->type);
    if(root->attr_name) printf("attr %s\n",root->attr_name);
    else printf("NULL\n");
    for(int i = 0;i < root->child_count;i++)
    {
        traverse_root((root->children)[i]);
    }
}

bool perform_select_op(char* tbl_name,node* root)
{
    // traverse_root(root);
    char* path = is_valid_table(tbl_name);
    char error_string[MAX_LEN];
    strcmp(error_string,tbl_name);
    strcat(error_string," not found\n");
    if(path == NULL) {
        yyerror(error_string);
        return false;
    }
    FILE* fptr = fopen(path,"r");
    char output_path[MAX_LEN];
    strcpy(output_path,"output/");
    strcat(output_path,tbl_name);
    strcat(output_path,"_select.csv");
    FILE* output = fopen(output_path,"w");
    printf("\nOutput of select operation\n\n");
    char** column_list = read_record(fptr);
    fprintf(output,"%s\n",coma_separated_string(column_list));
    printf("%s\n",coma_separated_string(column_list));
    char** record;
    while(record = read_record(fptr))
    {
        if(compare(root,record,column_list)){
            fprintf(output,"%s\n",coma_separated_string(record));
            printf("%s\n",coma_separated_string(record));
        } 
    }
    fclose(fptr);
    fclose(output);
    // printf("select operation successful\n");
    return true;
}

bool is_num(char* attr_name)
{
    if(attr_name == NULL) return false;
    int iter = 0;
    char v;
    while((v = attr_name[iter++]) != '\0'){
        if(v < '0' || v > '9') return false;
    }
    return true;
}

void get_values(node* child,char** val, int* value, bool* is_int, char** record, char** column_list)
{
    if(child->type == VAR)
    {
        int col_index = -1;
        char* var;
        int index = 0;
        while(var = column_list[index++])
        {
            if(strcmp(var,child->attr_name) == 0) {
                col_index = index - 1;
                break;
            }
        }
        char error_string[MAX_LEN] = {'\0'};
        strcpy(error_string,child->attr_name);
        strcat(error_string," not found\n");
        if(col_index == -1) {
            yyerror(error_string);
            return;
        }
        *val = record[col_index];
        *is_int = is_num(*val);
        if(*is_int) *value = atoi(*val);
    }
    else if(child->type == CONST)
    {
        *val = child->attr_name;
        *is_int = is_num(*val);
        if(*is_int) *value = atoi(*val);
    }
    else yyerror("Wrong node type for leaf\n");
}

bool calculate_arith(node* parent, char** record, char** column_list)
{
    if(parent->child_count != 2) return false;

    char *val1, *val2;
    int value1, value2;
    bool is_int1 = false, is_int2 = false;

    node* child1 = parent->children[0];
    node* child2 = parent->children[1];
    if(child1 == NULL || child2 == NULL) return false;

    get_values(child1,&val1, &value1, &is_int1, record, column_list);
    get_values(child2,&val2, &value2, &is_int2, record, column_list);
    switch(parent->type){
        case EQUAL:
                    return !strcmp(val1, val2);
                   break; 
        case LESS:
                    if(is_int1 && is_int2) {
                        return value1 < value2;
                    }
                    else {
                        return strcmp(val1,val2) > 0;
                    }
                   break;
        case MORE:
                    if(is_int1 && is_int2) return value1 > value2;
                    else return strcmp(val1,val2) < 0;
                   break;
        case LESSEQUAL:
                    if(is_int1 && is_int2) return value1 <= value2;
                    else return strcmp(val1,val2) >= 0;
                   break;
        case MOREEQUAL:
                    if(is_int1 && is_int2) return value1 >= value2;
                    else return strcmp(val1,val2) <= 0;
                   break;
    }
}

bool calculate_logic(node* parent, char** record, char** column_list)
{
    bool ans = parent->type == AND_op ? true : false;

    for(int i = 0;i <parent->child_count;i++)
    {
        if(parent->type == AND_op) ans = ans && compare((parent->children)[i],record, column_list);
        else ans = ans || compare((parent->children)[i],record, column_list);
    }
    return ans;
}

bool compare(node* parent, char** record, char** column_list)
{
    if(parent == NULL) return false;
    switch(parent->type)
    {
        case EQUAL: 
        case LESS:
        case MORE:
        case LESSEQUAL:
        case MOREEQUAL: return calculate_arith(parent, record, column_list);
        break;
        case AND_op:
        case OR_op: return calculate_logic(parent, record, column_list);
        break;
        case NOT_op: return (parent->child_count > 0 && !compare(parent->children[0], record, column_list));
        break;
        default: return false;
        break;
    }
}
