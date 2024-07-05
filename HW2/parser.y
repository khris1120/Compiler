%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>

    int lineNo = 1;
    int yylex();

%}


%union {
    char* stringVal;
}

%token <stringVal> NUM FLOAT CHAR STRING TYPE ID
%token <stringVal> INC DEC ADD MINUS MULTIPLY DIVIDE PERCENT LESS_THAN GREATER_THAN LOGICAL_NOT BITWISE_NOT AND_OP OR_OP XOR_OP ASSIGN
%token <stringVal> LESS_OR_EQUAL_THAN GREATER_OR_EQUAL_THAN SHIFT_LEFT SHIFT_RIGHT EQUAL NOT_EQUAL AND OR
%token <stringVal> SEMICOLON COMMA COLON L_BRACKET R_BRACKET L_SQ_BRACKET R_SQ_BRACKET L_CUR_BRACKET R_CUR_BRACKET
%token <stringVal> IF ELSE SWITCH CASE DEFAULT DO WHILE FOR RETURN BREAK CONTINUE

%start program
%type <stringVal> declarations declaration
%type <stringVal> scalar_decl idents ident var
%type <stringVal> array_decl arrays array  array_dimen array_content
%type <stringVal> func_decl parameters parameter 
%type <stringVal> func_def compound_stmt stmts stmt if_else_stmt switch_stmt switch_clauses switch_clause while_stmt for_stmt for_cond for_lastcond return_stmt
%type <stringVal> expr or_expr and_expr or_op_expr xor_op_expr and_op_expr equlity_expr compare_expr shift_expr add_minus_expr arith_expr prefix_expr postfix_expr last_expr array_sub params

%nonassoc UMINUS UADD UMULTI UANDOP
%nonassoc INCPOST DECPOST

%%

program 
    : declarations { printf("%s", $1); }
    ;

declarations 
    : declarations declaration {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+1));
        strcpy(s, $1);
        strcat(s, $2);
        $$ = s;
    }
    | declaration {
        $$ = $1;
    } 
    ;

declaration
    : scalar_decl { $$ = $1; }
    | array_decl { $$ = $1; }
    | func_decl { $$ = $1; }
    | func_def { $$ = $1; }
    ;

scalar_decl
    : TYPE idents SEMICOLON {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+28));
        strcpy(s, "<scalar_decl>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</scalar_decl>");
        $$ = s;
    }
    ;

idents
    : idents COMMA ident {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+1));
        strcpy(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        $$ = s;
    }
    | ident { $$ = $1; }
    ;

ident
    : var ASSIGN expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+1));
        strcpy(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        $$ = s;
    }
    | var {
        $$ = $1;
    }
    ;

var
    : ID {
        $$ = $1;
    }
    | MULTIPLY ID {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+1));
        strcpy(s, $1);
        strcat(s, $2);
        $$ = s;
    }
    ;

array_decl
    : TYPE arrays SEMICOLON {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+26));
        strcpy(s, "<array_decl>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</array_decl>");
        $$ = s;
    }
    ;

arrays
    : arrays COMMA array {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+1));
        strcpy(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        $$ = s;
    }
    | array { $$ = $1; }
    ;

array
    : ID array_dimen {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+1));
        strcpy(s, $1);
        strcat(s, $2);
        $$ = s;
    }
    | ID array_dimen ASSIGN L_CUR_BRACKET array_content R_CUR_BRACKET {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+strlen($5)+strlen($6)+1));
        strcpy(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        strcat(s, $5);
        strcat(s, $6);
        $$ = s;
    }
    ;

array_dimen
    : array_dimen L_SQ_BRACKET expr R_SQ_BRACKET {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+1));
        strcpy(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        $$ = s;
    }
    | L_SQ_BRACKET expr R_SQ_BRACKET {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+1));
        strcpy(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        $$ = s;
    }
    ;

array_content
    : L_CUR_BRACKET array_content R_CUR_BRACKET {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+1));
        strcpy(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        $$ = s;
    }
    | array_content COMMA L_CUR_BRACKET array_content R_CUR_BRACKET {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+strlen($5)+1));
        strcpy(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        strcat(s, $5);
        $$ = s;
    }
    | array_content COMMA expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+1));
        strcpy(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        $$ = s;
    }
    | expr {
        $$ = $1;
    }
    ;

