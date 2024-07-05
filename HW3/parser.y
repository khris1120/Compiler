%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "code.h"

    int lineNo = 1;
    int yylex();
    int in_if = 0;
    extern FILE* f_asm;
    int arg_cnt;
    int if_cnt = 0;
    int if_array[100];
    int cur_if = -1;
    int for_cnt;

%}


%union {
    char* stringVal;
    int intVal;
}

%token <intVal> NUM
%token <stringVal> __RV__UKADD8 __RV__CMPEQ8 __RV__UCMPLT8 __RV__UKSUB8 EXTDSPCODEGEN
%token <stringVal> FLOAT CHAR STRING TYPE ID
%token <stringVal> INC DEC ADD MINUS MULTIPLY DIVIDE PERCENT LESS_THAN GREATER_THAN LOGICAL_NOT BITWISE_NOT AND_OP ASSIGN
%token <stringVal> LESS_OR_EQUAL_THAN GREATER_OR_EQUAL_THAN SHIFT_LEFT SHIFT_RIGHT EQUAL NOT_EQUAL
%token <stringVal> SEMICOLON COMMA COLON L_BRACKET R_BRACKET L_SQ_BRACKET R_SQ_BRACKET L_CUR_BRACKET R_CUR_BRACKET
%token <stringVal> IF ELSE SWITCH CASE DEFAULT DO WHILE FOR RETURN BREAK CONTINUE

%start program
%type <stringVal> declarations declaration
%type <stringVal> scalar_decl idents ident var
%type <stringVal> array_decl
%type <stringVal> func_decl parameters parameter
%type <stringVal> func_def compound_stmt stmts stmt if_stmt if_else_stmt switch_stmt switch_clauses switch_clause while_stmt for_stmt for_init for_cond for_update return_stmt
%type <stringVal> exprs expr equlity_expr compare_expr shift_expr add_minus_expr arith_expr prefix_expr postfix_expr last_expr

%nonassoc UMINUS UADD UMULTI UANDOP
%nonassoc INCPOST DECPOST

%%

program 
    : declarations {  }
    ;

declarations 
    : declarations declaration {
        
    }
    | declaration {
        
    } 
    ;

declaration
    : scalar_decl {  }
    | array_decl {  }
    | func_decl {  }
    | func_def {  }
    ;


scalar_decl
    : TYPE idents SEMICOLON {
        
    }
    ;

idents
    : idents COMMA ident {
        
    }
    | ident {  }
    ;

ident
    : var ASSIGN expr {
        $$ = install_symbol($1);
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  sw t0, %d(fp)\n", table[look_up_symbol($1)].offset * (-4) - 48);
    }
    | var {
        
    }
    ;

var
    : ID {
        $$ = $1;
    }
    | MULTIPLY ID {
        $$ = $2;
    }
    ;

array_decl
    : TYPE ID L_SQ_BRACKET NUM R_SQ_BRACKET SEMICOLON {
        $$ = install_symbol($2);
        for (int i = 0; i < $4 - 1; i++) {
            install_symbol("");
        }
    }

/* array_decl
    : TYPE arrays SEMICOLON {
        
    }
    ;

arrays
    : arrays COMMA array {
        
    }
    | array {  }
    ;

array
    : ID array_dimen {
        
    }
    | ID array_dimen ASSIGN L_CUR_BRACKET array_content R_CUR_BRACKET {
        
    }
    ;

array_dimen
    : array_dimen L_SQ_BRACKET expr R_SQ_BRACKET {
        
    }
    | L_SQ_BRACKET expr R_SQ_BRACKET {
        
    }
    ;

array_content
    : L_CUR_BRACKET array_content R_CUR_BRACKET {
        
    }
    | array_content COMMA L_CUR_BRACKET array_content R_CUR_BRACKET {
        
    }
    | array_content COMMA expr {
        
    }
    | expr {
        
    }
    ; */

func_decl
    : TYPE ID L_BRACKET parameters R_BRACKET SEMICOLON {
        fprintf(f_asm, ".global %s\n", $2);
    }
    | TYPE MULTIPLY ID L_BRACKET parameters R_BRACKET SEMICOLON {
        fprintf(f_asm, ".global %s\n", $3);
    }
    | TYPE ID L_BRACKET R_BRACKET SEMICOLON {
        fprintf(f_asm, ".global %s\n", $2);
    }
    | TYPE MULTIPLY ID L_BRACKET R_BRACKET SEMICOLON {
        fprintf(f_asm, ".global %s\n", $3);
    }
    | TYPE EXTDSPCODEGEN L_BRACKET TYPE ID COMMA TYPE ID R_BRACKET SEMICOLON {
        fprintf(f_asm, ".global ext_dsp_codegen\n");
    }
    ;

