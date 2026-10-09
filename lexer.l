%option noyywrap yylineno
%x COMMENT
%{
#include <stdio.h>
#include <stdlib.h>
#include "parser.tab.h"
#include "ast.h"

int lexical_error_count = 0;
static int comment_start_line = 1;
static int comment_start_column = 1;
static int scan_line = 1;
static int scan_column = 1;

#define YY_USER_ACTION do { \
    int i; \
    yylloc.first_line = scan_line; \
    yylloc.first_column = scan_column; \
    for (i = 0; i < yyleng; ++i) { \
        if (yytext[i] == '\n') { ++scan_line; scan_column = 1; } \
        else { ++scan_column; } \
    } \
    yylloc.last_line = scan_line; \
    yylloc.last_column = scan_column > 1 ? scan_column - 1 : 1; \
} while (0);
%}

LETTER      [A-Za-z]
VALID_ID    {LETTER}+([0-9]*)
INVALID_ID  {LETTER}+[0-9]+{LETTER}[A-Za-z0-9]*

%%

"begin"         return BEGIN_UPL;
"end"           return END_UPL;
"int"           return INT_TYPE;
"bool"          return BOOL_TYPE;
"if"            return IF;
"then"          return THEN;
"else"          return ELSE;
"do"            return DO;
"while"         return WHILE;
"for"           return FOR;
"print"         return PRINT;

"=="            return EQ;
">="            return GE;
">"             return GT;

{INVALID_ID}     { fprintf(stderr, "Lexical error at %d:%d: identifier '%s' has digits before trailing letters.\n", yylloc.first_line, yylloc.first_column, yytext); ++lexical_error_count; return INVALID; }
{VALID_ID}       { yylval.text = ast_strdup(yytext); return IDENTIFIER; }
[0-9]+           { yylval.integer = strtol(yytext, NULL, 10); return INTEGER_LITERAL; }

"//"[^\n]*      { /* single-line comment */ }
"/*"            { comment_start_line = yylloc.first_line; comment_start_column = yylloc.first_column; BEGIN(COMMENT); }
<COMMENT>"*/"    { BEGIN(INITIAL); }
<COMMENT>\n      { /* yylineno is updated by Flex */ }
<COMMENT>.       { /* ignore comment contents */ }
<COMMENT><<EOF>> {
                    yylloc.first_line = yylloc.last_line = comment_start_line;
                    yylloc.first_column = yylloc.last_column = comment_start_column;
                    fprintf(stderr, "Lexical error at %d:%d: unterminated block comment.\n", comment_start_line, comment_start_column);
                    ++lexical_error_count;
                    BEGIN(INITIAL);
                    return INVALID;
                 }

[ \t\r\n]+     { /* whitespace */ }
[{}();=+*]       { return yytext[0]; }
.                { fprintf(stderr, "Lexical error at %d:%d: unexpected character '%s'.\n", yylloc.first_line, yylloc.first_column, yytext); ++lexical_error_count; return INVALID; }

%%