func_decl
    : TYPE ID L_BRACKET parameters R_BRACKET SEMICOLON {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+strlen($5)+strlen($6)+32));
        strcpy(s, "<func_decl>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        strcat(s, $5);
        strcat(s, $6);
        strcat(s, "</func_decl>");
        $$ = s;
    }
    | TYPE MULTIPLY ID L_BRACKET parameters R_BRACKET SEMICOLON {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+strlen($5)+strlen($6)+strlen($7)+32));
        strcpy(s, "<func_decl>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        strcat(s, $5);
        strcat(s, $6);
        strcat(s, $7);
        strcat(s, "</func_decl>");
        $$ = s;
    }
    | TYPE ID L_BRACKET R_BRACKET SEMICOLON {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+strlen($5)+32));
        strcpy(s, "<func_decl>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        strcat(s, $5);
        strcat(s, "</func_decl>");
        $$ = s;
    }
    | TYPE MULTIPLY ID L_BRACKET R_BRACKET SEMICOLON {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+strlen($5)+strlen($6)+32));
        strcpy(s, "<func_decl>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        strcat(s, $5);
        strcat(s, $6);
        strcat(s, "</func_decl>");
        $$ = s;
    }
    ;

parameters
    : parameters COMMA parameter {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+1));
        strcpy(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        $$ = s;
    }
    | parameter { $$ = $1; }
    ;

parameter
    : TYPE ID {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+1));
        strcpy(s, $1);
        strcat(s, $2);
        $$ = s;
    }
    | TYPE MULTIPLY ID {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+1));
        strcpy(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        $$ = s;
    }
    ;

func_def
    : TYPE ID L_BRACKET parameters R_BRACKET compound_stmt {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+strlen($5)+strlen($6)+30));
        strcpy(s, "<func_def>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        strcat(s, $5);
        strcat(s, $6);
        strcat(s, "</func_def>");
        $$ = s;
    }
    | TYPE MULTIPLY ID L_BRACKET parameters R_BRACKET compound_stmt {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+strlen($5)+strlen($6)+strlen($7)+30));
        strcpy(s, "<func_def>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        strcat(s, $5);
        strcat(s, $6);
        strcat(s, $7);
        strcat(s, "</func_def>");
        $$ = s;
    }
    | TYPE ID L_BRACKET R_BRACKET compound_stmt {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+strlen($5)+30));
        strcpy(s, "<func_def>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        strcat(s, $5);
        strcat(s, "</func_def>");
        $$ = s;
    }
    | TYPE MULTIPLY ID L_BRACKET R_BRACKET compound_stmt {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+strlen($5)+strlen($6)+30));
        strcpy(s, "<func_def>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        strcat(s, $5);
        strcat(s, $6);
        strcat(s, "</func_def>");
        $$ = s;
    }
    ;

expr
    : or_expr ASSIGN expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    | or_expr { $$ = $1; }
    ;

or_expr
    : or_expr OR and_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    | and_expr { $$ = $1; }
    ;

and_expr
    : and_expr AND or_op_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    | or_op_expr { $$ = $1; }
    ;

or_op_expr
    : or_op_expr OR_OP xor_op_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    | xor_op_expr { $$ = $1; }
    ;

xor_op_expr
    : xor_op_expr XOR_OP and_op_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    | and_op_expr { $$ = $1; }
    ;

and_op_expr
    : and_op_expr AND_OP equlity_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    | equlity_expr { $$ = $1; }
    ;

equlity_expr
    : equlity_expr EQUAL compare_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    | equlity_expr NOT_EQUAL compare_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    | compare_expr { $$ = $1; }
    ;

compare_expr
    : compare_expr GREATER_THAN shift_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    | compare_expr LESS_THAN shift_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    | compare_expr GREATER_OR_EQUAL_THAN shift_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    | compare_expr LESS_OR_EQUAL_THAN shift_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    | shift_expr { $$ = $1; }
    ;

shift_expr
    : shift_expr SHIFT_LEFT add_minus_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    | shift_expr SHIFT_RIGHT add_minus_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    | add_minus_expr { $$ = $1; }
    ;

add_minus_expr
    : add_minus_expr ADD arith_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    | add_minus_expr MINUS arith_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    | arith_expr { $$ = $1; }
    ;

