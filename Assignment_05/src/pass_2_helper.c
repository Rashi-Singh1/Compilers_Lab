#include "pass_2_helper.h"

string data_type_to_string(data_type a){
    switch(a){
        case INTEGER   : return "int";
        case FLOATING  : return "float";
        case NULLVOID  : return "void";
        case BOOLEAN   : return "bool";
        case ERRORTYPE : return "error";
        default: return "default";
    }
}

int data_type_to_int(data_type a){
    switch(a){
        case INTEGER   : return 0;
        case FLOATING  : return 1;
        case NULLVOID  : return 2;
        case BOOLEAN   : return 3;
        case ERRORTYPE : return 4;
        default : return 999;
    }
}
data_type string_to_data_type(string x){
    if(x=="0")
        return INTEGER;
    if(x=="1")
        return FLOATING;
    if(x=="2")
        return NULLVOID;
    return ERRORTYPE;
}
int get_offset(vector<function_entry> &functionList, vector<sym_tab_entry> &global_vars, string functionName, string variableName, int internalOffset, bool &is_global_var){
    is_global_var = false;
    for(auto it : functionList){
        if(it.name == functionName){
            for (auto it2 : it.var_list){
                if(it2->name == variableName){
                    int offset = it.function_offset - 4*( internalOffset + 1) - it2->var_offset;
                    return offset; 
                }
            }
            for (auto it2: it.param_list){
                if(it2->name == variableName){
                    int offset = it.function_offset + 4*(it.num_of_param - internalOffset - 1) - it2->var_offset;
                    return offset; 
                }
            }
        }
    }   
    for(auto it : global_vars){
        if(it.name == variableName){
            is_global_var = true;
            return 0;
        }
    }
    // cout << "Variable " << variableName << " not found in " << functionName << endl;
    return -1;
}

int get_function_offset(vector<function_entry> &functionList,string functionName){
    for(auto it : functionList){
        if(it.name == functionName){
            return it.function_offset;
        }
    }
    return -1;
}

void print_vector(vector<function_entry> &functionprintList){
    for(auto funcRecord : functionprintList){
        cout << "$$" << endl;
        cout << "_" << funcRecord.name << " " << data_type_to_string(funcRecord.return_type) << " ";
        cout << funcRecord.num_of_param << " " << funcRecord.function_offset << endl;
        cout << "$1" << endl;
        for(auto varRecord : funcRecord.param_list){
            cout <<varRecord->name << " " << data_type_to_int(varRecord->data_type_obj) << " " ;
            cout << varRecord->scope << " " << varRecord->var_offset << endl;
        }
        cout << "$2 " << funcRecord.var_list.size() << endl;
        for(auto varRecord : funcRecord.var_list){
            cout <<varRecord->name << " " << data_type_to_int(varRecord->data_type_obj) << " " ;
            cout << varRecord->scope << " " << varRecord->var_offset << endl;
        }
    }
}

void read_symtab(vector<function_entry> &functionList, vector<sym_tab_entry> &global_vars){
    ifstream myfile;
    myfile.open ("../firstPass/output/symtab.txt");
    string a;
    bool is_global_var = false;
    while(myfile >> a){
        if(a=="$$"){
            // cout<<"pp "<<a<<endl;
            function_entry p;
            myfile >> p.name;
            if(p.name == "GLOBAL"){
                is_global_var = true;
            }
            else{
                is_global_var = false;
            }
            string x;
            myfile >> x;
            p.return_type = string_to_data_type(x);
            myfile >> p.num_of_param;
            myfile >> p.function_offset;
            myfile >> x;
            if(is_global_var){
                // global_vars.insert(global_vars.end(), p.param_list.begin(), p.param_list.end());
                for(int i=0;i<p.num_of_param;i++){
                    sym_tab_entry newType;
                    string data_type_obj;
                    myfile >> newType.name;
                    myfile >> data_type_obj;
                    newType.data_type_obj = string_to_data_type(data_type_obj);
                    
                    myfile >> newType.scope;
                    myfile >> newType.var_offset;
                    global_vars.push_back(newType);
                }
                for(auto it : global_vars){
                    cout << "Global Variable Name : "<< it.name << endl;
                }
            }
            else{
                (p.param_list).resize(p.num_of_param);
                for(int i=0;i<p.num_of_param;i++){
                    p.param_list[i] = new sym_tab_entry;
                    myfile >> (p.param_list[i])->name;
                    string t;
                    myfile >> t;
                    (p.param_list[i])->data_type_obj= string_to_data_type(t);
                    myfile >> (p.param_list[i])->scope;
                    myfile >> (p.param_list[i])->var_offset; 
                }
            }
            myfile >> x;
            int z;
            myfile >> z;
            p.var_list.resize(z);
            for(int i=0;i<z;i++){
                p.var_list[i] = new sym_tab_entry;
                myfile >> (p.var_list[i])->name;
                string t;
                myfile >> t;
                (p.var_list[i])->data_type_obj= string_to_data_type(t);
                myfile >> (p.var_list[i])->scope;
                myfile >> (p.var_list[i])->var_offset;
            }
            if(!is_global_var){
                functionList.push_back(p);
            }
        }
    }
}

int get_param_offset(vector<function_entry> &functionList, string functionName){
    for(auto it : functionList){
        if(it.name == functionName){
            return 4*(it.num_of_param);
        }
    } 
    return 0;
}

