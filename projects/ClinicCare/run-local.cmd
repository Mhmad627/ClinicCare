@echo off
REM ===========================================================================
REM  ClinicCare - build and run locally WITHOUT opening Visual Studio.
REM  Double-click this file, or run it from a terminal.
REM  Press Ctrl+C (or close this window) to stop the server.
REM ===========================================================================
setlocal

set "APP=%~dp0ClinicCare"
set "PORT=52945"

REM --- Locate MSBuild from whichever Visual Studio / Build Tools is installed ---
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
set "MSBUILD="
if exist "%VSWHERE%" (
    for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -products * -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) do set "MSBUILD=%%i"
)

REM --- Build the code-behind. Changes to .aspx markup alone do not need this,
REM     but changes to any .cs file do. ---
if defined MSBUILD (
    echo Building ClinicCare...
    "%MSBUILD%" "%APP%\ClinicCare.csproj" /v:minimal /nologo
    if errorlevel 1 (
        echo.
        echo *** BUILD FAILED - fix the errors above before running. ***
        pause
        exit /b 1
    )
) else (
    echo MSBuild not found - serving the existing build in bin\ without recompiling.
)

REM --- Serve the site ---
set "IISEXPRESS=%ProgramFiles%\IIS Express\iisexpress.exe"
if not exist "%IISEXPRESS%" set "IISEXPRESS=%ProgramFiles(x86)%\IIS Express\iisexpress.exe"
if not exist "%IISEXPRESS%" (
    echo *** IIS Express not found. Install the "ASP.NET and web development"
    echo *** workload in the Visual Studio Installer.
    pause
    exit /b 1
)

echo.
echo   ClinicCare running at http://localhost:%PORT%/
echo   Press Ctrl+C to stop.
echo.

start "" "http://localhost:%PORT%/"
"%IISEXPRESS%" /path:"%APP%" /port:%PORT%

endlocal
