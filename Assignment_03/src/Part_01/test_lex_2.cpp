#include <stdio.h>
#include "lex.h"
#include <iostream>
#include <bits/stdc++.h>
using namespace std;
extern int yylex();
extern int yylineno;
extern char *yytext;

unordered_map<int, string> nope = {{0, "EOI"},
								   {1, "SEMI"},
								   {2, "PLUS"},
								   {3, "MUL"},
								   {4, "LP"},
								   {5, "RP"},
								   {6, "NUM_OR_ID"},
								   {7, "MINUS"},
								   {8, "DIV"},
								   {9, "LESS"},
								   {10, "MORE"},
								   {11, "EQUAL"},
								   {12, "ASSIGN"},
								   {13, "IF"},
								   {14, "THEN"},
								   {15, "WHILE"},
								   {16, "DO"},
								   {17, "START"},
								   {18, "FIN"},
								   {19, "CONST"},
								   {20, "CLASS"},
								   {21, "INT"},
								   {22, "CLP"},
								   {23, "CRP"},
								   {24, "COLON"},
								   {25, "MOD"},
								   {26, "COMMA"},
								   {27, "OPERATOR"},
								   {28, "DATA_TYPE"},
								   {29, "SCOPE"},
								   {-50, "ERR"}};
int main(void)
{
	int ntoken, vtoken;

	ntoken = yylex();
    cout << ntoken <<" "<<nope[ntoken]<< endl;
	ntoken = yylex();
    cout << ntoken << endl;

	return 0;
}
