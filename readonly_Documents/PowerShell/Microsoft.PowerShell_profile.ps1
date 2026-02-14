# Only load oh-my-posh in truly interactive sessions (avoids issues with Copilot CLI subprocesses)
# Check: not running with -Command/-c, has a console window, and is user interactive
$cmdArgs = [Environment]::GetCommandLineArgs()
$isNonInteractive = $cmdArgs -contains '-Command' -or $cmdArgs -contains '-c' -or $cmdArgs -contains '-NonInteractive'

if (-not $isNonInteractive -and $Host.Name -eq 'ConsoleHost' -and [Environment]::UserInteractive) {
    oh-my-posh init pwsh --config "~\.nikiforovall.omp.json" | Invoke-Expression
}
