#Requires -Version 5.1
<#
.SYNOPSIS
  Prepares a Windows PC for C# development in Visual Studio Code.

.DESCRIPTION
  Installs, if missing:
    - Git
    - .NET SDK 10 (current long-term support release; includes the runtime)
    - Visual Studio Code
    - C# language support, the .NET Install Tool, and C# Dev Kit

  Safe to run again. Packages that are already installed are left in place.
  WinGet may show a User Account Control prompt. Approve it so machine-wide
  installs can finish.

  C# Dev Kit is free for individuals, students, and open-source work. The first
  time you open it, VS Code may ask you to sign in with a Microsoft account.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\setup-windows.ps1

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\setup-windows.ps1 -CreateSample
#>
[CmdletBinding()]
param(
    [switch]$CreateSample
)

$ErrorActionPreference = "Stop"

$DotNetPackageId = "Microsoft.DotNet.SDK.10"
$VsCodePackageId = "Microsoft.VisualStudioCode"
$GitPackageId = "Git.Git"
$Extensions = @(
    "ms-dotnettools.vscode-dotnet-runtime",
    "ms-dotnettools.csharp",
    "ms-dotnettools.csdevkit"
)

# WinGet exit code when the package is already installed at the newest version.
# PowerShell may surface the same HRESULT as a signed or unsigned value.
$WingetAlreadyInstalled = @(-1978335189, 2316632107)

function Write-Step {
    param([string]$Message)
    Write-Host ""
    Write-Host "==> $Message" -ForegroundColor Cyan
}

function Write-Ok {
    param([string]$Message)
    Write-Host "    $Message" -ForegroundColor Green
}

function Refresh-SessionPath {
    $machine = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $user = [Environment]::GetEnvironmentVariable("Path", "User")
    $env:Path = "$machine;$user"
}

function Test-Command {
    param([string]$Name)
    return [bool](Get-Command $Name -ErrorAction SilentlyContinue)
}

function Install-WingetPackage {
    param(
        [Parameter(Mandatory = $true)][string]$Id,
        [Parameter(Mandatory = $true)][string]$Label
    )

    Write-Step "Installing $Label ($Id)"
    & winget install --id $Id --exact --source winget `
        --accept-package-agreements --accept-source-agreements `
        --disable-interactivity

    $code = $LASTEXITCODE
    if ($code -eq 0 -or $WingetAlreadyInstalled -contains $code) {
        Write-Ok "$Label is installed."
        return
    }

    throw "winget could not install $Label (exit code $code). Re-run this script from a normal PowerShell window and approve any permission prompts."
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

    if (Test-Command "code") {
        return (Get-Command code).Source
    }

    return $null
}

if (-not [Environment]::Is64BitOperatingSystem) {
    throw "This script expects 64-bit Windows. .NET 10 does not ship a 32-bit SDK."
}

Write-Host "C# + VS Code setup for Windows" -ForegroundColor White
Write-Host "This installs Git, the .NET 10 SDK, Visual Studio Code, and C# Dev Kit."

Write-Step "Checking WinGet"
if (-not (Test-Command "winget")) {
    throw "WinGet is not installed. Install 'App Installer' from the Microsoft Store, then run this script again."
}
Write-Ok "WinGet is available."

Install-WingetPackage -Id $GitPackageId -Label "Git"
Install-WingetPackage -Id $DotNetPackageId -Label ".NET SDK 10"
Install-WingetPackage -Id $VsCodePackageId -Label "Visual Studio Code"

Write-Step "Refreshing PATH for this window"
Refresh-SessionPath

Write-Step "Checking Git"
if (-not (Test-Command "git")) {
    throw "Git installed, but 'git' is not on PATH yet. Close this window, open a new PowerShell window, and run the script again."
}
& git config --global core.longpaths true
Write-Ok ("Git " + (& git --version))

Write-Step "Checking the .NET SDK"
if (-not (Test-Command "dotnet")) {
    throw ".NET installed, but 'dotnet' is not on PATH yet. Close this window, open a new PowerShell window, and run the script again."
}

$sdkList = @(& dotnet --list-sdks)
if ($LASTEXITCODE -ne 0 -or $sdkList.Count -eq 0) {
    throw "The dotnet command is on PATH, but no SDK is registered. Re-run this script."
}

$hasNet10 = $false
foreach ($line in @($sdkList)) {
    if ($line -match "^10\.") {
        $hasNet10 = $true
    }
}
if (-not $hasNet10) {
    throw ".NET is installed, but no 10.x SDK was found. Installed SDKs:`n$sdkList"
}
Write-Ok "Installed SDKs:"
foreach ($line in @($sdkList)) {
    Write-Host "      $line"
}

Write-Step "Installing VS Code C# extensions"
$codeCmd = Find-CodeCommand
if (-not $codeCmd) {
    throw "Visual Studio Code installed, but the 'code' command was not found. Open VS Code once, then run this script again."
}

foreach ($extension in $Extensions) {
    Write-Host "    Installing $extension"
    & $codeCmd --install-extension $extension --force
    if ($LASTEXITCODE -ne 0) {
        throw "Could not install the VS Code extension '$extension'."
    }
}

$installed = @(& $codeCmd --list-extensions)
foreach ($extension in $Extensions) {
    if ($installed -notcontains $extension) {
        throw "Extension '$extension' did not appear in 'code --list-extensions'."
    }
    Write-Ok $extension
}

if ($CreateSample) {
    Write-Step "Creating a HelloCSharp sample in the current folder"
    $sampleDir = Join-Path (Get-Location) "HelloCSharp"
    if (Test-Path -LiteralPath $sampleDir) {
        throw "Refusing to overwrite $sampleDir. Move that folder aside or run without -CreateSample."
    }
    New-Item -ItemType Directory -Path $sampleDir | Out-Null
    Push-Location $sampleDir
    try {
        & dotnet new console --name HelloCSharp --output .
        if ($LASTEXITCODE -ne 0) {
            throw "dotnet new console failed."
        }
        & dotnet run
        if ($LASTEXITCODE -ne 0) {
            throw "The sample project did not run."
        }
    }
    finally {
        Pop-Location
    }
    Write-Ok "Sample project is in $sampleDir"
}

Write-Step "This PC is ready for C#"
Write-Host ""
Write-Host "Open a new terminal so every program picks up the updated PATH, then try:" -ForegroundColor White
Write-Host ""
Write-Host "    mkdir HelloCSharp" -ForegroundColor Yellow
Write-Host "    cd HelloCSharp" -ForegroundColor Yellow
Write-Host "    dotnet new console" -ForegroundColor Yellow
Write-Host "    code ." -ForegroundColor Yellow
Write-Host "    dotnet run" -ForegroundColor Yellow
Write-Host ""
Write-Host "In VS Code, sign in if C# Dev Kit asks. That unlocks solution view, debugging, and tests." -ForegroundColor White
