# Use flex to redo Assignment_02

Use flex to count instances of the following in C++ code
- Object declaration
- Class definition
- Constructor definition
- Inherited class definition
- Operator overloaded function definition

## Instructions to run

### 1. Compile the code
```
$ make
```
Executable (a.out) and object files are created.

### 2. Run test cases for Assignment 02
There are 13 tests in ./tests directory, more can be added and run.
```
$ make test N=<test number>
$ make test N=13 	# To run ./tests/test13
```
Output is stored in multiple files in output/ directory.

### 3. (optional) Delete object files and the executable
```
$ make clean
```

### 4. (optional) Run lexer
```
$ make lexer_test N=<test number>
$ make lexer_test N=10		# To run lexer on ./tests/test10
```
Three .txt files will be created :

-	lex_output.txt shows both the symbol table and token_stream in a simple, more human readable form
-	symbol_table.txt contains the Symbol Table and token_stream.txt contains the Token Stream.
