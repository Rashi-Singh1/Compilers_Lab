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
void prog();
void prog2();
void classDef();
void class_stmts(string id);
void inherited();
void multiple_inherited();
string getID();
void class_stmt(string id);
void class_stmts(string id);
void  class_stmt_list_(string id);
void  class_stmt_list(string id);
void nextFUNC();
void operator_overload();
void constructor();
void opt_parameter();
void stmt_list_();
void stmt_list();
void parameter_list();





