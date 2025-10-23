# Basic FPsim Sample in R
# A comprehensive introduction to FPsim using R

cat("============================================================\n")
cat("FPsim Basic Sample - Family Planning Simulation (R version)\n")
cat("============================================================\n")

# Load required libraries
library(reticulate)
library(ggplot2)

# Import FPsim
fp <- import('fpsim')

# Example 1: Simplest possible simulation
cat("\n1. Running simplest simulation (default parameters)...\n")
start_time <- Sys.time()
sim1 <- fp$Sim()
sim1$run()
end_time <- Sys.time()
cat("✓ Completed in", round(as.numeric(end_time - start_time, units = "secs"), 2), "seconds\n")

# Example 2: Custom simulation with specific parameters
cat("\n2. Running custom simulation (Kenya, 1000 agents)...\n")
pars <- dict(
  location = 'kenya',
  n_agents = 1000L,
  start_year = 2000L,
  end_year = 2020L,
  exposure_factor = 1.0
)

start_time <- Sys.time()
sim2 <- fp$Sim(pars = pars)
sim2$run()
end_time <- Sys.time()
cat("✓ Completed in", round(as.numeric(end_time - start_time, units = "secs"), 2), "seconds\n")

# Example 3: Different locations
cat("\n3. Running simulations for different locations...\n")
locations <- c('senegal', 'ethiopia')

for (location in locations) {
  cat("   Running", location, "simulation...\n")
  start_time <- Sys.time()
  pars_loc <- dict(
    location = location,
    n_agents = 500L,
    start_year = 2000L,
    end_year = 2015L
  )
  sim_loc <- fp$Sim(pars = pars_loc)
  sim_loc$run()
  end_time <- Sys.time()
  cat("   ✓", tools::toTitleCase(location), "completed in", 
      round(as.numeric(end_time - start_time, units = "secs"), 2), "seconds\n")
}

# Example 4: Basic plotting
cat("\n4. Generating plots...\n")
tryCatch({
  # Create a simple plot of population size over time
  df <- data.frame(
    t = sim2$results$timevec,
    pop_size = sim2$results$n_alive
  )
  
  p <- ggplot(df, aes(x = t, y = pop_size)) +
    geom_line(color = "blue", size = 1) +
    labs(
      title = "Population Size Over Time",
      x = "Time (months)",
      y = "Population Size"
    ) +
    theme_minimal()
  
  print(p)
  cat("✓ Population plot generated\n")
  
}, error = function(e) {
  cat("⚠ Plotting failed:", e$message, "\n")
  cat("   (This is normal if running without display)\n")
})

# Example 5: Accessing results
cat("\n5. Accessing simulation results...\n")
tryCatch({
  # Get the last values from the results
  n_alive <- sim2$results$n_alive
  cum_deaths <- sim2$results$cum_deaths
  n_urban <- sim2$results$n_urban
  
  # Convert to R vectors and get last values
  n_alive_vec <- as.numeric(n_alive)
  cum_deaths_vec <- as.numeric(cum_deaths)
  n_urban_vec <- as.numeric(n_urban)
  
  cat("   Final population size:", format(n_alive_vec[length(n_alive_vec)], big.mark = ","), "\n")
  cat("   Total deaths:", format(cum_deaths_vec[length(cum_deaths_vec)], big.mark = ","), "\n")
  cat("   Urban population:", format(n_urban_vec[length(n_urban_vec)], big.mark = ","), "\n")
  
  # Show available result keys
  cat("\n   Available result keys:", paste(names(sim2$results), collapse = ", "), "\n")
}, error = function(e) {
  cat("⚠ Results access failed:", e$message, "\n")
  cat("   (This may be due to R-Python interface issues)\n")
})

cat("\n============================================================\n")
cat("Basic sample completed successfully!\n")
cat("============================================================\n")
cat("\nNext steps:\n")
cat("- Try different locations: 'kenya', 'senegal', 'ethiopia'\n")
cat("- Adjust n_agents for different population sizes\n")
cat("- Modify start_year and end_year for different time periods\n")
cat("- Check examples/ directory for more advanced usage\n")
