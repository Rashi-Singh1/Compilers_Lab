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
    bool project(custom_list * c , char * tbl);
    bool equi_join(char* table_1 , char * table_2 , list_pair * l);
%}

%union {
        char* str;
        void* attr_set;
        void* attr_pair;
        void* attr_pair_list;
       }
%start QUERY_LIST
%token MORE
%token RP
%token LP
%token EQUAL
%token COMMA
%token LESS
%token LESSEQUAL
%token MOREEQUAL
%token NOTEQUAL
%token WHITESPACE
%token NUM
%token QUOTE
%token SEMI
%token DOT
%token AND
%token OR
%token NOT
%token SELECT
%token PROJECT
%token CARTESIAN_PRODUCT
%token EQUI_JOIN
%token <str> ID 
%type <str> TABLE
%type <attr_set> ATTR_LIST
%type <attr_pair> EQUI_COND 
%type <attr_pair_list> JOIN_COND 

/* actual grammar implementation in C*/
%%
QUERY_LIST : QUERY SEMI | QUERY SEMI QUERY_LIST
;


QUERY : SELECT LESS SELECT_COND MORE LP TABLE RP {
        }

       | PROJECT LESS ATTR_LIST MORE LP TABLE RP {
           if(!project((custom_list *)$3 , $6)){
               yyerror("unsuccesful project");
           }

           free($6);
           free($3);
        }

       | LP TABLE RP CARTESIAN_PRODUCT LP TABLE RP {
           if(!cartesian_product($2 , $6)){
               yyerror("unsuccesful cartesian_product\n");
           }

           free($2);
           free($6);
        }
       
       | LP TABLE RP EQUI_JOIN LESS JOIN_COND MORE LP TABLE RP{
            if(!equi_join($2 , $9, (list_pair *) $6)){
                yyerror("unsuccesful equi_join operation\n");
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
              }

            | OR_NOT_COND AND SELECT_COND {
              }
;


OR_NOT_COND : NOT_COND {
              }

            | NOT_COND OR OR_NOT_COND {
              }
;


NOT_COND : NOT COND 
           | COND
;


COND : CONST_OR_ID OP CONST_OR_ID 
;


OP : EQUAL | LESS | MORE | LESSEQUAL | MOREEQUAL | NOTEQUAL 
;


CONST_OR_ID : ID | QUOTE ID QUOTE | NUM
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
    fprintf(stderr, "%s", s);
    exit(1);
}

char* is_valid_table(char* table)
{
    char* path1 = (char*) malloc(sizeof(char)*MAX_LEN);
    strcpy(path1,DB_PATH);
    strcat(path1,table);
    strcat(path1,".csv");
    FILE *fptr1 = fopen(path1,"r");
    if(fptr1 == NULL) {
        char error_string[MAX_LEN] = {'\0'};
        strcpy(error_string,path1);
        strcat(error_string," does not exist\n");
        yyerror(error_string);
        return NULL;
    }
    return path1;
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
    } else NULL;
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
    printf("TABLE_1 = %s, TABLE_2 = %s\n", table_1, table_2);
    
    // Check tables exist
    char* path1 = is_valid_table(table_1);
    char* path2 = is_valid_table(table_2);
    if(path1 == NULL || path2 == NULL) return false;
    
    // Open files
    FILE* fptr1 = fopen(path1,"r");
    FILE* fptr2 = fopen(path2,"r");
    char output_path[MAX_LEN] = {'\0'};
    strcpy(output_path,table_1);
    strcat(output_path,"_");
    strcat(output_path,table_2);
    strcat(output_path,"_cart.csv");
    FILE* output = fopen(output_path,"w");
    
    // Write column names
    char** column_list1 = read_record(fptr1);
    char** column_list2 = read_record(fptr2);
    char** all_columns = merge_arrays(column_list1,column_list2);
    fprintf(output,"%s\n",coma_separated_string(all_columns));
    
    // Read table 2 into memory
    char *** file2 = read_all_records(fptr2);
    
    // Print into output file
    char ** record1;
    while((record1 = read_record(fptr1))){
        char ** record2;
        int index = 0;
        while((record2 = file2[index++])){
          char** merged_record = merge_arrays(record1,record2);
          fprintf(output,"%s\n",coma_separated_string(merged_record));    
        }
    }

    // Close files
    fclose(fptr1);
    fclose(fptr2);
    fclose(output);

    printf("cartesian_product succesful\n");
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
    strcpy(output_path,tbl);
    strcat(output_path,"_proj.csv");
    FILE* output = fopen(output_path,"w");
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
            strcpy(error_string,(c->arr)[i]);
            strcat(error_string," not found in ");
            strcat(error_string,tbl);
            yyerror(error_string);
            return false;
        }
    }
    char** record;
    for(int i = c->last-1;i>0;i--)
    {
        fprintf(output,"%s,",(c->arr)[i]);
    }
    fprintf(output,"%s\n",(c->arr)[0]);
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
    }
    fclose(fptr);
    fclose(output);

    printf("project succesful\n");
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
    strcpy(output_file,table_1);
    strcat(output_file,"_");
    strcat(output_file,table_2);
    strcat(output_file,"_equi_join.csv");
    FILE* output = fopen(output_file,"w");
    char ** record1 , **record2;
    fprintf(output,"%s,%s\n",coma_separated_string(column_list1),coma_separated_string(column_list2));
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
            }
        }
        
    }
    printf("equi_join succesful\n");
    return true;
}
