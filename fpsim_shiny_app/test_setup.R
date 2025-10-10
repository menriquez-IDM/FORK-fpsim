# Test FPsim Shiny App Setup
# Verify R packages and Python/FPsim integration

cat("\n")
cat(paste(rep("=", 70), collapse = ""), "\n")
cat("FPsim Shiny App - Setup Test\n")
cat(paste(rep("=", 70), collapse = ""), "\n\n")

# Test 1: Check R packages
cat("Test 1: Checking R Packages\n")
cat(paste(rep("-", 70), collapse = ""), "\n")

required_packages <- c("shiny", "bslib", "reticulate", "plotly", "DT", "shinyjs", "jsonlite")
all_present <- TRUE

for (pkg in required_packages) {
  if (require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat(sprintf("  ✓ %s\n", pkg))
  } else {
    cat(sprintf("  ✗ %s (MISSING)\n", pkg))
    all_present <- FALSE
  }
}

if (!all_present) {
  cat("\n⚠ Some packages are missing. Run install_packages.R first.\n")
  quit(save = "no", status = 1)
}

cat("\n")

# Test 2: Check Python environment
cat("Test 2: Checking Python Environment\n")
cat(paste(rep("-", 70), collapse = ""), "\n")

venv_path <- file.path(dirname(getwd()), "venv")
cat(sprintf("  Virtual environment path: %s\n", venv_path))

if (dir.exists(venv_path)) {
  cat("  ✓ Virtual environment exists\n")
  
  tryCatch({
    use_virtualenv(venv_path, required = TRUE)
    cat("  ✓ Virtual environment activated\n")
    
    # Get Python version
    py_version <- py_config()
    cat(sprintf("  ✓ Python version: %s\n", py_version$version))
    cat(sprintf("  ✓ Python executable: %s\n", py_version$python))
    
  }, error = function(e) {
    cat(sprintf("  ✗ Error activating virtual environment: %s\n", e$message))
    quit(save = "no", status = 1)
  })
} else {
  cat("  ✗ Virtual environment not found\n")
  quit(save = "no", status = 1)
}

cat("\n")

# Test 3: Import FPsim
cat("Test 3: Importing FPsim\n")
cat(paste(rep("-", 70), collapse = ""), "\n")

tryCatch({
  fp <- import("fpsim")
  cat("  ✓ FPsim imported successfully\n")
  cat(sprintf("  ✓ FPsim version: %s\n", fp$`__version__`))
  
  # Test basic FPsim functionality
  cat("\n")
  cat("Test 4: Testing FPsim Functionality\n")
  cat(paste(rep("-", 70), collapse = ""), "\n")
  
  # Create a minimal simulation
  pars <- list(
    location = "kenya",
    n_agents = as.integer(500),
    start_year = as.integer(2020),
    end_year = as.integer(2022),
    verbose = as.integer(0)
  )
  
  cat("  Creating simulation with parameters:\n")
  cat(sprintf("    - Location: %s\n", pars$location))
  cat(sprintf("    - Agents: %d\n", pars$n_agents))
  cat(sprintf("    - Years: %d-%d\n", pars$start_year, pars$end_year))
  
  py_pars <- r_to_py(pars)
  sim <- fp$Sim(pars = py_pars)
  cat("  ✓ Simulation object created\n")
  
  # Run simulation
  cat("  Running simulation...\n")
  sim$run()
  cat("  ✓ Simulation completed\n")
  
  # Extract results - use .values attribute to get numpy arrays
  results <- list(
    timevec = py_to_r(sim$results$timevec$values),
    n_alive = py_to_r(sim$results$n_alive$values),
    cum_deaths = py_to_r(sim$results$cum_deaths$values)
  )
  
  cat("\n  Results summary:\n")
  cat(sprintf("    - Time steps: %d\n", length(results$timevec)))
  cat(sprintf("    - Initial population: %.0f\n", results$n_alive[1]))
  cat(sprintf("    - Final population: %.0f\n", results$n_alive[length(results$n_alive)]))
  cat(sprintf("    - Total deaths: %.0f\n", results$cum_deaths[length(results$cum_deaths)]))
  
  cat("\n")
  cat("Test 5: Testing Interface Functions\n")
  cat(paste(rep("-", 70), collapse = ""), "\n")
  
  # Source the interface file
  source("R/fpsim_interface.R")
  cat("  ✓ fpsim_interface.R sourced\n")
  
  source("R/utils.R")
  cat("  ✓ utils.R sourced\n")
  
  # Test run_fpsim_simulation function
  cat("  Testing run_fpsim_simulation()...\n")
  test_results <- run_fpsim_simulation(pars)
  cat("  ✓ run_fpsim_simulation() works\n")
  
  # Test get_available_methods function
  cat("  Testing get_available_methods()...\n")
  methods <- get_available_methods()
  cat(sprintf("  ✓ Found %d contraceptive methods\n", nrow(methods)))
  
  # Test utility functions
  cat("  Testing utility functions...\n")
  formatted <- format_number(12345.67, digits = 2)
  cat(sprintf("    - format_number(12345.67): %s\n", formatted))
  
  growth <- calc_growth_rate(100, 150)
  cat(sprintf("    - calc_growth_rate(100, 150): %.1f%%\n", growth))
  
  runtime <- estimate_sim_time(5000, 10)
  cat(sprintf("    - estimate_sim_time(5000, 10): %.1f seconds\n", runtime))
  cat("  ✓ Utility functions work\n")
  
  # Test validation
  cat("  Testing parameter validation...\n")
  validation <- validate_params(pars)
  cat(sprintf("    - Valid: %s\n", validation$valid))
  cat(sprintf("    - Message: %s\n", validation$message))
  cat("  ✓ Validation works\n")
  
  cat("\n")
  cat(paste(rep("=", 70), collapse = ""), "\n")
  cat("✓ ALL TESTS PASSED\n")
  cat(paste(rep("=", 70), collapse = ""), "\n")
  cat("\nThe Shiny app is ready to run!\n\n")
  cat("To start the app:\n")
  cat("  shiny::runApp()\n\n")
  
}, error = function(e) {
  cat(sprintf("  ✗ Error: %s\n", e$message))
  cat("\nTroubleshooting:\n")
  cat("  1. Ensure FPsim is installed: pip install -e . (from repo root)\n")
  cat("  2. Check virtual environment is activated\n")
  cat("  3. Verify Python version >= 3.8\n\n")
  quit(save = "no", status = 1)
})

