%code requires {
#include "ast.h"
}

%{
#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

int yylex(void);
void yyerror(const char *message);
Ast *ast_root = NULL;
int syntax_error_count = 0;
%}

%union {
    long integer;
    char *text;
    Ast *node;
}

%token BEGIN_UPL END_UPL INT_TYPE BOOL_TYPE IF THEN ELSE DO WHILE FOR PRINT
%token GT GE EQ INVALID
%token <text> IDENTIFIER
%token <integer> INTEGER_LITERAL
%type <text> type
%type <node> program items item block statement declaration for_init optional_init for_update optional_condition expression comparison additive multiplicative primary
%destructor { free($$); } <text>

%locations
%define parse.error detailed
%start program

%%
program
    : BEGIN_UPL items END_UPL
      { ast_root = ast_make(AST_PROGRAM, "UPL", $2, NULL, NULL); }
    ;

items
    : %empty                         { $$ = NULL; }
    | items item                     { $$ = ast_append($1, $2); }
    | items error ';'                { $$ = $1; yyerrok; }
    ;

item
    : declaration ';'                { $$ = $1; }
    | statement                      { $$ = $1; }
    ;

type
    : INT_TYPE                       { $$ = ast_strdup("int"); }
    | BOOL_TYPE                      { $$ = ast_strdup("bool"); }
    ;

declaration
    : type IDENTIFIER
      { $$ = ast_make(AST_DECL, $1, ast_make(AST_IDENTIFIER, $2, NULL, NULL, NULL), NULL, NULL); free($1); free($2); }
    | type IDENTIFIER '=' expression
      { $$ = ast_make(AST_DECL, $1, ast_make(AST_IDENTIFIER, $2, NULL, NULL, NULL), $4, NULL); free($1); free($2); }
    ;

block
    : '{' items '}'                  { $$ = ast_make(AST_BLOCK, NULL, $2, NULL, NULL); }
    ;

statement
    : block                          { $$ = $1; }
    | IDENTIFIER '=' expression ';'
      { $$ = ast_make(AST_ASSIGN, $1, $3, NULL, NULL); free($1); }
    | IF '(' expression ')' THEN block
      { $$ = ast_make(AST_IF, NULL, $3, $6, NULL); }
    | IF '(' expression ')' THEN block ELSE block
      { $$ = ast_make(AST_IF, "else", $3, $6, $8); }
    | DO block WHILE '(' expression ')' ';'
      { $$ = ast_make(AST_DO_WHILE, NULL, $2, $5, NULL); }
    | FOR '(' optional_init ';' optional_condition ';' for_update ')' block
      { $$ = ast_make(AST_FOR, NULL, $3, $5, ast_make(AST_BLOCK, "update", $7, $9, NULL)); }
    | PRINT '(' expression ')' ';'
      { $$ = ast_make(AST_PRINT, NULL, $3, NULL, NULL); }
    ;

optional_init
    : %empty                         { $$ = NULL; }
    | for_init                       { $$ = $1; }
    ;

for_init
    : type IDENTIFIER
      { $$ = ast_make(AST_DECL, $1, ast_make(AST_IDENTIFIER, $2, NULL, NULL, NULL), NULL, NULL); free($1); free($2); }
    | type IDENTIFIER '=' expression
      { $$ = ast_make(AST_DECL, $1, ast_make(AST_IDENTIFIER, $2, NULL, NULL, NULL), $4, NULL); free($1); free($2); }
    | IDENTIFIER '=' expression
      { $$ = ast_make(AST_ASSIGN, $1, $3, NULL, NULL); free($1); }
    ;

optional_condition
    : %empty                         { $$ = NULL; }
    | expression                     { $$ = $1; }
    ;

for_update
    : %empty                         { $$ = NULL; }
    | IDENTIFIER '=' expression
      { $$ = ast_make(AST_ASSIGN, $1, $3, NULL, NULL); free($1); }
    ;

expression
    : comparison                     { $$ = $1; }
    ;

comparison
    : additive                       { $$ = $1; }
    | additive GT additive           { $$ = ast_make(AST_BINARY, ">", $1, $3, NULL); }
    | additive GE additive           { $$ = ast_make(AST_BINARY, ">=", $1, $3, NULL); }
    | additive EQ additive           { $$ = ast_make(AST_BINARY, "==", $1, $3, NULL); }
    ;

additive
    : additive '+' multiplicative    { $$ = ast_make(AST_BINARY, "+", $1, $3, NULL); }
    | multiplicative                 { $$ = $1; }
    ;

multiplicative
    : multiplicative '*' primary    { $$ = ast_make(AST_BINARY, "*", $1, $3, NULL); }
    | primary                        { $$ = $1; }
    ;

primary
    : INTEGER_LITERAL                { $$ = ast_integer($1); }
    | IDENTIFIER                     { $$ = ast_make(AST_IDENTIFIER, $1, NULL, NULL, NULL); free($1); }
    | '(' expression ')'             { $$ = $2; }
    ;

%%

void yyerror(const char *message) {
    fprintf(stderr, "Syntax error near line %d: %s\n", yylloc.first_line, message);
    ++syntax_error_count;
}
