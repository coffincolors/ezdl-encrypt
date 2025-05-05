@echo off
rem -------------------------------------------------
rem  Start.cmd - helper to package payload.ps1
rem -------------------------------------------------

cd /d "%~dp0"

echo.
echo =================================================
echo   EZDL-Encrypt  -  one-shot payload packager
echo =================================================
echo.

:: --- 1. Check required files ----------------------------------
set "missing="
if not exist "ezdl-encrypt.ps1" (
    echo ERROR: ezdl-encrypt.ps1 not found.
    set "missing=1"
)
if not exist "payload.ps1" (
    echo ERROR: payload.ps1 not found.
    set "missing=1"
)

if defined missing (
    echo.
    echo One or more required files are missing.
    echo Fix the problem, then run Start.cmd again.
    echo.
    pause
    goto :eof
)

echo All required files are present.
echo If you still need to edit payload.ps1 press Ctrl+C to cancel,
echo make your changes, then run Start.cmd again.
pause

:: --- 2. Run the encryptor -------------------------------------
powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File ".\ezdl-encrypt.ps1"
if errorlevel 1 (
    echo.
    echo PowerShell reported an error - secure_loader.ps1 not created.
    pause
    goto :eof
)

:: --- 3. Report result ----------------------------------------
echo.
if exist "secure_loader.ps1" (
    echo SUCCESS: secure_loader.ps1 has been created.
) else (
    echo WARNING: secure_loader.ps1 was NOT created.
)
echo.
pause
