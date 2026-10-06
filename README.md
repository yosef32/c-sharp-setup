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

Open PowerShell and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup-windows.ps1
```

Approve the permission prompt if Windows shows one. That lets the .NET SDK install for the whole PC.

To also create and run a small console app in the current folder:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup-windows.ps1 -CreateSample
```

WinGet must be available. On current Windows 10 and Windows 11 it comes with App Installer. If `winget` is missing, install App Installer from the Microsoft Store and run the script again.

## Mac

Open Terminal and run:

```bash
chmod +x setup-mac.sh
./setup-mac.sh
```

Homebrew may ask for your Mac password the first time. If a dialog appears asking to install Xcode Command Line Tools, finish that dialog and run the script again.

To also create and run a small console app in the current folder:

```bash
./setup-mac.sh --sample
```

The script uses the Homebrew `dotnet-sdk` cask, which installs Microsoft's .NET package. If that cask is unavailable, it falls back to Microsoft's `dotnet-install.sh` script and adds `~/.dotnet` to your PATH.

## After setup

Open a new terminal, then create a project:

```bash
mkdir HelloCSharp
cd HelloCSharp
dotnet new console
code .
dotnet run
```

In VS Code, use **Run and Debug** to start the app with the debugger.
