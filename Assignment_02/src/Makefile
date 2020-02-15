.PHONY=all clean test
.DEFAULT=all

all: a.out

a.out: main.cpp code_gen.cpp name.cpp lex.cpp hashtable.cpp
	g++ -w -g -c main.cpp code_gen.cpp name.cpp lex.cpp hashtable.cpp
	g++ *.o

clean: 
	-rm -f *.o a.out token_stream.txt lex_output.txt symbol_table.txt

test: all
	./a.out code_gen < ./tests/test$(N)
	cat ./tests/test$(N)