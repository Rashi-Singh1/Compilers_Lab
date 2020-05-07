%{
#pragma GCC diagnostic ignored "-Wwrite-strings"
#include <iostream>
#include <vector>
#include <stack>
#include <stdio.h>
#include <fstream>
#include "pass_2_helper.h"
using namespace std;

#define INTSIZE 4
#define FLOATSIZE 4

extern int yylex();
extern int yyparse();
extern int yylineno;
extern char* yytext;
extern int yyleng;
void yyerror(char* s);

FILE *output_file;
string current_function_name;
int param_offset;
string return_value;
int floatLabel = 0;
vector<function_entry> functionList;
vector<sym_tab_entry> global_vars;

void sw_all_registers(int frameSize);
void lw_all_registers(int frameSize);  
bool is_global_var;  
%}

%union {
    int intval;
    float floatval;
    char *idName;
}

%token FUNCTION BEG END IF GOTO PARAM REFPARAM CALL LSB RSB RETURN NEWLINE
%token CONVERTINT CONVERTFLOAT LP RP
%token USERVAR REGINT REGFLOAT LABEL NUMINT NUMFLOAT PRINT READ
%token COMMA COLON SEMI
%token PLUS MINUS MUL DIV MOD
%token EQUAL NOTEQUAL OR AND LT GT LE GE ASSIGN NEG

%type <idName> NUMFLOAT NUMINT REGINT REGFLOAT LABEL USERVAR 

%%

STMT_LIST: STMT_LIST STMT NEWLINE
    | STMT NEWLINE
;

