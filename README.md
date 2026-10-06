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

If `winget` is missing, the script installs it. That needs Windows 10 version 1809 or newer, or Windows 11, plus an internet connection.

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
