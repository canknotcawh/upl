#include <stdio.h>
#include "ast.h"

int yyparse(void);
extern FILE *yyin;
extern int yylineno;
extern Ast *ast_root;
extern int syntax_error_count;
extern int lexical_error_count;

int main(int argc, char **argv) {
    int result;
    if (argc > 2) {
        fprintf(stderr, "Usage: %s [source.upl]\n", argv[0]);
        return 2;
    }
    if (argc == 2) {
        yyin = fopen(argv[1], "r");
        if (yyin == NULL) {
            perror(argv[1]);
            return 2;
        }
    }
    yylineno = 1;
    result = yyparse();
    if (result == 0 && syntax_error_count == 0 && lexical_error_count == 0) {
        puts("Parse successful. AST:");
        ast_print(ast_root, 0);
    } else {
        fprintf(stderr, "Parse failed: %d syntax error(s), %d lexical error(s).\n", syntax_error_count, lexical_error_count);
    }
    ast_free(ast_root);
    if (argc == 2) fclose(yyin);
    return (result == 0 && syntax_error_count == 0 && lexical_error_count == 0) ? 0 : 1;
}
