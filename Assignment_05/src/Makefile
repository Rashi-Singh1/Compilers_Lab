PRINT_LINE = @printf "\n------------------------------------------\n"

.PHONY: all clean test test_lex
.DEFAULT: main

main: lex.yy.c pass_1.tab.c datastructures.c helperfunctions.c datastructures.h helperfunctions.h
	g++ -g  lex.yy.c pass_1.tab.c datastructures.c helperfunctions.c -o main

pass_1.tab.c pass_1.tab.h: pass_1.y datastructures.c helperfunctions.c datastructures.h helperfunctions.h
	bison -d pass_1.y

lex.yy.c: pass_1.l pass_1.tab.h
	flex pass_1.l

./tests/lex/test_lex: ./tests/lex/test_bench.c pass_1.tab.h lex.yy.c
	gcc -g --std=gnu11 lex.yy.c pass_1.tab.h ./tests/lex/test_bench.c -o ./tests/lex/test_lex

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
	-rm -f main lex.yy.c pass_1.tab.c pass_1.tab.h pass_1.tab.h.gch ./tests/lex/test_lex 
	-rm -f output/intermediate.txt
	-rm -f output/symtab.txt