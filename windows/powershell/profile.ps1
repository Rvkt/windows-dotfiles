using namespace System.Management.Automation
using namespace System.Management.Automation.Language

# -------------------------------------------------------
# 0. Global settings
# -------------------------------------------------------
$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'
$env:POWERSHELL_UPDATECHECK = 'Off'

# Debug mode
$DOTFILES_DEBUG = $env:DOTFILES_DEBUG -eq "1"

# Dotfiles path
$DOTFILES = Join-Path $env:USERPROFILE ".dotfiles"
$env:DOTFILES = $DOTFILES

# -------------------------------------------------------
# 1. Helpers (DRY core)
# -------------------------------------------------------

function Write-DebugLog {
    param(
        [string]$Message,
        [string]$Color = "DarkGray"
    )

    if ($DOTFILES_DEBUG) {
        Write-Host $Message -ForegroundColor $Color
    }
}

function Invoke-Safe {
    param(
        [scriptblock]$Script,
        [string]$Name = "unknown"
    )

    try {
        & $Script
    } catch {
        Write-DebugLog "Error in ${Name}: $($_.Exception.Message)" "Red"
    }
}

function Import-OptionalModule {
    param([string]$Name)

    if (Get-Module -ListAvailable -Name $Name) {
        Invoke-Safe {
            Import-Module $Name -ErrorAction Stop
        } $Name
    }
}

function Load-Folder {
    param(
        [string]$Path,
        [string]$Label
    )

    if (-not (Test-Path $Path)) {
        Write-DebugLog "${Label} directory not found: $Path" "Yellow"
        return
    }

    Get-ChildItem -Path $Path -Filter "*.ps1" -File |
        Sort-Object Name |
        ForEach-Object {
            $file = $_
            Invoke-Safe {
                Write-DebugLog ("Loading {0}: {1}" -f $Label, $file.Name)
                . $file.FullName
            } $file.Name
        }
}

# -------------------------------------------------------
# 2. Core modules
# -------------------------------------------------------
Import-Module PSReadLine -ErrorAction SilentlyContinue

# -------------------------------------------------------
# 3. Oh My Posh
# -------------------------------------------------------
$OmpThemePath = Join-Path $DOTFILES "windows\powershell\omp-themes\pwshTheme.omp.json"

Invoke-Safe {
    if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
        oh-my-posh init pwsh --config $OmpThemePath | Invoke-Expression
    }
} "oh-my-posh"

# -------------------------------------------------------
# 4. Optional modules
# -------------------------------------------------------
'Terminal-Icons', 'z' | ForEach-Object {
    Import-OptionalModule $_
}

# -------------------------------------------------------
# 5. Git symlink (self-healing)
# -------------------------------------------------------
$gitConfigPath = Join-Path $HOME ".gitconfig"
$gitTargetPath = Join-Path $DOTFILES "shared\git\.gitconfig"

Invoke-Safe {
    if (-not (Test-Path $gitConfigPath)) {
        New-Item -ItemType SymbolicLink `
            -Path $gitConfigPath `
            -Target $gitTargetPath | Out-Null

        Write-DebugLog "Created git symlink"
    }
    else {
        $item = Get-Item $gitConfigPath -ErrorAction SilentlyContinue

        if ($item -and $item.LinkType -eq "SymbolicLink") {
            if ($item.Target -ne $gitTargetPath) {
                Remove-Item $gitConfigPath -Force
                New-Item -ItemType SymbolicLink `
                    -Path $gitConfigPath `
                    -Target $gitTargetPath | Out-Null

                Write-DebugLog "Fixed git symlink"
            }
        }
    }
} "git-symlink"

# -------------------------------------------------------
# 6. Load scripts & functions
# -------------------------------------------------------
Load-Folder (Join-Path $DOTFILES "windows\powershell\scripts")   "script"
Load-Folder (Join-Path $DOTFILES "windows\powershell\functions") "function"