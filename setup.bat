echo off
echo Administrative permissions required. Detecting permissions...

net session >nul 2>&1
if %errorLevel% == 0 (
    echo Success: Administrative permissions confirmed.
) else (
    echo Failure: Current permissions inadequate.
    pause
    exit /b 1
)

set BASEPATH=%~dp0
echo %BASEPATH%
echo %LOCALAPPDATA%

mklink /D %LOCALAPPDATA%\nvim %BASEPATH%\nvim
