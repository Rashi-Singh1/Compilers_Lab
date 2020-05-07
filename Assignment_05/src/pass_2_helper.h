#include <iostream>
#include <vector>
#include <stack>
#include <stdio.h>
#include <fstream>
#include <utility>
using namespace std;

#define RST   "\x1B[0m"
#define KRED  "\x1B[31m"
#define KYEL  "\x1B[33m"
#define KBLU  "\x1B[34m"
#define KCYN  "\x1B[36m"

#define FRED(x) KRED x RST
#define FYEL(x) KYEL x RST
#define FBLU(x) KBLU x RST
#define FCYN(x) KCYN x RST

#define BOLD(x) "\x1B[1m" x RST

enum data_type {INTEGER, FLOATING, NULLVOID, BOOLEAN, ERRORTYPE};
enum var_type {SIMPLE, ARRAY};
enum var_param_tag {PARAMAETER, VARIABLE};

struct sym_tab_entry {
    string name;
    data_type data_type_obj;
    int scope;
    int var_offset;
}; 

struct function_entry {
    string name;
    data_type return_type;
    int num_of_param;
    int function_offset;
    vector <sym_tab_entry*> var_list;
    vector <sym_tab_entry*> param_list;
}; 

string data_type_to_string(data_type a);
int data_type_to_int(data_type a);
data_type string_to_data_type(string x);

int get_param_offset(vector<function_entry> &functionList, string functionName);
void read_symtab(vector<function_entry> &functionList, vector<sym_tab_entry> &global_vars);
int get_offset(vector<function_entry> &functionList, vector<sym_tab_entry> &global_vars, string functionName, string variableName, int internalOffset, bool &is_global_var);
int get_function_offset(vector<function_entry> &functionList, string functionName);
void print_vector(vector<function_entry> &functionList);