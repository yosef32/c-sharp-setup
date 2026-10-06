# C# and VS Code setup

These scripts install everything needed to start writing C# in Visual Studio Code.

Both scripts install:

- Git
- .NET SDK 10 (the current long-term support release; the SDK includes the runtime)
- Visual Studio Code
- The .NET Install Tool, the C# extension, and C# Dev Kit

They are safe to run more than once. Anything already installed is skipped.

C# Dev Kit is free for individuals, students, and open-source work. The first time it opens, VS Code may ask you to sign in with a Microsoft account.

## Windows

Double-click `setup-windows.cmd`. A window opens, installs everything, and stays open until you press a key.

Approve the permission prompt if Windows shows one. That lets the .NET SDK install for the whole PC.

You can also open PowerShell and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup-windows.ps1
```

When the install finishes, the script creates a `HelloCSharp` console app in the current folder, runs it once, and opens that folder in Visual Studio Code.

If `winget` is missing, the script installs it. That needs Windows 10 version 1809 or newer, or Windows 11, plus an internet connection.

## Mac

Double-click `setup-mac.command`. Terminal opens, installs everything, and stays open until you press Enter.

If macOS says the file cannot be opened, right-click it, choose **Open**, then **Open** again.

Homebrew may ask for your Mac password the first time. If a dialog appears asking to install Xcode Command Line Tools, finish that dialog and double-click the file again.

You can also open Terminal and run:

```bash
chmod +x setup-mac.sh
./setup-mac.sh
```

When the install finishes, the script creates a `HelloCSharp` console app in the current folder, runs it once, and opens that folder in Visual Studio Code.

The script uses the Homebrew `dotnet-sdk` cask, which installs Microsoft's .NET package. If that cask is unavailable, it falls back to Microsoft's `dotnet-install.sh` script and adds `~/.dotnet` to your PATH.

## Uninstall

These scripts remove Git, the .NET SDK, Visual Studio Code, and the C# extensions. They ask you to type `YES` before deleting anything.

On Windows, WinGet stays installed. On Mac, Homebrew and the Xcode Command Line Tools stay installed.

Windows: double-click `uninstall-windows.cmd`, or run:

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall-windows.ps1
```

Mac: double-click `uninstall-mac.command`, or run:

```bash
chmod +x uninstall-mac.sh
./uninstall-mac.sh
```

Add `-RemoveSample` on Windows, or `--remove-sample` on Mac, to also delete a `HelloCSharp` sample in the current folder. Add `-Force` on Windows, or `--yes` on Mac, to skip the confirmation.

## After setup

The script leaves `HelloCSharp` open in Visual Studio Code. Press F5, or open **Run and Debug** and start **Launch HelloCSharp**. That configuration is in `HelloCSharp/.vscode/launch.json`. It builds the project, then runs it under the debugger.

You can also run it from the VS Code terminal:

```bash
dotnet run
```

Sign in if C# Dev Kit asks.
