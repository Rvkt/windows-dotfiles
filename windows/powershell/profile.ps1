using namespace System.Management.Automation
using namespace System.Management.Automation.Language

# -------------------------------------------------------
# 0. Global settings
# -------------------------------------------------------
$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'
$env:POWERSHELL_UPDATECHECK = 'Off'

# Debug mode (enable when needed)
$DOTFILES_DEBUG = $env:DOTFILES_DEBUG -eq "1"

# Global dotfiles path
$DOTFILES = Join-Path $env:USERPROFILE ".dotfiles"
$env:DOTFILES = $DOTFILES

# -------------------------------------------------------
# 1. PSReadLine (always load)
# -------------------------------------------------------
Import-Module PSReadLine -ErrorAction SilentlyContinue

# -------------------------------------------------------
# 2. Oh My Posh (safe init)
# -------------------------------------------------------
$OmpThemePath = Join-Path $DOTFILES "windows\powershell\omp-themes\pwshTheme.omp.json"

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    try {
        oh-my-posh init pwsh --config $OmpThemePath | Invoke-Expression
    } catch {
        if ($DOTFILES_DEBUG) {
            Write-Host "Oh My Posh failed: $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
}

# -------------------------------------------------------
# 3. Optional modules (lazy-safe)
# -------------------------------------------------------
foreach ($mod in 'Terminal-Icons', 'z') {
    if (Get-Module -ListAvailable -Name $mod) {
        try {
            Import-Module $mod -ErrorAction Stop
        } catch {
            if ($DOTFILES_DEBUG) {
                Write-Host "Failed to load module: $mod" -ForegroundColor Yellow
            }
        }
    }
}

# -------------------------------------------------------
# 4. Load modular scripts
# -------------------------------------------------------
$scriptDir = Join-Path $DOTFILES "windows\powershell\scripts"

if (Test-Path $scriptDir) {
    Get-ChildItem $scriptDir -Filter "*.ps1" | Sort-Object Name | ForEach-Object {
        try {
            if ($DOTFILES_DEBUG) {
                Write-Host "Loading script: $($_.Name)" -ForegroundColor DarkGray
            }
            . $_.FullName
        } catch {
            Write-Host "Error in script: $($_.Name)" -ForegroundColor Red
        }
    }
} elseif ($DOTFILES_DEBUG) {
    Write-Host "Scripts directory not found: $scriptDir" -ForegroundColor Yellow
}

# -------------------------------------------------------
# 5. Load functions
# -------------------------------------------------------
$functionDir = Join-Path $DOTFILES "windows\powershell\functions"

if (Test-Path $functionDir) {
    Get-ChildItem $functionDir -Filter "*.ps1" | Sort-Object Name | ForEach-Object {
        try {
            if ($DOTFILES_DEBUG) {
                Write-Host "Loading functions: $($_.Name)" -ForegroundColor DarkCyan
            }
            . $_.FullName
        } catch {
            Write-Host "Error in function file: $($_.Name)" -ForegroundColor Red
        }
    }
} elseif ($DOTFILES_DEBUG) {
    Write-Host "Functions directory not found: $functionDir" -ForegroundColor Yellow
}