STMT: ASG
    | FLOATASG
    | GOTO LABEL
    {
        fprintf(output_file, "j %s\n", $2);
    }
    | LABEL COLON
    {
        fprintf(output_file, "%s:\n", $1);
    }
    | IFSTMT
    | PARAM REGINT
    {
        // The initial frame of the caller function remains intact, grows downwards for each param
        param_offset += INTSIZE;
        fprintf(output_file, "sub $sp, $sp, %d\n", INTSIZE); // addu $sp, $sp, -INTSIZE
        fprintf(output_file, "sw $t%c, 0($sp)\n", $2[1]);     // sw $t0, 0($sp)
    }
    | PARAM REGFLOAT
    {
        param_offset += FLOATSIZE;
        fprintf(output_file, "sub $sp, $sp, %d\n", FLOATSIZE);    // addu $sp, $sp, -INTSIZE
        fprintf(output_file, "mfc1 $s0, $f%s\n", $2+1);             // store a float reg into int reg s0
        fprintf(output_file, "sw $s0, 0($sp)\n");                 // sw $t0, 0($sp)
    }
    | REFPARAM REGINT 
    {
        return_value = string($2);
    }
    | REFPARAM REGFLOAT
    {
        return_value = string($2);
    }
    | CALL USERVAR COMMA NUMINT
    {
        int frameSize = get_function_offset(functionList, current_function_name); 
        sw_all_registers(frameSize+param_offset);       // Save all temp registers
        fprintf(output_file, "jal %s\n", $2);                     // jal calling
        lw_all_registers(frameSize+param_offset);   // retrieve all registers
        if(return_value==""){

        } else if(return_value[0] == 'F'){
            fprintf(output_file, "move $s0, $v0\n");   // move result to refparam
            fprintf(output_file, "mtc1 $s0, $f%s\n", return_value.c_str()+1);   // move result to refparam
        } else {
            fprintf(output_file, "move $t%c, $v0\n", return_value[1]);   // move result to refparam 
        }
        int funcParamOffset = get_param_offset(functionList, string($2));
        fprintf(output_file, "add $sp, $sp, %d\n", funcParamOffset);  // collapse space used by parameters
        param_offset-=funcParamOffset;
        return_value = "";
    }
    | FUNCTION BEG USERVAR 
    {
        current_function_name = string($3);
        fprintf(output_file, "%s:\n", $3);
        // Push return address and frame pointer to top of frame
        int frameSize = get_function_offset(functionList, current_function_name);
        fprintf(output_file, "subu $sp, $sp, %d\n", frameSize);
        fprintf(output_file, "sw $ra, %d($sp)\n", frameSize-INTSIZE);
        fprintf(output_file, "sw $fp, %d($sp)\n", frameSize-2*INTSIZE);
        fprintf(output_file, "move $fp, $sp\n");
    }
    | FUNCTION END
    {
        int frameSize = get_function_offset(functionList, current_function_name);
        fprintf(output_file, "end_%s:\n", current_function_name.c_str());
        fprintf(output_file, "move $sp, $fp\n");                          // move    $sp,$fp
        fprintf(output_file, "lw $ra, %d($sp)\n", frameSize-INTSIZE);     // lw      $31,52($sp)
        fprintf(output_file, "lw $fp, %d($sp)\n", frameSize-2*INTSIZE);   // lw      $fp,48($sp)
        fprintf(output_file, "addu $sp, $sp, %d\n", frameSize);           // addiu   $sp,$sp,56
        fprintf(output_file, "j $ra\n");                                  // j       $31
        //nop
    }
    | RETURN 
    {
        fprintf(output_file, "j end_%s\n", current_function_name.c_str());
    }
    | RETURN REGINT
    {
        fprintf(output_file, "move $v0, $t%c\n", $2[1]);
        fprintf(output_file, "j end_%s\n", current_function_name.c_str());
    }
    | RETURN REGFLOAT
    {
        fprintf(output_file, "mfc1 $s0, $f%s\n", $2+1);
        fprintf(output_file, "move $v0, $s0\n");
        fprintf(output_file, "j end_%s\n", current_function_name.c_str());
    }
    | PRINT REGINT
    {
        fprintf(output_file, "move $a0, $t%s\n", $2+1);
        fprintf(output_file, "li $v0 1\n");
        fprintf(output_file, "syscall\n");
        fprintf(output_file, "li $v0, 4\n");//         li $v0, 4 # system call code for printing string = 4
        fprintf(output_file, "la $a0, endline\n");// la $a0, out_string # load address of string to be printed into $a0
        fprintf(output_file, "syscall\n");// syscall
    }
    | PRINT REGFLOAT
    {
        fprintf(output_file, "mov.s $f12, $f%s\n", $2+1);
        fprintf(output_file, "li $v0 2\n");
        fprintf(output_file, "syscall\n");
        fprintf(output_file, "li $v0, 4\n");//         li $v0, 4 # system call code for printing string = 4
        fprintf(output_file, "la $a0, endline\n");// la $a0, out_string # load address of string to be printed into $a0
        fprintf(output_file, "syscall\n");// syscall
    }
    | READ REGINT
    {
        fprintf(output_file, "li $v0 5\n");
        fprintf(output_file, "syscall\n");
        fprintf(output_file, "move $t%s, $v0\n", $2+1);
    }
    | READ REGFLOAT
    {
        fprintf(output_file, "li $v0 6\n");
        fprintf(output_file, "syscall\n");
        fprintf(output_file, "mov.s $f%s, $f0\n", $2+1);
    }
;


