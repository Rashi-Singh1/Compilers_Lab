#include<stdio.h>
#include<stdlib.h>
#include "lex.h"

//denotes the reg in x85 or x86 for assembly code gen
char  *Names[] = { "t0", "t1", "t2", "t3", "t4", "t5", "t6", "t7","t10", "t11", "t12", "t13", "t14", "t15", "t16", "t17"  };   
char  **Namep  = Names;   
   
//using new reg
//gives error if all reg already in use
char  *newname()   
{   
    if( Namep >= &Names[ sizeof(Names)/sizeof(*Names) ] )   
    {   
        fprintf( stderr, "%d: Expression too complex\n", yylineno );   
        exit( 1 );   
    }   
   
    return( *Namep++ );   
}   

//freeing the use of reg
//gives error if no reg in use
freename(s)   
char    *s;   
{   
    if( Namep > Names )   
    *--Namep = s;   
    else   
    fprintf(stderr, "%d: (Internal error) Name stack underflow\n",   
                                yylineno );   
}   
