# UPL Flex/Bison demo (C)

A small source-code demo for the UPL language in BTL01-2026. It contains a Flex lexer, a Bison parser, C AST helpers, and sample programs. It parses syntax and prints an AST; it does not evaluate programs or check variable declarations and types.

## Language features in this demo

- `begin ... end` program boundaries
- `int` and `bool` declarations, optionally initialized
- identifiers beginning with a letter, followed only by letters and optional trailing digits
- `+`, `*`, `>`, `>=`, and `==`; multiplication binds more tightly than addition
- parenthesized expressions
- `if (...) then { ... }` and `if (...) then { ... } else { ... }`
- `do { ... } while (...);`
- C-style `for (init; condition; update) { ... }`
- `print(expression);`
- `//` and `/* ... */` comments
- line-aware syntax and lexical diagnostics; parser recovery at semicolons
- a shared token, source-location, and AST interface described in `INTEGRATION_CONTRACT.md`

Booleans are a type in the assignment, but boolean literals are not specified there and are intentionally not added in this demo. Comparisons can be used to initialize a `bool` variable syntactically.

## Build

Requirements: GCC, Flex, Bison, and GNU Make. On Windows, use an MSYS2 MinGW64 or UCRT64 terminal with these tools installed. Then run:

```sh
make
```

The build creates `upl` (or `upl.exe` under MinGW).

## Run examples

```sh
./upl examples/valid.upl
./upl examples/invalid.upl
```

On Windows, use `upl.exe` in place of `./upl` if needed. The valid example prints an AST. The invalid example demonstrates line-numbered diagnostics.

## Source files

- `lexer.l`: Flex token rules and comment handling
- `parser.y`: Bison grammar and AST construction actions
- `ast.h`, `ast.c`: AST representation, printing, and cleanup
- `main.c`: file input and parse result reporting
- `examples/`: valid and invalid UPL programs
- `INTEGRATION_CONTRACT.md`: token values, location handling, AST shape, and parallel-work agreement
- `tests/parser/`: accepted/rejected parser inputs and a PowerShell smoke-test script

The assignment sheet does not define a concrete `for` syntax; this demo adopts the common C-style form shown above. The grammar also follows the assignment's sample by requiring braces around `if`, loop, and `for` bodies.
