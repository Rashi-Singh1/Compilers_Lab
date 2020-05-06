%{
#pragma GCC diagnostic ignored "-Wwrite-strings"
#include <iostream>
#include <vector>
#include <stack>
#include <stdio.h>
#include "helperfunctions.h"
#include "datastructures.h"
using namespace std;
#include <algorithm>
#include <utility>
#include <fstream>
#define YYERROR_VERBOSE 1

extern int yylex();
extern int yyparse();
extern int yylineno;
extern char* yytext;
extern int yyleng;
void yyerror(const char* s);

int offsetCalc;
string text;
data_type resultType;
vector<sym_tab_entry*> sym_tab_entry_list;
stack<vector<sym_tab_entry*> > paramListStack;
sym_tab_entry* var_rec;
vector<int> decdimlist;
vector<sym_tab_entry*> global_vars;

int nextquad;
vector<string> functionInstruction;
register_handler_class tempSet;

vector<function_entry*> sym_tab_func_entry;
function_entry* current_function;
function_entry* func_call_ptr;
int scope;
int found;
bool errorFound;
int numberOfParameters;
string conditionVar;
vector<string> switchVar;
vector<function_entry*> callFuncPtrList;
vector<string> dimlist;

vector<pair<string,int>> sVar;


%} 

%code requires{
    #include "helperfunctions.h"
    #include "datastructures.h"
}

%union {
    int intval;
    float floatval;
    char *idName;
    int quad;
    struct expression expr;
    struct stmt stmtval;
    struct whileexp whileexpval;
    struct shortcircuit shortCircuit;
    struct switchcaser switchCase;
    struct switchtemp switchTemp;
    struct condition2temp ctemp;
}

%token INT FLOAT VOID NUMFLOAT NUMINT ID NEWLINE READ PRINT
%token COLON QUESTION DOT LCB RCB LSB RSB LP RP SEMI COMMA ASSIGN
%token IF ELSE CASE BREAK DEFAULT CONTINUE WHILE FOR RETURN SWITCH MAIN
%token LSHIFT RSHIFT PLUSASG MINASG MULASG MODASG DIVASG INCREMENT DECREMENT XOR BITAND BITOR PLUS MINUS DIV MUL MOD
%token NOT AND OR LT GT LE GE EQUAL NOTEQUAL

%type <idName> NUMFLOAT
%type <idName> NUMINT
%type <idName> ID
%type <expr> EXPR2 TERM FACTOR ID_ARR ASG ASG1 EXPR1 EXPR21 LHS FUNC_CALL BR_DIMLIST
%type <whileexpval> WHILEEXP IFEXP N3 P3 Q3 FOREXP TEMP1
%type <stmtval> BODY WHILESTMT IFSTMT M2 FORLOOP STMT STMT_LIST
%type <quad> M1 M3 Q4 
%type <shortCircuit> CONDITION1 CONDITION2
%type <switchCase> CASELIST
%type <switchTemp> TEMP2
%type <ctemp> TP1
%%

MAIN_PROG: PROG MAINFUNCTION
    | MAINFUNCTION
;

PROG: PROG FUNC_DEF
    | PROG VAR_DECL
    | FUNC_DEF
    | VAR_DECL
;

MAINFUNCTION: MAIN_HEAD LCB BODY RCB
    {
        clear_var_list(current_function, scope);
        current_function=NULL;
        scope=0;
        string s = "function end";
        generate_instr(functionInstruction, s, nextquad);
    }
;

MAIN_HEAD: INT MAIN LP RP
    {   
        scope=1;
        current_function = new function_entry;
        current_function->name = string("main");
        current_function->return_type = INTEGER;
        current_function->param_num = 0;
        current_function->param_list.clear();
        current_function->list_of_variables.clear();  
        current_function->function_offset = 0;      ;
        sym_tab_entry_list.clear();
        look_up_function(current_function, sym_tab_func_entry, found);
        if (found) {
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": Function " << current_function->name <<  " already declared." << endl;
            delete current_function;
            current_function = NULL;
        }   
        else {
            function_append(current_function, sym_tab_func_entry);
            scope = 2; 
            string s = "function begin main";
            generate_instr(functionInstruction, s, nextquad);
        }
    }
;

FUNC_DEF: FUNC_HEAD LCB BODY RCB
    {
        clear_var_list(current_function, scope);   
        current_function = NULL;
        scope = 0;
        string s = "function end";
        generate_instr(functionInstruction, s, nextquad);
    }
;

FUNC_HEAD: RES_ID LP DECL_PLIST RP
    {
        int found = 0;
        look_up_function(current_function, sym_tab_func_entry, found);
        if(found){
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": Function " << current_function->name <<  " already declared." << endl;
            errorFound = true;
            delete current_function;
            // cout<<"Function head me current_function deleted"<<endl;
        }   
        else{
            current_function->param_num = sym_tab_entry_list.size();
            current_function->param_list = sym_tab_entry_list;
            current_function->function_offset = 0;
            sym_tab_entry_list.clear();
            function_append(current_function, sym_tab_func_entry);
            scope = 2; 
            string s = "function begin _" + current_function->name;
            generate_instr(functionInstruction, s, nextquad);
        }
    }
; 

RES_ID: T ID       
    {   
        scope=1;
        current_function = new function_entry;
        current_function->name = string($2);
        current_function->return_type = resultType;
    } 
    | VOID ID
    {
        scope=1;
        current_function = new function_entry;
        current_function->name = string($2);
        current_function->return_type = NULLVOID;
    }
;




DECL_PLIST: DECL_PL
    | %empty
;

DECL_PL: DECL_PL COMMA DECL_PARAM
    {
        int found = 0;
        sym_tab_entry* pn = NULL;
        param_search(var_rec->name, sym_tab_entry_list, found, pn);
        if(found){
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": Redeclaration of parameter " << var_rec->name <<endl;
        } else {
            // cout << "Variable: "<< var_rec->name << " declared." << endl;
            sym_tab_entry_list.push_back(var_rec);
        }
        
    }
    | DECL_PARAM
    {  
        int found = 0;
        sym_tab_entry* pn = NULL;
        param_search(var_rec->name, sym_tab_entry_list, found , pn );
        if (found){
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": Redeclaration of parameter " << var_rec->name <<endl;
        } else {
            // cout << "Variable: "<< var_rec->name << " declared." << endl;
            sym_tab_entry_list.push_back(var_rec);
        }
    }
;

DECL_PARAM: T ID
    {
        var_rec = new sym_tab_entry;
        var_rec->name = string($2);
        var_rec->type = SIMPLE;
        var_rec->tag = VARIABLE;
        var_rec->scope = scope;
        var_rec->data_type_obj = resultType;
    }
;

BODY: STMT_LIST
    {
        $$.next_list = new vector<int>;
        merge_lists($$.next_list, $1.next_list);
        $$.break_list = new vector<int>;
        merge_lists($$.break_list, $1.break_list);
        $$.continue_list = new vector<int>;
        merge_lists($$.continue_list, $1.continue_list);
    }
    | %empty 
    {
        $$.next_list = new vector<int>;
        $$.break_list = new vector<int>;
        $$.continue_list = new vector<int>;
    }
;

STMT_LIST: STMT_LIST STMT 
    {
        $$.next_list = new vector<int>;
        merge_lists($$.next_list, $1.next_list);
        merge_lists($$.next_list, $2.next_list);
        $$.break_list = new vector<int>;
        merge_lists($$.break_list, $1.break_list);
        merge_lists($$.break_list, $2.break_list);
        $$.continue_list = new vector<int>;
        merge_lists($$.continue_list, $1.continue_list);
        merge_lists($$.continue_list, $2.continue_list);
    }
    | STMT 
    {
        $$.next_list = new vector<int>;
        merge_lists($$.next_list, $1.next_list);
        $$.break_list = new vector<int>;
        merge_lists($$.break_list, $1.break_list);
        $$.continue_list = new vector<int>;
        merge_lists($$.continue_list, $1.continue_list);
    }
;

