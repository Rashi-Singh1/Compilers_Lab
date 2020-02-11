#include <cstdio>
#include "lex.h"
#include "code_gen.h"
#include <cstdlib>
#include <bits/stdc++.h>

using namespace std;

unordered_set<string> class_names;
int cntClass = 0, cntObject = 0, cntIClass = 0, cntConstructor = 0, cntOverload = 0;

bool prog(){
    //TODO : call as a while loop
    cout<<"Entering prog"<<endl;
    advance();
    string id = getID();
    if(match(CLASS))
    {
        advance();
        if(classDef()) cntClass++;
        else return false;
    }
    else if(match(NUM_OR_ID) && class_names.count(id))
    {
        advance();
        if(!object_def(id)) return false;
        if(!more_def(id)) return false;
        cntObject++; 
    }
    // else if(match(INT))
    // {
    //     // advance();
    // }
    cout<<"Coming out of prog"<<endl;
    cout<<"Number of Class Definitions: "<<cntClass<<endl;
    cout<<"Number of Inherited Class Definitions: "<<cntIClass<<endl;
    cout<<"Number of Object Declarations: "<<cntObject<<endl;
    cout<<"Number of Constructors: "<<cntConstructor<<endl;
    cout<<"Number of Operator Overloaded Functions: "<<cntOverload<<endl;
    return true;
}

bool object_def(string id)
{
    cout<<"Entering object_def"<<endl;
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
    cout<<"Coming out of object_def"<<endl;
    return true;

}

bool more_def(string id)
{
    cout<<"Entering more_def"<<endl;
    if(match(SEMI))
    {
        advance();
    }
    else if(match(COMMA))
    {
        advance();
        cntObject++;
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
    cout<<"Coming out of more_def"<<endl;
    return true;
   
}

bool ending(string id)
{
    cout<<"Entering ending"<<endl;
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
    }
    cout<<"Coming out of ending"<<endl;
    return true;
}

bool prog2(){
    cout<<"Entering prog2"<<endl;
    string id = getID();
    cout << " class name **********************************************************************\n";
    for(auto x : class_names) cout << x << " ";
    cout << '\n';
    if(match(CLASS))
    {
        advance();
        if(!classDef()) return false;
        cntClass++;
        cntIClass++;
    }
    else if(match(NUM_OR_ID) && class_names.count(id))
    {
        advance();
        if(!object_def(id)) return false;
        cntObject++;
    }
    cout<<"Coming out of prog2"<<endl;
    return true;
}

//to get the token from yytext
string getID()
{
    cout<<"Entering getID"<<endl;
    char* temp=(char*)malloc(sizeof(char)*(yyleng+1));
    for(int i=0;i<yyleng;i++){
        *(temp+i)=*(yytext+i);
    }
    *(temp+yyleng)='\0';
    string id(temp);
    cout<<"id : "<<id<<endl;
    return id;
}

