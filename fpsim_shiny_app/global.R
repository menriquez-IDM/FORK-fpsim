# FPsim Shiny Application - Global Setup
# This file runs once when the app starts

# Load required packages
library(shiny)
library(bslib)
library(reticulate)
library(plotly)
library(DT)
library(shinyjs)
library(jsonlite)

# Configure Python environment
# Point to the venv in parent directory
venv_path <- file.path(dirname(getwd()), "venv")

if (dir.exists(venv_path)) {
  use_virtualenv(venv_path, required = TRUE)
  message("Using Python virtual environment: ", venv_path)
} else {
  warning("Virtual environment not found at: ", venv_path)
  warning("Please ensure FPsim is installed in a virtual environment")
}

# Global variables
FPSIM_LOADED <- FALSE
FP <- NULL

# Initialize FPsim
init_fpsim <- function() {
  tryCatch({
    fp <<- import("fpsim")
    FPSIM_LOADED <<- TRUE
    message("FPsim version: ", fp$`__version__`)
    return(TRUE)
  }, error = function(e) {
    warning("Failed to load FPsim: ", e$message)
    return(FALSE)
  })
}

# Cache for location data
location_cache <- new.env()

# App configuration
APP_CONFIG <- list(
  app_version = "0.1.0",
  fpsim_version = "3.3.1",
  phase = "Phase 1 - Foundation",
  
  # Performance limits
  max_agents = 50000,
  max_years = 90,
  default_agents = 5000,
  default_start = 2000,
  default_end = 2030,
  
  # Available locations
  national_locations = c("kenya", "senegal", "ethiopia"),
  
  regional_locations = list(
    ethiopia = c(
      "addis_ababa", "afar", "amhara", "benishangul_gumuz",
      "dire_dawa", "gambela", "harari", "oromia", "snnpr",
      "somali", "tigray"
    )
  ),
  
  # Plot colors
  colors = list(
    primary = "#3498db",
    secondary = "#2ecc71",
    danger = "#e74c3c",
    warning = "#f39c12",
    info = "#3498db",
    light = "#ecf0f1",
    dark = "#34495e"
  )
)

# Helper function: estimate runtime
estimate_runtime <- function(n_agents, n_years) {
  # Based on benchmarks: ~0.7 seconds for 5000 agents, 5 years
  # Linear scaling assumption
  base_time <- 0.7
  base_agents <- 5000
  base_years <- 5
  
  estimated <- base_time * (n_agents / base_agents) * (n_years / base_years)
  return(round(estimated, 1))
}

# Helper function: format number with commas
format_number <- function(x) {
  format(x, big.mark = ",", scientific = FALSE)
}

# Initialize FPsim on startup
message(paste(rep("=", 60), collapse = ""))
message("FPsim Shiny App - Global Setup")
message(paste(rep("=", 60), collapse = ""))
message("App Version: ", APP_CONFIG$app_version)
message("Phase: ", APP_CONFIG$phase)
message("Initializing FPsim...")

if (init_fpsim()) {
  message("✓ FPsim loaded successfully")
  message("✓ FPsim version: ", fp$`__version__`)
} else {
  message("✗ FPsim loading failed - check Python environment")
}

message(paste(rep("=", 60), collapse = ""))

