%{
    #include <stdio.h>
    #include <string.h>

    char cur_line[300];
    int num_lines = 1;
    int pragma_source = 1;
    int pragma_token = 1;

    FILE *debug_file;
    int debug = 0;
    void debug_init()
    {
        debug_file = fopen("debug.txt", "w");
        debug = 1;
    }

%}

%x COMMENT

KEY "for"|"do"|"while"|"break"|"continue"|"if"|"else"|"return"|"struct"|"switch"|"case"|"default"|"void"|"int"|"double"|"float"|"char"|"const"|"signed"|"unsigned"|"short"|"long"
MACRO "NULL"|"__COUNTER__"|"__LINE__"|"INT_MAX"|"INT_MIN"|"CHAR_MAX"|"CHAR_MIN"|"MAX"|"MIN"
ID ((_|[a-zA-Z])(_|[a-zA-Z]|[0-9])*)
OP ("+"|"-"|"*"|"/"|"%"|"++"|"--"|"<"|">"|"<="|">="|"="|"=="|"!="|"&&"|"||"|"!"|"&"|"|")
PUNC (":"|";"|","|"."|"["|"]"|"("|")"|"{"|"}")
INTEGER ([+-]?)[0-9]+
FLOAT (([+-]?)[0-9]*"."[0-9]+)|([+-]?[0-9]+"."[0-9]*)
CHAR \'(.|"\\a"|"\\b"|"\\e"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v"|"\\\\"|"\\'"|"\\\""|"\\\?"|"\\0"|"\\"([[:digit:]]{1,3})|"\\x"([0-9A-Fa-f]+)|"\\u"([0-9A-Fa-f]{4})|"\\U"([0-9A-Fa-f]{8}))?\'
STRING \"(.|"\\a"|"\\b"|"\\e"|"\\f"|"\\n"|"\\r"|"\\t"|"\\v"|"\\\\"|"\\'"|"\\\""|"\\\?"|"\\0"|"\\"([[:digit:]]{1,3})|"\\x"([0-9A-Fa-f]+)|"\\u"([0-9A-Fa-f]{4,4})|"\\U"([0-9A-Fa-f]{8,8}))*\"

BLANK " "|[\t]

%%

\n {
    if (pragma_source)
        printf("%d:%s\n", num_lines, cur_line);
    if (debug)
        fprintf(debug_file, "%d:%s\n", num_lines, cur_line);
    num_lines++;
    memset(cur_line, 0, sizeof(cur_line));
}

{KEY} { if (pragma_token) printf("#key:%s\n", yytext); strcat(cur_line, yytext); }
{MACRO} { if (pragma_token) printf("#macro:%s\n", yytext); strcat(cur_line, yytext); }
{ID} { if (pragma_token) printf("#id:%s\n", yytext); strcat(cur_line, yytext); }
{OP} { if (pragma_token) printf("#op:%s\n", yytext); strcat(cur_line, yytext); }
{PUNC} { if (pragma_token) printf("#punc:%s\n", yytext); strcat(cur_line, yytext); }
{INTEGER} { if (pragma_token) printf("#integer:%s\n", yytext); strcat(cur_line, yytext); }
{FLOAT} { if (pragma_token) printf("#float:%s\n", yytext); strcat(cur_line, yytext); }
{CHAR} { if (pragma_token) printf("#char:%s\n", yytext); strcat(cur_line, yytext); }
{STRING} { if (pragma_token) printf("#string:%s\n", yytext); strcat(cur_line, yytext); }

{BLANK} { strcat(cur_line, yytext); }

#{BLANK}*pragma{BLANK}+source{BLANK}+on   { pragma_source = 1; strcat(cur_line, yytext); }
#{BLANK}*pragma{BLANK}+source{BLANK}+off  { pragma_source = 0; strcat(cur_line, yytext);}
#{BLANK}*pragma{BLANK}+token{BLANK}+on    { pragma_token = 1; strcat(cur_line, yytext);  }
#{BLANK}*pragma{BLANK}+token{BLANK}+off   { pragma_token = 0; strcat(cur_line, yytext); }


"//".*                   { strcat(cur_line, yytext); }
"/*"                     { strcat(cur_line, yytext); BEGIN COMMENT;}
<COMMENT>"*/"            { strcat(cur_line, yytext); BEGIN 0;}
<COMMENT>.               { strcat(cur_line, yytext); }
<COMMENT>\n              {
    printf("%d:%s\n", num_lines, cur_line);
    if (debug)
        fprintf(debug_file, "%d:%s\n", num_lines, cur_line);
    num_lines++;
    memset(cur_line, 0, sizeof(cur_line));
}

%%

int main(int argc, char **argv)
{
    if (debug) debug_init();
    yylex();
    return 0;
}