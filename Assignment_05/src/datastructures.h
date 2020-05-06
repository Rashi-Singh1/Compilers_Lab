#pragma once
#include <iostream>
#include <vector>
#include <stack>
#include <stdio.h>
// #include <algorithm>
#include <utility>
#include <fstream>
using namespace std;

#define RST  "\x1B[0m"
#define KRED  "\x1B[31m"
#define KYEL  "\x1B[33m"
#define KBLU  "\x1B[34m"
#define KCYN  "\x1B[36m"

#define FRED(x) KRED x RST
#define FYEL(x) KYEL x RST
#define FBLU(x) KBLU x RST
#define FCYN(x) KCYN x RST

#define BOLD(x) "\x1B[1m" x RST

class register_handler_class {
private:
    vector<int> temp_regs;
    vector<int> float_regs;
public:
    register_handler_class(){
        temp_regs.clear();
        for(int i=9; i>=0; i--){
            temp_regs.push_back(i);
        }
        float_regs.clear();
        for(int i=10; i>=0; i--){
            if(i==0||i==12){
                continue;
            }
            float_regs.push_back(i);
        }
    }
    string get_temp_reg();
    string get_float_reg();
    void free_reg(string s);
};

void generate_instr(vector<string> &, string ,int &);
void backpatch(vector<int> *&, int, vector<string> &);
void merge_lists(vector<int> *&, vector<int> *&);
void merge_lists_switch(vector<pair<string,int>> *&receiver,vector<pair<string,int>> *&donor); 
