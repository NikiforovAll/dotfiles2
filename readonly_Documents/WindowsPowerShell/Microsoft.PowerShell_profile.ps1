# Check if output is redirected (e.g. captured by an agent or pipeline).
# [Console]::IsOutputRedirected is safer than [Environment]::UserInteractive for this purpose.
if (-not [Console]::IsOutputRedirected) {
    oh-my-posh init pwsh --config "~\.nikiforovall.omp.json" | Invoke-Expression
}

