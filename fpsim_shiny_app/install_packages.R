# Install Required R Packages for FPsim Shiny App
# Run this script once to set up your R environment

cat("="*60, "\n")
cat("FPsim Shiny App - Package Installation\n")
cat("="*60, "\n\n")

# Required packages
required_packages <- c(
  "shiny",           # Core Shiny framework
  "bslib",           # Bootstrap 5 theming
  "reticulate",      # R-Python interface
  "plotly",          # Interactive plots
  "DT",              # Interactive tables
  "shinyjs",         # JavaScript operations
  "jsonlite",        # JSON handling
  "dplyr",           # Data manipulation (future use)
  "tidyr",           # Data tidying (future use)
  "ggplot2"          # Static plots (future use)
)

# Optional packages for future phases
optional_packages <- c(
  "leaflet",         # Interactive maps (Phase 4)
  "echarts4r",       # Advanced charts (Phase 2)
  "shinyWidgets",    # Enhanced widgets (Phase 2)
  "shinydashboard",  # Dashboard layouts (future)
  "rmarkdown",       # Report generation (Phase 5)
  "knitr",           # Report generation (Phase 5)
  "testthat"         # Unit testing (Phase 2)
)

# Function to install package if not already installed
install_if_missing <- function(package) {
  if (!require(package, character.only = TRUE, quietly = TRUE)) {
    cat(sprintf("Installing %s...\n", package))
    install.packages(package, dependencies = TRUE, quiet = FALSE)
    return(TRUE)
  } else {
    cat(sprintf("✓ %s already installed\n", package))
    return(FALSE)
  }
}

# Install required packages
cat("\n=== Installing Required Packages ===\n\n")
required_installed <- sapply(required_packages, install_if_missing)

# Install optional packages (with user confirmation)
cat("\n=== Optional Packages ===\n")
cat("These packages are needed for future phases.\n")
cat("Install now? (y/n): ")

response <- readline()
if (tolower(response) == "y") {
  cat("\nInstalling optional packages...\n\n")
  optional_installed <- sapply(optional_packages, install_if_missing)
} else {
  cat("Skipping optional packages. You can install them later.\n")
}

# Verify installations
cat("\n=== Verification ===\n\n")

all_packages <- c(required_packages)
success <- TRUE

for (pkg in all_packages) {
  if (require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat(sprintf("✓ %s loaded successfully\n", pkg))
  } else {
    cat(sprintf("✗ %s failed to load\n", pkg))
    success <- FALSE
  }
}

# Check Python/reticulate
cat("\n=== Python Environment Check ===\n\n")

tryCatch({
  library(reticulate)
  
  # Try to find virtual environment
  venv_path <- file.path(dirname(getwd()), "venv")
  
  if (dir.exists(venv_path)) {
    cat(sprintf("✓ Virtual environment found: %s\n", venv_path))
    use_virtualenv(venv_path, required = FALSE)
    
    # Try to import fpsim
    tryCatch({
      fp <- import("fpsim")
      cat(sprintf("✓ FPsim loaded successfully\n"))
      cat(sprintf("  Version: %s\n", fp$`__version__`))
    }, error = function(e) {
      cat("✗ FPsim not found in Python environment\n")
      cat("  Please install FPsim:\n")
      cat("    cd /Users/mine/fpgit/FORK-fpsim\n")
      cat("    source venv/bin/activate\n")
      cat("    pip install -e .\n")
      success <<- FALSE
    })
  } else {
    cat(sprintf("✗ Virtual environment not found at: %s\n", venv_path))
    cat("  Please create a virtual environment and install FPsim\n")
    success <<- FALSE
  }
}, error = function(e) {
  cat("✗ Error checking Python environment:", e$message, "\n")
  success <<- FALSE
})

# Summary
cat("\n")
cat("="*60, "\n")
if (success) {
  cat("✓ Installation Complete - Ready to Run!\n")
  cat("="*60, "\n")
  cat("\nTo start the app:\n")
  cat("  setwd('/Users/mine/fpgit/FORK-fpsim/fpsim_shiny_app')\n")
  cat("  shiny::runApp()\n\n")
} else {
  cat("⚠ Installation Complete with Warnings\n")
  cat("="*60, "\n")
  cat("\nPlease resolve the issues above before running the app.\n\n")
}

