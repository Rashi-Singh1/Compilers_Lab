DEFAULT=all

all:start
start: main.cpp code_gen.cpp name.cpp lex.cpp hashtable.cpp
	g++ -w -g -c main.cpp code_gen.cpp name.cpp lex.cpp hashtable.cpp
	g++ *.o
clean: 
	-rm *.o a.out token_stream.txt lex_output.txt symbol_table.txt