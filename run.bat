@echo off
REM SonicCanvas - Start both frontend and backend servers
REM This batch file starts the FastAPI backend and React frontend dev server in separate windows

setlocal enabledelayedexpansion

echo.
echo ========================================
echo   SonicCanvas - Starting App
echo ========================================
echo.

REM Check if venv is activated, activate if not
if not defined VIRTUAL_ENV (
    echo [1/2] Activating Python virtual environment...
    call venv\Scripts\activate.bat
    if errorlevel 1 (
        echo ERROR: Failed to activate virtual environment
        echo Run this first:
        echo   python -m venv venv
        pause
        exit /b 1
    )
)

REM Check if models are pre-downloaded (optional warning)
if not exist "%USERPROFILE%\.cache\huggingface\hub\models--facebook--musicgen-small*" (
    echo.
    echo WARNING: MusicGen model not pre-downloaded!
    echo First request will take 5-15 minutes.
    echo.
    echo Tip: Pre-download model with:
    echo   python download_model.py
    echo.
)

echo [2/2] Starting backend and frontend servers...
echo.
echo Backend: http://127.0.0.1:8000
echo Frontend: http://127.0.0.1:5173
echo.

REM Start backend in new window
echo Starting backend (FastAPI/Uvicorn)...
start "SonicCanvas Backend" cmd /k ".venv\Scripts\activate.bat && python -m uvicorn app:app --reload --host 127.0.0.1 --port 8000"

REM Small delay to let backend start
timeout /t 2 /nobreak > nul

REM Start frontend in new window
echo Starting frontend (Vite dev server)...
start "SonicCanvas Frontend" cmd /k "cd frontend && npm run dev -- --host 127.0.0.1 --port 5173"

echo.
echo ========================================
echo App starting in separate windows...
echo Close either window to stop that server.
echo ========================================
echo.

REM Keep main window open
pause
