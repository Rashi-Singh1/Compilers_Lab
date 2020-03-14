PRINT_LINE = @printf "\n------------------------------------------\n"

.PHONY=all clean test
.DEFAULT=all

all: a.out

a.out: main.cpp code_gen.cpp name.cpp hashtable2.cpp lex.l
	flex lex.l
	g++ -w -g -c main.cpp code_gen.cpp name.cpp hashtable2.cpp lex.yy.c
	g++ *.o

clean: 
	-rm -f *.o a.out token_stream.txt lex_output.txt symbol_table.txt debug_file.txt output_file.txt lex.yy.c

test: a.out
	-rm -f ./output/*.txt
	@mkdir -p output
	@touch output/debug_file.txt
	@touch output/output_file.txt
	@touch output/current_test_case.txt
	@touch output/class_def_file.txt
	@touch output/constructor_def_file.txt
	@touch output/int_class_def_file.txt
	@touch output/object_def_file.txt
	@touch output/op_overload_file.txt
	
	$(PRINT_LINE)
	./a.out $(N) code_gen < ./tests/test$(N)
	$(PRINT_LINE)
	@cat ./tests/test$(N) >> output/current_test_case.txt
	@cat ./tests/test$(N) >> output/debug_file.txt
	@echo "Output is in output/ directory."

	$(PRINT_LINE)
	@printf "./tests/test$(N)"
	$(PRINT_LINE)
	@cat -n ./tests/test$(N)	

	$(PRINT_LINE)
	@printf "./output/output_file.txt"
	$(PRINT_LINE)
	@cat ./output/output_file.txt

	$(PRINT_LINE)
	@printf "./output/class_def_file.txt"
	$(PRINT_LINE)
	@cat ./output/class_def_file.txt

	$(PRINT_LINE)
	@printf "./output/int_class_def_file.txt"
	$(PRINT_LINE)
	@cat ./output/int_class_def_file.txt
	
	$(PRINT_LINE)
	@printf "./output/object_def_file.txt"
	$(PRINT_LINE)
	@cat ./output/object_def_file.txt

	$(PRINT_LINE)
	@printf "./output/constructor_def_file.txt"
	$(PRINT_LINE)
	@cat ./output/constructor_def_file.txt
	
	$(PRINT_LINE)
	@printf "./output/op_overload_file.txt"
	$(PRINT_LINE)
	@cat ./output/op_overload_file.txt
	