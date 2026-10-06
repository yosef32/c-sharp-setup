#Requires -Version 5.1
<#
.SYNOPSIS
  Removes the C# and Visual Studio Code tools installed by setup-windows.ps1.

.DESCRIPTION
  Removes, when present:
    - C# Dev Kit, the C# extension, and the .NET Install Tool
    - Visual Studio Code
    - .NET SDK 10
    - Git

  WinGet stays installed. It is part of Windows App Installer, and other
  software uses it.

  The script asks you to type YES before it removes anything.
  Pass -Force to skip that question.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\uninstall-windows.ps1

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\uninstall-windows.ps1 -Force -RemoveSample
#>
[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$RemoveSample
)

$ErrorActionPreference = "Stop"

$DotNetPackageId = "Microsoft.DotNet.SDK.10"
$VsCodePackageId = "Microsoft.VisualStudioCode"
$GitPackageId = "Git.Git"
# Dev Kit first, then the extensions it depends on.
$Extensions = @(
    "ms-dotnettools.csdevkit",
    "ms-dotnettools.csharp",
    "ms-dotnettools.vscode-dotnet-runtime"
)

# 0 = removed. 3010 = removed, restart later.
# The other two values are the same "not installed" HRESULT, signed and unsigned.
$WingetOkCodes = @(0, 3010, -1978335212, 2316632084)

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Message)
    Write-Host "    $Message" -ForegroundColor Green
}

function Find-WorkingWinget {
    $command = Get-Command winget -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    $candidate = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
    if (Test-Path -LiteralPath $candidate) {
        $env:Path = "$env:LOCALAPPDATA\Microsoft\WindowsApps;$env:Path"
        return $candidate
    }

    return $null
}

function Find-CodeCommand {
    $candidates = @(
        "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd",
        "${env:ProgramFiles}\Microsoft VS Code\bin\code.cmd",
        "${env:ProgramFiles(x86)}\Microsoft VS Code\bin\code.cmd"
    )

    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) {
            return $candidate
        }
    }

    $command = Get-Command code -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    return $null
}

function Uninstall-WingetPackage {
    param(
        [Parameter(Mandatory = $true)][string]$Id,
        [Parameter(Mandatory = $true)][string]$Label
    )

    Write-Step "Removing $Label ($Id)"
    & $script:WingetCommand uninstall --id $Id --exact `
        --accept-source-agreements --disable-interactivity

    $code = $LASTEXITCODE
    if ($WingetOkCodes -contains $code) {
        if ($code -eq 3010) {
            Write-Ok "$Label was removed. Restart Windows when you can."
        }
        else {
            Write-Ok "$Label is removed."
        }
        return
    }

    throw "winget could not remove $Label (exit code $code). Approve any permission prompt and run this script again."
}

if (-not $Force) {
    Write-Host "This removes Git, the .NET 10 SDK, Visual Studio Code, and the C# extensions." -ForegroundColor Yellow
    Write-Host "WinGet stays installed." -ForegroundColor Yellow
    $answer = Read-Host "Type YES to continue"
    if ($answer -ne "YES") {
        throw "Uninstall cancelled."
    }
}

Write-Step "Checking WinGet"
$script:WingetCommand = Find-WorkingWinget
if (-not $script:WingetCommand) {
    throw "WinGet is not available, so the installed apps cannot be removed from here. Install App Installer from the Microsoft Store, then run this script again."
}
Write-Ok "WinGet is available."

Write-Step "Removing VS Code C# extensions"
$codeCmd = Find-CodeCommand
if ($codeCmd) {
    foreach ($extension in $Extensions) {
        & $codeCmd --uninstall-extension $extension
        if ($LASTEXITCODE -eq 0) {
            Write-Ok "Removed $extension"
        }
        else {
            Write-Ok "$extension was not installed."
        }
    }
}
else {
    Write-Ok "Visual Studio Code is not installed, so there are no extensions to remove."
}

if (Get-Command git -ErrorAction SilentlyContinue) {
    Write-Step "Reverting the Git setting added by setup"
    & git config --global --unset core.longpaths 2>$null
    Write-Ok "Cleared core.longpaths."
}

Uninstall-WingetPackage -Id $VsCodePackageId -Label "Visual Studio Code"
Uninstall-WingetPackage -Id $DotNetPackageId -Label ".NET SDK 10"
Uninstall-WingetPackage -Id $GitPackageId -Label "Git"

if ($RemoveSample) {
    Write-Step "Removing the HelloCSharp sample in the current folder"
    $sampleDir = Join-Path (Get-Location) "HelloCSharp"
    $projectFile = Join-Path $sampleDir "HelloCSharp.csproj"
    if (Test-Path -LiteralPath $projectFile) {
        Remove-Item -LiteralPath $sampleDir -Recurse -Force
        Write-Ok "Removed $sampleDir"
    }
    else {
        Write-Ok "No HelloCSharp sample was found here."
    }
}

Write-Step "C# setup was removed"
Write-Host ""
Write-Host "Open a new terminal so PATH updates. Restart Windows if an uninstaller asked for it." -ForegroundColor White
Write-Host "WinGet is still installed." -ForegroundColor White
