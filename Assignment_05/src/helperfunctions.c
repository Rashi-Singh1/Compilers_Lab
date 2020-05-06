#include "helperfunctions.h"

void attach_data_type(data_type data_type_obj, vector<sym_tab_entry*> &sym_tab_entry_list, int scope){
    for (sym_tab_entry* &it:sym_tab_entry_list) {
        it->scope = scope;
        it->data_type_obj = data_type_obj;
    }
    return;
}

void symbol_table_append(vector<sym_tab_entry*> &sym_tab_entry_list, function_entry* current_function) {
    if (current_function == NULL) {
        return;
    }
    current_function->list_of_variables.insert(current_function->list_of_variables.end(), sym_tab_entry_list.begin(), sym_tab_entry_list.end());
    return;
}

void add_global_var(vector<sym_tab_entry*> &sym_tab_entry_list, vector<sym_tab_entry*> &global_vars){
    global_vars.insert(global_vars.end(), sym_tab_entry_list.begin(), sym_tab_entry_list.end());
}

void sym_tab_insert_parameter(vector<sym_tab_entry*> &sym_tab_entry_list, function_entry* current_function) {
    if(current_function == NULL) {
        return;
    }
    current_function->param_list.insert(current_function->param_list.end(), sym_tab_entry_list.begin(), sym_tab_entry_list.end());
    current_function->param_num+=sym_tab_entry_list.size();
}

void clear_var_list(function_entry* current_function, int scope){
    if(current_function == NULL) {
        return;
    }
    vector <sym_tab_entry*> list_of_variables;

    for(auto it: current_function->list_of_variables){
        if(it->scope == scope){
            it->valid = false;
        }
        // if(it->scope!=scope){
        //     list_of_variables.push_back(it);
        // } else {
        //     free(it);
        // }
    }
    // current_function->list_of_variables.swap(list_of_variables);
}

void look_up_variable(string name, function_entry* current_function, int &found, sym_tab_entry *&rec, int scope) {   
    if(current_function == NULL) {
        return;
    }
    vector<sym_tab_entry*>::reverse_iterator i;
    bool flag=false;
    for (i = current_function->list_of_variables.rbegin(); i != current_function->list_of_variables.rend(); ++i) {
        if (name == (*i)->name && (*i)->scope==scope) {
            // found = 1;
            rec = *i;
            flag=true;
            // return;
        }
    }
    if(flag){
        found=1;
        return;
    }
    found = 0;
    rec = NULL;
    return;
}

void look_up_global_var(string name, vector<sym_tab_entry*> &global_vars, int &found, sym_tab_entry *&rec, int scope){
    bool flag=false;
    for (auto it : global_vars) {
        if (name == it->name && it->scope == scope) {
            flag=true;
        }
    }
    if(flag){
        found=1;
        return;
    }
    found = 0;
    rec = NULL;
}

void look_up_call_name(string name, function_entry* current_function, int &found, sym_tab_entry *&rec, vector<sym_tab_entry*> &global_vars) {
    if(current_function == NULL) {
        return;
    }
    vector<sym_tab_entry*>::reverse_iterator i;
    bool flag=false;
    int sc=0;
    for (i = current_function->list_of_variables.rbegin(); i != current_function->list_of_variables.rend(); ++i) {
        if (name == (*i)->name && (*i)->valid) {
            // found = 1;
            if(sc<(*i)->scope){
                sc=(*i)->scope;
                rec = *i;
            }
            flag=true;
            // return;
        }
    }
    if(flag){
        found=1;
        return;
    }
    for(auto it : global_vars){
        if(name == it->name && it->valid){
            flag = true;
            rec = it;
            break;
        }
    }
    if(flag){
        found=1;
        return;
    }
    found = 0;
    rec = NULL;
    return;
}

void param_search(string name, vector<sym_tab_entry*> &param_list, int &found, sym_tab_entry *&pn) {
    vector<sym_tab_entry*> :: reverse_iterator i;
    for (i = param_list.rbegin(); i != param_list.rend(); ++i){
        if(name == (*i)->name){
            found = 1;
            pn = (*i);
            return;
        }
    }
    found = 0;
    pn = NULL;
    return;
}