arith_expr
    : arith_expr MULTIPLY prefix_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    | arith_expr DIVIDE prefix_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    | arith_expr PERCENT prefix_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    | prefix_expr { $$ = $1; }
    ;

prefix_expr
    : INC prefix_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, "</expr>");
        $$ = s;
    }
    | DEC prefix_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, "</expr>");
        $$ = s;
    }
    | L_BRACKET TYPE R_BRACKET prefix_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        strcat(s, "</expr>");
        $$ = s;
    }
    | L_BRACKET TYPE MULTIPLY R_BRACKET prefix_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+strlen($5)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        strcat(s, $5);
        strcat(s, "</expr>");
        $$ = s;
    }
    | ADD prefix_expr %prec UADD {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, "</expr>");
        $$ = s;
    }
    | MINUS prefix_expr %prec UMINUS {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, "</expr>");
        $$ = s;
    }
    | LOGICAL_NOT prefix_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, "</expr>");
        $$ = s;
    }
    | BITWISE_NOT prefix_expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, "</expr>");
        $$ = s;
    }
    | MULTIPLY prefix_expr %prec UMULTI {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, "</expr>");
        $$ = s;
    }
    | AND_OP prefix_expr %prec UANDOP {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, "</expr>");
        $$ = s;
    }
    | postfix_expr { $$ = $1; }
    ;

postfix_expr
    : postfix_expr INC %prec INCPOST {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, "</expr>");
        $$ = s;
    }
    | postfix_expr DEC %prec DECPOST {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, "</expr>");
        $$ = s;
    }
    | postfix_expr L_BRACKET R_BRACKET {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    | postfix_expr L_BRACKET params R_BRACKET {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        strcat(s, "</expr>");
        $$ = s;
    }
    | last_expr { $$ = $1; }
    ;

last_expr
    : ID array_sub {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, "</expr>");
        $$ = s;
    }
    | ID {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, "</expr>");
        $$ = s;
    }
    | NUM {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, "</expr>");
        $$ = s;
    }
    | FLOAT {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, "</expr>");
        $$ = s;
    }
    | STRING {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, "</expr>");
        $$ = s;
    }
    | CHAR {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, "</expr>");
        $$ = s;
    }
    | L_BRACKET expr R_BRACKET {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<expr>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</expr>");
        $$ = s;
    }
    ;

array_sub
    : array_sub L_SQ_BRACKET expr R_SQ_BRACKET {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+1));
        strcpy(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        $$ = s;
    }
    | L_SQ_BRACKET expr R_SQ_BRACKET { 
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+1));
        strcpy(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        $$ = s;
    }
    ;


params
    : params COMMA expr {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+1));
        strcpy(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        $$ = s;
    }
    | expr {
        $$ = $1;
    }
    ;


compound_stmt
    : L_CUR_BRACKET stmts R_CUR_BRACKET {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+1));
        strcpy(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        $$ = s;
    }
    | L_CUR_BRACKET R_CUR_BRACKET {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+1));
        strcpy(s, $1);
        strcat(s, $2);
        $$ = s;
    }
    ;

stmts
    : stmts stmt {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+1));
        strcpy(s, $1);
        strcat(s, $2);
        $$ = s;
    }
    | stmt { $$ = $1; }
    ;

stmt
    : scalar_decl { $$ = $1; }
    | array_decl { $$ = $1; }
    | expr SEMICOLON {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+14));
        strcpy(s, "<stmt>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, "</stmt>");
        $$ = s;
    }
    | if_else_stmt { $$ = $1; }
    | switch_stmt { $$ = $1; }
    | while_stmt { $$ = $1; }
    | for_stmt { $$ = $1; }
    | return_stmt { $$ = $1; }
    | BREAK SEMICOLON {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+14));
        strcpy(s, "<stmt>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, "</stmt>");
        $$ = s;
    }
    | CONTINUE SEMICOLON {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+14));
        strcpy(s, "<stmt>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, "</stmt>");
        $$ = s;
    }
    | compound_stmt {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+14));
        strcpy(s, "<stmt>");
        strcat(s, $1);
        strcat(s, "</stmt>");
        $$ = s;
    }
    ;

