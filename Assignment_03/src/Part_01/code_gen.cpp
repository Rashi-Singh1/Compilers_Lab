#include <cstdio>
#include "lex.h"
#include "code_gen.h"
#include <cstdlib>
#include <bits/stdc++.h>
#include <fstream>
#include <iostream> 
// #define show(x) ("output/debug_file.txt");
// debugFile.open("output/debug_file.txt",std::ios_base::app);
// debugFile << #x << " incremented to " << x << endl;
// debugFile.close();
ofstream debugFile;
ofstream outputFile;
ifstream testFile;
string test_file;

#define MAX_ITS 100
using namespace std;

unordered_set<string> class_names;
int cntClass = 0, cntObject = 0, cntIClass = 0, cntConstructor = 0, cntOverload = 0;

void inc(int &v, string name, string output_file_name){
    ++v;
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Incremented "<< name <<" to "<< v << endl;    
    debugFile.close();
    testFile.open(test_file,std::ios_base::app);
    string curLine;
    for(int i = 0;i < yylineno;i++) std::getline(testFile,curLine);
    testFile.close();
    ofstream out_file;
    out_file.open("output/"+output_file_name,std::ios_base::app);
    out_file<<yylineno<<" "<<curLine<<endl;    
    out_file.close();
}

bool prog(string test){
    //TODO : call as a while loop
    test_file = test;
    debugFile.open("output/debug_file.txt");
    debugFile<<"Entering prog"<<endl;    
    debugFile.close();
    advance();
    int no_of_iterations = 0;
    while(!match(EOI)){
        ++no_of_iterations;
        if(no_of_iterations > MAX_ITS){
             debugFile.open("output/debug_file.txt",std::ios_base::app);
             debugFile << "error -- may be infinite loop\n";             
             debugFile.close();
             return false;
        }
        string id = getID();
        if(match(CLASS))
        {
            if(!prog2()) return false;
        }
        else if(match(DATA_TYPE))
        {
            advance();
            string new_id = getID();
            if(match(NUM_OR_ID) && class_names.count(new_id)){
                advance();
                if(match(COLON)){
                    advance();
                    if(match(COLON)){
                        advance();
                        debugFile.open("output/debug_file.txt",std::ios_base::app);
                        debugFile << "normal _ function -----------------\n";                        
                        debugFile.close();
                        if(!normal_function()) return false;
                    } else{
                        fprintf( stderr, "%d: scope operator incomplete \n", yylineno );
                        return false;
                    }
                } else{
                    fprintf( stderr, "%d: expected scope operator\n", yylineno );
                    return false;
                }
            } else{
                 string str = getID();
                 if(match(MAIN)){
                     debugFile.open("output/debug_file.txt",std::ios_base::app);
                     debugFile << "----------------MAIN MATCHED ----------------\n";                     
                     debugFile.close();
                     advance();
                     if(match(LP)){ 
                            advance();
                            if(!parameter_list()) return false;
                            if(match(RP)){
                                 advance();
                                 if(match(CLP)){
                                         advance();
                                         if(!stmt_list()) return false;
                                         if(match(CRP)){
                                              advance();
                                              
                                         } else{
                                                fprintf( stderr, "%d: curly right parenthesis expected \n", yylineno );
                                                return false;
                                         }
                                 } else{
                                    fprintf( stderr, "%d: missing curly left parenthesis\n", yylineno );
                                    return false;
                                 }
                            } else{
                                 fprintf( stderr, "%d: missing right parenthesis\n", yylineno );
                                 return false;
                            }
                     } else{
                          fprintf( stderr, "%d: expected left parenthesis after main\n", yylineno );
                          return false;
                     }
                 }
                 else {
                     debugFile.open("output/debug_file.txt",std::ios_base::app);
                     debugFile << "culprit----------------------- \n";                     
                     debugFile.close();
                     if(!normal_function()) return false;
                 }
            }
        }
        else if((match(NUM_OR_ID) && class_names.count(id)))
        {
             // object definition or scoped constructor or scoped operator overload 
            advance();
            // scoped constructor
              if(match(COLON)){
                    advance();
                    if(match(COLON)){
                        advance();
                        string name_str = getID();
                        debugFile.open("output/debug_file.txt",std::ios_base::app);
                        debugFile << "name_str = " << name_str << endl;                        
                        debugFile.close();
                        if(name_str == id){
                            advance();
                            if(match(LP)){
                                  advance();
                                  if(!constructor()) return false;
                            } else{
                                    fprintf( stderr, "%d: left parenthesis expected \n", yylineno );
                                    return false;        
                                  }
                        }
                    } else{
                        fprintf( stderr, "%d: scope operator incomplete \n", yylineno );
                        return false;
                    }
                } else{
                     string name_str = getID();
                     if(id == name_str){
                          // may be a scoped operator
                          advance();
                          if(match(COLON)){
                               advance();
                               if(match(COLON)){
                                    advance();
                                   // operator operator_overload
                                   string op = getID();
                                   if(op == "operator"){
                                        advance();
                                        if(!operator_overload(id)) return false;
                                   } else{
                                    // class_name:: normalfunction() type
                                       if(!normal_function()) return false;
         
                                   }

                               } else{
                                    fprintf( stderr, "%d: incomplete scope operator \n", yylineno );
                                    return false;
                               }
                          } else{
                                    fprintf( stderr, "%d: scope operator expected\n", yylineno );
                                    return false;
                          }            
                     } else{
                             // may be a object definition
                             if(!object_def(id)){
                                  return false;
                             }
                     }
                }

        }
    }
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Coming out of prog"<<endl;    
    outputFile.open("output/output_file.txt");
    debugFile<<endl<<"Number of Class Definitions: "<<cntClass<<endl;    
    debugFile<<"Number of Inherited Class Definitions: "<<cntIClass<<endl;    
    debugFile<<"Number of Object Declarations: "<<cntObject<<endl;    
    debugFile<<"Number of Constructors: "<<cntConstructor<<endl;    
    debugFile<<"Number of Operator Overloaded Functions: "<<cntOverload<<endl<<endl;    
    outputFile<<endl<<"Number of Class Definitions: "<<cntClass<<endl;    
    outputFile<<"Number of Inherited Class Definitions: "<<cntIClass<<endl;    
    outputFile<<"Number of Object Declarations: "<<cntObject<<endl;    
    outputFile<<"Number of Constructors: "<<cntConstructor<<endl;    
    outputFile<<"Number of Operator Overloaded Functions: "<<cntOverload<<endl<<endl; 
    outputFile.close();
    debugFile.close();
    return true;
}