STMT: VAR_DECL
    {
        $$.next_list = new vector<int>;
        $$.break_list = new vector<int>;
        $$.continue_list = new vector <int>;
    }
    | ASG SEMI
    {
        $$.next_list = new vector<int>;
        $$.break_list = new vector<int>;
        $$.continue_list = new vector <int>;
        if ($1.type != NULLVOID && $1.type != ERRORTYPE)
            tempSet.free_reg(*($1.reg_name));
    } 
    | FORLOOP
    {
        $$.next_list = new vector<int>;
        $$.break_list = new vector<int>;
        $$.continue_list = new vector <int>;
    }
    | IFSTMT
    {
        $$.next_list = new vector<int>;
        $$.break_list = new vector<int>;
        $$.continue_list = new vector <int>;
        merge_lists($$.continue_list, $1.continue_list);
        merge_lists($$.break_list, $1.break_list);

    }
    | WHILESTMT
    {
        $$.next_list = new vector<int>;
        $$.break_list = new vector<int>;
        $$.continue_list = new vector <int>;
    }
    | SWITCHCASE
    {
        $$.next_list = new vector<int>;
        $$.break_list = new vector<int>;
        $$.continue_list = new vector <int>;
    }
    | LCB {scope++;} BODY RCB 
    {
        $$.next_list = new vector<int>;
        $$.break_list = new vector<int>;
        $$.continue_list = new vector <int>;
        clear_var_list(current_function, scope);
        scope--;
        merge_lists($$.continue_list, $3.continue_list);
        merge_lists($$.break_list, $3.break_list);
    }
    | BREAK SEMI
    {
        $$.next_list = new vector<int>;
        $$.break_list = new vector<int>;
        $$.continue_list = new vector <int>;
        $$.break_list->push_back(nextquad);  
        generate_instr(functionInstruction, "goto L", nextquad);      
    }
    | CONTINUE SEMI
    {
        $$.next_list = new vector<int>;
        $$.break_list = new vector<int>;
        $$.continue_list = new vector <int>;
        $$.continue_list->push_back(nextquad);
        generate_instr(functionInstruction, "goto L", nextquad);
    }
    | RETURN ASG1 SEMI 
    {
        $$.next_list = new vector<int>;
        $$.break_list = new vector<int>;
        $$.continue_list = new vector <int>;
        if ($2.type != ERRORTYPE && current_function != NULL) {
            if (current_function->return_type == NULLVOID && $2.type != NULLVOID) {
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": function " << current_function->name << " has void return type not " << $2.type << endl;
            }
            else if (current_function->return_type != NULLVOID && $2.type == NULLVOID) {
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": function " << current_function->name << " has non-void return type" << endl;
            }
            else {
                string s;
                if (current_function->return_type != NULLVOID && $2.type != NULLVOID) {
                    if ($2.type == INTEGER && current_function->return_type == FLOATING)  {
                        string floatReg = tempSet.get_float_reg();
                        s = floatReg + " = " + "convertToFloat(" + *($2.reg_name) + ")";
                        cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                        generate_instr(functionInstruction, s, nextquad);
                        s = "return " + floatReg;
                        generate_instr(functionInstruction, s, nextquad);
                        tempSet.free_reg(*($2.reg_name));
                        tempSet.free_reg(floatReg);
                    }
                    else if ($2.type == FLOATING && current_function->return_type == INTEGER) {
                        string intReg = tempSet.get_temp_reg();
                        s = intReg + " = " + "convertToInt(" + *($2.reg_name) + ")";
                        cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                        generate_instr(functionInstruction, s, nextquad);
                        s = "return " + intReg;
                        generate_instr(functionInstruction, s, nextquad);
                        tempSet.free_reg(*($2.reg_name));
                        tempSet.free_reg(intReg);                        
                    }
                    else {
                        s = "return " + *($2.reg_name);
                        generate_instr(functionInstruction, s, nextquad);
                        tempSet.free_reg(*($2.reg_name));
                    }
                }
                else if (current_function->return_type == NULLVOID && $2.type == NULLVOID) {
                    s = "return";
                    generate_instr(functionInstruction, s, nextquad);
                }
                else {
                    errorFound = 1;
                    cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": Exactly one of function " << current_function->name << "and this return statement has void return type" << endl;
                    if ($2.type != NULLVOID) tempSet.free_reg(*($2.reg_name));
                } 
            }
        }
    }
    | READ ID_ARR SEMI
    {
        $$.next_list = new vector<int>;
        $$.break_list = new vector<int>;
        $$.continue_list = new vector <int>;
        if($2.type == ERRORTYPE){
            errorFound = true;
        }
        else{
            string reg_name;
            if ($2.type == INTEGER){
                reg_name = tempSet.get_temp_reg();
            }
            else {
                reg_name = tempSet.get_float_reg();
            }
            string s;
            s = "read " + reg_name;
            generate_instr(functionInstruction, s, nextquad);
            s = (*($2.reg_name)) + " = " +  reg_name;
            generate_instr(functionInstruction, s, nextquad);
            tempSet.free_reg(reg_name);
            if ($2.offset_reg_name != NULL) tempSet.free_reg(*($2.offset_reg_name));
        }
    }
    | PRINT ID_ARR SEMI
    {
        $$.next_list = new vector<int>;
        $$.break_list = new vector<int>;
        $$.continue_list = new vector <int>;
        if($2.type == ERRORTYPE){
            errorFound = true;
        }
        else{
            string reg_name;
            if ($2.type == INTEGER){
                reg_name = tempSet.get_temp_reg();
            }
            else {
                reg_name = tempSet.get_float_reg();
            }
            string s = reg_name + " = " + (*($2.reg_name)) ;
            generate_instr(functionInstruction, s, nextquad);
            s = "print " + reg_name;
            generate_instr(functionInstruction, s, nextquad);
            tempSet.free_reg(reg_name);
            if ($2.offset_reg_name != NULL) tempSet.free_reg(*($2.offset_reg_name));
        }
    }
    | error SEMI
    {
        errorFound = 1;
        $$.next_list = new vector<int>;
        $$.break_list = new vector<int>;
        $$.continue_list = new vector <int>;
        cout << BOLD(FRED("ERROR : ")) << FYEL("Line no. " + to_string(yylineno) + ": Syntax error") << endl;
    }
    | error
    {
        errorFound = 1;
        $$.next_list = new vector<int>;
        $$.break_list = new vector<int>;
        $$.continue_list = new vector <int>;
        cout << BOLD(FRED("ERROR : ")) << FYEL("Line no. " + to_string(yylineno) + ": Syntax error") << endl;
    }
;

VAR_DECL: D SEMI 
;

D: T L
    { 
        attach_data_type(resultType, sym_tab_entry_list, scope);
        if(scope > 1){
            symbol_table_append(sym_tab_entry_list, current_function);
            
        }
        else if(scope == 0){
            add_global_var(sym_tab_entry_list, global_vars);
        }
        sym_tab_entry_list.clear();
    }
;

T:  INT         { resultType = INTEGER; }
    | FLOAT     { resultType = FLOATING; }
;    

L: DEC_ID_ARR
    | L COMMA DEC_ID_ARR      
;

DEC_ID_ARR: ID
    {   
        int found = 0;
        sym_tab_entry* rec = NULL;
        // cout << "Scope : "<<scope<<endl;
        if(current_function!=NULL && scope > 0){
            look_up_variable(string($1), current_function, found, rec, scope);
            if (found) {
                if(rec->valid==true){
                    cout << BOLD(FRED("ERROR : ")) << "Line no. :" << yylineno << " Variable " << string($1) << " already declared at same level " << scope << endl ;
                }
                else{
                    if(rec->data_type_obj == resultType){
                        rec->valid=true;
                        rec->max_dim_offset = max(rec->max_dim_offset,1);
                        rec->type=SIMPLE;
                    }
                    else {
                        var_rec = new sym_tab_entry;
                        var_rec->name = string($1);
                        var_rec->type = SIMPLE;
                        var_rec->tag = VARIABLE;
                        var_rec->scope = scope;
                        var_rec->valid=true;
                        var_rec->max_dim_offset=1;
                        sym_tab_entry_list.push_back(var_rec);
                    }
                }
            }
            else if (scope == 2) {
                sym_tab_entry* pn = NULL;
                param_search(string($1), current_function->param_list, found , pn);
                if (found) {
                    // printf("Line no. %d: Vaiable %s is already declared as a parameter with scope %d\n", yylineno, $1, scope);
                    cout << BOLD(FRED("ERROR : ")) << "Line no. :" << yylineno << " Variable " << string($1) << " already declared in parameters " << endl ;
                } 
                else {
                    var_rec = new sym_tab_entry;
                    var_rec->name = string($1);
                    var_rec->type = SIMPLE;
                    var_rec->tag = VARIABLE;
                    var_rec->scope = scope;
                    var_rec->valid=true;
                    var_rec->max_dim_offset=1;
                    sym_tab_entry_list.push_back(var_rec);
                }
            }
            else {
                var_rec = new sym_tab_entry;
                var_rec->name = string($1);
                var_rec->type = SIMPLE;
                var_rec->tag = VARIABLE;
                var_rec->scope = scope;
                var_rec->valid=true;
                var_rec->max_dim_offset=1;
                sym_tab_entry_list.push_back(var_rec);
            }
        }
        else if(scope == 0){
            look_up_global_var(string($1), global_vars, found, rec, scope);
            if (found) {
                // printf("Variable %s already declared at global level \n", $1);
                cout << BOLD(FRED("ERROR : ")) << "Line no. :" << yylineno << " Variable " << string($1) << " already declared at global level " << endl ;
            }
            else{
                var_rec = new sym_tab_entry;
                var_rec->name = string($1);
                var_rec->type = SIMPLE;
                var_rec->tag = VARIABLE;
                var_rec->scope = scope;
                var_rec->valid=true;
                var_rec->max_dim_offset=1;
                // cout<<"variable name: "<<var_rec->name<<endl;
                sym_tab_entry_list.push_back(var_rec);   
            }
        } 
        else {
            errorFound = true;
        }
        
    }
    | ID ASSIGN ASG
    {
        int found = 0;
        sym_tab_entry* rec = NULL;
        if(current_function!=NULL){
            look_up_variable(string($1), current_function, found, rec, scope);
            bool varCreated = false;;
            if (found) {
                if(rec->valid==true){
                    cout << BOLD(FRED("ERROR : ")) << "Line no. :" << yylineno << " Variable " << string($1) << " already declared at same level " << scope << endl ;
                }
                else{
                    if(rec->data_type_obj == resultType){
                        rec->valid=true;
                        rec->max_dim_offset = max(rec->max_dim_offset,1);
                        rec->type=SIMPLE;
                        varCreated = true;
                    }
                    else {
                        var_rec = new sym_tab_entry;
                        var_rec->name = string($1);
                        var_rec->type = SIMPLE;
                        var_rec->tag = VARIABLE;
                        var_rec->scope = scope;
                        var_rec->valid=true;
                        var_rec->max_dim_offset=1;
                        sym_tab_entry_list.push_back(var_rec);
                        varCreated = true;
                    }
                }
            }
            else if (scope == 2) {
                sym_tab_entry* pn = NULL;
                param_search(string($1), current_function->param_list, found , pn);
                if (found) {
                    cout << BOLD(FRED("ERROR : ")) << "Line no. :" << yylineno << " Variable " << string($1) << " already declared at parameter level " << endl ;
                } 
                else {
                    var_rec = new sym_tab_entry;
                    var_rec->name = string($1);
                    var_rec->type = SIMPLE;
                    var_rec->tag = VARIABLE;
                    var_rec->scope = scope;
                    var_rec->max_dim_offset=1;
                    var_rec->valid=true;
                    sym_tab_entry_list.push_back(var_rec);
                    varCreated = true;
                }
            }
            else {
                var_rec = new sym_tab_entry;
                var_rec->name = string($1);
                var_rec->type = SIMPLE;
                var_rec->tag = VARIABLE;
                var_rec->scope = scope;
                var_rec->max_dim_offset=1;
                var_rec->valid=true;
                sym_tab_entry_list.push_back(var_rec);
                varCreated = true;
            }
            if(varCreated){
                if ($3.type == ERRORTYPE) {
                    errorFound = true;
                }
                else if ($3.type == NULLVOID) {
                    cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": Cannot assign void to non-void type " << string($1) << endl;
                    errorFound = true;
                }
                else {
                    string reg_name;
                    if (resultType == INTEGER && $3.type == FLOATING) {
                        reg_name = tempSet.get_temp_reg();
                        string s = reg_name + " = convertToInt(" + (*($3.reg_name)) + ")";   
                        cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                        generate_instr(functionInstruction, s, nextquad);
                        tempSet.free_reg(*($3.reg_name));
                    }
                    else if(resultType == FLOATING && ($3.type == INTEGER || $3.type == BOOLEAN)) {
                        reg_name = tempSet.get_float_reg();
                        string s = reg_name + " = convertToFloat(" + (*($3.reg_name)) + ")"; 
                        cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                        generate_instr(functionInstruction, s, nextquad); 
                        tempSet.free_reg(*($3.reg_name));
                    }
                    else {
                        reg_name = *($3.reg_name);
                    }
                    string dataType = get_string_from_data_type(resultType);
                    dataType += "_" + to_string(scope);
                    string s =  "_" + string($1) + "_" + dataType + " = " + reg_name ;
                    generate_instr(functionInstruction, s, nextquad);
                    tempSet.free_reg(reg_name);
                }   
            }
        }
        else if(scope == 0){
            cout << BOLD(FRED("ERROR : ")) << "Line No " << yylineno << ": ID assignments not allowed in global level : Variable " << string($1) << endl;
            errorFound = true;
        }
        else {
            errorFound = true;
        }
    }
    | ID DEC_BR_DIMLIST
    {  
        if (current_function != NULL) {
            int found = 0;
            sym_tab_entry* rec = NULL;
            look_up_variable(string($1), current_function, found, rec,scope); 
            if (found) {
                if(rec->valid==true){
                    cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": Variable " << string($1) << " already declared at same level " << scope << endl;
                }
                else{
                    if(rec->data_type_obj == resultType){
                        rec->valid=true;
                        int a=1;
                        for(auto it : decdimlist){
                            a*=(it);
                        }
                        rec->max_dim_offset = max(rec->max_dim_offset,a);
                        if(rec->type==ARRAY){
                            rec->dimlist.clear();           
                        }
                        rec->type=ARRAY;
                        rec->dimlist = decdimlist;
                    }
                    else {
                        var_rec = new sym_tab_entry;
                        var_rec->name = string($1);
                        var_rec->type = ARRAY;
                        var_rec->tag = VARIABLE;
                        var_rec->scope = scope;
                        var_rec->dimlist = decdimlist;
                        var_rec->valid=true;
                        int a=1;
                        for(auto it : decdimlist){
                            a*=(it);
                        }
                        var_rec->max_dim_offset = a;
                        sym_tab_entry_list.push_back(var_rec);
                    }
                }
            }
            else if (scope == 2) {
                sym_tab_entry* pn = NULL;
                param_search(string($1), current_function->param_list, found, pn);
                if (found) {
                    cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": Variable " << string($1) << " already declared at parameter level " << endl;
                } 
                else {
                    var_rec = new sym_tab_entry;
                    var_rec->name = string($1);
                    var_rec->type = ARRAY;
                    var_rec->tag = VARIABLE;
                    var_rec->scope = scope;
                    var_rec->dimlist = decdimlist;
                    var_rec->valid=true;
                    int a=1;
                    for(auto it : decdimlist){
                        a*=(it);
                    }
                    var_rec->max_dim_offset = a;
                    sym_tab_entry_list.push_back(var_rec);
                }
            }
            else{
                var_rec = new sym_tab_entry;        
                var_rec->name = string($1);
                var_rec->type = ARRAY;
                var_rec->tag = VARIABLE;
                var_rec->scope = scope;
                var_rec->dimlist = decdimlist;
                var_rec->valid=true;
                int a=1;
                for(auto it : decdimlist){
                    a*=(it);
                }
                var_rec->max_dim_offset = a;
                sym_tab_entry_list.push_back(var_rec);
            }
            // decdimlist.clear();  
        } 
        else if(scope == 0){
            sym_tab_entry* rec = NULL;
            look_up_global_var(string($1), global_vars, found, rec, scope);
            if (found) {
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": Variable " << string($1) << " already declared at global level " << endl;
            }
            else{
                var_rec = new sym_tab_entry;
                var_rec->name = string($1);
                var_rec->type = ARRAY;
                var_rec->tag = VARIABLE;
                var_rec->scope = scope;
                var_rec->dimlist = decdimlist;
                var_rec->valid=true;
                int a=1;
                for(auto it : decdimlist){
                    a*=(it);
                }
                var_rec->max_dim_offset = a;
                // cout<<"variable name : "<<var_rec->name<<endl;
                sym_tab_entry_list.push_back(var_rec);   
            }
        }   
        else{
            errorFound = 1;
        }
        decdimlist.clear();
    }