/* parameters
    : TYPE ID COMMA TYPE ID {
        install_symbol($2);
        install_symbol($5);
        fprintf(f_asm, "sw a0, %d(fp)\n", table[look_up_symbol($2)].offset * (-4) - 48);
        fprintf(f_asm, "sw a1, %d(fp)\n", table[look_up_symbol($5)].offset * (-4) - 48);
        fprintf(f_asm, "\n");
    }
    ; */

parameters
    : parameters COMMA parameter {
        
    }
    | parameter {  }
    ;

parameter
    : TYPE ID {
        
    }
    | TYPE MULTIPLY ID {
        
    }
    ;

func_def
    : TYPE ID L_BRACKET parameters R_BRACKET {
        cur_scope++;
        code_gen_func_header($2);
    } compound_stmt {
        pop_up_symbol(cur_scope);
        cur_scope--;
        code_gen_at_end_of_function_body($2);
    }
    | TYPE MULTIPLY ID L_BRACKET parameters R_BRACKET {
        cur_scope++;
        code_gen_func_header($2);
    } compound_stmt {
        pop_up_symbol(cur_scope);
        cur_scope--;
        code_gen_at_end_of_function_body($2);
    }
    | TYPE ID L_BRACKET R_BRACKET {
        cur_scope++;
        code_gen_func_header($2);
    } compound_stmt {
        pop_up_symbol(cur_scope);
        cur_scope--;
        code_gen_at_end_of_function_body($2);
    }
    | TYPE MULTIPLY ID L_BRACKET R_BRACKET {
        cur_scope++;
        code_gen_func_header($2);
    } compound_stmt {
        pop_up_symbol(cur_scope);
        cur_scope--;
        code_gen_at_end_of_function_body($2);
    }
    | TYPE EXTDSPCODEGEN L_BRACKET TYPE ID COMMA TYPE ID R_BRACKET {
        cur_scope++;
        code_gen_func_header($2);
        install_symbol($5);
        install_symbol($8);
        fprintf(f_asm, "  sw a0, %d(fp)\n", table[look_up_symbol($5)].offset * (-4) - 48);
        fprintf(f_asm, "  sw a1, %d(fp)\n", table[look_up_symbol($8)].offset * (-4) - 48);
        fprintf(f_asm, "\n");
    } compound_stmt {
        pop_up_symbol(cur_scope);
        cur_scope--;
        code_gen_at_end_of_function_body($2);
    }
    ;


exprs
    : exprs COMMA expr {
        arg_cnt++;
    }
    | expr {
        arg_cnt++;
        $$ = $1;
    }
    ;

expr
    : ID ASSIGN expr {
        int index = look_up_symbol($1);
        printf("in id assign\n");
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  sw t0, %d(fp)\n", table[index].offset * (-4) - 48);
    }
    | MULTIPLY ID ASSIGN expr {
        int index = look_up_symbol($2);
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  lw t1, %d(fp)\n", table[index].offset * (-4) - 48);
        fprintf(f_asm, "  add t1, fp, t1\n");
        fprintf(f_asm, "  sw t0, 0(t1)\n");
    }
    | ID L_SQ_BRACKET expr R_SQ_BRACKET ASSIGN expr {
        int index = look_up_symbol($1);
        fprintf(f_asm, "  li t0, %d\n", table[index].offset * (-4) - 48);
        fprintf(f_asm, "  lw t1, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  lw t2, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  li t3, -4\n");
        fprintf(f_asm, "  mul t2, t2, t3\n");
        fprintf(f_asm, "  add t0, t0, t2\n");
        fprintf(f_asm, "  add t0, t0, fp\n");
        fprintf(f_asm, "  sw t1, 0(t0)\n");
        fprintf(f_asm, "  \n");
    }
    | equlity_expr {  }
    ;

equlity_expr
    : equlity_expr EQUAL compare_expr {
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  lw t1, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  xor t2, t1, t0\n");
        fprintf(f_asm, "  sltu t2, zero, t2\n");
        fprintf(f_asm, "  xori t2, t2, 1\n");
        fprintf(f_asm, "  addi sp, sp, -4\n");
        fprintf(f_asm, "  sw t2, 0(sp)\n");
        $$ = $1;
    }
    | equlity_expr NOT_EQUAL compare_expr {
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  lw t1, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  xor t2, t1, t0\n");
        fprintf(f_asm, "  sltu t2, zero, t2\n");
        fprintf(f_asm, "  addi sp, sp, -4\n");
        fprintf(f_asm, "  sw t2, 0(sp)\n");
        $$ = $1;
    }
    | compare_expr {  }
    ;

