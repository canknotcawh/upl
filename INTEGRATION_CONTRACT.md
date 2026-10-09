# UPL Lexer and Parser Integration Contract

This document defines the interface for parallel work on the UPL lexer and parser. The parser and AST files are the reference implementation. The lexer contributor should implement `lexer.l` to return the tokens and values below without changing `parser.y` or `ast.h` unless the two contributors agree on an interface change first.

## 1. Source of truth and file ownership

| File | Owner | Purpose |
|---|---|---|
| `parser.y` | Member 2 | Bison grammar, AST construction, syntax-error recovery |
| `ast.h`, `ast.c` | Member 2 | Shared AST types and helper functions |
| `lexer.l` | Member 1 | Flex rules, token values, lexical errors and source positions |
| `INTEGRATION_CONTRACT.md` | Both | Stable interface and decisions |

Do not hand-edit generated `parser.tab.c`, `parser.tab.h`, or `scanner.c`. The Makefile regenerates them from `parser.y` and `lexer.l`. A lexer branch should be based on the commit containing this contract, then merge its `lexer.l` changes back into the shared branch.

## 2. Token interface

`lexer.l` must include the generated `parser.tab.h`. Return these named tokens exactly:

| Source text | Token | Semantic value |
|---|---|---|
| `begin`, `end` | `BEGIN_UPL`, `END_UPL` | none |
| `int`, `bool` | `INT_TYPE`, `BOOL_TYPE` | none |
| `if`, `then`, `else` | `IF`, `THEN`, `ELSE` | none |
| `do`, `while`, `for` | `DO`, `WHILE`, `FOR` | none |
| `print` | `PRINT` | none |
| `>` | `GT` | none |
| `>=` | `GE` | none |
| `==` | `EQ` | none |
| identifier | `IDENTIFIER` | `yylval.text`, a heap-allocated, null-terminated `char *` |
| decimal integer | `INTEGER_LITERAL` | `yylval.integer`, type `long` |
| invalid input | `INVALID` | none |

Return these punctuation characters directly as character tokens: `(`, `)`, `{`, `}`, `;`, `=`, `+`, `*`. Whitespace and both comment forms (`//...` and `/*...*/`) are skipped. Match `>=` and `==` before their one-character prefixes.

Identifier rule: one or more ASCII letters, optionally followed by one or more digits. Digits cannot appear before a later letter. Thus `abc`, `abc12` are valid; `a1b` is invalid. Keywords are recognized as keywords only when the entire lexeme matches, so `begin2` remains an identifier.

`IDENTIFIER` strings must be separately allocated for each token. Parser actions copy names into AST nodes and then free the token string; Bison also has a destructor for strings discarded during error recovery. Do not return a pointer into Flex's reusable `yytext` buffer.

For a lexical error, print a message with the 1-based source position, increment `lexical_error_count`, and return `INVALID`. The counter is defined by the lexer and read by `main.c`.

## 3. Source positions

The parser is built with Bison `%locations`. For every returned token, the lexer must set:

```c
yylloc.first_line
yylloc.first_column
yylloc.last_line
yylloc.last_column
```

Lines and columns are 1-based. Count each source character, including a tab, as one column. Advance the line and reset the column after `\n`. `yyerror` uses the first position and prints `Syntax error at line:column: ...`. Unterminated block comments should report their opening position.

The existing Flex file has a `YY_USER_ACTION` location tracker to demonstrate this interface. If it is rewritten, keep the same `YYLTYPE` contract and include `parser.tab.h` so the location type is available.

## 4. AST shape

`Ast` nodes have `kind`, optional `text`, optional `integer`, three child pointers (`left`, `middle`, `right`) and a sibling pointer (`next`). `next` links items in a program or block; it is not a child pointer. Never attach one node to more than one parent.

| Kind | Fields |
|---|---|
| `AST_PROGRAM` | `left`: top-level item list |
| `AST_BLOCK` | `left`: block item list |
| `AST_DECL` | `text`: `"int"` or `"bool"`; `left`: identifier node; `middle`: optional initializer expression |
| `AST_ASSIGN` | `text`: target variable name; `left`: value expression |
| `AST_IF` | `left`: condition; `middle`: then-block; `right`: optional else-block |
| `AST_DO_WHILE` | `left`: body block; `middle`: condition |
| `AST_FOR` | `left`: optional initializer; `middle`: optional condition; `right`: `AST_FOR_TAIL` node |
| `AST_FOR_TAIL` | `left`: optional update assignment; `middle`: loop body block |
| `AST_PRINT` | `left`: printed expression |
| `AST_BINARY` | `text`: operator; `left` and `middle`: operands |
| `AST_IDENTIFIER` | `text`: identifier name |
| `AST_INTEGER` | `integer`: literal value |

AST constructors copy `text`. The caller retains ownership of the input string and should free it after constructing the node. Child pointers transfer ownership to the parent. Sibling lists transfer ownership to their containing program or block. `ast_free` recursively releases an owned tree.

## 5. Grammar decisions in this implementation

- Program form: `begin ... end`.
- Declarations end in `;`; assignments and `print` statements end in `;`.
- `if`, `do/while`, and `for` bodies use braces, matching the assignment examples.
- `for` uses `for (init; condition; update) { ... }`; init, condition, and update may be omitted. Update is an assignment.
- Expression precedence is `*` above `+`; parentheses can group expressions.
- Comparisons are `>`, `>=`, and `==`. This grammar permits one comparison operator in an expression.
- `bool` literals are not added because the assignment does not define their spelling.
- Syntax recovery synchronizes at `;` inside the current item list. Diagnostics include line and column.

These are implementation choices where the assignment leaves syntax open. Raise a proposed change before editing the grammar so the examples, lexer, and parser stay aligned.

## 6. Integration checklist

1. Member 1 implements the lexer against the token table and location contract.
2. Member 2 keeps the parser and AST API stable while that work proceeds.
3. Merge the lexer change, then build from source with `make` so Bison regenerates the token header before Flex compiles.
4. Run the valid and invalid UPL examples; add cases for every token, comments, identifier edge cases, precedence, nested blocks, and syntax errors on separate lines.
5. Review any interface changes together and update this document and both components in the same merge.