bool object_def(string id)
{
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Entering object_def"<<endl;    
    debugFile.close();
    inc(cntObject , "cntobject","object_def_file.txt" ); 
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile << "getID() IN object def is " << getID() << endl;    
    debugFile.close();

    if(match(NUM_OR_ID))
    {
        advance();
        if(!ending(id)) return false;
        if(!more_def(id)) return false;
    }
    else{
        fprintf( stderr, "%d: Specify the object name\n", yylineno );
        return false;
    } 
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Coming out of object_def"<<endl;    
    debugFile.close();
    return true;

}

bool more_def(string id)
{
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Entering more_def"<<endl;    
    debugFile.close();
    if(match(SEMI))
    {
        advance();
    }
    else if(match(COMMA))
    {
        advance();
        inc(cntObject , "cntobject", "object_def_file.txt");
        if(match(NUM_OR_ID))
        {
            advance();
            ending(id);
            more_def(id);
        }
        else{
            fprintf( stderr, "%d: Trailing comma\n", yylineno );
            return false;
        } 
    }
    else{
        fprintf( stderr, "%d: Unexpected ending of object declaration\n", yylineno );
        return false;
    } 
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Coming out of more_def"<<endl;    
    debugFile.close();
    return true;
   
}

bool ending(string id)
{
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Entering ending"<<endl;    
    debugFile.close();
    if(match(EQUAL))
    {
        advance();
        string curClass = getID();
        if(id == curClass)
        {
            advance();
            if(match(LP))
            {
                advance();
                if(match(RP)){
                    advance();
                    return true;
                }
                else advance();
                //random parameters as of now
                do{
                    if(match(RP)){
                        advance();
                        break;
                    }
                    advance();
                }
                while(!match(EOI) && !match(RP));
                if(match(RP)){
                    advance();
                    return true;
                }
            }
            else{
                fprintf( stderr, "%d: Missing (\n", yylineno );
                return false;
            } 
        }
        else{
            fprintf( stderr, "%d: Class mismatch\n", yylineno );
            return false;
        } 
    }
    else if(match(LP))
    {
        advance();
        if(match(RP)){
            advance();
            return true;
        }
        else advance();
        //random parameters as of now
            do{
            if(match(RP)){
                advance();
                break;
            }
            advance();
        }
        while(!match(EOI) && !match(RP));
        if(match(RP)){
            advance();
            return true;
        }
    }
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Coming out of ending"<<endl;    
    debugFile.close();
    return true;
}

