# Instructions to run

### 1. Compile the code
```
$ make
```
Executable (a.out) and object files are created.

### 1. Run test cases for Assignment 02
There are 13 tests in ./tests directory, more can be added and run.
```
$ make test N=<test number>
$ make test N=13 	# To run ./tests/test13
```
Output is stored in multiple files in output/ directory.

### 1. (optional) Delete object files and the executable
```
$ make clean
```

### 1. (optional) Run lexer
```
$ make
$ ./a.out < ./tests/test10		# To run lexer on ./tests/test10
```
Three .txt files will be created :

-	lex_output.txt shows both the symbol table and token_stream in a simple, more human readable form
-	symbol_table.txt contains the Symbol Table and token_stream.txt contains the Token Stream.

To view the files in terminal, use
```
$ cat lex_output.txt
$ cat symbol_table.txt
$ cat token_stream.txt
```