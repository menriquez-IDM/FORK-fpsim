@echo off
REM FPsim Family Planning Simulation Shiny App - Windows Batch Startup Script
REM This script sets up the environment and starts the FPsim Shiny app
REM Run from the shiny\ directory

echo ========================================
echo FPsim Family Planning Shiny App Startup
echo ========================================
echo.

REM Check if we're in the right directory
if not exist "app.R" (
    echo ERROR: app.R not found. Please run this script from the shiny\ directory
    pause
    exit /b 1
)

REM Kill any existing processes on port 3031
echo [INFO] Checking for existing processes on port 3031...
netstat -ano | findstr :3031 >nul
if %errorlevel% == 0 (
    echo [WARNING] Found existing process on port 3031, attempting to kill...
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3031') do taskkill /F /PID %%a 2>nul
    timeout /t 2 /nobreak >nul
)

REM Check if R is installed
echo [INFO] Checking R installation...
where R >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] R is not installed or not in PATH
    echo Please install R from https://cran.r-project.org/
    pause
    exit /b 1
)

REM Check if Python is installed
echo [INFO] Checking Python installation...
where python >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not in PATH
    echo Please install Python from https://www.python.org/
    pause
    exit /b 1
)

REM Go to project root
echo [INFO] Setting up Python virtual environment...
cd ..

REM Create virtual environment if it doesn't exist
if not exist "venv" (
    echo [INFO] Creating Python virtual environment...
    python -m venv venv
)

REM Activate virtual environment
echo [INFO] Activating virtual environment...
call venv\Scripts\activate.bat

REM Upgrade pip
echo [INFO] Upgrading pip...
python -m pip install --upgrade pip

REM Install Python dependencies
echo [INFO] Installing Python dependencies...
if exist "shiny\python\requirements.txt" (
    pip install -r shiny\python\requirements.txt
) else (
    echo [WARNING] requirements.txt not found, installing basic dependencies...
    pip install numpy pandas matplotlib seaborn plotly scipy scikit-learn
)

REM Install FPsim package
echo [INFO] Installing FPsim package...
pip install -e .

REM Install R dependencies
echo [INFO] Installing R dependencies...
cd shiny
Rscript install_dependencies.R

REM Final cleanup
echo [INFO] Final cleanup - ensuring port 3031 is free...
netstat -ano | findstr :3031 >nul
if %errorlevel% == 0 (
    for /f "tokens=5" %%a in ('netstat -ano ^| findstr :3031') do taskkill /F /PID %%a 2>nul
    timeout /t 2 /nobreak >nul
)

REM Start the app
echo [SUCCESS] Setup complete! Starting app on http://localhost:3031
echo [INFO] Press Ctrl+C to stop the app
echo.

Rscript app.R

pause