;

DEC_BR_DIMLIST: LSB NUMINT RSB
    {
        decdimlist.push_back(atoi($2));
    }
    | DEC_BR_DIMLIST LSB NUMINT RSB 
    {
        decdimlist.push_back(atoi($3));
    }
;

FUNC_CALL: ID LP PARAMLIST RP
    {
        func_call_ptr = new function_entry;
        func_call_ptr->name = string($1);
        func_call_ptr->param_list = sym_tab_entry_list;
        func_call_ptr->param_num = sym_tab_entry_list.size();
        int found = 0;
        // display_function(current_function);
        // display_function(func_call_ptr);
        int vfound=0;
        sym_tab_entry* rec;
        look_up_variable(func_call_ptr->name,current_function,vfound,rec,scope);
        if (vfound) {
            $$.type = ERRORTYPE;
            cout<< BOLD(FRED("ERROR : ")) << "Line no." << yylineno << ": called object "<< func_call_ptr->name << " is not a function or function pointer"<< endl;
        }
        else {
            check_function_entry(func_call_ptr,sym_tab_func_entry,found);
            $$.type = ERRORTYPE;
            if (found == 0) {
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
                cout << "No function with name " << string($1) << " exists" << endl;
            }
            else if (found == -1) {
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
                cout << "call parameter list does not match with defined paramters of function " << string($1) << endl;
            }
            else {
                $$.type = func_call_ptr->return_type;
                if(func_call_ptr->return_type == INTEGER){
                    $$.reg_name = new string(tempSet.get_temp_reg());
                    generate_instr(functionInstruction, "refparam " + (*($$.reg_name)), nextquad);
                    generate_instr(functionInstruction, "call _" + func_call_ptr->name + ", " + to_string(sym_tab_entry_list.size() + 1 ), nextquad);      
                }
                else if(func_call_ptr->return_type == FLOATING){
                    $$.reg_name = new string(tempSet.get_float_reg());
                    generate_instr(functionInstruction, "refparam " + (*($$.reg_name)), nextquad);
                    generate_instr(functionInstruction, "call _" + func_call_ptr->name + ", " + to_string(sym_tab_entry_list.size() + 1 ), nextquad);      
                }
                else if (func_call_ptr->return_type == NULLVOID) {
                    $$.reg_name = NULL;
                    generate_instr(functionInstruction, "call _" + func_call_ptr->name + ", " + to_string(sym_tab_entry_list.size()), nextquad);      
                }
                else {
                    cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": Illegal return type of function " << func_call_ptr->name << endl;
                }
            }
        }
        sym_tab_entry_list.clear();
        sym_tab_entry_list.swap(paramListStack.top());
        paramListStack.pop();
    }
;

PARAMLIST: PLIST
    | {paramListStack.push(sym_tab_entry_list); sym_tab_entry_list.clear();} %empty 
;

PLIST: PLIST COMMA ASG
    {
        var_rec = new sym_tab_entry;
        var_rec->data_type_obj = $3.type;
        if ($3.type == ERRORTYPE) {
            errorFound = true;
        }
        else {
            var_rec->name = *($3.reg_name);
            var_rec->type = SIMPLE;
            generate_instr(functionInstruction, "param " +  *($3.reg_name), nextquad);   
            tempSet.free_reg(*($3.reg_name));
        }
        sym_tab_entry_list.push_back(var_rec);
    }
    | {paramListStack.push(sym_tab_entry_list); sym_tab_entry_list.clear();} ASG
    {
        var_rec = new sym_tab_entry;
        var_rec->data_type_obj = $2.type;
        if ($2.type == ERRORTYPE) {
            errorFound = true;
        }
        else {
            var_rec->name = *($2.reg_name);
            var_rec->type = SIMPLE; 
            generate_instr(functionInstruction, "param " +  *($2.reg_name), nextquad);   
            tempSet.free_reg(*($2.reg_name));
        }
        sym_tab_entry_list.push_back(var_rec);
    }
;

