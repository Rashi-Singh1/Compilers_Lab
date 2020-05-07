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
$ sudo apt install bison flex spim
$ make test N=<test number>
$ make test N=1 	# To run ./tests/test1
$ spim
(spim) read "output/mips.s"
(spim) run
```
### 1. Compile both passes
```
$ make
```
```pass_1``` executable, ```pass_2``` executable are created.

### 2. Run tests
```
$ make test N=TEST_NO
$ make test N=3             # Run test3
```
Intermediate code and mips code is created in output directory.

### 3. Run output in SPIM
```
$ spim
(spim) read "output/mips.s"
(spim) run
```

### 4. Test lexer only
```
$ make test_lex N=TEST_NO
$ make test_lex N=3			# Lexically analyse test3
```

## Information about files
- **pass_1.l** : Flex input file for pass 1
- **pass_1.y** : Bison input file for pass 1
- **pass_2.l** : Flex input file for pass 2
- **pass_2.y** : Bison input file for pass 2