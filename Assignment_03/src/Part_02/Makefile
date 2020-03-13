PRINT_LINE = @printf "\n------------------------------------------\n"

.PHONY: all clean test
.DEFAULT: main

main: lex.yy.c parser.tab.c
	gcc -g lex.yy.c parser.tab.c -o main

parser.tab.c parser.tab.h: parser.y
	bison -d parser.y

lex.yy.c: lex.l parser.tab.h
	flex lex.l

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
	-rm -f main lex.yy.c parser.tab.c parser.tab.h *.csv
