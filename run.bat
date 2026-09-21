@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "ROOT=%~dp0"
set "BACKEND_VENV=%ROOT%.venv"
set "BACKEND_PY=%BACKEND_VENV%\Scripts\python.exe"
set "FRONTEND_DIR=%ROOT%frontend"
set "MODEL_CACHE=%USERPROFILE%\.cache\huggingface\hub\models--facebook--musicgen-small*"

pushd "%ROOT%" >nul

echo.
echo ========================================
echo   SonicCanvas - Setup and Launch
echo ========================================
echo.

call :ResolvePython || goto :fail
call :EnsureEnvFiles || goto :fail
call :EnsureVirtualEnv || goto :fail
call :InstallBackendDeps || goto :fail
call :InstallFrontendDeps || goto :fail
call :PreDownloadModel

if /i "%SC_SKIP_LAUNCH%"=="1" goto :done
call :StartServers || goto :fail

:done
echo.
echo ========================================
echo Setup complete.
echo Leave the backend and frontend windows open to keep the app running.
echo ========================================
echo.
pause
popd >nul
exit /b 0

:ResolvePython
set "PYTHON_CMD="

for %%V in (3.13 3.12 3.11 3.10) do (
    if not defined PYTHON_CMD (
        for /f "delims=" %%I in ('py -%%V -c "import sys; print(sys.executable)" 2^>nul') do set "PYTHON_CMD=%%I"
    )
)

if not defined PYTHON_CMD (
    where python >nul 2>nul || (
        echo ERROR: Python 3.10 or newer is required.
        exit /b 1
    )
    for /f "delims=" %%I in ('python -c "import sys; print(sys.executable)"') do set "PYTHON_CMD=%%I"
)

if not defined PYTHON_CMD (
    echo ERROR: Python 3.10 or newer is required.
    exit /b 1
)

"%PYTHON_CMD%" -c "import sys; raise SystemExit(0 if sys.version_info >= (3, 10) else 1)" >nul 2>&1
if errorlevel 1 (
    echo ERROR: Found Python at "%PYTHON_CMD%" but it is older than 3.10.
    echo Install Python 3.10+ and run this file again.
    exit /b 1
)

echo Using Python: %PYTHON_CMD%
exit /b 0

:EnsureEnvFiles
if not exist ".env" (
    copy /y ".env.example" ".env" >nul || (
        echo ERROR: Missing .env.example in the project root.
        exit /b 1
    )
)

if not exist "%FRONTEND_DIR%\.env" (
    copy /y "%FRONTEND_DIR%\.env.example" "%FRONTEND_DIR%\.env" >nul || (
        echo ERROR: Missing frontend\.env.example.
        exit /b 1
    )
)

exit /b 0

:EnsureVirtualEnv
if not exist "%BACKEND_PY%" (
    echo Creating Python virtual environment...
    "%PYTHON_CMD%" -m venv "%BACKEND_VENV%" || exit /b 1
)

exit /b 0

:InstallBackendDeps
echo Installing backend dependencies...
"%BACKEND_PY%" -m pip install --upgrade pip setuptools wheel || exit /b 1
"%BACKEND_PY%" -m pip install --upgrade -r requirements.txt || exit /b 1
exit /b 0

:InstallFrontendDeps
echo Installing frontend dependencies...
pushd "%FRONTEND_DIR%" >nul
npm install --no-audit --no-fund || (
    popd >nul
    exit /b 1
)
popd >nul
exit /b 0

:PreDownloadModel
if not exist "%USERPROFILE%\.cache\huggingface\hub\models--facebook--musicgen-small*" (
    echo Downloading MusicGen model cache for first run...
    "%BACKEND_PY%" download_model.py
    if errorlevel 1 (
        echo WARNING: Model pre-download failed.
        echo The app can still start, but generation may fail until the model is downloaded.
    )
)
exit /b 0

:StartServers
echo Starting backend and frontend servers...
echo Backend: http://127.0.0.1:8000
echo Frontend: http://127.0.0.1:5173
echo.

start "SonicCanvas Backend" cmd /k ""%BACKEND_PY%" -m uvicorn app:app --reload --host 127.0.0.1 --port 8000"
timeout /t 2 /nobreak >nul
start "SonicCanvas Frontend" cmd /k "cd /d ""%FRONTEND_DIR%"" && npm run dev -- --host 127.0.0.1 --port 5173"
exit /b 0

:fail
echo.
echo Setup failed. Fix the error above and run run.bat again.
echo.
popd >nul
pause
exit /b 1
