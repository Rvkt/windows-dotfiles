function Install-Winget {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host 'Winget already installed.' -ForegroundColor Green
        return
    }

    Write-Host 'Installing winget...' -ForegroundColor Yellow

    $uri  = 'https://aka.ms/getwinget'
    $path = Join-Path $env:TEMP 'AppInstaller.msixbundle'

    Invoke-WebRequest -Uri $uri -OutFile $path -UseBasicParsing
    Add-AppxPackage -Path $path

    Write-Host 'Done. Restart PowerShell.' -ForegroundColor Green
}

function New-SymLink {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName Microsoft.VisualBasic

    $sourceBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $sourceBrowser.Description = 'Select SOURCE folder'
    $sourceBrowser.ShowNewFolderButton = $false

    if ($sourceBrowser.ShowDialog() -ne 'OK') { return }

    $source = $sourceBrowser.SelectedPath

    $target = [Microsoft.VisualBasic.Interaction]::InputBox(
        "Enter TARGET path:`nSource: $source",
        'Create Symlink',
        "$env:USERPROFILE\.config\"
    )

    if (-not $target) { return }

    try {
        $parent = Split-Path $target -Parent
        if (-not (Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }

        if (Test-Path $target) {
            Write-Host "Target exists." -ForegroundColor Yellow
            return
        }

        New-Item -ItemType SymbolicLink -Path $target -Target $source | Out-Null
        Write-Host "Symlink created." -ForegroundColor Green
    } catch {
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}
Set-Alias symlink New-SymLink