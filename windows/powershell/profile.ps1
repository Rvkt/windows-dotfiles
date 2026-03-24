using namespace System.Management.Automation
using namespace System.Management.Automation.Language

# -------------------------------------------------------
# 0. Global settings
# -------------------------------------------------------
$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'
$env:POWERSHELL_UPDATECHECK = 'Off'

# -------------------------------------------------------
# 1. Host & PSReadLine
# -------------------------------------------------------
if ($host.Name -eq 'ConsoleHost') {
    if (Get-Module -ListAvailable -Name PSReadLine) {
        Import-Module PSReadLine -ErrorAction SilentlyContinue
    }
}

# -------------------------------------------------------
# 2. Oh My Posh (safe init)
# -------------------------------------------------------
$OmpThemePath = "$env:USERPROFILE\.dotfiles\windows\powershell\omp-themes\pwshTheme.omp.json"

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    try {
        oh-my-posh init pwsh --config $OmpThemePath | Invoke-Expression
    } catch {
        Write-Verbose "Failed to init oh-my-posh: $($_.Exception.Message)"
    }
}

# -------------------------------------------------------
# 3. Core modules (optional cosmetics)
# -------------------------------------------------------
foreach ($mod in 'Terminal-Icons', 'z') {
    if (Get-Module -ListAvailable -Name $mod) {
        Import-Module $mod -ErrorAction SilentlyContinue
    }
}

# -------------------------------------------------------
# 4. Custom PSReadLine config (optional)
# -------------------------------------------------------
$customPsrl = "C:\Users\Rvknt\.dotfiles\windows\powershell\CustomPSReadLineConfig.ps1"
if (Test-Path $customPsrl) {
    . $customPsrl
}

# -------------------------------------------------------
# 5. Generic utilities
# -------------------------------------------------------
function New-TimeStampedFolder {
    [CmdletBinding()]
    param(
        [string]$BasePath = '.'
    )

    $folderName = (Get-Date).ToString('yyyyMMdd-HHmmss')
    $fullPath   = Join-Path $BasePath $folderName

    New-Item -Path $fullPath -ItemType Directory -Force | Out-Null
    Invoke-Item -Path $fullPath

    return $fullPath
}

Set-Alias tsf New-TimeStampedFolder -Scope Global

# -------------------------------------------------------
# 6. Flutter helpers
# -------------------------------------------------------
function Invoke-FlutterRefresh {
    [CmdletBinding()]
    param()

    Write-Host 'Cleaning Flutter project...' -ForegroundColor Cyan
    flutter clean

    Write-Host 'Fetching Flutter dependencies...' -ForegroundColor Cyan
    flutter pub get

    $gradlePath = Join-Path (Get-Location) 'android\.gradle'
    if (Test-Path $gradlePath) {
        Write-Host 'Deleting Gradle cache...' -ForegroundColor Cyan
        Remove-Item -Path $gradlePath -Recurse -Force
    }

    Write-Host 'Flutter project refresh complete.' -ForegroundColor Green
}
Set-Alias flutter-refresh Invoke-FlutterRefresh -Scope Global

function Get-FlutterBuildTag {
    [CmdletBinding()]
    param(
        [ValidateSet('release','debug','staging')]
        [string]$Configuration = 'release'
    )

    $pubspecPath = Join-Path (Get-Location) 'pubspec.yaml'
    if (-not (Test-Path $pubspecPath)) {
        Write-Host 'pubspec.yaml not found.' -ForegroundColor Red
        return
    }

    $content = Get-Content $pubspecPath
    $name    = ($content | Select-String '^name:'    | ForEach-Object { $_.Line.Split(':')[1].Trim() })
    $version = ($content | Select-String '^version:' | ForEach-Object { $_.Line.Split(':')[1].Trim() })

    $timestamp = Get-Date -Format 'yyyyMMddTHHmmss'
    "$name-v$version-$Configuration-D$timestamp"
}

# -------------------------------------------------------
# 7. Git shortcut
# -------------------------------------------------------
function g {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments = $true)]
        [object[]]$Args
    )

    git @Args
}

