# Parser test cases

These inputs check syntax acceptance, AST construction, precedence, nested statements, error locations, and parser recovery. They rely on the agreed `lexer.l` interface in `INTEGRATION_CONTRACT.md`.

## Cases

| File | Expected result | What it covers |
|---|---|---|
| `valid/minimal.upl` | Accept; print `Program (UPL)` | Empty program body |
| `valid/expressions.upl` | Accept; AST contains declarations, comparisons, and binary nodes | `*` precedence over `+`, grouping, all comparison syntax used here |
| `valid/nested_if.upl` | Accept; AST has nested `If` nodes and both branches | Nested `if/then/else` association |
| `valid/loops_and_comments.upl` | Accept; AST has `DoWhile` and `For` nodes | Loop grammar, optional `for` fields, comments, nested blocks |
| `invalid/missing_semicolon.upl` | Reject; syntax diagnostic points to a source position | Missing declaration terminator |
| `invalid/missing_operand.upl` | Reject; syntax diagnostic points to line 2; parser should continue to the next item | Incomplete expression and recovery at `;` |
| `invalid/missing_then.upl` | Reject; syntax diagnostic points to line 2 | Required `then` keyword |
| `invalid/multiple_errors.upl` | Reject; at least two syntax diagnostics on separate lines; later items should still be parsed where recovery allows | Multiple errors and recovery at semicolons |

Columns and lines are 1-based. Exact wording from Bison may vary by version, so automated checks should assert the diagnostic prefix and source position rather than the complete parser message.

## Run manually

From the project root after building:

```sh
./upl tests/parser/valid/expressions.upl
./upl tests/parser/invalid/multiple_errors.upl
```

On Windows use `upl.exe` if that is the generated executable name.

## Automated smoke run

In PowerShell from the project root:

```powershell
powershell -ExecutionPolicy Bypass -File tests/parser/run-tests.ps1
```

The script checks valid/invalid exit status, selected AST shapes (including both precedence and grouping), line/column diagnostics, and multiple-error reporting. It does not compare the entire AST text, so formatting changes do not make the checks brittle.
