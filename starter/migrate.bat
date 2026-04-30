@echo off
REM Windows launcher for Own Your Site.
REM Double-click this file. It opens a terminal in this folder
REM and starts Claude Code automatically.

cd /d "%~dp0"

where claude >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
  echo Claude Code is not installed yet.
  echo Open https://claude.com/claude-code in your browser and follow the install instructions.
  echo Then double-click this file again.
  pause
  exit /b 1
)

claude
