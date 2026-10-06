@echo off
title Remove C# + VS Code setup
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0uninstall-windows.ps1"
echo.
pause
