#Requires -Version 5.1
<#
.SYNOPSIS
  Creates a new C# console app and opens it in Visual Studio Code.

.DESCRIPTION
  Asks for a project name, creates that console app in the current folder,
  runs it once, and opens the folder in Visual Studio Code.

  Run setup-windows.cmd first so .NET and Visual Studio Code are installed.

  Double-click new-project-windows.cmd to run this from File Explorer.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\new-project-windows.ps1 -Name MyApp
#>
[CmdletBinding()]
param(
    [string]$Name
)

$ErrorActionPreference = "Stop"

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
    if ($machine -or $user) {
        $env:Path = "$machine;$user"
    }
}

function Test-ProjectName {
    param([string]$Value)
    if ($Value -notmatch '^[A-Za-z][A-Za-z0-9_]{0,49}$') {
        return $false
    }

    $reserved = @(
        "CON", "PRN", "AUX", "NUL",
        "COM1", "COM2", "COM3", "COM4", "COM5", "COM6", "COM7", "COM8", "COM9",
        "LPT1", "LPT2", "LPT3", "LPT4", "LPT5", "LPT6", "LPT7", "LPT8", "LPT9"
    )
    return $reserved -notcontains $Value.ToUpperInvariant()
}

function Read-ProjectName {
    $invalid = "Use a name that starts with a letter and uses only letters, numbers, and underscores. For example: MyApp"

    if (-not [string]::IsNullOrWhiteSpace($Name)) {
        $candidate = $Name.Trim()
        if (-not (Test-ProjectName $candidate)) {
            throw $invalid
        }
        if (Test-Path -LiteralPath (Join-Path (Get-Location) $candidate)) {
            throw "A folder named $candidate is already here. Pick another name."
        }
        return $candidate
    }

    $useDialog = $true
    try {
        Add-Type -AssemblyName Microsoft.VisualBasic -ErrorAction Stop
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    }
    catch {
        $useDialog = $false
    }

    $suggested = "MyApp"
    while ($true) {
        if ($useDialog) {
            $prompt = @"
Type a name for the new console app.

Use a letter first, then letters, numbers, or underscores.

The folder is created in:
$(Get-Location)
"@
            $candidate = [Microsoft.VisualBasic.Interaction]::InputBox($prompt, "New C# project", $suggested)
            if ([string]::IsNullOrWhiteSpace($candidate)) {
                Write-Host "Project creation cancelled."
                exit 0
            }
        }
        else {
            Write-Host "The new project folder is created in:" -ForegroundColor White
            Write-Host "    $(Get-Location)" -ForegroundColor White
            $typed = (Read-Host "Project name [$suggested]").Trim()
            if ([string]::IsNullOrWhiteSpace($typed)) {
                $candidate = $suggested
            }
            else {
                $candidate = $typed
            }
        }

        $candidate = $candidate.Trim()
        if (-not (Test-ProjectName $candidate)) {
            if ($useDialog) {
                [System.Windows.Forms.MessageBox]::Show($invalid, "New C# project") | Out-Null
                if (-not [string]::IsNullOrWhiteSpace($candidate)) {
                    $suggested = $candidate
                }
            }
            else {
                Write-Host "    $invalid"
            }
            continue
        }

        if (Test-Path -LiteralPath (Join-Path (Get-Location) $candidate)) {
            $exists = "A folder named $candidate is already here. Pick another name."
            if ($useDialog) {
                [System.Windows.Forms.MessageBox]::Show($exists, "New C# project") | Out-Null
            }
            else {
                Write-Host "    $exists"
            }
            continue
        }

        return $candidate
    }
}