compare_expr
    : compare_expr GREATER_THAN shift_expr {
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  lw t1, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  sgt t2, t1, t0\n");
        fprintf(f_asm, "  addi sp, sp, -4\n");
        fprintf(f_asm, "  sw t2, 0(sp)\n");
        $$ = $1;
    }
    | compare_expr LESS_THAN shift_expr {
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  lw t1, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  slt t2, t1, t0\n");
        fprintf(f_asm, "  addi sp, sp, -4\n");
        fprintf(f_asm, "  sw t2, 0(sp)\n");
        $$ = $1;
    }
    | compare_expr GREATER_OR_EQUAL_THAN shift_expr {
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  lw t1, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  sub t0, t1, t0\n");
        fprintf(f_asm, "  slti t0, t0, 0\n");
        fprintf(f_asm, "  seqz t0, t0\n");
        fprintf(f_asm, "  sw t0, -4(sp)\n");
        fprintf(f_asm, "  addi sp, sp, -4\n");
        $$ = $1;
    }
    | compare_expr LESS_OR_EQUAL_THAN shift_expr {
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  lw t1, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  sub t0, t1, t0\n");
        fprintf(f_asm, "  li t2, 0\n");
        fprintf(f_asm, "  sgt t0, t0, t2\n");
        fprintf(f_asm, "  seqz t0, t0\n");
        fprintf(f_asm, "  sw t0, -4(sp)\n");
        fprintf(f_asm, "  addi sp, sp, -4\n");
        $$ = $1;
    }
    | shift_expr {  }
    ;

shift_expr
    : shift_expr SHIFT_LEFT add_minus_expr {
        
    }
    | shift_expr SHIFT_RIGHT add_minus_expr {
        
    }
    | add_minus_expr {  }
    ;

add_minus_expr
    : add_minus_expr ADD arith_expr {
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  lw t1, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  add t0, t0, t1\n");
        fprintf(f_asm, "  sw t0, -4(sp)\n");
        fprintf(f_asm, "  addi sp, sp, -4\n");
        $$ = NULL;
    }
    | add_minus_expr MINUS arith_expr {
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  lw t1, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  sub t0, t1, t0\n");
        fprintf(f_asm, "  sw t0, -4(sp)\n");
        fprintf(f_asm, "  addi sp, sp, -4\n");
        $$ = NULL;
    }
    | arith_expr {  }
    ;

arith_expr
    : arith_expr MULTIPLY prefix_expr {
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  lw t1, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  mul t0, t0, t1\n");
        fprintf(f_asm, "  sw t0, -4(sp)\n");
        fprintf(f_asm, "  addi sp, sp, -4\n");
        $$ = NULL;
    }
    | arith_expr DIVIDE prefix_expr {
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  lw t1, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  div t0, t1, t0\n");
        fprintf(f_asm, "  sw t0, -4(sp)\n");
        fprintf(f_asm, "  addi sp, sp, -4\n");
        $$ = NULL;
    }
    | arith_expr PERCENT prefix_expr {
        
    }
    | prefix_expr {  }
    ;

prefix_expr
    : INC prefix_expr {
        
    }
    | DEC prefix_expr {
        
    }
    | L_BRACKET TYPE R_BRACKET prefix_expr {
        
    }
    | L_BRACKET TYPE MULTIPLY R_BRACKET prefix_expr {
        
    }
    | ADD prefix_expr %prec UADD {
        
    }
    | MINUS prefix_expr %prec UMINUS {
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  sub t0, zero, t0\n");
        fprintf(f_asm, "  addi sp, sp, -4\n");
        fprintf(f_asm, "  sw t0, 0(sp)\n");
    }
    | LOGICAL_NOT prefix_expr {
        
    }
    | BITWISE_NOT prefix_expr {
        
    }
    | MULTIPLY ID %prec UMULTI {
        int index = look_up_symbol($2);
        fprintf(f_asm, "  lw t0, %d(fp)\n", table[index].offset * (-4) - 48);
        fprintf(f_asm, "  add t0, t0, fp\n");
        fprintf(f_asm, "  lw t1, 0(t0)\n");
        fprintf(f_asm, "  addi sp, sp, -4\n");
        fprintf(f_asm, "  sw t1, 0(sp)\n");
    }
    | AND_OP ID %prec UANDOP {
        int index = look_up_symbol($2);
        fprintf(f_asm, "  li t0, %d\n", table[index].offset * (-4) - 48);
        fprintf(f_asm, "  addi sp, sp, -4\n");
        fprintf(f_asm, "  sw t0, 0(sp)\n");
    }
    | postfix_expr {  }
    ;