//classDef -> id inherited {class_stmt_list};
bool classDef()
{
    cout<<"Entering classDef"<<endl;
    // advance();
    if(match(NUM_OR_ID))
    {
        string id = getID();
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
    cout<<"Coming out of classDef"<<endl;
    return true;
}

//classDef -> epsilon | class_stmt_list(id)
bool class_stmt_list(string id)
{
     cout<<"Entering class_stmt_list"<<endl;
    if(!class_stmt(id)) return false;
    if(!class_stmt_list_(id)) return false;
    cout<<"Coming out of class_stmt_list"<<endl;
    return true;
}


bool  class_stmt_list_(string id)
{
    cout<<"Entering class_stmt_list_"<<endl;
    string curid = getID();
    cout <<" curid in class stmt list : " << curid << '\n';
    if(curid != "}")
    {
        if(!class_stmt(id)) return false;
        if(!class_stmt_list_(id)) return false;
    }
    cout<<"Coming out of class_stmt_list_"<<endl;
    return true;
}


bool class_stmt(string id)
{
    cout<<"Entering class_stmt"<<endl;
    string curID = getID();
    // cout<<"id passed in class_stmt********************************************"<<id<<endl;

    if(curID == id)
    {
        advance();
        if(!nextFUNC(id)) return false;
    }else{
        // advance();
        if(!prog2())return false;
    }
    cout<<"Coming out of class_stmt"<<endl;
    return true;

}

bool nextFUNC(string id)
{
    cout<<"Entering nextFunc"<<endl;
    string curID = getID();
    if(match(LP))
    {
        advance();
        if(!constructor()) return false;
        cntConstructor++;
    }
    else if(curID == "operator")
    {
        advance();
        if(!operator_overload(id)) return false;
    }
    

    cout<<"Coming out of nextFunc"<<endl;
    return true;
}

bool constructor()
{
    cout<<"Entering constructor"<<endl;
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

cout<<"Coming out of constructor"<<endl;
    return true;
    

}

bool parameter_list()
{
    cout<<"Entering parameter_list"<<endl;
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
    cout<<"Coming out of parameter_list"<<endl;
    return true;
}

bool opt_parameter(){
    cout<<"Entering opt_parameter"<<endl;
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
    cout<<"Coming out of opt_parameter"<<endl;
    return true;
}

bool stmt_list()
{
    cout<<"Entering stmt_list"<<endl;
    if(!prog2()) return false;
    if(!stmt_list_()) return false;

    cout<<"Coming out of stmt_list"<<endl;
    return true;
}

bool stmt_list_()
{
    cout<<"Entering stmt_list_"<<endl;
    if(match(SEMI))
    {
        advance();
        if(!prog2()) return false;
        if(!stmt_list_()) return false;
    }
    cout<<"Coming out of stmt_list_"<<endl;
    return true;
}

bool is_overloaded_operator(){
    cout<<"Entering is_overload_operator"<<endl;
    if(match(PLUS)|| match(MINUS) || match(MUL) || match(DIV) || match(LESS )|| match(COLON) || match(COMMA) || match(MORE )|| match(EQUAL) || match(ASSIGN))
    {
        return true;
    }
    return false;
}

bool operator_overload(string id)
{
    cout<<"Entering operator_overload"<<endl;
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
    cntOverload++;
    cout<<"Coming out of operator_overload"<<endl;
    return true;
}

bool inherited()
{
    cout<<"Entering inherited"<<endl;
    if(match(COLON))
    {
        advance();
        if(match(MODE))
        {
            advance();
            //TODO : hash map vala check
            if(match(NUM_OR_ID))
            {
                string id = getID();
                advance();
                if(multiple_inherited()) {
                    cntIClass++;
                    cntClass++;
                }else{
                    return false;
                }
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

cout<<"Coming out of inherited"<<endl;
    return true;
}

bool multiple_inherited()
{
    cout<<"Entering multiple_inherited"<<endl;
    if(match(COMMA))
    {
        advance();
        if(match(MODE))
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
    cout<<"Coming out of multiple_inherited"<<endl;
    return true;
}

void perform_lexical_analysis(){
    cout<<"Entering lexical_analyse"<<endl;
    lexically_analyse();
}

// /*lexical analysis done*/
// bool  init_stmt_list_(int padding){
//     if(match(SEMI))
//     {
//         advance();
//         init_stmt(padding);
//         init_stmt_list_(padding);
//     }
// }

// void  init_stmt_list(int padding){
//     init_stmt(padding );
//     init_stmt_list_(padding);
// }


// void opt_init_stmts(int padding)
// {
//     init_stmt_list(padding);
// }
// void init_stmt(int padding)
// {
//         /* init_stmt->   id:=expr
//                |if expr then init_stmt
//                |while expr do init_stmt
//                |begin opt_init_stmts end
//     */  
//     if(match(NUM_OR_ID)){
//             char *tempvar = newname();
//             for(int i = 0;i < padding;i++) printf("\t");
//             printf("%s = _%0.*s\n", tempvar, yyleng, yytext );
//                 advance();
//             if(match(ASSIGN)){
//                 advance();
//                 char* tempvar3=exp(padding);
//                 for(int i = 0;i < padding;i++) printf("\t");
//                 printf("%s := %s\n",tempvar,tempvar3);  
//             }else{
//                 fprintf( stderr, "%d: Assignment operator expected\n", yylineno );
//             }
//         }
//         else if(match(IF))
//         {
//             advance();
//             for(int i = 0;i < padding;i++) printf("\t");
//             printf("\n");
//             char* tempvar2 = exp(padding);
//             printf("\n");
//             // advance();
//             if(match(THEN))
//             {
//                 advance();
//                 for(int i = 0;i < padding;i++) printf("\t");
//                 printf("if\n");
//                 for(int i = 0;i <= padding;i++) printf("\t");
//                 printf("%s\n",tempvar2);
//                 for(int i = 0;i < padding;i++) printf("\t");
//                 printf("then\n " );
//                 init_stmt(padding + 1);
//             }
//             else{
//     fprintf( stderr, "%d: 'then' expected\n", yylineno );
//     return false;
// } 
            
//         }
//         else if(match(WHILE))
//         {
//             advance();
//             for(int i = 0;i < padding;i++) printf("\t");
//             printf("\n");
//             char* tempvar2 = exp(padding);
//             printf("\n");
//             // advance();
//             if(match(DO))
//             {
//                 advance();
//                 for(int i = 0;i < padding;i++) printf("\t");
//                 printf("while\n");
//                 for(int i = 0;i <= padding;i++) printf("\t");
//                 printf("%s\n",tempvar2);
//                 for(int i = 0;i < padding;i++) printf("\t");
//                 printf("do\n " );
//                 init_stmt(padding + 1);
//             }
//             else{
//     fprintf( stderr, "%d: 'do' expected\n", yylineno );            
//     return false;
// } 
//         }
//         else if(match(BEGIN))
//         {
//             advance();
//             for(int i = 0;i < padding;i++) printf("\t");    
//             printf("begin\n");
//             opt_init_stmts(padding + 1);
//             // advance();
//             if(match(END))
//             {
//                 advance();
//                 for(int i = 0;i < padding;i++) printf("\t");
//                 printf("end\n");
//             }
//             else{
//     fprintf( stderr, "%d: 'end' expected\n", yylineno );
//     return false;
// } 
            
//         }
//         else
//             fprintf( stderr, "%d: invalid statement\n", yylineno );
// }

// char Log()
// {
//     if(match(LESS)) return '<';
//     else if(match(MORE)) return '>';
//     else if(match(EQUAL)) return '=';
//     else return '@';
// }


// char Add()
// {
//     if(match(PLUS)) return '+';
//     else if(match(MINUS)) return '-';
//     else return '@';
// }

// char Mul()
// {
//     if(match(MUL)) return '*';
//     else if(match(DIV)) return '/';
//     else return '@';
// }


// char    *AN(int padding)
// {
//     char *tempvar;
//     if( match(NUM_OR_ID) )
//     {
//     /* Print the assignment instruction. The %0.*s conversion is a form of
//      * %X.Ys, where X is the field width and Y is the maximum number of
//      * characters that will be printed (even if the string is longer). I'm
//      * using the %0.*s to print the string because it's not \0 terminated.
//      * The field has a default width of 0, but it will grow the size needed
//      * to print the string. The ".*" tells printf() to take the maximum-
//      * number-of-characters count from the next argument (yyleng).
//      */
//         for(int i = 0;i < padding;i++) printf("\t");
//         printf("%s = _%0.*s\n", tempvar = newname(), yyleng, yytext );
//         advance();
//     }
//     else
//     fprintf( stderr, "%d: Number or identifier expected\n", yylineno );

//     return tempvar;
// }

// char    *exp(int padding)
// {
//     /* exp -> expA exp_
//         exp_ -> log expA exp_ |  epsilon
//      */

//     char  *tempvar, *tempvar2;
//     tempvar = expA(padding);
//     char cur;
//     while((cur=Log())!='@')
//     {
//         advance();
//         tempvar2 = expA(padding);
//         for(int i = 0;i < padding;i++) printf("\t");
//         printf("%s =   %s %c %s\n", tempvar, tempvar, cur, tempvar2 );
//         freename( tempvar2 );
//     }

//     return tempvar;
// }


// char    *expA(int padding)
// {
//     /* expA -> expM expA_
//         expA_ -> PLUS expM expA_ |  epsilon
//      */

//     // char  *tempvar, *tempvar2;
//     char  *tempvar, *tempvar2;

//     tempvar = expM(padding);
//     char cur;
//     while((cur=Add())!='@')
//     {
//         advance();
//         tempvar2 = expM(padding);
//         for(int i = 0;i < padding;i++) printf("\t");
//         printf("%s =   %s %c %s\n", tempvar, tempvar, cur, tempvar2 );
//         freename( tempvar2 );
//     }

//     return tempvar;
// }

// char    *expM(int padding)
// {
//     /* expM -> AN expM_
//         expM_ -> mul AN expM_ |  epsilon
//      */

//     // char  *tempvar, *tempvar2;
//     char  *tempvar, *tempvar2;

//     tempvar = AN(padding);
//     char cur;
//     while((cur=Mul())!='@')
//     {
//         advance();
//         tempvar2 = AN(padding);
//         for(int i = 0;i < padding;i++) printf("\t");
//         printf("%s =   %s %c %s\n", tempvar, tempvar, cur, tempvar2 );
//         freename( tempvar2 );
//     }

//     return tempvar;
// }