ASG: CONDITION1
    {
        $$.type = $1.type;
        if($$.type != ERRORTYPE && $$.type != NULLVOID) {
            $$.reg_name = $1.reg_name;
            if($1.jump_list!=NULL){
                vector<int>* qList = new vector<int>;
                qList->push_back(nextquad);
                generate_instr(functionInstruction,"goto L",nextquad);
                backpatch($1.jump_list, nextquad, functionInstruction);
                generate_instr(functionInstruction, "L" + to_string(nextquad) + ":", nextquad);
                generate_instr(functionInstruction,(*($$.reg_name)) + " = 1",nextquad) ;
                backpatch(qList,nextquad,functionInstruction);
                qList->clear();
                generate_instr(functionInstruction, "L" + to_string(nextquad) + ":", nextquad);
            }
        }
    }
    | LHS ASSIGN ASG
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE;
            errorFound = true;
        }
        else if ($3.type == NULLVOID) {
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
            cout << "Cannot assign void to non-void type " << *($1.reg_name) << endl;
            $$.type = ERRORTYPE;
            errorFound = true;
        }
        else {
            $$.type = $1.type;
            string reg_name;
            if ($1.type == INTEGER && $3.type == FLOATING) {
                reg_name = tempSet.get_temp_reg();
                string s = reg_name + " = convertToInt(" + (*($3.reg_name)) + ")";   
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generate_instr(functionInstruction, s, nextquad);
                tempSet.free_reg(*($3.reg_name));
            }
            else if($1.type == FLOATING && ($3.type == INTEGER || $3.type == BOOLEAN)) {
                reg_name = tempSet.get_float_reg();
                string s = reg_name + " = convertToFloat(" + (*($3.reg_name)) + ")";   
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generate_instr(functionInstruction, s, nextquad); 
                tempSet.free_reg(*($3.reg_name));
            }
            else {
                reg_name = *($3.reg_name);
            }
            string s = (*($1.reg_name)) + " = " + reg_name ;
            generate_instr(functionInstruction, s, nextquad);
            $$.reg_name = new string(reg_name);
            if ($1.offset_reg_name != NULL) tempSet.free_reg(*($1.offset_reg_name));
        }
    }
    | LHS PLUSASG ASG
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE;
            errorFound = true;
        }
        else if ($3.type == NULLVOID) {
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
            cout << "Cannot assign void to non-void type " << *($1.reg_name) << endl;
            $$.type = ERRORTYPE;
            errorFound = true;
        }
        else {
            $$.type = $1.type;
            string reg_name;
            if ($1.type == INTEGER && $3.type == FLOATING) {
                reg_name = tempSet.get_temp_reg();
                string s = reg_name + " = convertToInt(" + (*($3.reg_name)) + ")";  
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generate_instr(functionInstruction, s, nextquad);
                tempSet.free_reg(*($3.reg_name));
            }
            else if($1.type == FLOATING && ($3.type == INTEGER || $3.type == BOOLEAN)) {
                reg_name = tempSet.get_float_reg();
                string s = reg_name + " = convertToFloat(" + (*($3.reg_name)) + ")";   
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generate_instr(functionInstruction, s, nextquad); 
                tempSet.free_reg(*($3.reg_name));
            }
            else {
                reg_name = *($3.reg_name);
            }
            string s, tempReg;
            if($1.type == INTEGER){
                tempReg = tempSet.get_temp_reg();
                s = tempReg + " = " + (*($1.reg_name));
                generate_instr(functionInstruction, s, nextquad);
            }
            else{
                tempReg = tempSet.get_float_reg();
                s = tempReg + " = " + (*($1.reg_name));   
                generate_instr(functionInstruction, s, nextquad);
            }
            s = reg_name + " = " + reg_name + " + " + tempReg;
            generate_instr(functionInstruction, s, nextquad);
            tempSet.free_reg(tempReg);
            s = (*($1.reg_name)) + " = " + reg_name ;
            generate_instr(functionInstruction, s, nextquad);
            $$.reg_name = new string(reg_name);
            if ($1.offset_reg_name != NULL) tempSet.free_reg(*($1.offset_reg_name));
        }
    }
    | LHS MINASG ASG
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE;
            errorFound = true;
        }
        else if ($3.type == NULLVOID) {
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
            cout << "Cannot assign void to non-void type " << *($1.reg_name) << endl;
            $$.type = ERRORTYPE;
            errorFound = true;
        }
        else {
            $$.type = $1.type;
            string reg_name;
            if ($1.type == INTEGER && $3.type == FLOATING) {
                reg_name = tempSet.get_temp_reg();
                string s = reg_name + " = convertToInt(" + (*($3.reg_name)) + ")";   
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generate_instr(functionInstruction, s, nextquad);
                tempSet.free_reg(*($3.reg_name));
            }
            else if($1.type == FLOATING && ($3.type == INTEGER || $3.type == BOOLEAN)) {
                reg_name = tempSet.get_float_reg();
                string s = reg_name + " = convertToFloat(" + (*($3.reg_name)) + ")"; 
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generate_instr(functionInstruction, s, nextquad); 
                tempSet.free_reg(*($3.reg_name));
            }
            else {
                reg_name = *($3.reg_name);
            }
            string s, tempReg;
            if($1.type == INTEGER){
                tempReg = tempSet.get_temp_reg();
                s = tempReg + " = " + (*($1.reg_name));
                generate_instr(functionInstruction, s, nextquad);
            }
            else{
                tempReg = tempSet.get_float_reg();
                s = tempReg + " = " + (*($1.reg_name));   
                generate_instr(functionInstruction, s, nextquad);
            }
            s = reg_name + " = " + reg_name + " - " + tempReg;
            generate_instr(functionInstruction, s, nextquad);
            tempSet.free_reg(tempReg);
            s = (*($1.reg_name)) + " = " + reg_name ;
            generate_instr(functionInstruction, s, nextquad);
            $$.reg_name = new string(reg_name);
            if ($1.offset_reg_name != NULL) tempSet.free_reg(*($1.offset_reg_name));
        }
    }
    | LHS MULASG ASG
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE;
            errorFound = true;
        }
        else if ($3.type == NULLVOID) {
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
            cout << "Cannot assign void to non-void type " << *($1.reg_name) << endl;
            $$.type = ERRORTYPE;
            errorFound = true;
        }
        else {
            $$.type = $1.type;
            string reg_name;
            if ($1.type == INTEGER && $3.type == FLOATING) {
                reg_name = tempSet.get_temp_reg();
                string s = reg_name + " = convertToInt(" + (*($3.reg_name)) + ")"; 
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generate_instr(functionInstruction, s, nextquad);
                tempSet.free_reg(*($3.reg_name));
            }
            else if($1.type == FLOATING && ($3.type == INTEGER || $3.type == BOOLEAN)) {
                reg_name = tempSet.get_float_reg();
                string s = reg_name + " = convertToFloat(" + (*($3.reg_name)) + ")";  
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generate_instr(functionInstruction, s, nextquad); 
                tempSet.free_reg(*($3.reg_name));
            }
            else {
                reg_name = *($3.reg_name);
            }
            string s, tempReg;
            if($1.type == INTEGER){
                tempReg = tempSet.get_temp_reg();
                s = tempReg + " = " + (*($1.reg_name));
                generate_instr(functionInstruction, s, nextquad);
            }
            else{
                tempReg = tempSet.get_float_reg();
                s = tempReg + " = " + (*($1.reg_name));   
                generate_instr(functionInstruction, s, nextquad);
            }
            s = reg_name + " = " + reg_name + " * " + tempReg;
            generate_instr(functionInstruction, s, nextquad);
            tempSet.free_reg(tempReg);
            s = (*($1.reg_name)) + " = " + reg_name ;
            generate_instr(functionInstruction, s, nextquad);
            $$.reg_name = new string(reg_name);
            if ($1.offset_reg_name != NULL) tempSet.free_reg(*($1.offset_reg_name));
        }
    }
    | LHS DIVASG ASG
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE;
            errorFound = true;
        }
        else if ($3.type == NULLVOID) {
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
            cout << "Cannot assign void to non-void type " << *($1.reg_name) << endl;
            $$.type = ERRORTYPE;
            errorFound = true;
        }
        else {
            $$.type = $1.type;
            string reg_name;
            if ($1.type == INTEGER && $3.type == FLOATING) {
                reg_name = tempSet.get_temp_reg();
                string s = reg_name + " = convertToInt(" + (*($3.reg_name)) + ")";   
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generate_instr(functionInstruction, s, nextquad);
                tempSet.free_reg(*($3.reg_name));
            }
            else if($1.type == FLOATING && ($3.type == INTEGER || $3.type == BOOLEAN)) {
                reg_name = tempSet.get_float_reg();
                string s = reg_name + " = convertToFloat(" + (*($3.reg_name)) + ")";   
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generate_instr(functionInstruction, s, nextquad); 
                tempSet.free_reg(*($3.reg_name));
            }
            else {
                reg_name = *($3.reg_name);
            }
            string s, tempReg;
            if($1.type == INTEGER){
                tempReg = tempSet.get_temp_reg();
                s = tempReg + " = " + (*($1.reg_name));
                generate_instr(functionInstruction, s, nextquad);
            }
            else{
                tempReg = tempSet.get_float_reg();
                s = tempReg + " = " + (*($1.reg_name));   
                generate_instr(functionInstruction, s, nextquad);
            }
            s = reg_name + " = " + reg_name + " / " + tempReg;
            generate_instr(functionInstruction, s, nextquad);
            tempSet.free_reg(tempReg);
            s = (*($1.reg_name)) + " = " + reg_name ;
            generate_instr(functionInstruction, s, nextquad);
            $$.reg_name = new string(reg_name);
            if ($1.offset_reg_name != NULL) tempSet.free_reg(*($1.offset_reg_name));
        }
    }
    | LHS MODASG ASG
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE;
            errorFound = true;
        }
        else if ($3.type == NULLVOID) {
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
            cout << "Cannot assign void to non-void type " << *($1.reg_name) << endl;
            $$.type = ERRORTYPE;
            errorFound = true;
        }
        else {
            $$.type = $1.type;
            string reg_name;
            if ($1.type == INTEGER && $3.type == FLOATING) {
                reg_name = tempSet.get_temp_reg();
                string s = reg_name + " = convertToInt(" + (*($3.reg_name)) + ")";   
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generate_instr(functionInstruction, s, nextquad);
                tempSet.free_reg(*($3.reg_name));
            }
            else if($1.type == FLOATING && ($3.type == INTEGER || $3.type == BOOLEAN)) {
                reg_name = tempSet.get_float_reg();
                string s = reg_name + " = convertToFloat(" + (*($3.reg_name)) + ")";   
                cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                generate_instr(functionInstruction, s, nextquad); 
                tempSet.free_reg(*($3.reg_name));
            }
            else {
                reg_name = *($3.reg_name);
            }
            string s, tempReg;
            if($1.type == INTEGER){
                tempReg = tempSet.get_temp_reg();
                s = tempReg + " = " + (*($1.reg_name));
                generate_instr(functionInstruction, s, nextquad);
            }
            else{
                tempReg = tempSet.get_float_reg();
                s = tempReg + " = " + (*($1.reg_name));   
                generate_instr(functionInstruction, s, nextquad);
            }
            s = reg_name + " = " + reg_name + " % " + tempReg;
            generate_instr(functionInstruction, s, nextquad);
            tempSet.free_reg(tempReg);
            s = (*($1.reg_name)) + " = " + reg_name ;
            generate_instr(functionInstruction, s, nextquad);
            $$.reg_name = new string(reg_name);
            if ($1.offset_reg_name != NULL) tempSet.free_reg(*($1.offset_reg_name));
        }
    }
;

LHS: ID_ARR  
    {
        $$.type = $1.type;
        if ($$.type != ERRORTYPE) {
            $$.reg_name = $1.reg_name;
            $$.offset_reg_name = $1.offset_reg_name;
        } 
    } 
;

