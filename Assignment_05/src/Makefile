PRINT_LINE = @printf "\n------------------------------------------\n"

.PHONY: all clean test test_lex
.DEFAULT: main

main: lex.yy.c parser.tab.c datastructures.c helperfunctions.c datastructures.h helperfunctions.h
	g++ -g  lex.yy.c parser.tab.c datastructures.c helperfunctions.c -o main

parser.tab.c parser.tab.h: parser.y datastructures.c helperfunctions.c datastructures.h helperfunctions.h
	bison -d parser.y

lex.yy.c: lex.l parser.tab.h
	flex lex.l

./tests/lex/test_lex: ./tests/lex/test_bench.c parser.tab.h lex.yy.c
	gcc -g --std=gnu11 lex.yy.c parser.tab.h ./tests/lex/test_bench.c -o ./tests/lex/test_lex

test_lex: ./tests/test$(N) ./tests/lex/test_lex
	$(PRINT_LINE)
	@printf "test$(N)"
	$(PRINT_LINE)
	@cat ./tests/test$(N)

	$(PRINT_LINE)
	@printf "./tests/lex/test_lex < ./tests/test$(N)"
	$(PRINT_LINE)
	@./tests/lex/test_lex < ./tests/test$(N)

test: ./tests/test$(N) main
	$(PRINT_LINE)
	@printf "test$(N)"
	$(PRINT_LINE)
	@cat ./tests/test$(N)

	$(PRINT_LINE)
	@printf "./main < ./tests/test$(N)"
	$(PRINT_LINE)
	@./main < ./tests/test$(N)

clean:
	-rm -f main lex.yy.c parser.tab.c parser.tab.h parser.tab.h.gch ./tests/lex/test_lex 
	-rm -f output/intermediate.txt
	-rm -f output/symtab.txt