bool prog2(){
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Entering prog2"<<endl;    
    debugFile.close();
    string id = getID();
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile << " class name **********************************************************************\n";    
    debugFile.close();
    // for(auto x : classbugFile ("output/debug_file.txt");
    // debugFile.open("output/debug_file.txt",std::ios_base::app);
    // debugFilet << x << " ";   
    // debugFile.close();
    if(match(CLASS))
    {
        advance();
        // inc(cntIClass , "cntIclass");
        if(!classDef()) return false;
    }
    else if(match(NUM_OR_ID))
    {
        if(!(class_names.count(id))){
            debugFile.open("output/debug_file.txt",std::ios_base::app);
            debugFile<<"Undeclared class name"<<endl;            
            debugFile.close();
            return false;
        }
        advance();
        if(!object_def(id)) return false;
    }
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Coming out of prog2"<<endl;    
    debugFile.close();
    return true;
}

//to get the token from yytext
string getID()
{
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Entering getID"<<endl;    
    debugFile.close();
    // char* temp=(char*)malloc(sizeof(char)*(yyleng+1));
    // for(int i=0;i<yyleng;i++){
    //     *(temp+i)=*(yytext+i);
    // }
    // *(temp+yyleng)='\0';
    // string id(temp);
    string id(yytext);
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"id : "<<id<<endl;    
    debugFile.close();
    return id;
}

//classDef -> id inherited {class_stmt_list};
bool classDef()
{
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Entering classDef"<<endl;    
    debugFile.close();
    inc(cntClass , "cntclass","class_def_file.txt");
    // advance();
    if(match(NUM_OR_ID))
    {
        string id = getID();
        cout<<"in code_gen inserting in class_names "<<id<<endl;
        class_names.insert(id);
        advance();
        if(!inherited()) return false;
        if(match(CLP))
        {
            advance();
            if(!class_stmt_list(id)) return false;
            if(match(CRP))
            {
                advance();
                if(match(SEMI)) advance();
                else{
                    fprintf( stderr, "%d: Missing semicolon \n", yylineno );
                    return false;
                } 

            }
            else{
                fprintf( stderr, "%d: Missing parenthesis } \n", yylineno );
                return false;
            } 
        }
        else{
            fprintf( stderr, "%d: Missing parenthesis { \n", yylineno );
            return false;
        } 
        
    }
    else{
        fprintf( stderr, "%d: Specify the class name\n", yylineno );
        return false;
    } 
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Coming out of classDef"<<endl;    
    debugFile.close();
    return true;
}

//classDef -> epsilon | class_stmt_list(id)
bool class_stmt_list(string id)
{
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Entering class_stmt_list"<<endl;    
    debugFile.close();
    if(!class_stmt(id)) return false;
    if(!class_stmt_list_(id)) return false;
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Coming out of class_stmt_list"<<endl;    
    debugFile.close();
    return true;
}


bool  class_stmt_list_(string id)
{
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Entering class_stmt_list_"<<endl;    
    debugFile.close();
    string curid = getID();
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile <<" curid in class stmt list : " << curid << '\n';    
    debugFile.close();
    if(curid != "}")
    {
        if(!class_stmt(id)) return false;
        if(!class_stmt_list_(id)) return false;
    }
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Coming out of class_stmt_list_"<<endl;    
    debugFile.close();
    return true;
}


bool class_stmt(string id)
{
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Entering class_stmt"<<endl;    
    debugFile.close();
    string curID = getID();
    // ofstream debugFt");
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"id passed in class_stmt********************************************"<<id<<endl;    
    debugFile.close();

    if(curID == id)
    {
        advance();
        if(!nextFUNC(id)) return false;
    }else if(match(DATA_TYPE)){
        advance();
        if(!normal_function()) return false;
    }else{
        // advance();
        if(!prog2())return false;
    }
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Coming out of class_stmt"<<endl;    
    debugFile.close();
    return true;

}

