#include "datastructures.h"

string register_handler_class::get_temp_reg() {
    string reg = "";
    if (temp_regs.size()==0) {
        cout << BOLD(FRED("FATAL ERROR : Exceeded maximum temporary Int registers")) << endl;
        exit(1);
        return reg;
    }
    reg += "T";
    int x = temp_regs[temp_regs.size()-1];
    reg += to_string(x);
    temp_regs.pop_back();
    return reg;
}

string register_handler_class::get_float_reg() {
    string reg = "";
    if (float_regs.size()==0) {
        cout << BOLD(FRED("FATAL ERROR : Exceeded maximum temporary Float registers")) << endl;
        exit(1);
        return reg;
    }
    reg += "F";
    int x = float_regs[float_regs.size()-1];
    reg += to_string(x);
    float_regs.pop_back();
    return reg;
}


void register_handler_class::free_reg(string s){
    if(s[0]=='F'){
        s[0] = '0';
        int x = stoi(s);
        for(auto it : float_regs){
            if(it==x){
                // cout<<"Trying to free an already freed Float Register "<<s<<endl;
                return;
            }
        }
        // cout<<"FLoat Register Freed "<< s <<endl;
        float_regs.push_back(x);
    } else if(s[0] == 'T'){
        s[0] = '0';
        int x = stoi(s);
        for(auto it:temp_regs){
            if(it==x){
                // cout<<"Trying to free an already freed Int Register "<<s<<endl;
                return;
            }
        }
        // cout<<"Int Register Freed "<< s <<endl;
        temp_regs.push_back(x);
    } else {
        cout << "Not a Temp Variable : " << s << endl;
    }
}

void generate_instr(vector<string> &all_instructions, string instruction, int &nextQuad){
    all_instructions.push_back(instruction);
    nextQuad++;
    // cout << instruction << endl;
    return;
}

void backpatch(vector<int> *&lineNumbers, int labelNumber, vector<string> &all_instructions){
    if(lineNumbers == NULL){
        cout << "Given line numbers for "<<labelNumber<<" is NULL"<<endl;
        return;
    }
    string statement;
    for(int it : (*lineNumbers)){
        // statement = all_instructions[it];        // statement +=("L"+ to_string(labelNumber));
        all_instructions[it] += (to_string(labelNumber));
    }
    lineNumbers->clear();
}

void merge_lists(vector<int> *&receiver, vector<int> *&donor) {
    if(donor==NULL || receiver == NULL){
        // cout<<"Conitnued because vector empty"<<endl;
        return;
    }
    for(int i:(*donor)){
        receiver->push_back(i);
    }
    donor->clear();
    return;
}

void merge_lists_switch(vector<pair<string,int>> *&receiver,vector<pair<string,int>> *&donor) {
    if(donor==NULL || receiver == NULL){
        // cout<<"Conitnued because vector empty"<<endl;
        return;
    }
    for(auto i:(*donor)){
        receiver->push_back(i);
    }
    donor->clear();
    return;
}