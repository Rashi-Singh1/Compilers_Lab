.PHONY=all clean test
.DEFAULT=all

all: a.out

a.out: main.cpp code_gen.cpp name.cpp lex.cpp hashtable.cpp
	g++ -w -g -c main.cpp code_gen.cpp name.cpp lex.cpp hashtable.cpp
	g++ *.o

clean: 
	-rm -f *.o a.out token_stream.txt lex_output.txt symbol_table.txt debug_file.txt output_file.txt

test: all
	-rm ./output/*.txt
	./a.out $(N) code_gen < ./tests/test$(N)
	@touch output/debug_file.txt
	@touch output/output_file.txt
	@touch output/check output_file.txt
	@touch output/class_def_file.txt
	@touch output/constructor_def_file.txt
	@touch output/int_class_def_file.txt
	@touch output/object_def_file.txt
	@touch output/op_overload_file.txt
	@cat ./tests/test$(N) >> output/debug_file.txt
	@cat ./tests/test$(N) >> output/output_file.txt
	@echo "Please go to the output directory and check output_file.txt 		for a short summary"
	@echo "\t\t\t\t\t    class_def_file.txt 		for detailed info about classes"
	@echo "\t\t\t\t\t    constructor_def_file.txt 	for detailed info about consructors"
	@echo "\t\t\t\t\t    int_class_def_file.txt 	for detailed info about intermediate classes"
	@echo "\t\t\t\t\t    object_def_file.txt 	for detailed info about objects"
	@echo "\t\t\t\t\t    op_overload_file.txt 	for detailed info about operator overloading functions"
	# cat ./tests/test$(N)