bool nextFUNC(string id)
{
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Entering nextFunc"<<endl;    
    debugFile.close();
    string curID = getID();
    if(match(LP))
    {
        advance();
        if(!constructor()) return false;
        debugFile.open("output/debug_file.txt",std::ios_base::app);
        debugFile<<"Coming out of nextFunc"<<endl;        
        debugFile.close();
        return true;
    }
    else if(curID == "operator")
    {
        advance();
        if(!operator_overload(id)) return false;
        debugFile.open("output/debug_file.txt",std::ios_base::app);
        debugFile<<"Coming out of nextFunc"<<endl;        
        debugFile.close();
        return true;
    }else {
        if(!normal_function()) return false;
        debugFile.open("output/debug_file.txt",std::ios_base::app);
        debugFile<<"Coming out of nextFunc"<<endl;        
        debugFile.close();
        return true;
    }

    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Coming out of nextFunc (nextFunc failed)"<<endl;    
    debugFile.close();
    return false;
}

bool normal_function(){
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Entering normal_function"<<endl;    
    debugFile.close();
    if(match(NUM_OR_ID))
    {
        advance();
        debugFile.open("output/debug_file.txt",std::ios_base::app);
        debugFile << "id is " << getID() << endl;        
        debugFile.close();
        if(match(LP)){
            advance();
            if(!parameter_list()) return false;
            if(match(RP)){
                advance();
                if(match(CLP)){
                    advance();
                    if(!stmt_list()) return false;
                    if(match(CRP)){
                        advance();
                        return true;
                    }
                    else{
                        fprintf( stderr, "%d: Missing curly right parenthesis\n", yylineno );
                        return false;
                    }
                }
                else
                {
                    fprintf( stderr, "%d: Missing curly left parenthesis\n", yylineno );
                    return false;
                }
            }
            else{
                fprintf( stderr, "%d: Missing right parenthesis\n", yylineno );
                return false;
            }
        }else{
            fprintf( stderr, "%d: broooo Missing left parenthesis\n", yylineno );
            return false;
        }

    }else{
        fprintf( stderr, "%d: Missing function name\n", yylineno );
        return false;
    }
}

bool constructor()
{
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Entering constructor"<<endl;    
    debugFile.close();
    inc(cntConstructor , "cntconstructor","constructor_def_file.txt");

    if(!parameter_list()) return false;

    if(match(RP))
    {
        advance();
        if(match(CLP))
        {
            advance();
            if(!stmt_list()) return false;
            if(match(CRP))
            {
                advance();
            }
            else{
                fprintf( stderr, "%d: Missing parenthesis } \n", yylineno );
                return false;
            } 
        }
        else{
            fprintf( stderr, "%d: Missing parenthesis { \n", yylineno );
            return false;
        } 
    }
    else{
        fprintf( stderr, "%d: Missing right bracket\n", yylineno );
        return false;
    } 

debugFile.open("output/debug_file.txt",std::ios_base::app);
debugFile<<"Coming out of constructor"<<endl;
debugFile.close();
    return true;
    

}

bool parameter_list()
{
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Entering parameter_list"<<endl;    
    debugFile.close();
    if(match(DATA_TYPE))
    {
        advance();
        if(match(NUM_OR_ID))
        {
            advance();
            if(!opt_parameter()) return false;
        }
        else{
            fprintf( stderr, "%d: Missing parameter name\n", yylineno );
            return false;
        } 
    }
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Coming out of parameter_list"<<endl;    
    debugFile.close();
    return true;
}

bool opt_parameter(){
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Entering opt_parameter"<<endl;    
    debugFile.close();
    if(match(COMMA))
    {
        advance();
        if(match(DATA_TYPE))
        {
            advance();
            if(match(NUM_OR_ID))
            {
                advance();
                if(!opt_parameter()) return false;
            }
            else{
                fprintf( stderr, "%d: Missing parameter name\n", yylineno );
                return false;
            } 
        }
        else{
            fprintf( stderr, "%d: Trailing comma\n", yylineno );
            return false;
        } 
    }
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Coming out of opt_parameter"<<endl;    
    debugFile.close();
    return true;
}

