#include <cstdio>
#include "lex.h"
#include "code_gen.h"
#include <cstdlib>

using namespace std;

void prog(){
    //TODO : call as a while loop
       if(match(NUM_OR_ID)){
           //
        }
        else if(match(CLASS))
        {
            classDef();
        }
        else if(match(INT))
        {
            // advance();
        }
}


void prog2(){
       if(match(NUM_OR_ID)){
           //
        }
        else if(match(CLASS))
        {
            classDef();
        }

}

//to get the token from yytext
string getID()
{
    char* temp=(char*)malloc(sizeof(char)*(yyleng+1));
    for(int i=0;i<yyleng;i++){
        *(temp+i)=*(yytext+i);
    }
    *(temp+yyleng)='\0';
    string id(temp);
    return id;
}

//classDef -> id inherited {class_stmts};
void classDef()
{
    advance();
    if(match(NUM_OR_ID))
    {
        string id = getID();
        cout<<id<<endl;
        advance();
        inherited();
        if(match(CLP))
        {
            advance();
            class_stmts(id);
            if(match(CRP))
            {
                advance();
                if(match(SEMI)) advance();
                else fprintf( stderr, "%d: Missing semicolon \n", yylineno );

            }
            else fprintf( stderr, "%d: Missing parenthesis } \n", yylineno );
        }
        else fprintf( stderr, "%d: Missing parenthesis { \n", yylineno );
        
    }
    else fprintf( stderr, "%d: Specify the class name\n", yylineno );
}

//classDef -> epsilon | class_stmt_list(id)
void class_stmts(string id)
{
    //TODO: advance after matching
    class_stmt_list(id);
}


void  class_stmt_list_(string id)
{
    if(match(SEMI))
    {
        advance();
        class_stmt(id);
        class_stmt_list_(id);
    }
}

void  class_stmt_list(string id)
{
    class_stmt(id);
    class_stmt_list_(id);
}

void class_stmt(string id)
{
    string curID = getID();
    if(curID == id)
    {
        advance();
        nextFUNC();
    }
    else prog2();
}

void nextFUNC()
{
    string curID = getID();
    if(match(LP))
    {
        advance();
        constructor();
    }
    else if(curID == "operator")
    {
        advance();
        operator_overload();
    }
    else fprintf( stderr, "%d: Extra keyword\n", yylineno );
}

void constructor()
{
    parameter_list();
    if(match(RP))
    {
        advance();
        if(match(CLP))
        {
            advance();
            stmt_list();
            if(match(CRP))
            {
                advance();
                if(match(SEMI)) advance();
                else fprintf( stderr, "%d: Missing semicolon \n", yylineno );

            }
            else fprintf( stderr, "%d: Missing parenthesis } \n", yylineno );
        }
        else fprintf( stderr, "%d: Missing parenthesis { \n", yylineno );
    }
    else fprintf( stderr, "%d: Missing right bracket\n", yylineno );
    

}

void parameter_list()
{
    if(match(DATA_TYPE))
    {
        advance();
        if(match(NUM_OR_ID))
        {
            advance();
            opt_parameter();
        }
        else fprintf( stderr, "%d: Missing parameter name\n", yylineno );
    }
}

void opt_parameter(){
    if(match(COMMA))
    {
        advance();
        if(match(DATA_TYPE))
        {
            advance();
            if(match(NUM_OR_ID))
            {
                advance();
                opt_parameter();
            }
            else fprintf( stderr, "%d: Missing parameter name\n", yylineno );
        }
        else fprintf( stderr, "%d: Trailing comma\n", yylineno );
    }
}

void stmt_list()
{
    prog2();
    stmt_list_();
}

void stmt_list_()
{
    if(match(SEMI))
    {
        advance();
        prog2();
        stmt_list_();
    }
}

void operator_overload()
{

}

void inherited()
{
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
                multiple_inherited();
            }
            else fprintf( stderr, "%d: Specify super class name\n", yylineno );
        }
        else fprintf( stderr, "%d: Specify access modifier\n", yylineno );
    }
}

void multiple_inherited()
{
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
                multiple_inherited();
            }
            else fprintf( stderr, "%d: Specify super class name\n", yylineno );
        }
        else fprintf( stderr, "%d: Specify access modifier\n", yylineno );
    }
}

void perform_lexical_analysis(){
    lexically_analyse();
}

// /*lexical analysis done*/
// void  init_stmt_list_(int padding){
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
//             else fprintf( stderr, "%d: 'then' expected\n", yylineno );
            
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
//             else fprintf( stderr, "%d: 'do' expected\n", yylineno );            
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
//             else fprintf( stderr, "%d: 'end' expected\n", yylineno );
            
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