# -------------------------------------------------------
# 8. Flutter release builder
# -------------------------------------------------------
function Invoke-FlutterReleaseBuild {
    [CmdletBinding()]
    param(
        [switch]$Apk,
        [switch]$Aab,
        [switch]$All
    )

    if (-not ($Apk -or $Aab -or $All)) {
        Write-Host "`nSelect build type:" -ForegroundColor Yellow
        Write-Host '1. APK'
        Write-Host '2. AAB'
        Write-Host '3. APK + AAB'
        $choice = Read-Host 'Enter choice (1/2/3)'

        $Apk = $choice -in 1, 3
        $Aab = $choice -in 2, 3
    }

    if ($All) {
        $Apk = $true
        $Aab = $true
    }

    Write-Host 'Starting Flutter release build...' -ForegroundColor Cyan

    if ($Apk) { flutter build apk --release }
    if ($Aab) { flutter build appbundle }

    $pubspecPath = Join-Path (Get-Location) 'pubspec.yaml'
    $pubspec     = Get-Content $pubspecPath
    $name        = ($pubspec | Select-String '^name:'    | ForEach-Object { $_.Line.Split(':')[1].Trim() })
    $version     = ($pubspec | Select-String '^version:' | ForEach-Object { $_.Line.Split(':')[1].Trim() })

    $now        = Get-Date
    $timestamp  = $now.ToString('yyyyMMddHHmmss')
    $upperName  = ($name.ToUpper() -replace '[^A-Z0-9]', '_')
    $formatted  = "${upperName}_RELEASE_v$version_$timestamp"
    $releaseDir = Join-Path ([Environment]::GetFolderPath('Desktop')) ("Releases\" + $now.ToString('yyyyMMdd'))

    New-Item -ItemType Directory -Force -Path $releaseDir | Out-Null

    if ($Apk -and (Test-Path 'build\app\outputs\apk\release\app-release.apk')) {
        Copy-Item 'build\app\outputs\apk\release\app-release.apk' (Join-Path $releaseDir "$formatted.apk") -Force
    }

    if ($Aab -and (Test-Path 'build\app\outputs\bundle\release\app-release.aab')) {
        Copy-Item 'build\app\outputs\bundle\release\app-release.aab' (Join-Path $releaseDir "$formatted.aab") -Force
    }

    Start-Process explorer.exe $releaseDir
    Write-Host 'Flutter release completed.' -ForegroundColor Green
}
Set-Alias flutter-build-release Invoke-FlutterReleaseBuild -Scope Global

# -------------------------------------------------------
# 9. Android Studio launcher
# -------------------------------------------------------
function studio {
    [CmdletBinding()]
    param(
        [string]$Path = '.'
    )

    & 'C:\Program Files\Android\Android Studio\bin\studio64.exe' $Path
}

# -------------------------------------------------------
# 10. Winget installer helper
# -------------------------------------------------------
function Install-Winget {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Write-Host 'Checking winget availability...' -ForegroundColor Cyan

    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host 'Winget already installed.' -ForegroundColor Green
        return
    }

    Write-Host 'Winget not found. Installing App Installer...' -ForegroundColor Yellow

    $uri           = 'https://aka.ms/getwinget'
    $installerPath = Join-Path $env:TEMP 'AppInstaller.msixbundle'

    Invoke-WebRequest -Uri $uri -OutFile $installerPath -UseBasicParsing
    Add-AppxPackage -Path $installerPath -ErrorAction Stop

    Write-Host 'App Installer installed.' -ForegroundColor Green

    $wingetPath = Join-Path $env:LOCALAPPDATA 'Microsoft\WindowsApps'
    if ($env:PATH -notlike '*WindowsApps*') {
        Write-Host 'Adding winget to PATH...' -ForegroundColor Yellow
        [Environment]::SetEnvironmentVariable(
            'PATH',
            $env:PATH + ';' + $wingetPath,
            'User'
        )
    }

    Write-Host 'Restart PowerShell to start using winget.' -ForegroundColor Green
}

