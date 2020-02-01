#include <stdio.h>
#include "lex.h"
#include <stdlib.h>

char    *factor     ( void );
char    *term       ( void );
char    *expression ( void );
extern char *newname( void       );
char *exp( int padding    );
char *expA( int padding       );
char *expM( int padding       );
char *AN( int padding       );
extern void freename( char *name );

/*performed lexical analysis*/
void perform_lexical_analysis(void);

void perform_lexical_analysis(){
    lexically_analyse();
}

/*lexical analysis done*/
void  stmt_list_(int padding){
    if(match(SEMI))
    {
        advance(padding);
        stmt(padding);
        stmt_list_(padding);
    }
}

void  stmt_list(int padding){
    stmt(padding );
    stmt_list_(padding);
}


void opt_stmts(int padding)
{
    stmt_list(padding);
}
void stmt(int padding)
{
        /* stmt->   id:=expr
               |if expr then stmt
               |while expr do stmt
               |begin opt_stmts end
    */  
    if(match(NUM_OR_ID)){
          printf("matched num or id\n");
            char *tempvar = newname();
            for(int i = 0;i < padding;i++) printf("\t");
            printf("%s = _%0.*s\n", tempvar, yyleng, yytext );
                advance();
            if(match(ASSIGN)){
                advance();
                char* tempvar3=exp(padding);
                for(int i = 0;i < padding;i++) printf("\t");
                printf("%s := %s\n",tempvar,tempvar3);  
            }else{
                fprintf( stderr, "%d: Assignment operator expected\n", yylineno );
            }
        }
        else if(match(IF))
        {
            advance();
            for(int i = 0;i < padding;i++) printf("\t");
            printf("\n");
            char* tempvar2 = exp(padding);
            printf("\n");
            // advance();
            if(match(THEN))
            {
                advance();
                for(int i = 0;i < padding;i++) printf("\t");
                printf("if\n");
                for(int i = 0;i <= padding;i++) printf("\t");
                printf("%s\n",tempvar2);
                for(int i = 0;i < padding;i++) printf("\t");
                printf("then\n " );
                stmt(padding + 1);
            }
            else fprintf( stderr, "%d: 'then' expected\n", yylineno );
            
        }
        else if(match(WHILE))
        {
            advance();
            for(int i = 0;i < padding;i++) printf("\t");
            printf("\n");
            char* tempvar2 = exp(padding);
            printf("\n");
            // advance();
            if(match(DO))
            {
                advance();
                for(int i = 0;i < padding;i++) printf("\t");
                printf("while\n");
                for(int i = 0;i <= padding;i++) printf("\t");
                printf("%s\n",tempvar2);
                for(int i = 0;i < padding;i++) printf("\t");
                printf("do\n " );
                stmt(padding + 1);
            }
            else fprintf( stderr, "%d: 'do' expected\n", yylineno );            
        }
        else if(match(BEGIN))
        {
            advance();
            for(int i = 0;i < padding;i++) printf("\t");    
            printf("begin\n");
            opt_stmts(padding + 1);
            // advance();
            if(match(END))
            {
                advance(padding + 1);
                for(int i = 0;i < padding;i++) printf("\t");
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


char    *AN(int padding)
{
    char *tempvar;
    printf("yytext = _%0.*s\n", yyleng, yytext );
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
        for(int i = 0;i < padding;i++) printf("\t");
        printf("%s = _%0.*s\n", tempvar = newname(), yyleng, yytext );
        advance();
    }
    else
    fprintf( stderr, "%d: Number or identifier expected\n", yylineno );

    return tempvar;
}

char    *exp(int padding)
{
    /* exp -> expA exp_
        exp_ -> log expA exp_ |  epsilon
     */

    char  *tempvar, *tempvar2;
    tempvar = expA(padding);
    char cur;
    while((cur=Log())!='@')
    {
        advance();
        tempvar2 = expA(padding);
        for(int i = 0;i < padding;i++) printf("\t");
        printf("%s =   %s %c %s\n", tempvar, tempvar, cur, tempvar2 );
        freename( tempvar2 );
    }

    return tempvar;
}


char    *expA(int padding)
{
    /* expA -> expM expA_
        expA_ -> PLUS expM expA_ |  epsilon
     */

    // char  *tempvar, *tempvar2;
    char  *tempvar, *tempvar2;

    tempvar = expM(padding);
    char cur;
    while((cur=Add())!='@')
    {
        advance();
        tempvar2 = expM(padding);
        for(int i = 0;i < padding;i++) printf("\t");
        printf("%s =   %s %c %s\n", tempvar, tempvar, cur, tempvar2 );
        freename( tempvar2 );
    }

    return tempvar;
}

char    *expM(int padding)
{
    /* expM -> AN expM_
        expM_ -> mul AN expM_ |  epsilon
     */

    // char  *tempvar, *tempvar2;
    char  *tempvar, *tempvar2;

    tempvar = AN(padding);
    char cur;
    while((cur=Mul())!='@')
    {
        advance();
        tempvar2 = AN(padding);
        for(int i = 0;i < padding;i++) printf("\t");
        printf("%s =   %s %c %s\n", tempvar, tempvar, cur, tempvar2 );
        freename( tempvar2 );
    }

    return tempvar;
}