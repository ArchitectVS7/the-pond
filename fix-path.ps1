# Fix Claude Code PATH - Run as Administrator
# This script permanently adds npm global bin to your system PATH

Write-Host "Fixing Claude Code PATH..." -ForegroundColor Cyan

# Get npm global bin path
$npmPath = "C:\Users\J\AppData\Roaming\npm"
Write-Host "npm global bin: $npmPath" -ForegroundColor Yellow

# Get current system PATH
$currentPath = [Environment]::GetEnvironmentVariable("Path", "User")

# Check if npm path is already in PATH
if ($currentPath -like "*$npmPath*") {
    Write-Host "npm path already in PATH!" -ForegroundColor Green
} else {
    Write-Host "Adding npm path to User PATH..." -ForegroundColor Yellow

    # Add to User PATH (permanent)
    $newPath = $currentPath + ";$npmPath"
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")

    Write-Host "npm path added to User PATH permanently!" -ForegroundColor Green
}

# Update current session PATH
$env:Path += ";$npmPath"

Write-Host ""
Write-Host "Testing Claude Code..." -ForegroundColor Cyan

# Test claude command
try {
    $claudeVersion = & claude --version 2>&1
    Write-Host "Claude Code found: $claudeVersion" -ForegroundColor Green
} catch {
    Write-Host "Claude Code not found yet. Try closing and reopening PowerShell." -ForegroundColor Red
}

Write-Host ""
Write-Host "DONE! Close and reopen PowerShell for changes to take effect." -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Cyan
Write-Host "  1. Close this PowerShell window" -ForegroundColor White
Write-Host "  2. Open a NEW PowerShell window" -ForegroundColor White
Write-Host "  3. Run: claude --version" -ForegroundColor White
Write-Host "  4. Run: claude-flow --version" -ForegroundColor White