postfix_expr
    : postfix_expr INC %prec INCPOST {
        
    }
    | postfix_expr DEC %prec DECPOST {
        
    }
    | postfix_expr L_BRACKET R_BRACKET {
        
    }
    | postfix_expr L_BRACKET {
        arg_cnt = 0;
    } exprs R_BRACKET {
        for(int i = arg_cnt - 1, j = 0; i >=0; i--, j++) {
            fprintf(f_asm, "  lw a%d, %d(sp)\n", j, i * 4);
        }
        fprintf(f_asm, "  addi sp, sp, %d\n", arg_cnt * 4);
        fprintf(f_asm, "  sw ra, -4(sp)\n");
        fprintf(f_asm, "  addi sp, sp, -4\n");
        fprintf(f_asm, "  jal ra, %s\n", $1);
        fprintf(f_asm, "  lw ra, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  \n");
        
    }
    | __RV__UKADD8 L_BRACKET expr COMMA expr R_BRACKET {
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  lw t1, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  ukadd8 t0, t0, t1\n");
        fprintf(f_asm, "  sw t0, -4(sp)\n");
        fprintf(f_asm, "  addi sp, sp, -4\n");
        $$ = NULL;
    }
    | __RV__CMPEQ8 L_BRACKET expr COMMA expr R_BRACKET {
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  lw t1, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  cmpeq8 t0, t1, t0\n");
        fprintf(f_asm, "  sw t0, -4(sp)\n");
        fprintf(f_asm, "  addi sp, sp, -4\n");
        fprintf(f_asm, "\n");
        $$ = NULL;
    }
    | __RV__UCMPLT8 L_BRACKET expr COMMA expr R_BRACKET {
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  lw t1, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  ucmplt8 t0, t1, t0\n");
        fprintf(f_asm, "  sw t0, -4(sp)\n");
        fprintf(f_asm, "  addi sp, sp, -4\n");
        fprintf(f_asm, "\n");
        $$ = NULL;
    }
    | __RV__UKSUB8 L_BRACKET expr COMMA expr R_BRACKET {
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  lw t1, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  uksub8 t0, t1, t0\n");
        fprintf(f_asm, "  sw t0, -4(sp)\n");
        fprintf(f_asm, "  addi sp, sp, -4\n");
        fprintf(f_asm, "\n");
        $$ = NULL;
    }
    | last_expr {  }
    ;

last_expr
    : ID {
        int index = look_up_symbol($1);
        fprintf(f_asm, "  lw t0, %d(fp)\n", table[index].offset * (-4) - 48);
        fprintf(f_asm, "  sw t0, -4(sp)\n");
        fprintf(f_asm, "  addi sp, sp, -4\n");
        $$ = $1;
    }
    | ID L_SQ_BRACKET expr R_SQ_BRACKET {
        int index = look_up_symbol($1);
        fprintf(f_asm, "  li t0, %d\n", table[index].offset * (-4) - 48);
        fprintf(f_asm, "  lw t1, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  li t2, -4\n");
        fprintf(f_asm, "  mul t1, t1, t2\n");
        fprintf(f_asm, "  add t0, t0, t1\n");
        fprintf(f_asm, "  add t0, t0, fp\n");
        fprintf(f_asm, "  lw t1, 0(t0)\n");
        fprintf(f_asm, "  sw t1, -4(sp)\n");
        fprintf(f_asm, "  addi sp, sp, -4\n");
        $$ = $1;
    }
    | NUM {
        fprintf(f_asm, "  li t0, %d\n", $1);
        fprintf(f_asm, "  sw t0, -4(sp)\n");
        fprintf(f_asm, "  addi sp, sp, -4\n");
        $$ = NULL;
    }
    | FLOAT {
        
    }
    | STRING {
        
    }
    | CHAR {
        
    }
    | L_BRACKET expr R_BRACKET {

    }
    ;


compound_stmt
    : L_CUR_BRACKET stmts R_CUR_BRACKET {
        
    }
    | L_CUR_BRACKET R_CUR_BRACKET {
        
    }
    ;

stmts
    : stmts stmt {
        
    }
    | stmt {  }
    ;