SWITCHCASE: SWITCH LP ASG RP TEMP1 LCB  CASELIST RCB 
    {
        clear_var_list(current_function,scope);
        scope--;

        int q=nextquad;
        vector<int>* qList = new vector<int>;
        qList->push_back(q);
        generate_instr(functionInstruction, "goto L", nextquad);
        backpatch($5.false_list, nextquad, functionInstruction);
        generate_instr(functionInstruction, "L" + to_string(nextquad) + ":", nextquad);
        reverse($7.case_pair->begin(), $7.case_pair->end());
        for(auto it : *($7.case_pair)){
            if(it.first == "default"){
                generate_instr(functionInstruction, "goto L"+to_string(it.second), nextquad);
            }
            else{
                generate_instr(functionInstruction, "if "+ (*($3.reg_name)) +" == "+ it.first + " goto L" + to_string(it.second), nextquad);
            }
        }
        $7.case_pair->clear();
        backpatch(qList, nextquad, functionInstruction);
        backpatch($7.break_list, nextquad, functionInstruction);
        generate_instr(functionInstruction, "L" + to_string(nextquad) + ":", nextquad);
    }
;

TEMP1: %empty
    {
        $$.begin=nextquad;
        $$.false_list = new vector<int>;
        $$.false_list->push_back(nextquad);
        generate_instr(functionInstruction, "goto L", nextquad);
        scope++;
    }
;

TEMP2:%empty
    {
        $$.case_pair = new vector<pair<string,int>>;

    }
;

CASELIST:
    CASE MINUS NUMINT TEMP2 {
        $4.case_pair->push_back(make_pair("-"+string($3), nextquad));
        generate_instr(functionInstruction, "L" + to_string(nextquad) + ":", nextquad);
        } COLON BODY 
    CASELIST
    {
        $$.next_list = new vector<int>;
        $$.break_list = new vector<int>;
        $$.continue_list = new vector <int>;
        $$.case_pair = new vector<pair<string,int>>;
        merge_lists($$.continue_list,$8.continue_list);
        merge_lists($$.break_list, $8.break_list);
        merge_lists($$.next_list, $8.next_list);
        merge_lists($$.continue_list,$7.continue_list);
        merge_lists($$.break_list, $7.break_list);
        merge_lists($$.next_list, $7.next_list);
        merge_lists_switch($$.case_pair, $8.case_pair);
        merge_lists_switch($$.case_pair, $4.case_pair);
    }
    |
    CASE NUMINT TEMP2 {
        $3.case_pair->push_back(make_pair(string($2), nextquad));
        generate_instr(functionInstruction, "L" + to_string(nextquad) + ":", nextquad);
        } COLON BODY 
    CASELIST
    {
        $$.next_list = new vector<int>;
        $$.break_list = new vector<int>;
        $$.continue_list = new vector <int>;
        $$.case_pair = new vector<pair<string,int>>;
        merge_lists($$.continue_list,$6.continue_list);
        merge_lists($$.break_list, $6.break_list);
        merge_lists($$.next_list, $6.next_list);
        merge_lists($$.continue_list,$7.continue_list);
        merge_lists($$.break_list, $7.break_list);
        merge_lists($$.next_list, $7.next_list);
        merge_lists_switch($$.case_pair, $7.case_pair);
        merge_lists_switch($$.case_pair, $3.case_pair);
    }
    | %empty
    {
        $$.next_list = new vector<int>;
        $$.break_list = new vector<int>;
        $$.continue_list = new vector <int>;
        $$.case_pair = new vector<pair<string,int>>;
    }
    | DEFAULT COLON TEMP2 {
        $3.case_pair->push_back(make_pair("default", nextquad));
        generate_instr(functionInstruction, "L" + to_string(nextquad) + ":", nextquad);
    }
     BODY {
        $$.next_list = new vector<int>;
        $$.break_list = new vector<int>;
        $$.case_pair = new vector<pair<string,int>>;
        $$.continue_list = new vector <int>;
        merge_lists($$.continue_list,$5.continue_list);
        merge_lists($$.break_list, $5.break_list);
        merge_lists($$.next_list, $5.next_list);
        merge_lists_switch($$.case_pair, $3.case_pair);
    }
;

M3: %empty
    { 
        $$ = nextquad;
        generate_instr(functionInstruction, "L" + to_string(nextquad) + ":", nextquad); 
    }
;

N3: %empty
    { 
        $$.begin = nextquad; 
        $$.false_list = new vector<int>;
        $$.false_list->push_back(nextquad);
        generate_instr(functionInstruction, "goto L", nextquad);
    }
;

P3: %empty 
    { 
        $$.false_list = new vector<int>;
        $$.false_list->push_back(nextquad);
        generate_instr(functionInstruction, "goto L", nextquad);
        $$.begin = nextquad; 
        generate_instr(functionInstruction, "L"+to_string(nextquad)+":", nextquad);
    }
;

Q3: %empty
    {
        $$.begin = nextquad;
        $$.false_list = new vector<int>;
        $$.false_list->push_back(nextquad);
    }
;

Q4: %empty
    {
        $$ = nextquad;
    }
;

FORLOOP: FOREXP Q4 LCB BODY RCB
    {
        clear_var_list(current_function, scope);
        scope--;
        generate_instr(functionInstruction, "goto L" + to_string($1.begin), nextquad); 
        merge_lists($1.false_list,$4.break_list);
        backpatch($4.continue_list,$1.begin, functionInstruction);
        backpatch($1.false_list, nextquad, functionInstruction);
        generate_instr(functionInstruction, "L" + to_string(nextquad) + ":", nextquad); 
    }
;

FOREXP: FOR LP ASG1 SEMI M3 ASG1 Q3 {
        if($6.type!=NULLVOID){
            generate_instr(functionInstruction, "if "+ (*($6.reg_name)) + " == 0 goto L", nextquad);
        }
    } P3 SEMI ASG1 N3 RP 
    {
        backpatch($12.false_list,$5,functionInstruction);
        backpatch($9.false_list,nextquad,functionInstruction);
        generate_instr(functionInstruction, "L" + to_string(nextquad) + ":", nextquad); 
        $$.false_list = new vector<int>;
        if($6.type!=NULLVOID){
            $$.false_list->push_back($7.begin);            
        }
        $$.begin = $9.begin;
        scope++;
        if($3.type!=NULLVOID){
            tempSet.free_reg(*($3.reg_name));
        }
        if($6.type!=NULLVOID){
            tempSet.free_reg(*($6.reg_name));
        }
        if($11.type!=NULLVOID){
            tempSet.free_reg(*($11.reg_name));
        }
    }
    | FOR error RP
    {
        errorFound = 1;
        $$.false_list = new vector<int>;
        cout << BOLD(FRED("ERROR : ")) << FYEL("Line no. " + to_string(yylineno) + ": Syntax error in for loop, discarded token till RP") << endl;
        scope++;
    }
;

ASG1: ASG
    {
        $$.type= $1.type;
        if ($1.type != ERRORTYPE && $1.type != NULLVOID) {
            $$.reg_name = $1.reg_name;
        }
    }
    | %empty {
        $$.type = NULLVOID;
    }
;

M1: %empty
    {
        $$=nextquad;
        generate_instr(functionInstruction, "L" + to_string(nextquad) + ":", nextquad);
    }
;

M2: %empty
    {
        $$.next_list = new vector<int>;
        ($$.next_list)->push_back(nextquad);
        generate_instr(functionInstruction, "goto L", nextquad);
    }
;

IFSTMT: IFEXP LCB BODY RCB 
    {
        clear_var_list(current_function,scope);
        scope--;
        $$.next_list= new vector<int>;
        $$.break_list = new vector<int>;
        $$.continue_list= new vector<int>;
        merge_lists($$.next_list, $1.false_list);
        merge_lists($$.break_list, $3.break_list);
        merge_lists($$.continue_list, $3.continue_list);
        backpatch($$.next_list,nextquad,functionInstruction);
        generate_instr(functionInstruction, "L" + to_string(nextquad) + ":", nextquad);
    }
    | IFEXP LCB BODY RCB {clear_var_list(current_function,scope);} M2 ELSE M1 LCB BODY RCB
    {
        clear_var_list(current_function,scope);
        scope--;
        $$.next_list= new vector<int>;
        $$.break_list = new vector<int>;
        $$.continue_list= new vector<int>;
        backpatch($1.false_list,$8,functionInstruction);
        merge_lists($$.next_list,$6.next_list );
        backpatch($$.next_list,nextquad,functionInstruction);
        generate_instr(functionInstruction, "L" + to_string(nextquad) + ":", nextquad);
        merge_lists($$.break_list, $3.break_list);
        merge_lists($$.continue_list, $3.continue_list);
        merge_lists($$.break_list, $10.break_list);
        merge_lists($$.continue_list, $10.continue_list);
    }
;

IFEXP: IF LP ASG RP 
    {
        if($3.type != ERRORTYPE && $3.type!=NULLVOID){
            $$.false_list = new vector <int>;
            $$.false_list->push_back(nextquad);
            if($3.type == NULLVOID){
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << "condition in if statement can't be empty" << endl;
                errorFound=true;
            }
            generate_instr(functionInstruction, "if "+ (*($3.reg_name)) + " == 0 goto L", nextquad);
            scope++;
            tempSet.free_reg(*($3.reg_name));
        } 
    }
    | IF error RP
    {
        errorFound = 1;
        $$.false_list = new vector <int>;
        cout << BOLD(FRED("ERROR : ")) << FYEL("Line no. " + to_string(yylineno) + ": Syntax error in if, discarding tokens till RP") << endl;
        scope++;
    }
;

WHILESTMT:  WHILEEXP LCB BODY RCB 
    {
        clear_var_list(current_function,scope);
        scope--;

        generate_instr(functionInstruction, "goto L" + to_string($1.begin), nextquad);
        backpatch($3.next_list, $1.begin, functionInstruction);
        backpatch($3.continue_list, $1.begin, functionInstruction);
        $$.next_list = new vector<int>;
        merge_lists($$.next_list, $1.false_list);
        merge_lists($$.next_list, $3.break_list);
        backpatch($$.next_list,nextquad,functionInstruction);
        generate_instr(functionInstruction, "L" + to_string(nextquad) + ":", nextquad);
    }
