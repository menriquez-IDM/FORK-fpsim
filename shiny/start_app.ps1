# FPsim Family Planning Simulation Shiny App - PowerShell Startup Script
# This script sets up the environment and starts the FPsim Shiny app
# Run from the shiny/ directory

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "FPsim Family Planning Shiny App Startup" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Function to print colored messages
function Print-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Print-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Print-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Print-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Check if we're in the right directory
if (-not (Test-Path "app.R") -or -not (Test-Path "python")) {
    Print-Error "Please run this script from the shiny/ directory (where app.R is located)"
    Read-Host "Press Enter to exit"
    exit 1
}

# Kill any existing processes on port 3031
Print-Status "Checking for existing processes on port 3031..."
$processIds = Get-NetTCPConnection -LocalPort 3031 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess
if ($processIds) {
    Print-Warning "Found existing process on port 3031, killing it..."
    $processIds | ForEach-Object { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue }
    Start-Sleep -Seconds 2
}

# Check if R is installed
Print-Status "Checking R installation..."
$rPath = Get-Command R -ErrorAction SilentlyContinue
if (-not $rPath) {
    Print-Error "R is not installed or not in PATH"
    Print-Error "Please install R from https://cran.r-project.org/"
    Read-Host "Press Enter to exit"
    exit 1
}

# Check if Python is installed
Print-Status "Checking Python installation..."
$pythonPath = Get-Command python -ErrorAction SilentlyContinue
if (-not $pythonPath) {
    Print-Error "Python is not installed or not in PATH"
    Print-Error "Please install Python from https://www.python.org/"
    Read-Host "Press Enter to exit"
    exit 1
}

# Go to project root
Print-Status "Setting up Python virtual environment..."
Set-Location ..

# Create virtual environment if it doesn't exist
if (-not (Test-Path "venv")) {
    Print-Status "Creating Python virtual environment..."
    python -m venv venv
}

# Activate virtual environment
Print-Status "Activating virtual environment..."
& ".\venv\Scripts\Activate.ps1"

# Upgrade pip
Print-Status "Upgrading pip..."
python -m pip install --upgrade pip

# Install Python dependencies
Print-Status "Installing Python dependencies..."
if (Test-Path "shiny\python\requirements.txt") {
    pip install -r shiny\python\requirements.txt
} else {
    Print-Warning "requirements.txt not found, installing basic dependencies..."
    pip install numpy pandas matplotlib seaborn plotly scipy scikit-learn
}

# Install FPsim package
Print-Status "Installing FPsim package..."
pip install -e .

# Install R dependencies
Print-Status "Installing R dependencies..."
Set-Location shiny
Rscript -e "
# Install required R packages
required_packages <- c(
  'shiny',
  'shinyjs',
  'shinybusy',
  'plotly',
  'DT',
  'reticulate',
  'dplyr',
  'ggplot2',
  'rstudioapi',
  'shinyWidgets',
  'htmltools',
  'jsonlite'
)

# Function to install packages
install_if_missing <- function(pkg) {
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat('Installing', pkg, '...\n')
    install.packages(pkg, repos = 'https://cran.r-project.org/')
  } else {
    cat(pkg, 'already installed\n')
  }
}

# Install all packages
for (pkg in required_packages) {
  install_if_missing(pkg)
}

cat('All R packages installed successfully!\n')
"

# Final cleanup
Print-Status "Final cleanup - ensuring port 3031 is free..."
$processIds = Get-NetTCPConnection -LocalPort 3031 -ErrorAction SilentlyContinue | Select-Object -ExpandProperty OwningProcess
if ($processIds) {
    $processIds | ForEach-Object { Stop-Process -Id $_ -Force -ErrorAction SilentlyContinue }
    Start-Sleep -Seconds 2
}

# Start the app
Print-Success "Setup complete! Starting app on http://localhost:3031"
Print-Status "Press Ctrl+C to stop the app"
Write-Host ""

Rscript app.R

Read-Host "Press Enter to exit"