function Get-DotNetAt {
    param([string]$Exe)

    if (-not $Exe -or -not (Test-Path -LiteralPath $Exe)) {
        return $null
    }

    $root = Split-Path -Parent $Exe
    $hadRoot = Test-Path Env:DOTNET_ROOT
    $oldRoot = $env:DOTNET_ROOT
    $oldPath = $env:Path
    $previous = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $env:DOTNET_ROOT = $root
        $env:Path = "$root;$oldPath"
        $raw = @(& $Exe --version 2>&1)
        foreach ($item in $raw) {
            $text = "$item".Trim()
            if ($text -match "^[0-9]+\.[0-9]+\.[0-9]+") {
                return @{
                    Exe     = $Exe
                    Root    = $root
                    Version = $text
                }
            }
        }
        return $null
    }
    finally {
        $ErrorActionPreference = $previous
        if ($hadRoot) {
            $env:DOTNET_ROOT = $oldRoot
        }
        else {
            Remove-Item Env:DOTNET_ROOT -ErrorAction SilentlyContinue
        }
        $env:Path = $oldPath
    }
}

function Find-DotNet {
    Refresh-SessionPath

    $candidates = @(
        "$env:ProgramFiles\dotnet\dotnet.exe",
        "${env:ProgramFiles(x86)}\dotnet\dotnet.exe",
        "$env:LocalAppData\Microsoft\dotnet\dotnet.exe",
        "$env:LocalAppData\dotnet\dotnet.exe"
    )

    $command = Get-Command dotnet -ErrorAction SilentlyContinue
    if ($command) {
        $candidates += $command.Source
    }

    $seen = @{}
    foreach ($candidate in $candidates) {
        if (-not $candidate) {
            continue
        }
        $key = $candidate.ToLowerInvariant()
        if ($seen.ContainsKey($key)) {
            continue
        }
        $seen[$key] = $true

        $found = Get-DotNetAt -Exe $candidate
        if ($found) {
            return $found
        }
    }

    return $null
}

function Use-DotNet {
    param($Found)
    $env:DOTNET_ROOT = $Found.Root
    $env:Path = "$($Found.Root);$env:Path"
    $script:DotNetExe = $Found.Exe
    $script:DotNetRoot = $Found.Root
    $script:DotNetVersion = $Found.Version
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

function Get-TargetFramework {
    param([string]$ProjectFile)
    $text = Get-Content -LiteralPath $ProjectFile -Raw
    if ($text -match "<TargetFramework>([^<]+)</TargetFramework>") {
        return $Matches[1].Trim()
    }
    throw "Could not read the target framework from $ProjectFile."
}

function Write-ProjectEditorFiles {
    param(
        [Parameter(Mandatory = $true)][string]$ProjectDir,
        [Parameter(Mandatory = $true)][string]$ProjectName,
        [Parameter(Mandatory = $true)][string]$TargetFramework,
        [Parameter(Mandatory = $true)][string]$DotNetExe,
        [Parameter(Mandatory = $true)][string]$DotNetRoot
    )

    $vscodeDir = Join-Path $ProjectDir ".vscode"
    New-Item -ItemType Directory -Force -Path $vscodeDir | Out-Null

    $exeJson = $DotNetExe.Replace("\", "\\")
    $rootJson = $DotNetRoot.Replace("\", "\\")

    @"
{
  "dotnet.dotnetPath": "$exeJson",
  "dotnetAcquisitionExtension.sharedExistingDotnetPath": "$exeJson",
  "terminal.integrated.env.windows": {
    "DOTNET_ROOT": "$rootJson",
    "PATH": "$rootJson;`${env:PATH}"
  }
}
"@ | Set-Content -LiteralPath (Join-Path $vscodeDir "settings.json") -Encoding utf8

    $launch = @'
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch PROJECT_NAME",
      "type": "coreclr",
      "request": "launch",
      "preLaunchTask": "build",
      "program": "${workspaceFolder}/bin/Debug/TARGET_FRAMEWORK/PROJECT_NAME.dll",
      "args": [],
      "cwd": "${workspaceFolder}",
      "stopAtEntry": false,
      "console": "integratedTerminal"
    }
  ]
}
'@
    $launch = $launch.Replace("PROJECT_NAME", $ProjectName).Replace("TARGET_FRAMEWORK", $TargetFramework)
    Set-Content -LiteralPath (Join-Path $vscodeDir "launch.json") -Value $launch -Encoding utf8

    $tasks = @'
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "build",
      "command": "dotnet",
      "type": "process",
      "args": [
        "build",
        "${workspaceFolder}/PROJECT_NAME.csproj",
        "/property:GenerateFullPaths=true",
        "/consoleloggerparameters:NoSummary;ForceNoAlign"
      ],
      "group": {
        "kind": "build",
        "isDefault": true
      },
      "problemMatcher": "$msCompile"
    }
  ]
}
'@
    $tasks = $tasks.Replace("PROJECT_NAME", $ProjectName)
    Set-Content -LiteralPath (Join-Path $vscodeDir "tasks.json") -Value $tasks -Encoding utf8
}

