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

statements()
{
    // /*  statements -> expression SEMI  |  expression SEMI statements  */

    // char *tempvar;

    // while( !match(EOI) )
    // {
    //     tempvar = expression();

    //     if( match( SEMI ) )
    //         advance();
    //     else
    //         fprintf( stderr, "%d: Inserting missing semicolon\n", yylineno );

    //     freename( tempvar );
    // }

     /*  statements -> expression SEMI  |  expression SEMI statements  */

    char *tempvar;

        tempvar = exp();
        freename( tempvar );
}

char    *expression()
{
    /* expression -> term expression'
     * expression' -> PLUS term expression' |  epsilon
     */

    char  *tempvar, *tempvar2;

    tempvar = term();
    while( match( PLUS ) )
    {
        advance();
        tempvar2 = term();
        printf("    %s += %s\n", tempvar, tempvar2 );
        freename( tempvar2 );
    }

    return tempvar;
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

        printf("    %s = %0.*s\n", tempvar = newname(), yyleng, yytext );
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

    while( match( LESS ) || match( MORE) || match(EQUAL))
    {
        char cur = Log();
        if(cur == '@') {
            fprintf( stderr, "%d: Logical operator expected\n", yylineno );
            exit(1);
        }
        advance();
        tempvar2 = expA();
        printf("    %s %c %s\n", tempvar,cur, tempvar2 );
        freename( tempvar2 );
    }

    return tempvar;
}


char    *expA()
{
    /* expA -> expM expA_
        expA_ -> PLUS expM expA_ |  epsilon
     */

    char  *tempvar, *tempvar2;

    tempvar = expM();

    while( match( PLUS ) || match( MINUS))
    {
        char cur = Add();
        if(cur == '@') {
            fprintf( stderr, "%d: Arithmetic_1 operator expected\n", yylineno );
            exit(1);
        }
        advance();
        tempvar2 = expM();
        printf("    %s %c %s\n", tempvar, cur,tempvar2 );
        freename( tempvar2 );
    }

    return tempvar;
}

char    *expM()
{
    /* expM -> AN expM_
        expM_ -> mul AN expM_ |  epsilon
     */

    char  *tempvar, *tempvar2;

    tempvar = AN();

    while( match( MUL ) || match( DIV))
    {
        char cur = Mul();
        if(cur == '@') {
            fprintf( stderr, "%d: Arithmetic_2 operator expected\n", yylineno );
            exit(1);
        }
        advance();
        tempvar2 = AN();
        printf("    %s %c %s\n", tempvar, cur,tempvar2 );
        freename( tempvar2 );
    }

    return tempvar;
}


char    *term()
{
    char  *tempvar, *tempvar2 ;

    tempvar = factor();
    while( match( MUL ) )
    {
        advance();
        tempvar2 = factor();
        printf("    %s *= %s\n", tempvar, tempvar2 );
        freename( tempvar2 );
    }

    return tempvar;
}

char    *factor()
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

        printf("    %s = %0.*s\n", tempvar = newname(), yyleng, yytext );
        advance();
    }
    else if( match(LP) )
    {
        advance();
        tempvar = expression();
        if( match(RP) )
            advance();
        else
            fprintf(stderr, "%d: Mismatched parenthesis\n", yylineno );
    }
    else
	fprintf( stderr, "%d: Number or identifier expected\n", yylineno );

    return tempvar;
}



