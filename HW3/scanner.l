%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"

char cur_line[300];
int line_num = 0;

void remove_spaces(char *s) {
    char *new_str = (char*)malloc(sizeof(char)*strlen(s));
    for (int i = 0, j = 0; i < strlen(s); i++) {
        if (s[i] != ' ') {
            new_str[j] = s[i];
            j++;
        }
    }
    strcpy(s, new_str);
}

%}

%x COMMENT
%x MULTIPLE_COMMENTS

ID [a-zA-Z_][[:alnum:]_]*
INTEGER [0-9]+
BLANK " "|[\t]
TYPE (("const"(" ")+)?("signed"(" ")+|"unsigned"(" ")+)?("long long"(" ")+|"long"(" ")+|"short"(" ")+)?"int")|(("const"(" ")+)?("signed"(" ")+|"unsigned"(" ")+)?("long long"(" ")+|"long"(" ")+|"short"(" ")+|"char"(" ")+))|(("const"(" ")+)?("signed"(" ")+|"unsigned"(" ")+|"float"(" ")+|"double"(" ")+|"void"(" ")+))|("const")|"char4"|"char8"|"uint32_t"
LINE "\n"

%%

"/*" {
    BEGIN MULTIPLE_COMMENTS;
}

"//" {
    BEGIN COMMENT;
}

<MULTIPLE_COMMENTS>([^\n]) {
    
}

<MULTIPLE_COMMENTS>"*/" {
    BEGIN 0;
}

<COMMENT>[^\n] {
    
}

<MULTIPLE_COMMENTS>{LINE} {
    
}

<COMMENT>{LINE} {
    BEGIN 0;
}

"NULL" {
    yylval.intVal = 0;
    return NUM;
}

"if" { return IF; }
"else" { return ELSE; }
"do" { return DO; }
"while" { return WHILE; }
"for" { return FOR; }
"return" { return RETURN; }
"break" { return BREAK;}
"continue" { return CONTINUE; }

"HIGH" {
    yylval.intVal = 1;
    return NUM;
}

"LOW" {
    yylval.intVal = 0;
    return NUM;
}

"ext_dsp_codegen" {yylval.stringVal = strdup(yytext); return EXTDSPCODEGEN;}
"__rv__ukadd8"   {yylval.stringVal = strdup(yytext); return __RV__UKADD8;}
"__rv__cmpeq8"   {yylval.stringVal = strdup(yytext); return __RV__CMPEQ8;}
"__rv__ucmplt8"  {yylval.stringVal = strdup(yytext); return __RV__UCMPLT8;}
"__rv__uksub8"   {yylval.stringVal = strdup(yytext); return __RV__UKSUB8;}

{TYPE} {
    remove_spaces(yytext);
    yylval.stringVal = strdup(yytext);
    return TYPE;
}

{ID} {
    yylval.stringVal = strdup(yytext);
    return ID;
}

{INTEGER} {
    yylval.intVal = atoi(yytext);
    return NUM;
}

{BLANK} { }
{LINE} { }

"<=" { return LESS_OR_EQUAL_THAN; }
">=" { return GREATER_OR_EQUAL_THAN; }
"==" { return EQUAL; }
"!=" { return NOT_EQUAL; }
"+" { return ADD; }
"-" { return MINUS; }
"*" { return MULTIPLY; }
"/" { return DIVIDE; }
"<" { return LESS_THAN; }
">" { return GREATER_THAN; }
"&" { return AND_OP; }
"=" { return ASSIGN; }

";" { return SEMICOLON; }
"," { return COMMA; }
"(" { return L_BRACKET; }
")" { return R_BRACKET; }
"[" { return L_SQ_BRACKET; }
"]" { return R_SQ_BRACKET; }
"{" { return L_CUR_BRACKET; }
"}" { return R_CUR_BRACKET; }

%%