;

WHILEEXP: WHILE M1 LP ASG RP
    {
        scope++;
        if($4.type == NULLVOID || $4.type == ERRORTYPE){
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
            cout<<"Expression in if statement can't be empty"<<endl;
            errorFound = true;
        }
        else{
            $$.false_list = new vector<int>;
            ($$.false_list)->push_back(nextquad);
            generate_instr(functionInstruction, "if " + *($4.reg_name) + "== 0 goto L", nextquad);
            $$.begin = $2; 
        }
    }
    | WHILE error RP
    {   
        $$.false_list = new vector<int>;
        cout << BOLD(FRED("ERROR : ")) << FYEL("Line no. " + to_string(yylineno) + ": Syntax error in while loop, discarding tokens till RP") << endl;
        scope++;
    }
;

TP1: %empty
{
    $$.temp = new vector<int>;
}
;

CONDITION1: CONDITION1 TP1
    {
        if($1.type!=ERRORTYPE){
            $2.temp->push_back(nextquad);
            generate_instr(functionInstruction, "if " + *($1.reg_name) + "!= 0 goto L", nextquad);

        }
    }
     OR CONDITION2
    {
        if($1.type==ERRORTYPE || $5.type==ERRORTYPE){
            $$.type = ERRORTYPE;
        }
        else if($1.type == NULLVOID || $5.type == NULLVOID){
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. "<< yylineno << ": Both the expessions should not be NULL" << endl;
        }
        else{
            $$.type = BOOLEAN;
            $$.reg_name = new string(tempSet.get_temp_reg());
            vector<int>* qList = new vector<int>;
            if($5.jump_list!=NULL){
                qList->push_back(nextquad);
                generate_instr(functionInstruction,"goto L",nextquad);
                backpatch($5.jump_list, nextquad, functionInstruction);
                generate_instr(functionInstruction, "L" + to_string(nextquad) + ":", nextquad);
                generate_instr(functionInstruction,(*($5.reg_name)) + " = 0",nextquad) ;
                backpatch(qList,nextquad,functionInstruction);
                generate_instr(functionInstruction, "L" + to_string(nextquad) + ":", nextquad);
                qList->clear();
            }
            
            $$.jump_list = new vector<int>;
            merge_lists($$.jump_list,$1.jump_list);
            
            merge_lists($$.jump_list, $2.temp);
            ($$.jump_list)->push_back(nextquad);
            generate_instr(functionInstruction, "if " + *($5.reg_name) + "!= 0 goto L", nextquad);
            string s = (*($$.reg_name)) + " = 0";   
            generate_instr(functionInstruction,s,nextquad);
            tempSet.free_reg(*($1.reg_name));
            tempSet.free_reg(*($5.reg_name)); 
        }
    }
    | CONDITION2
    {
        $$.type = $1.type;
        if ($$.type != ERRORTYPE && $$.type != NULLVOID) {
            $$.reg_name = $1.reg_name; 
            if($1.jump_list!=NULL){
                vector<int>* qList = new vector<int>;
                qList->push_back(nextquad);
                generate_instr(functionInstruction,"goto L",nextquad);
                backpatch($1.jump_list, nextquad, functionInstruction);
                generate_instr(functionInstruction, "L" + to_string(nextquad) + ":", nextquad);
                generate_instr(functionInstruction,(*($$.reg_name)) + " = 0",nextquad) ;
                backpatch(qList,nextquad,functionInstruction);
                generate_instr(functionInstruction, "L" + to_string(nextquad) + ":", nextquad);
                qList->clear();   
            }
        }
    }
;  


CONDITION2: CONDITION2 TP1
    {
      if ($1.type!=ERRORTYPE ){

          ($2.temp)->push_back(nextquad);
         generate_instr(functionInstruction, "if " + *($1.reg_name) + " == 0 " +" goto L", nextquad);
      } 
    }
    AND EXPR1 
    {
        if ($1.type==ERRORTYPE || $5.type==ERRORTYPE) {
            $$.type = ERRORTYPE;
        }
        else if($1.type == NULLVOID || $5.type == NULLVOID){
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. "<< yylineno << ": Both the expessions should not be NULL" << endl;
        }
        else{
            $$.type = BOOLEAN;
            $$.reg_name = new string(tempSet.get_temp_reg());
            $$.jump_list = new vector<int>;
            merge_lists($$.jump_list,$1.jump_list);
            vector<int>* qList = new vector<int>;
            
            merge_lists($$.jump_list, $2.temp);
            ($$.jump_list)->push_back(nextquad);
            generate_instr(functionInstruction, "if " + *($5.reg_name) + " == 0 "+" goto L", nextquad);

            string s = (*($$.reg_name)) + " = 1";   
            generate_instr(functionInstruction,s,nextquad);
            tempSet.free_reg(*($1.reg_name));
            tempSet.free_reg(*($5.reg_name));   
        }
    }
    | EXPR1
    {
        $$.type = $1.type;
        if ($1.type != ERRORTYPE && $1.type != NULLVOID) {
            $$.reg_name = $1.reg_name; 
            $$.jump_list = new vector<int>;
            $$.jump_list=NULL;   
        }
    }
;

EXPR1: NOT EXPR21
    {
        $$.type = $2.type;
        if ($2.type != ERRORTYPE && $2.type != NULLVOID) {
            $$.reg_name = $2.reg_name;
            string s = (*($$.reg_name)) + " = ~" + (*($2.reg_name));   
            generate_instr(functionInstruction, s, nextquad);
        }
    }
    | EXPR21
    {
        $$.type = $1.type;
        if ($1.type != ERRORTYPE && $1.type != NULLVOID) {
            $$.reg_name = $1.reg_name;    
        }
    }
;

EXPR21: EXPR2 EQUAL EXPR2
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE;
        }
        else if($1.type == NULLVOID || $3.type == NULLVOID){
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. "<< yylineno << ":Both the expessions should not be  NULL" << endl;
        }
        else {
            $$.type = BOOLEAN;
            $$.reg_name = new string(tempSet.get_temp_reg());     
            string s = (*($$.reg_name)) + " = " + (*($1.reg_name)) + " == " + (*($3.reg_name))   ;
            generate_instr(functionInstruction, s, nextquad);
            tempSet.free_reg(*($1.reg_name));
            tempSet.free_reg(*($3.reg_name));  
        }   
    }
    | EXPR2 NOTEQUAL EXPR2
    {
        if($1.type == ERRORTYPE || $3.type == ERRORTYPE){
            $$.type = ERRORTYPE;
        }
        else if($1.type == NULLVOID || $3.type == NULLVOID){
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. "<< yylineno << ":Both the expessions should not be  NULL" << endl;
        }
        else{
            $$.type = BOOLEAN;
            $$.reg_name = new string(tempSet.get_temp_reg());     
            string s = (*($$.reg_name)) + " = " + (*($1.reg_name)) + " != " + (*($3.reg_name));   
            generate_instr(functionInstruction, s, nextquad);
            tempSet.free_reg(*($1.reg_name));
            tempSet.free_reg(*($3.reg_name));  
        }   
    }
    | EXPR2 LT EXPR2 
    {
        if($1.type == ERRORTYPE || $3.type == ERRORTYPE){
            $$.type = ERRORTYPE;
        }
        else if($1.type == NULLVOID || $3.type == NULLVOID){
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. "<< yylineno << ":Both the expessions should not be  NULL" << endl;
        }
        else{
            $$.type = BOOLEAN;
            $$.reg_name = new string(tempSet.get_temp_reg());     
            string s = (*($$.reg_name)) + " = " + (*($1.reg_name)) + " < " + (*($3.reg_name));   
            generate_instr(functionInstruction, s, nextquad);
            tempSet.free_reg(*($1.reg_name));
            tempSet.free_reg(*($3.reg_name));  
        }   
    }
    | EXPR2 GT EXPR2
    {
        if($1.type == ERRORTYPE || $3.type == ERRORTYPE){
            $$.type = ERRORTYPE;
        }
        else if($1.type == NULLVOID || $3.type == NULLVOID){
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. "<< yylineno << ":Both the expessions should not be  NULL" << endl;
        }
        else{
            $$.type = BOOLEAN;
            $$.reg_name = new string(tempSet.get_temp_reg());     
            string s = (*($$.reg_name)) + " = " + (*($1.reg_name)) + " > " + (*($3.reg_name));   
            generate_instr(functionInstruction, s, nextquad);
            tempSet.free_reg(*($1.reg_name));
            tempSet.free_reg(*($3.reg_name));  
        }   
    }
    | EXPR2 LE EXPR2
    {
        if($1.type == ERRORTYPE || $3.type == ERRORTYPE){
            $$.type = ERRORTYPE;
            errorFound = true;
        }
        else if($1.type == NULLVOID || $3.type == NULLVOID){
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. "<< yylineno << ":Both the expessions should not be  NULL" << endl;
        }
        else{
            $$.type = BOOLEAN;
            $$.reg_name = new string(tempSet.get_temp_reg());     
            string s = (*($$.reg_name)) + " = " + (*($1.reg_name)) + " <= " + (*($3.reg_name));   
            generate_instr(functionInstruction, s, nextquad);
            tempSet.free_reg(*($1.reg_name));
            tempSet.free_reg(*($3.reg_name));  
        }   
    }
    | EXPR2 GE EXPR2
    {
        if($1.type == ERRORTYPE || $3.type == ERRORTYPE){
            $$.type = ERRORTYPE;
        }
        else if($1.type == NULLVOID || $3.type == NULLVOID){
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. "<< yylineno << ":Both the expessions should not be  NULL" << endl;
        }
        else{
            $$.type = BOOLEAN;
            $$.reg_name = new string(tempSet.get_temp_reg());     
            string s = (*($$.reg_name)) + " = " + (*($1.reg_name)) + " >= " + (*($3.reg_name));  
            generate_instr(functionInstruction, s, nextquad);
            tempSet.free_reg(*($1.reg_name));
            tempSet.free_reg(*($3.reg_name));  
        }   
    } 
    | EXPR2 
    {
        $$.type = $1.type; 
        if($$.type == ERRORTYPE){
            errorFound = true;
        }
        else{
            if($1.type != NULLVOID){
                $$.reg_name = new string(*($1.reg_name)); 
                delete $1.reg_name; 
            }
        }    
    }
