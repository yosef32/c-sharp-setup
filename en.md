# C# and Visual Studio Code, step by step

These steps install Git, the .NET 10 SDK, Visual Studio Code, and the C# extensions. After that you can run the sample, create another console app, or remove the tools.

You only need an internet connection. Setup is safe to run again. Anything already installed is skipped.

C# Dev Kit is free for individuals, students, and open-source work. The first time it opens, Visual Studio Code may ask you to sign in with a Microsoft account.

## 1. Install on Windows

Use this on Windows 10 version 1809 or newer, or on Windows 11. The PC must be 64-bit.

### Option A. Double-click

1. Open the folder that contains these scripts.
2. Double-click `setup-windows.cmd`.
3. If Windows asks for permission, choose **Yes**. That lets the .NET SDK install for the whole PC.
4. Wait until the window says the PC is ready for C#.
5. Press a key to close the window.

Visual Studio Code opens the `HelloCSharp` folder when the install finishes.

### Option B. PowerShell

1. Open the folder that contains these scripts.
2. Click the address bar, type `powershell`, and press Enter.
3. Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup-windows.ps1
```

4. If Windows asks for permission, choose **Yes**.
5. Wait until the window says the PC is ready for C#.

### What the install does

1. Installs WinGet if the `winget` command is missing.
2. Installs Git.
3. Installs the .NET 10 SDK. The SDK includes the runtime.
4. Installs Visual Studio Code.
5. Installs the .NET Install Tool, the C# extension, and C# Dev Kit.
6. Creates a `HelloCSharp` console app in the current folder.
7. Runs that app once.
8. Opens that folder in Visual Studio Code.

Go to [Run the sample](#3-run-the-sample).

## 2. Install on a Mac

### Option A. Double-click

1. Open the folder that contains these scripts.
2. Double-click `setup-mac.command`.
3. If macOS says the file cannot be opened, right-click it, choose **Open**, then choose **Open** again.
4. If a dialog asks to install Xcode Command Line Tools, finish that dialog, then double-click `setup-mac.command` again.
5. If Homebrew asks for your Mac password, type it and press Return. The password does not appear as you type.
6. Wait until Terminal says the Mac is ready for C#.
7. Press Return to close the window.

Visual Studio Code opens the `HelloCSharp` folder when the install finishes.

### Option B. Terminal

1. Open Terminal.
2. Go to the folder that contains these scripts. For example:

```bash
cd ~/Downloads/c-sharp-setup
```

3. Run:

```bash
chmod +x setup-mac.sh
./setup-mac.sh
```

4. Finish the Xcode Command Line Tools dialog if it appears, then run `./setup-mac.sh` again.
5. Type your Mac password if Homebrew asks.

### What the install does

1. Checks for Xcode Command Line Tools, and opens the installer dialog if they are missing.
2. Installs Homebrew if it is missing.
3. Installs Git.
4. Installs the .NET 10 SDK from Homebrew. If that install does not finish, the script uses Microsoft's installer and adds `~/.dotnet` to your PATH.
5. Installs Visual Studio Code.
6. Installs the .NET Install Tool, the C# extension, and C# Dev Kit.
7. Creates a `HelloCSharp` console app in the current folder.
8. Runs that app once.
9. Opens that folder in Visual Studio Code.

## 3. Run the sample

The setup script leaves `HelloCSharp` open in Visual Studio Code.

1. Use the new `HelloCSharp` window. Close an older Visual Studio Code window if one was already open.
2. Press **F5**.
3. Or open **Run and Debug** and start **Launch HelloCSharp**.

That builds the project, then runs it under the debugger. The program prints:

```text
Hello, World!
```

You can also open the terminal in that window and run:

```bash
dotnet run
```

Sign in if C# Dev Kit asks. That unlocks solution view, debugging, and tests.

## 4. Create a new project on Windows

Run [Install on Windows](#1-install-on-windows) first. The new project is a console app, created in the current folder. A double-click uses the folder that contains the script.

The name must start with a letter and use only letters, numbers, and underscores, up to 50 characters. `MyApp` is a valid name. `123App` and `My App` are not.

### Option A. Double-click, then set the name

1. Double-click `new-project-windows.cmd`.
2. A window opens so you can set the project name. `MyApp` is already filled in.
3. Change the name, or leave `MyApp`. Choose **OK**.
4. Wait until the app prints `Hello, World!`.
5. Visual Studio Code opens the new folder.
6. Press a key to close the setup window.
7. In Visual Studio Code, press **F5**, or start **Launch** and the project name from **Run and Debug**.

Choose **Cancel** to stop without creating a project.

If that name is already a folder here, the script asks for a different name.

### Option B. Pass the name from PowerShell

1. Open PowerShell in the folder where you want the project.
2. Run:

```powershell
powershell -ExecutionPolicy Bypass -File .\new-project-windows.ps1 -Name MyApp
```

3. Change `MyApp` to the name you want.
4. In the Visual Studio Code window that opens, press **F5**.

## 5. Create a new project on a Mac

Run [Install on a Mac](#2-install-on-a-mac) first. The name rules are the same as on Windows.

### Option A. Double-click, then set the name

1. Double-click `new-project-mac.command`.
2. If macOS blocks the file, right-click it, choose **Open**, then choose **Open** again.
3. A window opens so you can set the project name. `MyApp` is already filled in.
4. Change the name, or leave `MyApp`. Choose **Create**.
5. Wait until the app prints `Hello, World!`.
6. Visual Studio Code opens the new folder.
7. Press Return to close the Terminal window.
8. In Visual Studio Code, press **F5**, or start **Launch** and the project name from **Run and Debug**.

Choose **Cancel** to stop without creating a project.

### Option B. Pass the name from Terminal

1. Open Terminal in the folder where you want the project.
2. Run:

```bash
chmod +x new-project-mac.sh
./new-project-mac.sh MyApp
```

3. Change `MyApp` to the name you want.
4. In the Visual Studio Code window that opens, press **F5**.

You can also run the app from the terminal inside Visual Studio Code:

```bash
dotnet run
```

## 6. Remove the tools on Windows

This removes the C# extension, the .NET Install Tool, C# Dev Kit, Visual Studio Code, the .NET 10 SDK, and Git. WinGet stays installed.

A double-click always asks you to type `YES`, and it does not delete the `HelloCSharp` folder. The extra choices below are for PowerShell.

### Option A. Double-click

1. Double-click `uninstall-windows.cmd`.
2. Read what will be removed.
3. Type `YES` and press Enter.
4. Wait until the window says the C# setup was removed.
5. Press a key to close the window.
6. Open a new terminal so PATH updates. Restart Windows if an uninstaller asked for it.

Type anything other than `YES` to cancel.

### Option B. PowerShell, with the confirmation

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall-windows.ps1
```

