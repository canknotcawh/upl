#include "ast.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

char *ast_strdup(const char *s) {
    size_t n;
    char *copy;
    if (s == NULL) return NULL;
    n = strlen(s) + 1;
    copy = (char *)malloc(n);
    if (copy != NULL) memcpy(copy, s, n);
    return copy;
}

Ast *ast_make(AstKind kind, const char *text, Ast *left, Ast *middle, Ast *right) {
    Ast *node = (Ast *)calloc(1, sizeof(*node));
    if (node == NULL) return NULL;
    node->kind = kind;
    node->text = ast_strdup(text);
    node->left = left;
    node->middle = middle;
    node->right = right;
    return node;
}

Ast *ast_integer(long value) {
    Ast *node = ast_make(AST_INTEGER, NULL, NULL, NULL, NULL);
    if (node != NULL) node->integer = value;
    return node;
}

Ast *ast_append(Ast *list, Ast *item) {
    Ast *tail;
    if (item == NULL) return list;
    if (list == NULL) return item;
    tail = list;
    while (tail->next != NULL) tail = tail->next;
    tail->next = item;
    return list;
}

const char *ast_kind_name(AstKind kind) {
    static const char *names[] = {
        "Program", "Block", "Declaration", "Assignment", "If", "DoWhile",
        "For", "Print", "Binary", "Identifier", "Integer"
    };
    if ((unsigned)kind >= sizeof(names) / sizeof(names[0])) return "Unknown";
    return names[kind];
}

static void print_indent(int depth) {
    int i;
    for (i = 0; i < depth; ++i) printf("  ");
}

void ast_print(const Ast *node, int depth) {
    while (node != NULL) {
        print_indent(depth);
        printf("%s", ast_kind_name(node->kind));
        if (node->text != NULL) printf(" (%s)", node->text);
        if (node->kind == AST_INTEGER) printf(" (%ld)", node->integer);
        putchar('\n');
        if (node->left != NULL) {
            print_indent(depth + 1); puts("left:");
            ast_print(node->left, depth + 2);
        }
        if (node->middle != NULL) {
            print_indent(depth + 1); puts("middle:");
            ast_print(node->middle, depth + 2);
        }
        if (node->right != NULL) {
            print_indent(depth + 1); puts("right:");
            ast_print(node->right, depth + 2);
        }
        node = node->next;
    }
}

void ast_free(Ast *node) {
    while (node != NULL) {
        Ast *next = node->next;
        ast_free(node->left);
        ast_free(node->middle);
        ast_free(node->right);
        free(node->text);
        free(node);
        node = next;
    }
}