bool stmt_list()
{
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Entering stmt_list"<<endl;    
    debugFile.close();
    if(match(CRP)){
        debugFile.open("output/debug_file.txt",std::ios_base::app);
        debugFile << "Coming out of stmt_list" << endl;        
        debugFile.close();
        return true;
    }

    string id = getID();
    int curly_paren_count = 0;
    int no_of_its = 0;

    while(curly_paren_count != 0  || !match(CRP))
    {
        no_of_its++;
        if(no_of_its > MAX_ITS){
            fprintf( stderr, "%d: Syntax error\n", yylineno );
            return false;
        }

        if(match(CLP)) {
            curly_paren_count++;
            advance();
        }
        else if(match(CRP)){
             curly_paren_count--;
             advance();
        }
        else if(match(CLASS) || (match(NUM_OR_ID)  && class_names.count(id))){
            if(!prog2()) return false;
        }else{
            advance();
        }
        if(match(EOI)) return false;
        id = getID();
    }

    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile << "Coming out of stmt_list" << endl;    
    debugFile.close();
    return true;
}

bool is_overloaded_operator(){
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Entering is_overload_operator"<<endl;    
    debugFile.close();
    if(match(PLUS)|| match(MINUS) || match(MUL) || match(DIV) || match(LESS )|| match(COLON) || match(COMMA) || match(MORE )|| match(EQUAL) || match(ASSIGN))
    {
        return true;
    }
    return false;
}

bool operator_overload(string id)
{
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Entering operator_overload"<<endl;    
    debugFile.close();
    inc(cntOverload , "cntOverload","op_overload_file.txt");
    if(is_overloaded_operator()){
        advance();
        if(match(LP)){
            advance();
            string curID = getID();
            if(curID == id){
                advance();
                if(match(NUM_OR_ID)){
                    advance();
                    if(match(RP)){
                        advance();
                        if(match(CLP)){
                            advance();
                            if(!stmt_list()) return false;
                            if(match(CRP)){
                                advance();
                            }
                            else{
                                fprintf( stderr, "%d: Missing curly right parenthesis }\n", yylineno );
                                return false;
                            } 
                        }
                        else{
                            fprintf( stderr, "%d: Missing curly left parenthesis {\n", yylineno );
                            return false;
                        } 
                    }
                    else{
                        fprintf( stderr, "%d: Missing right parenthesis )\n", yylineno );
                        return false;
                    } 
                }
                else{
                    fprintf( stderr, "%d: Missing param name\n", yylineno );
                    return false;
                } 
            }
            else{
                fprintf( stderr, "%d: Missing data type\n", yylineno );
                return false;
            } 
        }
        else{
            fprintf( stderr, "%d: Missing left parenthesis (\n", yylineno );
            return false;
        } 
    }
    else{
        fprintf( stderr, "%d: Missing operator\n", yylineno );
        return false;
    } 

    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Coming out of operator_overload"<<endl;    
    debugFile.close();
    return true;
}

bool inherited()
{
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Entering inherited"<<endl;    
    debugFile.close();
    if(match(COLON))
    {
        inc(cntIClass , "cntIclass","int_class_def_file.txt");
        advance();
        if(match(MOD))
        {
            advance();
            //TODO : hash map vala check
            if(match(NUM_OR_ID))
            {
                string id = getID();
                advance();
                if(!multiple_inherited()) return false;
            }
            else{
                fprintf( stderr, "%d: Specify super class name\n", yylineno );
                return false;
            } 
        }
        else{
            fprintf( stderr, "%d: Specify access modifier\n", yylineno );
            return false;
        } 
    }

debugFile.open("output/debug_file.txt",std::ios_base::app);
debugFile<<"Coming out of inherited"<<endl;
debugFile.close();
    return true;
}

bool multiple_inherited()
{
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Entering multiple_inherited"<<endl;    
    debugFile.close();
    if(match(COMMA))
    {
        advance();
        if(match(MOD))
        {
            advance();
            if(match(NUM_OR_ID))
            {
                string id = getID();
                //TODO : match id from hash function
                advance();
                if(!multiple_inherited()) return false;
            }
            else{
                fprintf( stderr, "%d: Specify super class name\n", yylineno );
                return false;
            } 
        }
        else{
            fprintf( stderr, "%d: Specify access modifier\n", yylineno );
            return false;
        } 
    }
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Coming out of multiple_inherited"<<endl;    
    debugFile.close();
    return true;
}

void perform_lexical_analysis(){
    debugFile.open("output/debug_file.txt",std::ios_base::app);
    debugFile<<"Entering lexical_analyse"<<endl;    
    debugFile.close();
    lexically_analyse();
}