Type `YES` when asked.

### Option C. Skip the confirmation

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall-windows.ps1 -Force
```

`-Force` does not ask you to type `YES`.

### Option D. Also delete the sample app

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall-windows.ps1 -RemoveSample
```

`-RemoveSample` deletes a `HelloCSharp` folder in the current folder when that folder is the sample project. The script still asks you to type `YES`.

### Option E. Skip the confirmation and delete the sample

```powershell
powershell -ExecutionPolicy Bypass -File .\uninstall-windows.ps1 -Force -RemoveSample
```

## 7. Remove the tools on a Mac

This removes the C# extensions, Visual Studio Code, the .NET SDK, and Git's Homebrew copy. Homebrew and the Xcode Command Line Tools stay installed.

A double-click always asks you to type `YES`, and it does not delete the `HelloCSharp` folder. The extra choices below are for Terminal.

### Option A. Double-click

1. Double-click `uninstall-mac.command`.
2. If macOS blocks the file, right-click it, choose **Open**, then choose **Open** again.
3. Type `YES` and press Return.
4. Type your Mac password if an uninstaller asks.
5. Wait until Terminal says the C# setup was removed.
6. Press Return to close the window.
7. Open a new terminal so PATH updates.

### Option B. Terminal, with the confirmation

```bash
chmod +x uninstall-mac.sh
./uninstall-mac.sh
```

Type `YES` when asked.

### Option C. Skip the confirmation

```bash
./uninstall-mac.sh --yes
```

`--yes` does not ask you to type `YES`.

### Option D. Also delete the sample app

```bash
./uninstall-mac.sh --remove-sample
```

`--remove-sample` deletes a `HelloCSharp` folder in the current folder when that folder is the sample project. The script still asks you to type `YES`.

### Option E. Skip the confirmation and delete the sample

```bash
./uninstall-mac.sh --yes --remove-sample
```

You can write those two options in either order.

## All options

| Goal | How |
| --- | --- |
| Install on Windows | Double-click `setup-windows.cmd` |
| Install on Windows from PowerShell | `powershell -ExecutionPolicy Bypass -File .\setup-windows.ps1` |
| Install on a Mac | Double-click `setup-mac.command` |
| Install on a Mac from Terminal | `./setup-mac.sh` |
| Run the sample | Press **F5**, or start **Launch HelloCSharp** |
| Run the sample from the terminal | `dotnet run` |
| New project on Windows | Double-click `new-project-windows.cmd` and set the name |
| New project on Windows, named | `powershell -ExecutionPolicy Bypass -File .\new-project-windows.ps1 -Name MyApp` |
| New project on a Mac | Double-click `new-project-mac.command` and set the name |
| New project on a Mac, named | `./new-project-mac.sh MyApp` |
| Remove tools on Windows | Double-click `uninstall-windows.cmd`, then type `YES` |
| Remove tools on Windows, no question | `powershell -ExecutionPolicy Bypass -File .\uninstall-windows.ps1 -Force` |
| Remove tools and the sample on Windows | `powershell -ExecutionPolicy Bypass -File .\uninstall-windows.ps1 -RemoveSample` |
| Remove tools and the sample on Windows, no question | `powershell -ExecutionPolicy Bypass -File .\uninstall-windows.ps1 -Force -RemoveSample` |
| Remove tools on a Mac | Double-click `uninstall-mac.command`, then type `YES` |
| Remove tools on a Mac, no question | `./uninstall-mac.sh --yes` |
| Remove tools and the sample on a Mac | `./uninstall-mac.sh --remove-sample` |
| Remove tools and the sample on a Mac, no question | `./uninstall-mac.sh --yes --remove-sample` |
