#ifndef UPL_AST_H
#define UPL_AST_H

typedef enum {
    AST_PROGRAM, AST_BLOCK, AST_DECL, AST_ASSIGN, AST_IF, AST_DO_WHILE,
    AST_FOR, AST_PRINT, AST_BINARY, AST_IDENTIFIER, AST_INTEGER
} AstKind;

typedef struct Ast Ast;
struct Ast {
    AstKind kind;
    char *text;
    long integer;
    Ast *left;
    Ast *middle;
    Ast *right;
    Ast *next;
};

char *ast_strdup(const char *s);
Ast *ast_make(AstKind kind, const char *text, Ast *left, Ast *middle, Ast *right);
Ast *ast_integer(long value);
Ast *ast_append(Ast *list, Ast *item);
void ast_print(const Ast *node, int depth);
void ast_free(Ast *node);
const char *ast_kind_name(AstKind kind);

#endif