;

EXPR2:  EXPR2 PLUS TERM
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE; 
            errorFound = true; 
        }
        else {
            if (check_type_mismatch($1.type, $3.type)) {
                $$.type = type_match($1.type,$3.type);

                if ($1.type == INTEGER && $3.type == FLOATING) {
                    string newReg = tempSet.get_float_reg();
                    string s = newReg + " = " + "convertToFloat(" + (*($1.reg_name)) + ")";
                    cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                    tempSet.free_reg(*($1.reg_name));
                    $1.reg_name = &newReg;
                    generate_instr(functionInstruction, s, nextquad);
                }
                else if ($1.type == FLOATING && $3.type == INTEGER) {
                    string newReg = tempSet.get_float_reg();
                    string s = newReg + " = " + "convertToFloat(" + (*($3.reg_name)) + ")";
                    cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                    tempSet.free_reg(*($3.reg_name));
                    $3.reg_name = &newReg;
                    generate_instr(functionInstruction, s, nextquad);
                }

                if ($$.type == INTEGER) 
                    $$.reg_name = new string(tempSet.get_temp_reg());
                else
                    $$.reg_name = new string(tempSet.get_float_reg());
                    
                string s = (*($$.reg_name)) + " = " + (*($1.reg_name)) + " + " + (*($3.reg_name));;   
                generate_instr(functionInstruction, s, nextquad);
                tempSet.free_reg(*($1.reg_name));
                tempSet.free_reg(*($3.reg_name));   
            }
            else {
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
                cout << "Type mismatch in expression" << endl;
                $$.type = ERRORTYPE;
            }
        }
    }
    | EXPR2 MINUS TERM
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE;
            errorFound = true;  
        }
        else {
            if (check_type_mismatch($1.type, $3.type)) {
                $$.type = type_match($1.type,$3.type);

                if ($1.type == INTEGER && $3.type == FLOATING) {
                    string newReg = tempSet.get_float_reg();
                    string s = newReg + " = " + "convertToFloat(" + (*($1.reg_name)) + ")";
                    cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                    tempSet.free_reg(*($1.reg_name));
                    $1.reg_name = &newReg;
                    generate_instr(functionInstruction, s, nextquad);
                }
                else if ($1.type == FLOATING && $3.type == INTEGER) {
                    string newReg = tempSet.get_float_reg();
                    string s = newReg + " = " + "convertToFloat(" + (*($3.reg_name)) + ")";
                    cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                    tempSet.free_reg(*($3.reg_name));
                    $3.reg_name = &newReg;
                    generate_instr(functionInstruction, s, nextquad);
                }

                if ($$.type == INTEGER) 
                    $$.reg_name = new string(tempSet.get_temp_reg());
                else
                    $$.reg_name = new string(tempSet.get_float_reg());
                    
                string s = (*($$.reg_name)) + " = " + (*($1.reg_name)) + " - " + (*($3.reg_name));;   
                generate_instr(functionInstruction, s, nextquad);
                tempSet.free_reg(*($1.reg_name));
                tempSet.free_reg(*($3.reg_name));   
            }
            else {
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
                cout << "Type mismatch in expression" << endl;
                $$.type = ERRORTYPE;
            }
        }
    }
    | TERM 
    { 
        $$.type = $1.type; 
        if ($1.type == ERRORTYPE) {
            errorFound = true;
        }
        else {
            if($1.type!= NULLVOID){
                $$.reg_name = new string(*($1.reg_name)); 
                delete $1.reg_name;
            }         
        } 
    }
;

TERM: TERM MUL FACTOR
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE;  
        }
        else {
            if (check_type_mismatch($1.type, $3.type)) {
                $$.type = type_match($1.type,$3.type);

                if ($1.type == INTEGER && $3.type == FLOATING) {
                    string newReg = tempSet.get_float_reg();
                    string s = newReg + " = " + "convertToFloat(" + (*($1.reg_name)) + ")";
                    cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                    tempSet.free_reg(*($1.reg_name));
                    $1.reg_name = &newReg;
                    generate_instr(functionInstruction, s, nextquad);
                }
                else if ($1.type == FLOATING && $3.type == INTEGER) {
                    string newReg = tempSet.get_float_reg();
                    string s = newReg + " = " + "convertToFloat(" + (*($3.reg_name)) + ")";
                    cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                    tempSet.free_reg(*($3.reg_name));
                    $3.reg_name = &newReg;
                    generate_instr(functionInstruction, s, nextquad);
                }

                if ($$.type == INTEGER) 
                    $$.reg_name = new string(tempSet.get_temp_reg());
                else
                    $$.reg_name = new string(tempSet.get_float_reg());
                    
                string s = (*($$.reg_name)) + " = " + (*($1.reg_name)) + " * " + (*($3.reg_name));;   
                generate_instr(functionInstruction, s, nextquad);
                tempSet.free_reg(*($1.reg_name));
                tempSet.free_reg(*($3.reg_name));   
            }
            else {
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
                cout << "Type mismatch in expression" << endl;
                $$.type = ERRORTYPE;
            }
        }
    }
    | TERM DIV FACTOR  
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
        $$.type = ERRORTYPE;  
        }
        else {
            if (check_type_mismatch($1.type, $3.type)) {
                $$.type = type_match($1.type,$3.type);

                if ($1.type == INTEGER && $3.type == FLOATING) {
                    string newReg = tempSet.get_float_reg();
                    string s = newReg + " = " + "convertToFloat(" + (*($1.reg_name)) + ")";
                    cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                    tempSet.free_reg(*($1.reg_name));
                    $1.reg_name = &newReg;
                    generate_instr(functionInstruction, s, nextquad);
                }
                else if ($1.type == FLOATING && $3.type == INTEGER) {
                    string newReg = tempSet.get_float_reg();
                    string s = newReg + " = " + "convertToFloat(" + (*($3.reg_name)) + ")";
                    cout << BOLD(FBLU("Warning : ")) << FCYN("Line No. "+to_string(yylineno)+":Implicit Type Conversion") << endl;
                    tempSet.free_reg(*($3.reg_name));
                    $3.reg_name = &newReg;
                    generate_instr(functionInstruction, s, nextquad);
                }

                if ($$.type == INTEGER) 
                    $$.reg_name = new string(tempSet.get_temp_reg());
                else
                    $$.reg_name = new string(tempSet.get_float_reg());
                    
                string s = (*($$.reg_name)) + " = " + (*($1.reg_name)) + " / " + (*($3.reg_name));   
                generate_instr(functionInstruction, s, nextquad);
                tempSet.free_reg(*($1.reg_name));
                tempSet.free_reg(*($3.reg_name));   
            }
            else {
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
                cout << "Type mismatch in expression" << endl;
                $$.type = ERRORTYPE;
            }
        }   
    }  
    | TERM MOD FACTOR
    {
        if ($1.type == ERRORTYPE || $3.type == ERRORTYPE) {
            $$.type = ERRORTYPE;  
        }
        else {
            if ($1.type == INTEGER && $3.type == INTEGER) {
                $$.type = INTEGER;
                $$.reg_name = new string(tempSet.get_temp_reg());  
                string s = (*($$.reg_name)) + " = " + (*($1.reg_name)) + " % " + (*($3.reg_name));;   
                generate_instr(functionInstruction, s, nextquad);
                tempSet.free_reg(*($1.reg_name));
                tempSet.free_reg(*($3.reg_name));   
            }
            else {
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
                cout << "Type mismatch in expression" << endl;
                $$.type = ERRORTYPE;
            }
        }   
    }
    | FACTOR 
    { 
        $$.type = $1.type; 
        if ($1.type == ERRORTYPE) {
            errorFound = true;
        }
        else {
            if($1.type != NULLVOID){
                $$.reg_name = new string(*($1.reg_name)); 
                delete $1.reg_name;
            }  
        } 
    }
;

