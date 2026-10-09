# UPL grammar used by the demo

The grammar is expressed in a compact EBNF-like notation. `*` means zero or more repetitions and `{ ... }` denotes a block.

```text
program       ::= begin item* end
item          ::= declaration ";" | statement
declaration   ::= type identifier ["=" expression]
type          ::= "int" | "bool"
statement     ::= block
                 | identifier "=" expression ";"
                 | "if" "(" expression ")" "then" block ["else" block]
                 | "do" block "while" "(" expression ")" ";"
                 | "for" "(" [for-init] ";" [expression] ";" [assignment] ")" block
                 | "print" "(" expression ")" ";"
block         ::= "{" item* "}"
for-init      ::= declaration-without-semicolon | assignment-without-semicolon
expression    ::= comparison
comparison    ::= additive [(">" | ">=" | "==") additive]
additive      ::= multiplicative ("+" multiplicative)*
multiplicative ::= primary ("*" primary)*
primary       ::= integer | identifier | "(" expression ")"
```

The grammar establishes `*` precedence over `+` structurally. This demo intentionally limits comparisons to one comparison operator per expression, which is sufficient for the operators described in the assignment.
