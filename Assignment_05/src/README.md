# Compile language subset of C to MIPS code

Use flex, bison to lexically analyse, parse, sematically analyse, generate intermediate code in 3 address code Quadruple format and generate MIPS output code (runnable on SPIM simulator).

Language subset of C to target:
- ```int``` and ```float``` variable declarations
- Arithmetic, logical and relational expressions with short circuit evaluation
- Function calls and function definitions
- Conditional expressions - ```if-else``` and ```switch-case``` statements
- Loops - ```for``` and ```while```

## Instructions to run
```
$ sudo apt install bison flex
$ make test N=<test number>
$ make test N=13 	# To run ./tests/test13
```
### 1. Compile parser
```
$ make
```
```main``` executable, ```lex.yy.c``` flex output, ```parser.tab.c``` and ```parser.tab.h``` bison outputs are created.

### 2. Run tests
```
$ make test N=TEST_NO
$ make test N=3             # Run test3
```

### 3. Test lexer only
```
$ make test_lex N=TEST_NO
$ make test_lex N=3			# Lexically analyse test3
```

## Information about files
- **lex.l** : Flex input file
- **parser.y** : Bison input file