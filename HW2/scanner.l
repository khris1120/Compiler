%{
    #include <stdio.h>
    #include <string.h>
    #include "y.tab.h"

    FILE *debug_file;
    int debug = 0;
    void debug_init()
    {
        debug_file = fopen("debug.txt", "w");
        debug = 1;
    }

    void remove_space(char *s) {
        char *new = (char*)malloc(sizeof(char)*strlen(s));
        for (int i = 0, j = 0; i < strlen(s); i++) {
            if (s[i] != ' ') {
                new[j] = s[i];
                j++;
            }
        }
        strcpy(s, new);
    }

    int assign_string(int token, const char *str) {
        yylval.stringVal = strdup(str);
        return token;
    }

%}

ID (_|[a-zA-Z])(_|[a-zA-Z]|[0-9])*
INTEGER [0-9]+
FLOAT ("."[0-9]+|[0-9]+"."|[0-9]+"."[0-9]+)
SPACE " "|"\t"
TYPE (("const"(" ")+)?("signed"(" ")+|"unsigned"(" ")+)?("long long"(" ")+|"long"(" ")+|"short"(" ")+)?"int")|(("const"(" ")+)?("signed"(" ")+|"unsigned"(" ")+)?("long long"|"long"|"short"|"char"))|(("const"(" ")+)?("signed"|"unsigned"|"float"|"double"|"void"))|"const"|"char"|"signed"|"unsigned"|"float"|"double"|"void"
CHAR \'(\\\'|\\[^\']|[^\n'\\])*\'  
STRING \"(\\\"|\\[^\"]|[^\n"\\])*\"
NEWLINE "\n"

%x COMMENT

%%

{SPACE} {}
{NEWLINE} {}
{TYPE} {
    remove_space(yytext);
    yylval.stringVal = strdup(yytext);
    return TYPE;
}
"NULL" {
    yylval.stringVal = strdup("0");
    return NUM;
}

"if" { return assign_string(IF, "if"); }
"else" { return assign_string(ELSE, "else");}
"switch" { return assign_string(SWITCH, "switch");}
"case" { return assign_string(CASE, "case");}
"default" { return assign_string(DEFAULT, "default");}
"do" { return assign_string(DO, "do");}
"while" { return assign_string(WHILE, "while");}
"for" { return assign_string(FOR, "for");}
"return" { return assign_string(RETURN, "return");}
"break" { return assign_string(BREAK, "break"); }
"continue" { return assign_string(CONTINUE, "continue");}


"+" { return assign_string(ADD, "+"); }
"-" { return assign_string(MINUS, "-");}
"*" { return assign_string(MULTIPLY, "*"); }
"/" { return assign_string(DIVIDE, "/"); }
"%" { return assign_string(PERCENT, "%"); }
"++" { return assign_string(INC, "++"); }
"--" { return assign_string(DEC, "--"); }
"<" { return assign_string(LESS_THAN, "<"); }
"<=" { return assign_string(LESS_OR_EQUAL_THAN, "<="); }
">" { return assign_string(GREATER_THAN, ">"); }
">=" { return assign_string(GREATER_OR_EQUAL_THAN, ">="); }
"==" { return assign_string(EQUAL, "=="); }
"!=" { return assign_string(NOT_EQUAL, "!="); }
"=" { return assign_string(ASSIGN, "="); }
"&&" { return assign_string(AND, "&&"); }
"||" { return assign_string(OR, "||"); }
"!" { return assign_string(LOGICAL_NOT, "!"); }
"~" { return assign_string(BITWISE_NOT, "~"); }
"^" { return assign_string(XOR_OP, "^"); }
"&" { return assign_string(AND_OP, "&"); }
"|" { return assign_string(OR_OP, "|"); }
">>" { return assign_string(SHIFT_RIGHT, ">>"); }
"<<" { return assign_string(SHIFT_LEFT, "<<"); }

";" { return assign_string(SEMICOLON, ";"); }
"," { return assign_string(COMMA, ","); }
":" { return assign_string(COLON, ":"); }
"(" { return assign_string(L_BRACKET, "("); }
")" { return assign_string(R_BRACKET, ")"); }
"[" { return assign_string(L_SQ_BRACKET, "["); }
"]" { return assign_string(R_SQ_BRACKET, "]"); }
"{" { return assign_string(L_CUR_BRACKET, "{"); }
"}" { return assign_string(R_CUR_BRACKET, "}"); }

{ID} {
    yylval.stringVal = strdup(yytext);
    return ID;
}

{INTEGER} {
    int val = atoi(yytext);
    int tmp = val;
    int i = 0;
    while (tmp > 0) {
        tmp /= 10;
        i++;
    }
    char *new_str = (char*)malloc(sizeof(char)*i);
    sprintf(new_str, "%d", val);
    yylval.stringVal = new_str;
    return NUM;
}

{FLOAT} {
    double val = atof(yytext);
    char *new_str = (char*)malloc(sizeof(char)*33);
    sprintf(new_str, "%f", val);
    yylval.stringVal = new_str;
    return FLOAT;
}


{STRING} {
    yylval.stringVal = strdup(yytext);
    return STRING;
}

{CHAR} {
    yylval.stringVal = yytext;
    return CHAR;
}

"//".*                   {}
"/*"                     {BEGIN COMMENT;}
<COMMENT>"*/"            {BEGIN 0;}
<COMMENT>.               {}
<COMMENT>\n              {}

%%