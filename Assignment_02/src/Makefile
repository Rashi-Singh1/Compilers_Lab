all:start
start: main.cpp code_gen.cpp name.cpp lex.cpp hashtable.cpp
	g++ -w -g -c main.cpp code_gen.cpp name.cpp lex.cpp hashtable.cpp
	g++ *.o
clean: 
	rm *.o a.out
dOut:
	rm lex_output.txt token_stream.txt symbol_table.txt