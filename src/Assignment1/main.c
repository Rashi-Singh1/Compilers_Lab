#include<stdio.h>
int padding = 0;

main ()
{
	// deleting previous contents of the file
	FILE *fptr;
	fptr=fopen("lex.txt", "w");
	fclose(fptr);
	
	stmt(padding);
}
