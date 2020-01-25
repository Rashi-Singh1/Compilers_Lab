#include <stdio.h>
#include "lex.h"
#include <stdlib.h>

char    *factor     ( void );
char    *term       ( void );
char    *expression ( void );

extern char *newname( void       );
char *exp( void       );
char *expA( void       );
char *expM( void       );
char *AN( void       );
extern void freename( char *name );


void  stmt_list_(){
    if(match(SEMI))
    {
        advance();
        stmt();
        stmt_list_();
    }
}

void  stmt_list(){
    stmt();
    stmt_list_();
}


void opt_stmts()
{
    stmt_list();
}

void stmt()
{
        /* stmt->   id:=expr
               |if expr then stmt
               |while expr do stmt
               |begin opt_stmts end
    */  

    if(match(NUM_OR_ID)){
            char *tempvar = newname();
            printf("    %s = _%0.*s\n", tempvar, yyleng, yytext );
                advance();
            if(match(ASSIGN)){
                advance();
                char* tempvar3=exp();
                printf("%s := %s\n",tempvar,tempvar3);  
            }else{
                fprintf( stderr, "%d: Assignment operator expected\n", yylineno );
            }
        }
        else if(match(IF))
        {
            advance();
            char* tempvar2 = exp();
            // advance();
            if(match(THEN))
            {
                advance();
                printf("if\n%s\nthen\n ",tempvar2 );
                stmt();
            }
            else fprintf( stderr, "%d: 'then' expected\n", yylineno );
            
        }
        else if(match(WHILE))
        {
            advance();
            char* tempvar2 = exp();
            // advance();
            if(match(DO))
            {
                advance();
                printf("while\n%s\ndo\n ",tempvar2 );
                stmt();
            }
            else fprintf( stderr, "%d: 'do' expected\n", yylineno );
            
        }
        else if(match(BEGIN))
        {
            advance();
            printf("begin\n");
            opt_stmts();
            // advance();
            if(match(END))
            {
                advance();
                printf("end\n");
            }
            else fprintf( stderr, "%d: 'end' expected\n", yylineno );
            
        }
        else
            fprintf( stderr, "%d: invalid statement\n", yylineno );
}

char Log()
{
    if(match(LESS)) return '<';
    else if(match(MORE)) return '>';
    else if(match(EQUAL)) return '=';
    else return '@';
}


char Add()
{
    if(match(PLUS)) return '+';
    else if(match(MINUS)) return '-';
    else return '@';
}

char Mul()
{
    if(match(MUL)) return '*';
    else if(match(DIV)) return '/';
    else return '@';
}


char    *AN()
{
    char *tempvar;

    if( match(NUM_OR_ID) )
    {
    /* Print the assignment instruction. The %0.*s conversion is a form of
     * %X.Ys, where X is the field width and Y is the maximum number of
     * characters that will be printed (even if the string is longer). I'm
     * using the %0.*s to print the string because it's not \0 terminated.
     * The field has a default width of 0, but it will grow the size needed
     * to print the string. The ".*" tells printf() to take the maximum-
     * number-of-characters count from the next argument (yyleng).
     */

        printf("    %s = _%0.*s\n", tempvar = newname(), yyleng, yytext );
        advance();
    }
    else
    fprintf( stderr, "%d: Number or identifier expected\n", yylineno );

    return tempvar;
}

char    *exp()
{
    /* exp -> expA exp_
        exp_ -> log expA exp_ |  epsilon
     */

    char  *tempvar, *tempvar2;

    tempvar = expA();
    char cur;
    while((cur=Log())!='@')
    {
        advance();
        tempvar2 = expA();
        printf("  %s =   %s %c %s\n", tempvar, tempvar, cur, tempvar2 );
        freename( tempvar2 );
    }

    return tempvar;
}


char    *expA()
{
    /* expA -> expM expA_
        expA_ -> PLUS expM expA_ |  epsilon
     */

    // char  *tempvar, *tempvar2;
    char  *tempvar, *tempvar2;

    tempvar = expM();
    char cur;
    while((cur=Add())!='@')
    {
        advance();
        tempvar2 = expM();
        printf("  %s =   %s %c %s\n", tempvar, tempvar, cur, tempvar2 );
        freename( tempvar2 );
    }

    return tempvar;
}

char    *expM()
{
    /* expM -> AN expM_
        expM_ -> mul AN expM_ |  epsilon
     */

    // char  *tempvar, *tempvar2;
    char  *tempvar, *tempvar2;

    tempvar = AN();
    char cur;
    while((cur=Mul())!='@')
    {
        advance();
        tempvar2 = AN();
        printf("  %s =   %s %c %s\n", tempvar, tempvar, cur, tempvar2 );
        freename( tempvar2 );
    }

    return tempvar;
}