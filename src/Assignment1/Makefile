all:start
start: main.c code_gen.c name.c lex.c hashtable.c
	gcc -g -c main.c code_gen.c name.c lex.c hashtable.c
	gcc *.o
clean: 
	rm *.o a.out