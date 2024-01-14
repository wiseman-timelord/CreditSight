@echo off
mode 120,80
color 80
title CreditSight
echo.
echo Batch Launcher Started....
echo.
echo.
timeout /t 1 /nobreak >nul

:: Initialization
echo Initialization Started...
echo.
echo Relocating To Script..
cd /d "%~dp0"
echo ..In Script Dir
echo Cleaning-Up Folder..
echo Cleaning up..
if exist ".\Errors-Crash.Log" (
    echo ...Deleting Log...
    del ".\Errors-Crash.Log"
)
echo ..Cleaning Done.
echo.
echo ...Initialization Completed.
echo.
echo.
timeout /t 1 /nobreak >nul

:: Launch Script
echo Starting Launch Sequence...
timeout /t 1 /nobreak >nul
echo Checking PowerShell..
where pwsh >nul 2>&1
echo.
echo ..Capabilities Detected.
if %ERRORLEVEL% equ 0 (
	echo Launching Psc Script..
    timeout /t 1 /nobreak >nul
    pwsh.exe -NoProfile -ExecutionPolicy Bypass -File ".\main.ps1"
    echo ..Psc Process Exited.
) else (
    echo Launching Ps Script..
    timeout /t 1 /nobreak >nul
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\main.ps1"
    echo.
	echo ..Ps Process Exited.
)
echo.
echo ...Launch Sequence Complete.
timeout /t 1 /nobreak >nul
echo.

:: Exit
echo.
echo ....Batch Launcher Finished.
echo.
pause