stmt
    : scalar_decl {  }
    | array_decl {  }
    | expr SEMICOLON {
        
    }
    | if_stmt {
        cur_if--;
     }
    | if_else_stmt {
        cur_if--;
     }
    | switch_stmt {  }
    | while_stmt {  }
    | for_stmt {  }
    | return_stmt {  }
    | BREAK SEMICOLON {
        
    }
    | CONTINUE SEMICOLON {
        
    }
    | compound_stmt {
        
    }
    ;

if_stmt
    : IF {
        if_cnt++;
        cur_if++;
        if_array[cur_if] = if_cnt;
    } L_BRACKET expr R_BRACKET {
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  beq t0, zero, .IF%d0\n", if_array[cur_if]);
        fprintf(f_asm, "\n");
        // end_if
        fprintf(f_asm, ".IF%d0:\n", if_array[cur_if]);
    } compound_stmt {
        
    }
    ;

if_else_stmt
    : if_stmt ELSE {
        fprintf(f_asm, "  j .IF%d1\n", if_array[cur_if]);
        // end_if
        fprintf(f_asm, ".IF%d1:\n", if_array[cur_if]);
    } compound_stmt {
    }
    ;

switch_stmt
    : SWITCH L_BRACKET expr R_BRACKET L_CUR_BRACKET R_CUR_BRACKET {
        
    }
    | SWITCH L_BRACKET expr R_BRACKET L_CUR_BRACKET switch_clauses R_CUR_BRACKET {
        
    }
    ;

switch_clauses
    : switch_clauses switch_clause {
        
    }
    | switch_clause {  }
    ;

switch_clause
    : CASE expr COLON {
        
    }
    | CASE expr COLON stmts {
        
    }
    | DEFAULT COLON stmts {
        
    }
    | DEFAULT COLON {
        
    }
    ;

while_stmt
    : DO {
        fprintf(f_asm, ".DOWHILE:\n");
    } stmt WHILE L_BRACKET expr R_BRACKET SEMICOLON {
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  beq t0, zero, .END_DOWHILE\n");
        fprintf(f_asm, "\n");
        fprintf(f_asm, "  j .DOWHILE\n");
        fprintf(f_asm, "\n");
        fprintf(f_asm, ".END_DOWHILE:\n");
    }
    | WHILE L_BRACKET {
        fprintf(f_asm, ".WHILE:\n");
    } expr R_BRACKET {
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  beq t0, zero, .END_WHILE\n");
        fprintf(f_asm, "\n");
    } stmt {
        fprintf(f_asm, "  j .WHILE\n");
        fprintf(f_asm, "\n");
        fprintf(f_asm, ".END_WHILE:\n");
    }
    ;

for_stmt
    : FOR L_BRACKET for_init SEMICOLON {
        for_cnt++;
        fprintf(f_asm, ".FOR%d:\n", for_cnt);
    } for_cond SEMICOLON {
        fprintf(f_asm, "  lw t0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "  beq t0, zero, .END_FOR%d\n", for_cnt);
        fprintf(f_asm, "\n");
        fprintf(f_asm, "  j .FOR%d_STMT\n", for_cnt);
        fprintf(f_asm, "\n");
        fprintf(f_asm, ".FOR%d_UPDATE:\n", for_cnt);
    } for_update R_BRACKET {
        fprintf(f_asm, "  j .FOR%d\n", for_cnt);
        fprintf(f_asm, "\n");
        fprintf(f_asm, ".FOR%d_STMT:\n", for_cnt);
    } stmt {
        fprintf(f_asm, "  j .FOR%d_UPDATE\n", for_cnt);
        fprintf(f_asm, "\n");
        fprintf(f_asm, ".END_FOR%d:\n", for_cnt);
    }
    ;

for_init
    : expr {}
    | {}
    ;

for_cond
    : expr {}
    | {}
    ;

for_update
    : expr {}
    | {}
    ;


return_stmt
    : RETURN SEMICOLON {
    }
    | RETURN expr SEMICOLON {
        fprintf(f_asm, "  lw a0, 0(sp)\n");
        fprintf(f_asm, "  addi sp, sp, 4\n");
        fprintf(f_asm, "\n");
    }
    ;


%%

int main(void) {
    if ((f_asm = fopen(FILENAME, "w")) == NULL) {
        perror("Error at opening file");
    }
    init();
    yydebug = 1;
    yyparse();
    return 0;
}

void yyerror(char *msg) {
    fprintf(stderr, "Error at line %d: %s\n", lineNo, msg);
    exit(1);
}
