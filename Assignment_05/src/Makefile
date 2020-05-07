PRINT_LINE = @printf "\n------------------------------------------\n"

.PHONY: all clean test test_lex
.DEFAULT: output/mips.s

output/mips.s: output/intermediate.txt output/symtab.txt pass_2
	./pass_2 < output/intermediate.txt
	cat mips.s

pass_2: pass_2.l pass_2.y symTabParser.h symTabParser.c
	bison -d pass_2.y
	flex pass_2.l
	g++ -o $@ pass_2.tab.c lex.yy.c symTabParser.c

pass_1: pass_1.l pass_1.y datastructures.c helperfunctions.c datastructures.h helperfunctions.h
	bison -d pass_1.y
	flex pass_1.l
	g++ -g -o $@ lex.yy.c pass_1.tab.c datastructures.c helperfunctions.c

./tests/lex/test_lex: ./tests/lex/test_bench.c pass_1.tab.h lex.yy.c
	bison -d pass_1.y
	flex pass_1.l
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

test: ./tests/test$(N) pass_1 pass_2
	$(PRINT_LINE)
	@printf "test$(N)"
	$(PRINT_LINE)
	@cat ./tests/test$(N)

	$(PRINT_LINE)
	@printf "./pass_1 < ./tests/test$(N)"
	$(PRINT_LINE)
	@./pass_1 < ./tests/test$(N)

	$(PRINT_LINE)
	@printf "./pass_2 < ./output/intermediate.txt"
	$(PRINT_LINE)
	@./pass_2 < ./output/intermediate.txt
	@cat output/mips.s
	$(PRINT_LINE)
	@echo "Output is in output/mips.s"
	@echo "Run it in spim"


clean:
	-rm -f pass_1 lex.yy.c pass_1.tab.c pass_1.tab.h pass_1.tab.h.gch ./tests/lex/test_lex 
	-rm -f output/intermediate.txt
	-rm -f output/symtab.txt
	-rm -f pass_2 pass_2.tab.c pass_2.tab.h pass_2.tab.h.gch
	-rm -f output/mips.s