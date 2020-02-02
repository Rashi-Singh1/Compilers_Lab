all:start
start: main.c code_gen.c name.c lex.c hashtable.c
	gcc -w -g -c main.c code_gen.c name.c lex.c hashtable.c
	gcc *.o
clean: 
	rm *.o a.out
dOut:
	rm lex_output.txt token_stream.txt symbol_table.txt