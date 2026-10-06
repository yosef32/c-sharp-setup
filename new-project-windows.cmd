@echo off
title New C# project
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0new-project-windows.ps1"
echo.
pause
