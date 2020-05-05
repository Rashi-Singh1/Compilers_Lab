#pragma once
#include <iostream>
#include <vector>
#include <stack>
#include <stdio.h>
// #include <algorithm>
#include <utility>
#include <fstream>
using namespace std;

// BOLD(FRED("ERROR : "))

#define RST  "\x1B[0m"
#define KRED  "\x1B[31m"
#define KGRN  "\x1B[32m"
#define KYEL  "\x1B[33m"
#define KBLU  "\x1B[34m"
#define KMAG  "\x1B[35m"
#define KCYN  "\x1B[36m"
#define KWHT  "\x1B[37m"

#define FRED(x) KRED x RST
#define FGRN(x) KGRN x RST
#define FYEL(x) KYEL x RST
#define FBLU(x) KBLU x RST
#define FMAG(x) KMAG x RST
#define FCYN(x) KCYN x RST
#define FWHT(x) KWHT x RST

#define BOLD(x) "\x1B[1m" x RST
#define UNDL(x) "\x1B[4m" x RST

enum data_type {INTEGER, FLOATING, NULLVOID, BOOLEAN, ERRORTYPE};
enum var_type {SIMPLE, ARRAY};
enum Tag{PARAMAETER, VARIABLE};

struct expression{
    data_type type;
    string* registerName;
    string* offsetRegName;
};

struct stmt {
    vector<int> *nextList;
    vector<int> *breakList;
    vector<int> *continueList;
};

struct whileexp {
    int begin;
    vector<int> *falseList;
};

struct shortcircuit{
    data_type type;
    string* registerName;
    vector<int>* jumpList;
};

struct condition2temp{
    vector<int> *temp;
};

struct switchcaser{
    vector<int> *nextList;
    vector<pair<string,int>> *casepair;
    vector<int> *breakList;
    vector<int> *continueList;
};

struct switchtemp{
    vector<pair<string,int>> *casepair;
};

struct sym_tab_entry {
    string name;
    var_type type;
    data_type data_type_obj;
    Tag tag;
    int scope;
    vector<int> dimlist; // cube[x][y][z] => (x -> y -> z)
    int variable_offset;
    bool valid;
    int max_dim_offset;
}; 

struct function_entry {
    string name;
    data_type return_type;
    int param_num;
    int function_offset;
    vector <sym_tab_entry*> list_of_variables;
    vector <sym_tab_entry*> param_list;
}; 

void attach_data_type(data_type type, vector<sym_tab_entry*> &sym_tab_entry_list, int scope);
void symbol_table_append(vector<sym_tab_entry*> &sym_tab_entry_list, function_entry* current_function);
void sym_tab_insert_parameter(vector<sym_tab_entry*> &sym_tab_entry_list, function_entry* current_function);
void clear_var_list(function_entry* current_function, int scope);
void look_up_function(function_entry* current_function,vector<function_entry*> &sym_tab_func_entry,int &found);
void check_function_entry(function_entry* &current_function,vector<function_entry*> &sym_tab_func_entry,int &found);
void look_up_variable(string name, function_entry* current_function, int &found, sym_tab_entry *&rec, int scope);
void look_up_call_name(string name, function_entry* current_function, int &found, sym_tab_entry *&rec, vector<sym_tab_entry*> &global_vars);
void param_search(string name, vector<sym_tab_entry*> &param_list, int &found, sym_tab_entry *&pn);
void function_append(function_entry* current_function, vector<function_entry*> &sym_tab_func_entry);
void show_list(vector<function_entry*> &sym_tab_func_entry);
void display_function(function_entry* &current_function);
bool check_type_mismatch(data_type type1, data_type type2);
data_type type_match(data_type type1, data_type type2);
void add_global_var(vector<sym_tab_entry*> &sym_tab_entry_list, vector<sym_tab_entry*> &global_vars);
void look_up_global_var(string name, vector<sym_tab_entry*> &global_vars, int &found, sym_tab_entry *&rec, int scope);

void set_offsets(vector<function_entry*> &sym_tab_func_entry, vector<sym_tab_entry*> &global_vars);
string get_string_from_data_type(data_type a);
int get_int_from_data_type(data_type a);
int get_string_from_var_type(var_type a);
int get_int_from_tag(Tag a);