if ($env:OS -ne "Windows_NT") {
    throw "This script is for Windows. On a Mac, double-click new-project-mac.command."
}

Write-Host "New C# project" -ForegroundColor White

Write-Step "Choosing a project name"
$projectName = Read-ProjectName
$projectDir = Join-Path (Get-Location) $projectName
$projectFile = Join-Path $projectDir "$projectName.csproj"
Write-Ok "The project name is $projectName."

Write-Step "Checking the .NET SDK"
$dotnet = Find-DotNet
if (-not $dotnet) {
    throw "The dotnet command was not found. Double-click setup-windows.cmd first, then run this script again."
}
Use-DotNet -Found $dotnet
$versionParts = $script:DotNetVersion.Split(".")
$framework = "net$($versionParts[0]).$($versionParts[1])"
Write-Ok ".NET SDK $script:DotNetVersion ($framework)"

Write-Step "Checking Visual Studio Code"
$codeCmd = Find-CodeCommand
if (-not $codeCmd) {
    throw "Visual Studio Code was not found. Double-click setup-windows.cmd first, then run this script again."
}
Write-Ok "Visual Studio Code is available."

Write-Step "Creating $projectName"
New-Item -ItemType Directory -Path $projectDir | Out-Null
$removeOnFailure = $true
Push-Location $projectDir
try {
    & $script:DotNetExe new console --language "C#" --name $projectName --output . --framework $framework --no-update-check
    if ($LASTEXITCODE -ne 0) {
        Get-ChildItem -Force | Remove-Item -Recurse -Force
        Write-Host "    Trying again with the SDK's default framework."
        & $script:DotNetExe new console --language "C#" --name $projectName --output . --no-update-check
    }
    if ($LASTEXITCODE -ne 0) {
        throw "dotnet new console failed. Double-click setup-windows.cmd first, then run this script again."
    }

    $removeOnFailure = $false
    & $script:DotNetExe run
    if ($LASTEXITCODE -ne 0) {
        throw "The new project did not run."
    }
}
finally {
    Pop-Location
    if ($removeOnFailure) {
        Remove-Item -LiteralPath $projectDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

$targetFramework = Get-TargetFramework -ProjectFile $projectFile
Write-ProjectEditorFiles -ProjectDir $projectDir -ProjectName $projectName -TargetFramework $targetFramework -DotNetExe $script:DotNetExe -DotNetRoot $script:DotNetRoot
Write-Ok "Created $projectDir"
Write-Ok "Run and Debug is set to Launch $projectName"

Write-Step "Opening the project in Visual Studio Code"
& $codeCmd $projectDir
if ($LASTEXITCODE -ne 0) {
    throw "Visual Studio Code did not open $projectDir."
}
Write-Ok "VS Code is opening $projectDir"

Write-Host ""
Write-Host "Press F5, or open Run and Debug and start Launch $projectName." -ForegroundColor White
Write-Host "You can also open a terminal in that window and run:" -ForegroundColor White
Write-Host ""
Write-Host "    dotnet run" -ForegroundColor Yellow
Write-Host ""
