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
bool prog();
bool prog2();
bool classDef();
bool class_stmt_list(string id);
bool inherited();
bool multiple_inherited();
string getID();
bool class_stmt(string id);
bool class_stmt_list(string id);
bool  class_stmt_list_(string id);
bool nextFUNC(string id);
bool operator_overload(string id);
bool constructor();
bool opt_parameter();
bool stmt_list_();
bool stmt_list();
bool parameter_list();
bool object_def(string id);
bool more_def(string id);
bool ending(string id);
bool normal_function();



