# FPsim R-Python Interface Functions
# Functions to interact with FPsim Python package via reticulate

#' Run FPsim Simulation
#' 
#' @param pars List of parameters for FPsim
#' @return List with simulation results
run_fpsim_simulation <- function(pars) {
  
  # Validate FPsim is loaded
  if (!exists("fp") || is.null(fp)) {
    stop("FPsim not loaded. Please check Python environment.")
  }
  
  # Validate parameters
  if (is.null(pars$location)) {
    stop("Location parameter is required")
  }
  
  if (is.null(pars$n_agents) || pars$n_agents < 100) {
    stop("n_agents must be at least 100")
  }
  
  # Convert R list to Python dict
  py_pars <- r_to_py(pars)
  
  # Create and run simulation
  sim <- fp$Sim(pars = py_pars)
  sim$run()
  
  # Extract results - use .values attribute to get numpy arrays
  results <- list(
    timevec = py_to_r(sim$results$timevec$values),
    n_alive = py_to_r(sim$results$n_alive$values),
    new_deaths = py_to_r(sim$results$new_deaths$values),
    cum_deaths = py_to_r(sim$results$cum_deaths$values),
    n_urban = py_to_r(sim$results$n_urban$values),
    n_wq1 = py_to_r(sim$results$n_wq1$values),
    n_wq2 = py_to_r(sim$results$n_wq2$values),
    n_wq3 = py_to_r(sim$results$n_wq3$values),
    n_wq4 = py_to_r(sim$results$n_wq4$values),
    n_wq5 = py_to_r(sim$results$n_wq5$values)
  )
  
  return(results)
}

#' Get Available Methods
#' 
#' @return Data frame with method information
get_available_methods <- function() {
  
  if (!exists("fp") || is.null(fp)) {
    stop("FPsim not loaded")
  }
  
  methods <- fp$make_methods()
  
  # Get method names (keys) 
  method_names <- py_to_r(list(methods$keys()))
  
  # Build list of method data
  method_list <- list()
  
  for (i in seq_along(method_names)) {
    method_name <- method_names[[i]]
    method <- methods[[method_name]]
    
    # Handle potentially NULL values
    name_val <- py_to_r(method$name)
    if (is.null(name_val)) name_val <- NA_character_
    
    label_val <- py_to_r(method$label)
    if (is.null(label_val)) label_val <- NA_character_
    
    efficacy_val <- py_to_r(method$efficacy)
    if (is.null(efficacy_val)) efficacy_val <- NA_real_
    
    modern_val <- py_to_r(method$modern)
    if (is.null(modern_val)) modern_val <- NA
    
    method_list[[i]] <- list(
      index = i,
      name = name_val,
      label = label_val,
      efficacy = efficacy_val,
      modern = modern_val
    )
  }
  
  # Convert to data frame
  method_df <- do.call(rbind, lapply(method_list, data.frame, stringsAsFactors = FALSE))
  
  return(method_df)
}

#' Create Intervention
#' 
#' @param type Type of intervention ("update_methods", "change_par", etc.)
#' @param year Year to apply intervention
#' @param params List of intervention-specific parameters
#' @return Python intervention object
create_intervention <- function(type = "update_methods", year, params = list()) {
  
  if (!exists("fp") || is.null(fp)) {
    stop("FPsim not loaded")
  }
  
  if (type == "update_methods") {
    # Create update_methods intervention
    intervention <- fp$update_methods(
      year = as.integer(year),
      eff = if (!is.null(params$eff)) r_to_py(params$eff) else NULL,
      p_use = if (!is.null(params$p_use)) params$p_use else NULL,
      method_mix = if (!is.null(params$method_mix)) r_to_py(params$method_mix) else NULL
    )
  } else if (type == "change_par") {
    # Create change_par intervention
    intervention <- fp$change_par(
      par = params$par,
      years = as.integer(year),
      vals = params$vals
    )
  } else {
    stop("Unsupported intervention type: ", type)
  }
  
  return(intervention)
}

#' Run Simulation with Intervention
#' 
#' @param pars Base parameters
#' @param interventions List of intervention objects
#' @return List with simulation results
run_sim_with_interventions <- function(pars, interventions = list()) {
  
  if (!exists("fp") || is.null(fp)) {
    stop("FPsim not loaded")
  }
  
  # Convert parameters
  py_pars <- r_to_py(pars)
  
  # Convert interventions list
  if (length(interventions) > 0) {
    py_interventions <- r_to_py(interventions)
  } else {
    py_interventions <- NULL
  }
  
  # Create and run simulation
  sim <- fp$Sim(pars = py_pars, interventions = py_interventions)
  sim$run()
  
  # Extract results (same as run_fpsim_simulation) - use .values attribute
  results <- list(
    timevec = py_to_r(sim$results$timevec$values),
    n_alive = py_to_r(sim$results$n_alive$values),
    new_deaths = py_to_r(sim$results$new_deaths$values),
    cum_deaths = py_to_r(sim$results$cum_deaths$values),
    n_urban = py_to_r(sim$results$n_urban$values),
    n_wq1 = py_to_r(sim$results$n_wq1$values),
    n_wq2 = py_to_r(sim$results$n_wq2$values),
    n_wq3 = py_to_r(sim$results$n_wq3$values),
    n_wq4 = py_to_r(sim$results$n_wq4$values),
    n_wq5 = py_to_r(sim$results$n_wq5$values)
  )
  
  return(results)
}

#' Get FPsim Version
#' 
#' @return Character string with FPsim version
get_fpsim_version <- function() {
  if (exists("fp") && !is.null(fp)) {
    return(py_to_r(fp$`__version__`))
  } else {
    return("Not loaded")
  }
}

#' Check if Location Exists
#' 
#' @param location Location name
#' @return Logical
location_exists <- function(location) {
  # List of valid locations
  valid_locations <- c(
    "kenya", "senegal", "ethiopia",
    "addis_ababa", "afar", "amhara", "benishangul_gumuz",
    "dire_dawa", "gambela", "harari", "oromia", "snnpr",
    "somali", "tigray"
  )
  
  return(location %in% valid_locations)
}

