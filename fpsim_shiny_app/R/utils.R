# Utility Functions for FPsim Shiny App

#' Format Large Numbers with Commas
#' 
#' @param x Numeric value
#' @param digits Number of decimal places (default 0)
#' @return Character string with formatted number
format_number <- function(x, digits = 0) {
  format(round(x, digits), big.mark = ",", scientific = FALSE, trim = TRUE)
}

#' Calculate Growth Rate
#' 
#' @param initial Initial value
#' @param final Final value
#' @return Growth rate as percentage
calc_growth_rate <- function(initial, final) {
  if (initial == 0) return(0)
  ((final / initial) - 1) * 100
}

#' Estimate Simulation Runtime
#' 
#' Based on benchmark: 0.7s for 5000 agents over 5 years
#' 
#' @param n_agents Number of agents
#' @param n_years Number of years
#' @return Estimated runtime in seconds
estimate_sim_time <- function(n_agents, n_years) {
  base_time <- 0.7
  base_agents <- 5000
  base_years <- 5
  
  estimated <- base_time * (n_agents / base_agents) * (n_years / base_years)
  return(round(estimated, 1))
}

#' Format Runtime Display
#' 
#' @param seconds Runtime in seconds
#' @return Human-readable string
format_runtime <- function(seconds) {
  if (seconds < 60) {
    return(paste0(round(seconds, 1), " seconds"))
  } else if (seconds < 3600) {
    mins <- floor(seconds / 60)
    secs <- round(seconds %% 60)
    return(paste0(mins, " min ", secs, " sec"))
  } else {
    hours <- floor(seconds / 3600)
    mins <- round((seconds %% 3600) / 60)
    return(paste0(hours, " hr ", mins, " min"))
  }
}

#' Get Location Display Name
#' 
#' @param location Location code
#' @return Human-readable name
get_location_name <- function(location) {
  location_names <- c(
    "kenya" = "Kenya",
    "senegal" = "Senegal",
    "ethiopia" = "Ethiopia",
    "addis_ababa" = "Addis Ababa",
    "afar" = "Afar",
    "amhara" = "Amhara",
    "benishangul_gumuz" = "Benishangul-Gumuz",
    "dire_dawa" = "Dire Dawa",
    "gambela" = "Gambela",
    "harari" = "Harari",
    "oromia" = "Oromia",
    "snnpr" = "SNNPR",
    "somali" = "Somali",
    "tigray" = "Tigray"
  )
  
  if (location %in% names(location_names)) {
    return(location_names[[location]])
  } else {
    return(location)
  }
}

#' Create Summary Statistics Table
#' 
#' @param results Simulation results object
#' @return Data frame for display
create_summary_stats <- function(results) {
  
  initial_pop <- head(results$n_alive, 1)
  final_pop <- tail(results$n_alive, 1)
  growth_rate <- calc_growth_rate(initial_pop, final_pop)
  total_deaths <- tail(results$cum_deaths, 1)
  
  # Wealth quintile distribution
  wq1 <- tail(results$n_wq1, 1)
  wq2 <- tail(results$n_wq2, 1)
  wq3 <- tail(results$n_wq3, 1)
  wq4 <- tail(results$n_wq4, 1)
  wq5 <- tail(results$n_wq5, 1)
  
  urban <- tail(results$n_urban, 1)
  
  summary_df <- data.frame(
    Category = c(
      "Demographics",
      "",
      "",
      "",
      "Wealth Distribution",
      "",
      "",
      "",
      "",
      "Urban/Rural"
    ),
    Metric = c(
      "Initial Population",
      "Final Population",
      "Population Growth",
      "Total Deaths",
      "Quintile 1 (Poorest)",
      "Quintile 2",
      "Quintile 3",
      "Quintile 4",
      "Quintile 5 (Richest)",
      "Urban Population"
    ),
    Value = c(
      format_number(initial_pop),
      format_number(final_pop),
      paste0(round(growth_rate, 1), "%"),
      format_number(total_deaths),
      format_number(wq1),
      format_number(wq2),
      format_number(wq3),
      format_number(wq4),
      format_number(wq5),
      format_number(urban)
    ),
    stringsAsFactors = FALSE
  )
  
  return(summary_df)
}