FACTOR: ID_ARR  
    { 
        $$.type = $1.type;
        if ($$.type != ERRORTYPE) {
            if ($$.type == INTEGER)
                $$.reg_name = new string(tempSet.get_temp_reg());
            else $$.reg_name = new string(tempSet.get_float_reg());
            string s = (*($$.reg_name)) + " = " + (*($1.reg_name)) ;
            generate_instr(functionInstruction, s, nextquad);
            if($1.offset_reg_name != NULL){
                tempSet.free_reg((*($1.offset_reg_name)));
            }
        }
    }
    | MINUS ID_ARR
    {
        $$.type = $2.type;
        if($2.type != ERRORTYPE){
            string s="";
            if ($$.type == INTEGER){
                $$.reg_name = new string(tempSet.get_temp_reg());
                string temp=tempSet.get_temp_reg();
                string temp1=tempSet.get_temp_reg();
                generate_instr(functionInstruction, temp + " = 0", nextquad);
                generate_instr(functionInstruction, temp1 + " = " +  (*($2.reg_name)), nextquad);
                s = (*($$.reg_name)) + " = " + temp + " -" + temp1 ;
                tempSet.free_reg(temp);
                tempSet.free_reg(temp1);
            }
            else{ 
                $$.reg_name = new string(tempSet.get_float_reg());
                string temp=tempSet.get_float_reg();
                string temp1=tempSet.get_temp_reg();
                generate_instr(functionInstruction, temp + " = 0", nextquad);
                generate_instr(functionInstruction, temp1 + " = " +  (*($2.reg_name)), nextquad);
                s = (*($$.reg_name)) + " = 0 -" + temp1 ;
                tempSet.free_reg(temp);
                tempSet.free_reg(temp1);
            }
            // string s = (*($$.reg_name)) + " = 0 -" + (*($2.reg_name)) ;
            generate_instr(functionInstruction, s, nextquad);
            if($2.offset_reg_name != NULL){
                tempSet.free_reg((*($2.offset_reg_name)));
            }
        }       
    }
    | MINUS NUMINT
    {
        $$.type = INTEGER; 
        $$.reg_name = new string(tempSet.get_temp_reg());
        string s = (*($$.reg_name)) + " = -" + string($2) ;
        generate_instr(functionInstruction, s, nextquad);  
        
    }
    | NUMINT    
    { 
        $$.type = INTEGER; 
        $$.reg_name = new string(tempSet.get_temp_reg());
        string s = (*($$.reg_name)) + " = " + string($1) ;
        generate_instr(functionInstruction, s, nextquad);  
    }
    | MINUS NUMFLOAT
    {
        $$.type = FLOATING;
        $$.reg_name = new string(tempSet.get_float_reg());
        string s = (*($$.reg_name)) + " = " + string($2) ;
        generate_instr(functionInstruction, s, nextquad);  
    }
    | NUMFLOAT  
    { 
        $$.type = FLOATING;
        $$.reg_name = new string(tempSet.get_float_reg());
        string s = (*($$.reg_name)) + " = " + string($1) ;
        generate_instr(functionInstruction, s, nextquad);  
    }
    | FUNC_CALL 
    { 
        $$.type = $1.type; 
        if ($1.type == ERRORTYPE) {
            if ($1.type == NULLVOID){
                delete func_call_ptr;
            }
            else {
                $$.reg_name = $1.reg_name;
                delete func_call_ptr;
            }
        }; 
    }
    | LP ASG RP 
    { 
        $$.type = $2.type; 
        if ($2.type != ERRORTYPE) {
            $$.reg_name = $2.reg_name;
        }
    }
    | ID_ARR INCREMENT
    {
        if ($1.type == INTEGER) {
            $$.type = INTEGER;   
            string newReg = tempSet.get_temp_reg();
            $$.reg_name = new string(newReg); 
            string s = newReg + " = " + (*($1.reg_name)) ;
            generate_instr(functionInstruction, s, nextquad); // T2 = i
            string newReg2 = tempSet.get_temp_reg();
            s = newReg2 + " = " + newReg + " + 1"; // T3 = T2+1
            generate_instr(functionInstruction, s, nextquad);
            s = (*($1.reg_name)) + " = " + newReg2; // i = T3
            generate_instr(functionInstruction, s, nextquad);
            tempSet.free_reg(newReg2);
            if($1.offset_reg_name != NULL){
                tempSet.free_reg((*($1.offset_reg_name)));
            }
        }
        else {
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
            cout << "Cannot increment non-integer type variable "<< *($1.reg_name) << endl; 
        }
    } 
    | ID_ARR DECREMENT
    {
        if ($1.type == INTEGER) {
            $$.type = INTEGER;   
            string newReg = tempSet.get_temp_reg();
            $$.reg_name = new string(newReg);
            string s = newReg + " = " + (*($1.reg_name)); // T0 = i
            generate_instr(functionInstruction, s, nextquad);
            string newReg2 = tempSet.get_temp_reg();
            s = newReg2 + " = " + newReg + " - 1"; // T3 = T2+1
            generate_instr(functionInstruction, s, nextquad);
            s = (*($1.reg_name)) + " = " + newReg2; // i = T3
            generate_instr(functionInstruction, s, nextquad);
            tempSet.free_reg(newReg2); 
            if($1.offset_reg_name != NULL){
                tempSet.free_reg((*($1.offset_reg_name)));
            }    
        }
        else {
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
            cout << "Cannot increment non-integer type variable " << *($1.reg_name) << endl; 
        }
    } 
    | INCREMENT ID_ARR
    {
        if ($2.type == INTEGER) {
            $$.type = INTEGER;   
            string newReg = tempSet.get_temp_reg();
            string s = newReg + " = " + (*($2.reg_name)); // T2 = i
            generate_instr(functionInstruction, s, nextquad);
            string newReg2 = tempSet.get_temp_reg();
            $$.reg_name = new string(newReg2);
            s = newReg2 + " = " + newReg + " + 1"; // T3 = T2+1
            generate_instr(functionInstruction, s, nextquad);
            s = (*($2.reg_name)) + " = " + newReg2; // i = T3
            generate_instr(functionInstruction, s, nextquad);
            tempSet.free_reg(newReg); 
            if($2.offset_reg_name != NULL){
                tempSet.free_reg((*($2.offset_reg_name)));
            }     
        }
        else {
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
            cout << "Cannot increment non-integer type variable "<<*($2.reg_name) << endl; 
        }
    } 
    | DECREMENT ID_ARR
    {
        if ($2.type == INTEGER) {
            $$.type = INTEGER;   
            string newReg = tempSet.get_temp_reg();
            string s = newReg + " = " + (*($2.reg_name)); // T2 = i
            generate_instr(functionInstruction, s, nextquad);
            string newReg2 = tempSet.get_temp_reg();
            $$.reg_name = new string(newReg2);
            s = newReg2 + " = " + newReg + " - 1"; // T3 = T2+1
            generate_instr(functionInstruction, s, nextquad);
            s = (*($2.reg_name)) + " = " + newReg2; // i = T3
            generate_instr(functionInstruction, s, nextquad);
            tempSet.free_reg(newReg);
            if($2.offset_reg_name != NULL){
                tempSet.free_reg((*($2.offset_reg_name)));
            }         
        }
        else {
            $$.type = ERRORTYPE;
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
            cout << "Cannot increment non-integer type variable " << *($2.reg_name) << endl; 
        }
    }
;

ID_ARR: ID
    {   
        // retrieve the highest level id with same name in param list or var list or global list
        int found = 0;
        sym_tab_entry* rec = NULL;
        look_up_call_name(string($1), current_function, found, rec, global_vars); 
        $$.offset_reg_name = NULL;
        if(found){
            if (rec->type == SIMPLE) {
                $$.type = rec->data_type_obj;
                string dataType = get_string_from_data_type($$.type);
                dataType += "_" + to_string(rec->scope);
                $$.reg_name = new string("_" + string($1) + "_" + dataType);
            }
            else {
                $$.type = ERRORTYPE;
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ":  ";
                cout << $1 << " is declared as an array but is being used as a singleton" << endl; 
            }
        }
        else {
            if (current_function != NULL)
                param_search(string ($1), current_function->param_list, found, rec);
            if (found) {
                if (rec->type == SIMPLE) {
                    $$.type = rec->data_type_obj;
                    string dataType = get_string_from_data_type($$.type);
                    dataType += "_" + to_string(rec->scope);
                    $$.reg_name = new string("_" + string($1) + "_" + dataType);
                }
                else {
                    $$.type = ERRORTYPE;
                    cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
                    cout << $1 << " is declared as an array but is being used as a singleton" << endl;
                }
            }
            else {
                $$.type = ERRORTYPE;
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
                cout << "Undeclared identifier " << $1 << endl;
            }
        }
    }
    | ID BR_DIMLIST
    {
        // retrieve the highest level id with same name in param list or var list
        int found = 0;
        sym_tab_entry* rec = NULL;
        $$.offset_reg_name = NULL; 
        if($2.type == ERRORTYPE){
            errorFound = true;
            $$.type = ERRORTYPE;
        }
        else{
            look_up_call_name(string($1), current_function, found, rec, global_vars); 
            if(found){
                if (rec->type == ARRAY) {
                    if (dimlist.size() == rec->dimlist.size()) {
                        $$.type = rec->data_type_obj;
                        // calculate linear address using dimensions then pass to FACTOR
                        string offsetRegister = tempSet.get_temp_reg();
                        string dimlistRegister = tempSet.get_temp_reg();
                        string s = offsetRegister + " = 0";
                        generate_instr(functionInstruction, s, nextquad);
                        for (int i = 0; i < rec->dimlist.size(); i++) {
                            s = offsetRegister + " = " + offsetRegister + " + " + dimlist[i];
                            generate_instr(functionInstruction, s, nextquad);
                            // offset += dimlist[i];
                            if (i != rec->dimlist.size()-1) {
                                // offset *= rec->dimlist[i+1];
                                s = dimlistRegister + " = " + to_string(rec->dimlist[i+1]);
                                generate_instr(functionInstruction, s, nextquad);                                
                                s = offsetRegister + " = " + offsetRegister + " * " + dimlistRegister;
                                generate_instr(functionInstruction, s, nextquad);
                            }
                            tempSet.free_reg(dimlist[i]);
                        }
                        string dataType = get_string_from_data_type($$.type);
                        dataType += "_" + to_string(rec->scope); 
                        s = "_" + string($1) + "_" + dataType ;
                        s += "[" + offsetRegister + "]";
                        $$.reg_name = new string(s);
                        tempSet.free_reg(dimlistRegister);
                        $$.offset_reg_name = new string(offsetRegister);
                        
                    }
                    else {
                        $$.type = ERRORTYPE;
                        cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
                        cout << "Dimension mismatch: " << $1 << " should have " << dimlist.size() <<" dimensions" << endl;
                    }
                }
                else {
                    $$.type = ERRORTYPE;
                    cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
                    cout << string($1) << " is declared as a singleton but is being used as an array" << endl; 
                }
            }
            else {
                $$.type = ERRORTYPE;
                cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
                cout << "Undeclared identifier " << $1 << endl;
            }
            dimlist.clear();
        }
    }
;

BR_DIMLIST: LSB ASG RSB
    {
        if ($2.type == INTEGER) {
            dimlist.push_back(*($2.reg_name));
        }
        else {
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
            cout << "One of the dimension of an array cannot be evaluated to integer" << endl;
        }
    }    
    | BR_DIMLIST LSB ASG RSB 
    {
        if ($3.type == INTEGER) {
            dimlist.push_back(*($3.reg_name));
        }
        else {
            cout << BOLD(FRED("ERROR : ")) << "Line no. " << yylineno << ": ";
            cout << "One of the dimension of an array cannot be evaluated to integer" << endl;
        }  
    }
;

%%

void yyerror(const char *s)
{      
    errorFound=1;
    fprintf (stderr, "%s\n", s);
    // cout << "Line no. " << yylineno << ": Syntax error" << endl;
    // fflush(stdout);
}

int main(int argc, char **argv)
{
    nextquad = 0;
    scope = 0;
    found = 0;
    offsetCalc = 0;
    errorFound=false;
    switchVar.clear();
    dimlist.clear();
    
    yyparse();
    set_offsets(sym_tab_func_entry, global_vars);
    ofstream outinter;
    outinter.open("./output/intermediate.txt");
    if(!errorFound){
        for(auto it:functionInstruction){
            cout << it << endl;
            outinter<<it<<endl;
        }
        cout << "intermediate code generated in output folder" << endl;
    } else {
        cout << "No intermediate code generated" << endl;
    }
    outinter.close();
}