ASG: USERVAR ASSIGN REGINT
    {
        int offset = get_offset(functionList, global_vars, current_function_name, string($1), 0, is_global_var)+param_offset;
        if(!is_global_var){
            fprintf(output_file, "sw $t%c, %d($sp)\n", $3[1], offset);
        } else {
            fprintf(output_file, "sw $t%s, %s\n", $3+1, $1); 
        }
    }
    | USERVAR LSB NUMINT RSB ASSIGN REGINT
    {
        // useless
        int offset = get_offset(functionList, global_vars, current_function_name, string($1), 0, is_global_var)+param_offset;
        fprintf(output_file, "sw $t%c, %d($sp)\n", $3[1], offset);
    }
    | USERVAR LSB REGINT RSB ASSIGN REGINT
    {
        int offset = get_offset(functionList, global_vars, current_function_name, string($1), 0, is_global_var)+param_offset;
        if(!is_global_var){
            fprintf(output_file, "mul $t%s, $t%s, %d\n", $3+1, $3+1, INTSIZE);
            fprintf(output_file,"li $s1, %d\n", offset);
            fprintf(output_file,"addu $s0, $sp, $s1\n");
            fprintf(output_file,"sub $s0, $s0, $t%s\n", $3+1);
            fprintf(output_file,"sw $t%s, 0($s0)\n", $6+1);
        } else {
            fprintf(output_file, "mul $t%s, $t%s, %d\n", $3+1, $3+1, INTSIZE);
            fprintf(output_file,"la $s1, %s\n", $1);
            fprintf(output_file,"addu $s0, $s1, $t%s\n", $3+1);
            fprintf(output_file,"sw $t%s, 0($s0)\n", $6+1);
        }
    }
    | REGINT ASSIGN USERVAR
    {
        int offset = get_offset(functionList, global_vars, current_function_name, string($3), 0, is_global_var)+param_offset;
        if(!is_global_var){
            fprintf(output_file, "lw $t%c, %d($sp)\n", $1[1], offset);
        } else {
            fprintf(output_file, "lw $t%c, %s\n", $1[1], $3);
        }
    }
    | REGINT ASSIGN USERVAR LSB REGINT RSB
    {
        int offset = get_offset(functionList, global_vars, current_function_name, string($3), 0, is_global_var)+param_offset;
        if(!is_global_var){
            fprintf(output_file, "mul $t%s, $t%s, %d\n", $5+1, $5+1, INTSIZE);
            fprintf(output_file,"li $s1, %d\n", offset);
            fprintf(output_file,"addu $s0, $sp, $s1\n");
            fprintf(output_file,"sub $s0, $s0, $t%s\n", $5+1);
            fprintf(output_file,"lw $t%s, 0($s0)\n", $1+1);
        } else {
            fprintf(output_file, "mul $t%s, $t%s, %d\n", $5+1, $5+1, INTSIZE);
            fprintf(output_file,"la $s0, %s\n", $3);
            fprintf(output_file,"addu $s0, $s0, $t%s\n", $3+1);
            fprintf(output_file,"lw $t%s, 0($s0)\n", $1+1);
        }
    }
    | REGINT ASSIGN USERVAR LSB NUMINT RSB
    {
        //useless
        int offset = get_offset(functionList, global_vars, current_function_name, string($3), 0, is_global_var)+param_offset;
        fprintf(output_file, "sw $t%c, %d($sp)\n", $1[1], offset);
    }
    | REGINT ASSIGN NUMINT
    {
        fprintf(output_file, "li $t%c, %s\n", $1[1], $3);
    }
    | REGINT ASSIGN REGINT
    {
        fprintf(output_file, "move $t%c, $t%c\n", $1[1], $3[3]);
    }
    | REGINT ASSIGN CONVERTINT LP REGFLOAT RP
    {
        fprintf(output_file, "cvt.w.s $f%s, $f%s\n", $5+1, $5+1);
        fprintf(output_file, "mfc1 $t%c, $f%s\n", $1[1], $5+1);
    }
    | REGINT ASSIGN REGINT PLUS NUMINT
    {
        fprintf(output_file, "addu $t%c, $t%c, %s\n", $1[1], $3[1], $5);
    }
    | REGINT ASSIGN REGINT MINUS NUMINT
    {
        fprintf(output_file, "subu $t%c, $t%c, %s\n", $1[1], $3[1], $5);
    }
    | REGINT ASSIGN REGINT PLUS REGINT
    {
        fprintf(output_file, "add $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
    | REGINT ASSIGN REGINT MINUS REGINT
    {
        fprintf(output_file, "sub $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
    | REGINT ASSIGN REGINT MUL REGINT
    {
        fprintf(output_file, "mul $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
    | REGINT ASSIGN REGINT DIV REGINT
    {
        fprintf(output_file, "div $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
        fprintf(output_file, "mflo $t%c\n", $1[1]);
    }
    | REGINT ASSIGN REGINT MOD REGINT
    {
        fprintf(output_file, "div $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
        fprintf(output_file, "mfhi $t%c\n", $1[1]);
    }
    | REGINT ASSIGN REGINT EQUAL REGINT
    {
        fprintf(output_file, "seq $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
    | REGINT ASSIGN REGINT NOTEQUAL REGINT
    {
        fprintf(output_file, "sne $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
    | REGINT ASSIGN REGINT AND REGINT 
    {
        // hack, will not arise when short-circuit is done
        fprintf(output_file, "sne $t%c, $t%c, 0\n", $3[1], $3[1]);
        fprintf(output_file, "sne $t%c, $t%c, 0\n", $5[1], $5[1]);
        fprintf(output_file, "and $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
    | REGINT ASSIGN REGINT OR REGINT
    {
        fprintf(output_file, "or $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
    | REGINT ASSIGN REGINT LT REGINT
    {
        fprintf(output_file, "slt $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
    | REGINT ASSIGN REGINT GT REGINT
    {
        fprintf(output_file, "sgt $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
    | REGINT ASSIGN REGINT LE REGINT
    {
        fprintf(output_file, "sle $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
    | REGINT ASSIGN REGINT GE REGINT
    {
        fprintf(output_file, "sge $t%c, $t%c, $t%c\n", $1[1], $3[1], $5[1]);
    }
;

FLOATASG: USERVAR ASSIGN REGFLOAT
    {
        int offset = get_offset(functionList, global_vars, current_function_name, string($1), 0, is_global_var)+param_offset;
        if(!is_global_var){
            fprintf(output_file, "s.s $f%s, %d($sp)\n", $3+1, offset);
        } else {
            fprintf(output_file, "s.s $f%s, %s\n", $3+1, $1);
        }
    }
    | USERVAR LSB NUMINT RSB ASSIGN REGFLOAT
    {
        //useless
        int offset = get_offset(functionList, global_vars, current_function_name, string($1), 0, is_global_var)+param_offset;
        fprintf(output_file, "s.s $f%s, %d($sp)\n", $3+1, offset);
    }
    | USERVAR LSB REGINT RSB ASSIGN REGFLOAT
    {
        int offset = get_offset(functionList, global_vars, current_function_name, string($1), 0, is_global_var)+param_offset;
        if(!is_global_var){
            fprintf(output_file, "mul $t%s, $t%s, %d\n", $3+1, $3+1, INTSIZE);
            fprintf(output_file,"li $s1, %d\n", offset);
            fprintf(output_file,"addu $s0, $sp, $s1\n");
            fprintf(output_file,"sub $s0, $s0, $t%s\n", $3+1);
            fprintf(output_file,"s.s $f%s, 0($s0)\n", $6+1);
        } else {
            fprintf(output_file, "mul $t%s, $t%s, %d\n", $3+1, $3+1, INTSIZE);
            fprintf(output_file,"la $s1, %s\n", $1);
            fprintf(output_file,"addu $s0, $s1, $t%s\n", $3+1);
            fprintf(output_file,"s.s $f%s, 0($s0)\n", $6+1);
        }
    }
    | REGFLOAT ASSIGN USERVAR
    {
        int offset = get_offset(functionList, global_vars, current_function_name, string($3), 0, is_global_var)+param_offset;
        if(!is_global_var){
            fprintf(output_file, "l.s $f%s, %d($sp)\n", $1+1, offset);
        } else {
            fprintf(output_file, "l.s $f%s, %s\n", $1+1, $3);
        }
    }
    | REGFLOAT ASSIGN USERVAR LSB REGINT RSB
    {
        int offset = get_offset(functionList, global_vars, current_function_name, string($3), 0, is_global_var)+param_offset;
        if(!is_global_var){
            fprintf(output_file, "mul $t%s, $t%s, %d\n", $5+1, $5+1, INTSIZE);
            fprintf(output_file, "subu $s0, $sp, $t%s\n", $5+1);
            fprintf(output_file, "l.s $f%s, %d($s0)\n", $1+1, offset);
        } else {
            fprintf(output_file, "mul $t%s, $t%s, %d\n", $5+1, $5+1, INTSIZE);
            fprintf(output_file,"la $s1, %s\n", $3);
            fprintf(output_file,"addu $s0, $s1, $t%s\n", $5+1);
            fprintf(output_file,"l.s $f%s, 0($s0)\n", $1+1);
        }
    }
    | REGFLOAT ASSIGN CONVERTFLOAT LP REGINT RP
    {
        // convert from integer to float
        fprintf(output_file, "mtc1 $t%c, $f%s\n", $5[1], $1+1);
        fprintf(output_file, "cvt.s.w $f%s, $f%s\n", $1+1, $1+1);
    }
    | REGFLOAT ASSIGN NUMFLOAT
    {
        fprintf(output_file, "li.s $f%s, %s\n", $1+1, $3);
    }
    | REGFLOAT ASSIGN REGFLOAT
    {
        fprintf(output_file, "mov.s $f%s, $f%s\n", $1+1, $3+1);
    }
    | REGFLOAT ASSIGN REGFLOAT PLUS REGFLOAT
    {
        fprintf(output_file, "add.s $f%s, $f%s, $f%s\n", $1+1, $3+1, $5+1);
    }
    | REGFLOAT ASSIGN REGFLOAT MINUS REGFLOAT
    {
        fprintf(output_file, "sub.s $f%s, $f%s, $f%s\n", $1+1, $3+1, $5+1);
    }
    | REGFLOAT ASSIGN REGFLOAT MUL REGFLOAT
    {
        fprintf(output_file, "mul.s $f%s, $f%s, $f%s\n", $1+1, $3+1, $5+1);
    }
    | REGFLOAT ASSIGN REGFLOAT DIV REGFLOAT
    {
        fprintf(output_file, "div.s $f%s, $f%s, $f%s\n", $1+1, $3+1, $5+1);
    }
    | REGINT ASSIGN REGFLOAT EQUAL REGFLOAT
    {
        fprintf(output_file, "li $t%c, 0\n", $1[1]);
        fprintf(output_file, "c.eq.s $f%s, $f%s\n", $3+1, $5+1);
        fprintf(output_file, "bc1f FLOAT%d\n", floatLabel);
        fprintf(output_file, "li $t%c, 1\n", $1[1]);
        fprintf(output_file, "FLOAT%d:\n", floatLabel);
        floatLabel++;
    }
    | REGINT ASSIGN REGFLOAT NOTEQUAL REGFLOAT
    {
        fprintf(output_file, "li $t%c, 1\n", $1[1]);
        fprintf(output_file, "c.eq.s $f%s, $f%s\n", $3+1, $5+1);
        fprintf(output_file, "bc1f FLOAT%d\n", floatLabel);
        fprintf(output_file, "li $t%c, 0\n", $1[1]);
        fprintf(output_file, "FLOAT%d:\n", floatLabel);
        floatLabel++;
    }
    | REGINT ASSIGN REGFLOAT AND REGFLOAT
    {
        fprintf(output_file, "li.d $f31, 0\n");
        fprintf(output_file, "li $t%c, 0\n", $1[1]);
        fprintf(output_file, "c.eq.s $f%s, $f31\n", $3+1);
        fprintf(output_file, "bc1f FLOAT%d\n", floatLabel);
        fprintf(output_file, "c.eq.s $f%s, $f31\n", $5+1);
        fprintf(output_file, "bc1f FLOAT%d\n", floatLabel);
        fprintf(output_file, "li $t%c, 1\n", $1[1]);
        fprintf(output_file, "FLOAT%d:\n", floatLabel);
        floatLabel++;
    }
    | REGINT ASSIGN REGFLOAT OR REGFLOAT
    {
        fprintf(output_file, "li.d $f31, 0\n");
        fprintf(output_file, "li $t%c, 1\n", $1[1]);
        fprintf(output_file, "c.eq.s $f%s, $f31\n", $3+1);
        fprintf(output_file, "bc1f FLOAT%d\n", floatLabel);
        fprintf(output_file, "c.eq.s $f%s, $f31\n", $5+1);
        fprintf(output_file, "bc1f FLOAT%d\n", floatLabel);
        fprintf(output_file, "li $t%c, 0\n", $1[1]);
        fprintf(output_file, "FLOAT%d:\n", floatLabel);
        floatLabel++;
    }
    | REGINT ASSIGN REGFLOAT LT REGFLOAT
    {
        fprintf(output_file, "li $t%c, 0\n", $1[1]);
        fprintf(output_file, "c.lt.s $f%s, $f%s\n", $3+1, $5+1);
        fprintf(output_file, "bc1f FLOAT%d\n", floatLabel);
        fprintf(output_file, "li $t%c, 1\n", $1[1]);
        fprintf(output_file, "FLOAT%d:\n", floatLabel);
        floatLabel++;
    }
    | REGINT ASSIGN REGFLOAT GT REGFLOAT
    {
        fprintf(output_file, "li $t%c, 1\n", $1[1]);
        fprintf(output_file, "c.le.s $f%s, $f%s\n", $3+1, $5+1);
        fprintf(output_file, "bc1f FLOAT%d\n", floatLabel);
        fprintf(output_file, "li $t%c, 0\n", $1[1]);
        fprintf(output_file, "FLOAT%d:\n", floatLabel);
        floatLabel++;
    }
    | REGINT ASSIGN REGFLOAT LE REGFLOAT
    {
        fprintf(output_file, "li $t%c, 0\n", $1[1]);
        fprintf(output_file, "c.le.s $f%s, $f%s\n", $3+1, $5+1);
        fprintf(output_file, "bc1f FLOAT%d\n", floatLabel);
        fprintf(output_file, "li $t%c, 1\n", $1[1]);
        fprintf(output_file, "FLOAT%d:\n", floatLabel);
        floatLabel++;
    }
    | REGINT ASSIGN REGFLOAT GE REGFLOAT
    {
        fprintf(output_file, "li $t%c, 1\n", $1[1]);
        fprintf(output_file, "c.lt.s $f%s, $f%s\n", $3+1, $5+1);
        fprintf(output_file, "bc1f FLOAT%d\n", floatLabel);
        fprintf(output_file, "li $t%c, 0\n", $1[1]);
        fprintf(output_file, "FLOAT%d:\n", floatLabel);
        floatLabel++;
    }
;

IFSTMT: IF REGINT EQUAL REGINT GOTO LABEL
    {
        fprintf(output_file, "beq $t%c, $t%c, %s\n", $2[1], $4[1], $6);
    }
    | IF REGINT NOTEQUAL REGINT GOTO LABEL
    {
        fprintf(output_file, "bne $t%c, $t%c, %s\n", $2[1], $4[1], $6);
    }
    | IF REGINT EQUAL NUMINT GOTO LABEL
    {
        fprintf(output_file, "beq $t%c, %s, %s\n", $2[1], $4, $6);
    }
    | IF REGINT NOTEQUAL NUMINT GOTO LABEL
    {
        fprintf(output_file, "bne $t%c, %s, %s\n", $2[1], $4, $6);
    }
    | IF REGFLOAT EQUAL REGFLOAT GOTO LABEL
    {
        fprintf(output_file, "li $s0, 1\n");
        fprintf(output_file, "c.eq.s $f%s, $f%s\n", $2+1, $4+1);
        fprintf(output_file, "bc1t FLOAT%d\n", floatLabel);
        fprintf(output_file, "li $s0, 0\n");
        fprintf(output_file, "FLOAT%d:\n", floatLabel);
        fprintf(output_file, "beq $s0, 1, %s\n", $6);
        floatLabel++;
    }
    | IF REGFLOAT NOTEQUAL REGFLOAT GOTO LABEL
    {
        fprintf(output_file, "li $s0, 1\n");
        fprintf(output_file, "c.eq.s $f%s, $f%s\n", $2+1, $4+1);
        fprintf(output_file, "bc1f FLOAT%d\n", floatLabel);
        fprintf(output_file, "li $s0, 0\n");
        fprintf(output_file, "FLOAT%d:\n", floatLabel);
        fprintf(output_file, "beq $s0, 1, %s\n", $6);
        floatLabel++;
    }
    | IF REGFLOAT EQUAL NUMINT GOTO LABEL
    {
        fprintf(output_file, "mtc1 $0, $f31\n");
        fprintf(output_file, "cvt.s.w $f31, $f31\n");
        fprintf(output_file, "li $s0, 1\n");
        fprintf(output_file, "c.eq.s $f%s, $f31\n", $2+1);
        fprintf(output_file, "bc1t FLOAT%d\n", floatLabel);
        fprintf(output_file, "li $s0, 0\n");
        fprintf(output_file, "FLOAT%d:\n", floatLabel);
        fprintf(output_file, "beq $s0, 1, %s\n", $6);
        floatLabel++;
    }
    | IF REGFLOAT NOTEQUAL NUMINT GOTO LABEL
    {
        fprintf(output_file, "mtc1 $0, $f31\n");
        fprintf(output_file, "cvt.s.w $f31, $f31\n");
        fprintf(output_file, "li $s0, 1\n");
        fprintf(output_file, "c.eq.s $f%s, $f31\n", $2+1);
        fprintf(output_file, "bc1f FLOAT%d\n", floatLabel); // goto label float when equal to 0
        fprintf(output_file, "li $s0, 0\n");
        fprintf(output_file, "FLOAT%d:\n", floatLabel);
        fprintf(output_file, "beq $s0, 1, %s\n", $6);
        floatLabel++;
    }
;

%%

void sw_all_registers(int frameSize){
    for(int i=0; i<10; i++){
        fprintf(output_file, "sw $t%d, %d($sp)\n", i, frameSize-2*INTSIZE-(i+1)*INTSIZE);
    }
    for(int i=0; i<11; i++){
        fprintf(output_file, "s.s $f%d, %d($sp)\n", i, frameSize-2*INTSIZE-(i+11)*INTSIZE);
    }
}

void lw_all_registers(int frameSize){
    for(int i=0; i<10; i++){
        fprintf(output_file, "lw $t%d, %d($sp)\n", i, frameSize-2*INTSIZE-(i+1)*INTSIZE);
    }
    for(int i=0; i<11; i++){
        fprintf(output_file, "l.s $f%d, %d($sp)\n", i, frameSize-2*INTSIZE-(i+11)*INTSIZE);
    }
}

void yyerror(char *s)
{      
    printf("\nSyntax error %s at line %d\n", s, yylineno);
    // cout << BOLD(FRED("Error : ")) << FYEL("Syntax error " + string(s) + "in intermediate code at line " + to_string(yylineno)) << endl;
    fflush(stdout);
}

int main(int argc, char **argv)
{
    read_symtab(functionList, global_vars);
    return_value = ""; 
    is_global_var = false;
    output_file = fopen("output/mips.s", "w");
    fflush(output_file);
    fprintf(output_file,".data\n");
    for(auto it : global_vars){
        fprintf(output_file, "%s: .space %d\n", it.name.c_str(), 4*(it.var_offset));
    }
    fprintf(output_file,"endline: .asciiz \"\\n\"\n");
    fprintf(output_file,".text\n");
    param_offset = 0;
    floatLabel = 0;
    yyparse();
    fflush(output_file);
    fclose(output_file);
}