void look_up_function(function_entry* current_function, vector<function_entry*> &sym_tab_func_entry, int &found){
    for (auto it : sym_tab_func_entry) {
        if(it->name == current_function->name) {
            found = 1;
            return;
        }
    }  
    found = 0;
    return;  
}

void check_function_entry(function_entry* &func_call_ptr, vector<function_entry*> &sym_tab_func_entry, int &found){
    
    for(auto it:sym_tab_func_entry){
        if(it->name == func_call_ptr->name  && it->param_num == func_call_ptr->param_num){
            int flag=1;
            for(int i=0;i<it->param_num;i++){
                if((it->param_list[i])->data_type_obj != func_call_ptr->param_list[i]->data_type_obj){
                    found=-1;
                    flag=0;
                    break;
                }
            }
            if(flag == 1){
                found=1;
                func_call_ptr->return_type = it->return_type;
                return;
            } 
        }
    }
    if (found != -1) found=0;
    return;    
}


void display_function(function_entry* &current_function){
    
        cout<<"Function Entry: --"<<(current_function->name)<<"--"<<endl;
        cout<<"Printing Parameter List"<<endl;
        for(auto it2:current_function->param_list){
            cout<<(it2->name)<<" "<<(it2->data_type_obj)<<endl;
        }
        cout<<"Printing Variable List"<<endl;
        for(auto it2:current_function->list_of_variables){
            cout<<(it2->name)<<" "<<(it2->data_type_obj)<<endl;
        } 
}

void show_list(vector<function_entry*> &sym_tab_func_entry){
    
    for(auto it:sym_tab_func_entry){
        cout<<"Function Entry: "<<(it->name)<<endl;
        cout<<"Printing Parameter List"<<endl;
        for(auto it2:it->param_list){
            cout<<(it2->name)<<" "<<(it2->data_type_obj)<<endl;
        }
        cout<<"Printing Variable List"<<endl;
        for(auto it2:it->param_list){
            cout<<(it2->name)<<" "<<(it2->data_type_obj)<<endl;
        } 
    }
}

void function_append(function_entry* current_function, vector<function_entry*> &sym_tab_func_entry){
    sym_tab_func_entry.push_back(current_function);
}

bool check_type_mismatch(data_type type1, data_type type2) {
    if ((type1 == INTEGER || type1 == FLOATING)
        && (type2 == INTEGER || type2 == FLOATING)) return true;
    return false;
}

data_type type_match(data_type type1, data_type type2) {
    if (type1 == INTEGER && type2 == INTEGER) {
        return INTEGER;
    }
    else if (type1 == FLOATING && type2 == FLOATING) {
        return FLOATING;
    }
    else if (type1 == INTEGER && type2 == FLOATING) {
        return FLOATING;
    }
    else if (type1 == FLOATING && type2 == INTEGER) {
        return FLOATING;
    }
    else return NULLVOID;
}

string get_string_from_data_type(data_type a){
    switch(a){
        case INTEGER   : return "int";
        case FLOATING  : return "float";
        case NULLVOID  : return "void";
        case BOOLEAN   : return "bool";
        case ERRORTYPE : return "error";
    }
    return "vvv";
}

int get_int_from_data_type(data_type a){
    switch(a){
        case INTEGER   : return 0;
        case FLOATING  : return 1;
        case NULLVOID  : return 2;
        case BOOLEAN   : return 3;
        case ERRORTYPE : return 4;
    }
    return 5;
}

int get_string_from_var_type(var_type a){
    switch(a){
        case SIMPLE : return 0;
        case ARRAY  : return 1;
    }
    return 2;
}


int get_int_from_tag(var_param_tag a){
    switch(a){
        case PARAMAETER : return 0;
        case VARIABLE   : return 1;
    }
    return 2;
}

void set_offsets(vector<function_entry*> &sym_tab_func_entry, vector<sym_tab_entry*> &global_vars){
    int ofs;
    for(auto &fr : sym_tab_func_entry){
        ofs = 0;
        for(auto &p_entry : fr->param_list){
            p_entry->variable_offset = ofs;
            ofs += 4;
        }
        // ofs += 80;
        ofs = 0;
        ofs += 92;
        for(auto &var_rec : fr->list_of_variables){
            var_rec->variable_offset = ofs;
            ofs += 4*(var_rec->max_dim_offset);
        }
        fr->function_offset = ofs;
    }
}

