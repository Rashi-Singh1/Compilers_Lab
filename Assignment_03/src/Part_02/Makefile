LINE = ------------------------------------------

.PHONY: all clean test
.DEFAULT: main

main: lex.yy.c parser.tab.c++
	g++ lex.yy.c parser.tab.c++ -o main

parser.tab.c++ parser.tab.h++: parser.y++
	bison -d parser.y++

lex.yy.c: lex.l parser.tab.h++
	flex lex.l

test: ./tests/test$(N) main
	@printf "\n$(LINE)\n"
	@printf "test$(N)"
	@printf "\n$(LINE)\n"
	@cat ./tests/test$(N)

	@printf "\n$(LINE)\n"
	@printf "./main < ./tests/test$(N)"
	@printf "\n$(LINE)\n"
	@./main < ./tests/test$(N)

clean:
	-rm -f main lex.yy.c parser.tab.c++ parser.tab.h++