# -------------------------------------------------------
# 11. Flutter package id finder / replacer
# -------------------------------------------------------
function Find-FlutterPackageUsage {
    [CmdletBinding()]
    param(
        [string]$ProjectPath = '.',
        [string]$Replace
    )

    $ProjectPath = (Resolve-Path $ProjectPath).Path
    $packageId   = $null

    Write-Host 'Detecting package id...'

    $gradleFiles = Get-ChildItem -Path (Join-Path $ProjectPath 'android\app') -Recurse `
        -Include 'build.gradle','build.gradle.kts' -ErrorAction SilentlyContinue

    foreach ($file in $gradleFiles) {
        $content = Get-Content $file.FullName -Raw

        if ($content -match 'applicationId\s*=?\s*"([^"]+)"') {
            $packageId = $matches[1]
            break
        }

        if ($content -match 'namespace\s*=\s*"([^"]+)"') {
            $packageId = $matches[1]
            break
        }
    }

    if (-not $packageId) {
        Write-Host 'Package ID not found.' -ForegroundColor Red
        return
    }

    Write-Host "Detected Package ID: $packageId"

    # Replace mode
    if ($PSBoundParameters.ContainsKey('Replace')) {
        Write-Host "Replacing with: $Replace"
        Write-Host '--------------------------------------'

        $escapedOld = [regex]::Escape($packageId)

        Get-ChildItem -Path $ProjectPath -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object {
                $_.Extension -match '\.(gradle|kts|xml|kt|java|dart|pbxproj|plist|json|yaml|yml)$'
            } |
            ForEach-Object {
                $content = Get-Content $_.FullName -Raw
                if ($content -match $escapedOld) {
                    $updated = $content -replace $escapedOld, $Replace
                    Set-Content $_.FullName $updated -NoNewline
                    $relativePath = $_.FullName.Replace($ProjectPath + '\', '')
                    Write-Host "Updated: $relativePath"
                }
            }

        $oldPath = $packageId.Replace('.', '\')
        $newPath = $Replace.Replace('.', '\')
        $srcMain = Join-Path $ProjectPath 'android\app\src\main'

        foreach ($lang in 'kotlin', 'java') {
            $baseDir     = Join-Path $srcMain $lang
            $oldFullPath = Join-Path $baseDir $oldPath
            $newFullPath = Join-Path $baseDir $newPath

            if (Test-Path $oldFullPath) {
                Write-Host "Renaming Android folder structure in $lang..."

                New-Item -ItemType Directory -Path $newFullPath -Force | Out-Null
                Move-Item "$oldFullPath\*" $newFullPath -Force
                Remove-Item $oldFullPath -Recurse -Force

                $relativeNew = $newFullPath.Replace($ProjectPath + '\', '')
                Write-Host "Folder Updated: $relativeNew"
            }
        }

        Write-Host '--------------------------------------'
        Write-Host 'Replacement completed successfully.'
        Write-Host 'Run: flutter clean'
        return
    }

    # Find mode
    Write-Host '--------------------------------------'

    Get-ChildItem -Path $ProjectPath -Recurse -File -ErrorAction SilentlyContinue |
        Where-Object {
            $_.Extension -match '\.(gradle|kts|xml|kt|java|dart|pbxproj|plist|json|yaml|yml)$'
        } |
        Select-String -Pattern $packageId -SimpleMatch |
        ForEach-Object {
            $relativePath = $_.Path.Replace($ProjectPath + '\', '')
            [PSCustomObject]@{
                Path       = $relativePath
                LineNumber = $_.LineNumber
                Line       = $_.Line.Trim()
            }
        }

    function New-SymLink {
    [CmdletBinding(SupportsShouldProcess)]
    param()

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName Microsoft.VisualBasic

    # ── Pick SOURCE (real folder in dotfiles) ──────────────────────
    $sourceBrowser                     = New-Object System.Windows.Forms.FolderBrowserDialog
    $sourceBrowser.Description         = 'Select SOURCE folder (the real folder, e.g. in .dotfiles)'
    $sourceBrowser.ShowNewFolderButton = $false
    $sourceBrowser.RootFolder          = 'MyComputer'

    if ($sourceBrowser.ShowDialog() -ne 'OK') {
        Write-Host 'Cancelled.' -ForegroundColor Yellow
        return
    }
    $source = $sourceBrowser.SelectedPath

    # ── Type TARGET path manually (symlink path, may not exist yet) ─
    $target = [Microsoft.VisualBasic.Interaction]::InputBox(
        "Enter the full TARGET path where the symlink will be created.`n`nSource: $source",
        'New Symlink — Target Path',
        "C:\Users\Rvknt\.config\"
    )

    if ([string]::IsNullOrWhiteSpace($target)) {
        Write-Host 'Cancelled.' -ForegroundColor Yellow
        return
    }

    # ── Confirm ────────────────────────────────────────────────────
    Write-Host "`nSource : $source" -ForegroundColor Cyan
    Write-Host "Target : $target"  -ForegroundColor Cyan
    $confirm = Read-Host "`nCreate symlink? (y/n)"

    if ($confirm -ne 'y') {
        Write-Host 'Aborted.' -ForegroundColor Yellow
        return
    }

    # ── Create parent dir if needed & make symlink ─────────────────
    try {
        $parentDir = Split-Path $target -Parent
        if (-not (Test-Path $parentDir)) {
            New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
            Write-Host "Created parent folder: $parentDir" -ForegroundColor DarkCyan
        }

        if (Test-Path $target) {
            Write-Host "Target path already exists: $target" -ForegroundColor Red
            Write-Host "Remove it first if you want to replace it." -ForegroundColor Yellow
            return
        }

        New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
        Write-Host "Symlink created:`n  $target`n  -> $source" -ForegroundColor Green
    } catch {
        Write-Host "Failed: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host 'Try running as Administrator or enable Developer Mode.' -ForegroundColor Yellow
    }
}

Set-Alias symlink New-SymLink -Scope Global

}