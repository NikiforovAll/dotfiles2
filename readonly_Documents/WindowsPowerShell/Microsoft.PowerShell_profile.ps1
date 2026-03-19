# Only load oh-my-posh in interactive sessions (skip -c/-Command and redirected output).
$cmdArgs = [Environment]::GetCommandLineArgs()
$isNonInteractive = $cmdArgs | Where-Object { $_ -in '-c', '-Command', '-NonInteractive', '-EncodedCommand', '-File' }
if (-not $isNonInteractive -and -not [Console]::IsOutputRedirected) {
    oh-my-posh init pwsh --config "~\.nikiforovall.omp.json" | Invoke-Expression
}

