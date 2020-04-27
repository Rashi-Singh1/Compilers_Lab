# Execute language subset of Relational Algebra on CSV files

Use flex, bison to analyse, execute the following language subset of Relational Algebra on CSV files
- ```SELECT <condition> (Table_Name)```
- ```PROJECT <attribute_list> (Table_Name)```
- ```(Table_Name_1) CARTESIAN_PRODUCT (Table_Name_2)```
- ```(Table_Name_1) EQUI_JOIN <condition> (Table_Name_2)```
- ```<condition>``` may be simple or compound condition

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

## Information about files
- **lex.l** : Flex input file
- **parser.y** : Bison input file