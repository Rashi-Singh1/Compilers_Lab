.PHONY=all
.DEFAULT=all

all: a.out

a.out: lex.l parser.y++
	bison -d parser.y++
	flex lex.l
	g++ lex.yy.c parser.tab.c++ -o main