#' Validate Simulation Parameters
#' 
#' @param pars List of parameters
#' @return List with valid=TRUE/FALSE and message
validate_params <- function(pars) {
  
  # Check required parameters
  if (is.null(pars$location)) {
    return(list(valid = FALSE, message = "Location is required"))
  }
  
  if (is.null(pars$n_agents)) {
    return(list(valid = FALSE, message = "Number of agents is required"))
  }
  
  if (pars$n_agents < 100) {
    return(list(valid = FALSE, message = "Number of agents must be at least 100"))
  }
  
  if (pars$n_agents > 100000) {
    return(list(valid = FALSE, message = "Number of agents exceeds maximum (100,000)"))
  }
  
  if (is.null(pars$start_year) || is.null(pars$end_year)) {
    return(list(valid = FALSE, message = "Start and end years are required"))
  }
  
  if (pars$start_year >= pars$end_year) {
    return(list(valid = FALSE, message = "End year must be after start year"))
  }
  
  if (pars$end_year - pars$start_year > 100) {
    return(list(valid = FALSE, message = "Simulation period exceeds 100 years"))
  }
  
  # All validations passed
  return(list(valid = TRUE, message = "Parameters valid"))
}

#' Calculate Method Statistics
#' 
#' @param methods_df Data frame of methods
#' @return List with summary statistics
summarize_methods <- function(methods_df) {
  list(
    total = nrow(methods_df),
    modern = sum(methods_df$modern),
    traditional = sum(!methods_df$modern),
    avg_efficacy = mean(methods_df$efficacy, na.rm = TRUE),
    min_efficacy = min(methods_df$efficacy, na.rm = TRUE),
    max_efficacy = max(methods_df$efficacy, na.rm = TRUE)
  )
}

#' Create Color Palette for Plots
#' 
#' @param n Number of colors needed
#' @param palette Name of palette ("default", "sequential", "diverging")
#' @return Vector of color hex codes
get_color_palette <- function(n, palette = "default") {
  
  if (palette == "default") {
    colors <- c(
      "#3498db", "#2ecc71", "#e74c3c", "#f39c12", "#9b59b6",
      "#1abc9c", "#34495e", "#e67e22", "#95a5a6", "#16a085"
    )
  } else if (palette == "sequential") {
    colors <- colorRampPalette(c("#3498db", "#2c3e50"))(n)
  } else if (palette == "diverging") {
    colors <- colorRampPalette(c("#e74c3c", "#ecf0f1", "#2ecc71"))(n)
  } else {
    colors <- rainbow(n)
  }
  
  if (n <= length(colors)) {
    return(colors[1:n])
  } else {
    return(colorRampPalette(colors)(n))
  }
}

#' Export Results to CSV
#' 
#' @param results Simulation results
#' @param filename Output filename
export_results_csv <- function(results, filename) {
  df <- data.frame(
    year = results$timevec,
    n_alive = results$n_alive,
    new_deaths = results$new_deaths,
    cum_deaths = results$cum_deaths,
    n_urban = results$n_urban,
    n_wq1 = results$n_wq1,
    n_wq2 = results$n_wq2,
    n_wq3 = results$n_wq3,
    n_wq4 = results$n_wq4,
    n_wq5 = results$n_wq5
  )
  write.csv(df, filename, row.names = FALSE)
}

#' Safe Division
#' 
#' @param numerator Numerator
#' @param denominator Denominator
#' @param default Default value if division by zero
#' @return Result of division or default
safe_divide <- function(numerator, denominator, default = 0) {
  if (is.null(denominator) || denominator == 0) {
    return(default)
  }
  return(numerator / denominator)
}

