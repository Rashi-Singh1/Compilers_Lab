#include <bits/stdc++.h>
using namespace std;

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
void stmt(int padding);
void prog(int padding);
void classDef();
void class_stmts(string id);
void inherited();
void multiple_inherited();
string getID();


