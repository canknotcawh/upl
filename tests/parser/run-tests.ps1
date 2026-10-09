param(
    [string]$Executable = (Join-Path $PSScriptRoot '..\..\upl.exe')
)

$Executable = [System.IO.Path]::GetFullPath($Executable)
if (-not (Test-Path -LiteralPath $Executable)) {
    Write-Error "Parser executable not found: $Executable. Build the project first."
    exit 2
}

$cases = @(
    @{ Path = 'valid/minimal.upl'; Valid = $true },
    @{ Path = 'valid/expressions.upl'; Valid = $true; AstPatterns = @('Binary \(\+\)\s+left:\s+Integer \(1\)\s+middle:\s+Binary \(\*\)', 'Binary \(\*\)\s+left:\s+Binary \(\+\)') },
    @{ Path = 'valid/nested_if.upl'; Valid = $true; AstPatterns = @('If') },
    @{ Path = 'valid/loops_and_comments.upl'; Valid = $true; AstPatterns = @('DoWhile', 'For', 'ForTail') },
    @{ Path = 'invalid/missing_semicolon.upl'; Valid = $false },
    @{ Path = 'invalid/missing_operand.upl'; Valid = $false },
    @{ Path = 'invalid/missing_then.upl'; Valid = $false },
    @{ Path = 'invalid/multiple_errors.upl'; Valid = $false; Multiple = $true }
)

$failures = 0
foreach ($case in $cases) {
    $inputPath = Join-Path $PSScriptRoot $case.Path
    $output = & $Executable $inputPath 2>&1 | Out-String
    $exitCode = $LASTEXITCODE
    $name = $case.Path
    $passed = $true

    if ($case.Valid) {
        $passed = ($exitCode -eq 0) -and ($output -match 'Parse successful\.') -and ($output -match 'Program \(UPL\)')
        foreach ($pattern in $case.AstPatterns) {
            $passed = $passed -and ($output -match $pattern)
        }
    } else {
        $syntaxLines = [regex]::Matches($output, 'Syntax error at (\d+):(\d+):')
        $passed = ($exitCode -ne 0) -and ($syntaxLines.Count -ge 1) -and ($output -match 'Parse failed:')
        if ($case.Multiple) {
            $distinctLines = @($syntaxLines | ForEach-Object { $_.Groups[1].Value } | Select-Object -Unique)
            $passed = $passed -and ($distinctLines.Count -ge 2)
        }
    }

    if ($passed) {
        Write-Host "PASS $name"
    } else {
        Write-Host "FAIL $name (exit $exitCode)"
        Write-Host $output
        ++$failures
    }
}

if ($failures -gt 0) {
    Write-Host "$failures parser case(s) failed."
    exit 1
}

Write-Host "All parser cases passed."
