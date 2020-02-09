
#define EOI		    0	/* End of input			*/
#define SEMI	    1	/* ; 				*/
#define PLUS 	    2	/* + 				*/
#define MUL		    3	/* * 				*/
#define LP		    4	/* (				*/
#define RP		    5	/* )	            */		
#define NUM_OR_ID	6	/* Decimal Number or Identifier */
#define MINUS 		7
#define DIV		    8
#define LESS		9
#define MORE		10
#define EQUAL		11
#define ASSIGN		12
#define IF		    13
#define THEN		14
#define WHILE		15
#define DO		    16
#define BEGIN		17
#define END		    18
#define CONST       19
#define CLASS       20
#define INT         21
#define CLP		    22	/* {				*/
#define CRP		    23	/* }                */
#define COLON	    24	/* : 				*/
#define MODE        25
#define COMMA       26
#define ERR         -50

                        
extern char *yytext;		/* in lex.c			*/
extern int yyleng;
extern int yylineno;

int isKeyWord(int);
int isOperator(int);
int isIdentifier(int);
int isConst(int);
int isSemi(int);
char * token_class(int);
int match(int token);
void advance(void);
void lexically_analyse(void);

