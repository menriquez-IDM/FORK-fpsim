# FPsim Family Planning Shiny Web App
# Main application file

# Load required libraries
library(shiny)
library(shinyjs)
library(plotly)
library(DT)
library(reticulate)
library(dplyr)
library(ggplot2)

# Set up Python environment with error handling
python_available <- FALSE
tryCatch({
  # Use the virtual environment Python where fpsim is installed
  use_python("../venv/bin/python", required = FALSE)
  source_python("python/fp_simulator.py")
  python_available <<- TRUE
  cat("FPsim Python environment configured successfully\n")
}, error = function(e) {
  cat("Python integration not available:", e$message, "\n")
  cat("Running in simulation-only mode\n")
})

# Source UI and server components
source("ui.R")
source("server.R")

# Run the application on port 3031
shinyApp(ui = ui, server = server, options = list(port = 3031, host = "0.0.0.0"))