if_else_stmt
    : IF L_BRACKET expr R_BRACKET compound_stmt {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+strlen($5)+14));
        strcpy(s, "<stmt>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        strcat(s, $5);
        strcat(s, "</stmt>");
        $$ = s;
    }
    | IF L_BRACKET expr R_BRACKET compound_stmt ELSE compound_stmt {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+strlen($5)+strlen($6)+strlen($7)+14));
        strcpy(s, "<stmt>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        strcat(s, $5);
        strcat(s, $6);
        strcat(s, $7);
        strcat(s, "</stmt>");
        $$ = s;
    }

switch_stmt
    : SWITCH L_BRACKET expr R_BRACKET L_CUR_BRACKET R_CUR_BRACKET {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+strlen($5)+strlen($6)+14));
        strcpy(s, "<stmt>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        strcat(s, $5);
        strcat(s, $6);
        strcat(s, "</stmt>");
        $$ = s;
    }
    | SWITCH L_BRACKET expr R_BRACKET L_CUR_BRACKET switch_clauses R_CUR_BRACKET {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+strlen($5)+strlen($6)+strlen($7)+14));
        strcpy(s, "<stmt>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        strcat(s, $5);
        strcat(s, $6);
        strcat(s, $7);
        strcat(s, "</stmt>");
        $$ = s;
    }
    ;

switch_clauses
    : switch_clauses switch_clause {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+1));
        strcpy(s, $1);
        strcat(s, $2);
        $$ = s;
    }
    | switch_clause { $$ = $1; }
    ;

switch_clause
    : CASE expr COLON {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+1));
        strcpy(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        $$ = s;
    }
    | CASE expr COLON stmts {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+1));
        strcpy(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        $$ = s;
    }
    | DEFAULT COLON stmts {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+1));
        strcpy(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        $$ = s;
    }
    | DEFAULT COLON {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+1));
        strcpy(s, $1);
        strcat(s, $2);
        $$ = s;
    }
    ;

while_stmt
    : DO stmt WHILE L_BRACKET expr R_BRACKET SEMICOLON {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+strlen($5)+strlen($6)+strlen($7)+14));
        strcpy(s, "<stmt>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        strcat(s, $5);
        strcat(s, $6);
        strcat(s, $7);
        strcat(s, "</stmt>");
        $$ = s;
    }
    | WHILE L_BRACKET expr R_BRACKET stmt {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+strlen($4)+strlen($5)+14));
        strcpy(s, "<stmt>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, $4);
        strcat(s, $5);
        strcat(s, "</stmt>");
        $$ = s;
    }
    ;

for_stmt
    : FOR L_BRACKET for_cond for_cond for_lastcond stmt {
        char *s = (char*)malloc(sizeof(char)*(strlen($3)+strlen($4)+strlen($5)+strlen($6)+18));
        strcpy(s, "<stmt>");
        strcat(s, "for");
        strcat(s, "(");
        strcat(s, $3);
        strcat(s, $4);
        strcat(s, $5);
        strcat(s, $6);
        strcat(s, "</stmt>");
        $$ = s;
    }
    ;

for_cond
    : SEMICOLON {
        char *s = (char*)malloc(sizeof(char)*2);
        strcpy(s, ";");
        $$ = s;
    }
    | expr SEMICOLON {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+2));
        strcpy(s, $1);
        strcat(s, ";");
        $$ = s;
    }
    ;

for_lastcond
    : R_BRACKET {
        char *s = (char*)malloc(sizeof(char)*2);
        strcpy(s, ")");
        $$ = s;
    }
    | expr R_BRACKET {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+2));
        strcpy(s, $1);
        strcat(s, ")");
        $$ = s;
    }
    ;

return_stmt
    : RETURN SEMICOLON {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+14));
        strcpy(s, "<stmt>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, "</stmt>");
        $$ = s;
    }
    | RETURN expr SEMICOLON {
        char *s = (char*)malloc(sizeof(char)*(strlen($1)+strlen($2)+strlen($3)+14));
        strcpy(s, "<stmt>");
        strcat(s, $1);
        strcat(s, $2);
        strcat(s, $3);
        strcat(s, "</stmt>");
        $$ = s;
    }
    ;


%%

int main(void) {
    yydebug = 1;
    yyparse();
    return 0;
}

void yyerror(char *msg) {
    fprintf(stderr, "Error at line %d: %s\n", lineNo, msg);
    exit(1);
}
