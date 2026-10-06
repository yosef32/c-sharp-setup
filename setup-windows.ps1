#Requires -Version 5.1
<#
.SYNOPSIS
  Prepares a Windows PC for C# development in Visual Studio Code.

.DESCRIPTION
  Installs, if missing:
    - WinGet (the Windows package installer), when the winget command is missing
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

function Test-WingetWorks {
    param([string]$CommandPath)
    if (-not $CommandPath -or -not (Test-Path -LiteralPath $CommandPath)) {
        return $false
    }

    $previous = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        & $CommandPath --version *> $null
        return $LASTEXITCODE -eq 0
    }
    catch {
        return $false
    }
    finally {
        $ErrorActionPreference = $previous
    }
}

function Find-WorkingWinget {
    $command = Get-Command winget -ErrorAction SilentlyContinue
    if ($command -and (Test-WingetWorks $command.Source)) {
        return $command.Source
    }

    $candidates = @(
        "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
    )
    $package = Get-AppxPackage -Name Microsoft.DesktopAppInstaller -ErrorAction SilentlyContinue
    if ($package -and $package.InstallLocation) {
        $candidates += (Join-Path $package.InstallLocation "winget.exe")
    }

    foreach ($candidate in $candidates) {
        if (Test-WingetWorks $candidate) {
            $windowsApps = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
            if ($env:Path -notlike "*${windowsApps}*") {
                $env:Path = "$windowsApps;$env:Path"
            }
            return $candidate
        }
    }

    return $null
}

function Get-WindowsPackageArch {
    if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64" -or $env:PROCESSOR_ARCHITEW6432 -eq "ARM64") {
        return "arm64"
    }
    return "x64"
}

function Install-WinGetFromGitHub {
    $temp = Join-Path $env:TEMP "csharp-setup-winget"
    New-Item -ItemType Directory -Force -Path $temp | Out-Null

    $headers = @{ "User-Agent" = "c-sharp-setup" }
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/microsoft/winget-cli/releases/latest" -Headers $headers
    $bundle = @($release.assets | Where-Object { $_.name -like "*.msixbundle" } | Select-Object -First 1)
    if ($bundle.Count -eq 0) {
        throw "Could not find the WinGet installer on GitHub."
    }

    $bundlePath = Join-Path $temp $bundle[0].name
    Invoke-WebRequest -Uri $bundle[0].browser_download_url -OutFile $bundlePath -UseBasicParsing

    $deps = @($release.assets | Where-Object { $_.name -like "*Dependencies*.zip" } | Select-Object -First 1)
    if ($deps.Count -gt 0) {
        $zipPath = Join-Path $temp $deps[0].name
        Invoke-WebRequest -Uri $deps[0].browser_download_url -OutFile $zipPath -UseBasicParsing
        $depsDir = Join-Path $temp "deps"
        Expand-Archive -Path $zipPath -DestinationPath $depsDir -Force

        $arch = Get-WindowsPackageArch
        $archDir = Get-ChildItem -Path $depsDir -Directory -Recurse | Where-Object { $_.Name -eq $arch } | Select-Object -First 1
        if ($archDir) {
            $dependencyPackages = @(Get-ChildItem -Path $archDir.FullName -File | Where-Object {
                $_.Extension -in @(".appx", ".msix")
            })
            foreach ($dependency in $dependencyPackages) {
                try {
                    Add-AppxPackage -Path $dependency.FullName -ErrorAction Stop
                }
                catch {
                    Write-Host "    Skipping $($dependency.Name); it is already installed or not required."
                }
            }
        }
    }

    Add-AppxPackage -Path $bundlePath -ErrorAction Stop
}

function Install-WinGet {
    Write-Step "WinGet was not found. Installing it."
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    $ProgressPreference = "SilentlyContinue"

    Write-Host "    Registering App Installer, if Windows already has it."
    try {
        Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe -ErrorAction Stop
    }
    catch {
        Write-Host "    App Installer is not on this account yet."
    }

    $existing = Get-AppxPackage -Name Microsoft.DesktopAppInstaller -ErrorAction SilentlyContinue
    if ($existing -and $existing.InstallLocation) {
        $manifest = Join-Path $existing.InstallLocation "AppxManifest.xml"
        if (Test-Path -LiteralPath $manifest) {
            try {
                Add-AppxPackage -DisableDevelopmentMode -Register $manifest -ErrorAction Stop
            }
            catch {
                Write-Host "    Could not repair the existing App Installer. Downloading a new copy."
            }
        }
    }

    Refresh-SessionPath
    if (Find-WorkingWinget) {
        Write-Ok "WinGet is ready."
        return
    }

    $installed = $false
    try {
        Write-Host "    Downloading WinGet with Microsoft's installer module."
        $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
            [Security.Principal.WindowsBuiltInRole]::Administrator)

        $providerParams = @{ Name = "NuGet"; Force = $true }
        $moduleParams = @{
            Name            = "Microsoft.WinGet.Client"
            Force           = $true
            Repository      = "PSGallery"
            AllowClobber    = $true
            Confirm         = $false
        }
        if ($isAdmin) {
            $moduleParams.Scope = "AllUsers"
        }
        else {
            $providerParams.Scope = "CurrentUser"
            $moduleParams.Scope = "CurrentUser"
        }

        Install-PackageProvider @providerParams | Out-Null
        try {
            if ((Get-PSRepository -Name PSGallery -ErrorAction Stop).InstallationPolicy -ne "Trusted") {
                Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
            }
        }
        catch {
            Write-Host "    Continuing without changing the PowerShell Gallery trust policy."
        }

        Install-Module @moduleParams
        Import-Module Microsoft.WinGet.Client -Force
        if ($isAdmin) {
            Repair-WinGetPackageManager -AllUsers
        }
        else {
            Repair-WinGetPackageManager
        }
        $installed = $true
    }
    catch {
        Write-Host "    Microsoft's installer module did not finish. Downloading WinGet from GitHub."
        Write-Host "    $($_.Exception.Message)"
    }

    if (-not $installed -or -not (Find-WorkingWinget)) {
        Install-WinGetFromGitHub
    }

    Refresh-SessionPath
    if (-not (Find-WorkingWinget)) {
        throw @"
WinGet still is not available.

Use Windows 10 version 1809 or newer, or Windows 11. Then open Settings, go to Apps, Advanced app settings, App execution aliases, and turn on Windows Package Manager Client. Run this script again after that.
"@
    }

    Write-Ok "WinGet is ready."
}

function Install-WingetPackage {
    param(
        [Parameter(Mandatory = $true)][string]$Id,
        [Parameter(Mandatory = $true)][string]$Label
    )

    Write-Step "Installing $Label ($Id)"
    & $script:WingetCommand install --id $Id --exact --source winget `
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
$script:WingetCommand = Find-WorkingWinget
if (-not $script:WingetCommand) {
    Install-WinGet
    $script:WingetCommand = Find-WorkingWinget
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
