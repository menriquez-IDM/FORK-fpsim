# FPsim Family Planning Shiny Web App - Server
# Server logic and reactive functions

server <- function(input, output, session) {
  
  # Theme toggle functionality
  theme_state <- reactiveVal("light")
  
  observeEvent(input$theme_toggle, {
    if (theme_state() == "light") {
      theme_state("dark")
      runjs("document.body.classList.add('dark-mode'); document.body.classList.remove('light-mode');")
    } else {
      theme_state("light")
      runjs("document.body.classList.add('light-mode'); document.body.classList.remove('dark-mode');")
    }
  })
  
  # Initialize with light mode
  observe({
    runjs("document.body.classList.add('light-mode');")
  })
  
  # Generate mock simulation data when Python is not available
  generate_mock_data <- function(params) {
    years <- params$start:params$end
    n_years <- length(years)
    
    # Generate realistic family planning metrics
    # Birth rate declining over time
    birth_rate <- 40 - (0:(n_years-1)) * 0.5 + rnorm(n_years, 0, 2)
    birth_rate <- pmax(birth_rate, 15)  # Floor at 15 per 1000
    
    # TFR declining
    tfr <- 5.5 - (0:(n_years-1)) * 0.15 + rnorm(n_years, 0, 0.2)
    tfr <- pmax(tfr, 2.0)
    
    # CPR increasing
    cpr <- 15 + (0:(n_years-1)) * 1.2 + rnorm(n_years, 0, 1)
    cpr <- pmin(cpr, 70) / 100
    
    # Method mix (proportions)
    method_names <- c('None', 'Pill', 'IUD', 'Injectable', 'Implant', 'Condom', 'Other')
    method_mix <- c(0.35, 0.15, 0.10, 0.20, 0.10, 0.05, 0.05)
    
    # Age-specific fertility rates
    age_groups <- c('15-19', '20-24', '25-29', '30-34', '35-39', '40-44', '45-49')
    asfr <- c(80, 180, 200, 160, 100, 40, 10) + rnorm(length(age_groups), 0, 10)
    
    # Maternal mortality
    mmr <- 500 - (0:(n_years-1)) * 8 + rnorm(n_years, 0, 20)
    mmr <- pmax(mmr, 100)
    
    # Unmet need
    unmet_need <- 25 - (0:(n_years-1)) * 0.5 + rnorm(n_years, 0, 1)
    unmet_need <- pmax(unmet_need, 5) / 100
    
    # Birth spacing (months)
    birth_spacing <- rnorm(200, mean = 30, sd = 10)
    birth_spacing <- pmax(birth_spacing, 6)
    
    # Parity distribution
    parity_counts <- c(50, 40, 30, 25, 20, 15, 10, 10)
    
    # Population pyramid
    age_bins <- seq(0, 80, by = 5)
    male_pop <- rnorm(length(age_bins), mean = params$n_agents / 40, sd = 50)
    female_pop <- rnorm(length(age_bins), mean = params$n_agents / 40, sd = 50)
    
    # Pregnancy outcomes
    live_births <- params$n_agents * 0.035 + rnorm(n_years, 0, 5)
    stillbirths <- live_births * 0.02 + rnorm(n_years, 0, 1)
    miscarriages <- live_births * 0.15 + rnorm(n_years, 0, 2)
    
    return(list(
      timevec = 1:n_years,
      years = years,
      birth_rate = birth_rate,
      tfr = tfr,
      cpr = cpr,
      mcpr = cpr * 0.8,  # Modern CPR is ~80% of total CPR
      method_mix = setNames(method_mix, method_names),
      asfr = setNames(asfr, age_groups),
      maternal_mortality = mmr,
      unmet_need = unmet_need,
      birth_spacing = birth_spacing,
      parity_counts = parity_counts,
      population_pyramid = list(
        age_bins = age_bins,
        male = male_pop,
        female = female_pop
      ),
      pregnancy_outcomes = list(
        years = years,
        live_births = live_births,
        stillbirths = stillbirths,
        miscarriages = miscarriages
      ),
      population_summary = list(
        total_pop = params$n_agents,
        women_reproductive_age = round(params$n_agents * 0.25),
        current_cpr = cpr[n_years],
        current_tfr = tfr[n_years],
        current_birth_rate = birth_rate[n_years]
      ),
      parameters = params
    ))
  }
  
  # Reactive values to store simulation results
  simulation_results <- reactiveValues(
    data = NULL,
    status = "Ready to run simulation",
    progress = 0
  )
  
  # Parameter validation
  validate_parameters <- function() {
    errors <- c()
    
    if (input$n_agents < 100) {
      errors <- c(errors, "Population size must be at least 100")
    }
    
    if (input$start_year >= input$end_year) {
      errors <- c(errors, "Start year must be before end year")
    }
    
    if (input$exposure_factor < 0.1 || input$exposure_factor > 3.0) {
      errors <- c(errors, "Exposure factor must be between 0.1 and 3.0")
    }
    
    return(errors)
  }
  
  # Run simulation
  observeEvent(input$run_simulation, {
    # Validate parameters
    errors <- validate_parameters()
    if (length(errors) > 0) {
      showNotification(paste("Parameter errors:", paste(errors, collapse = ", ")), 
                     type = "error", duration = 5)
      return()
    }
    
    # Update status
    simulation_results$status <- "Running simulation..."
    simulation_results$progress <- 10
    
    # Prepare parameters
    params <- list(
      n_agents = as.integer(input$n_agents),
      start = input$start_year,
      end = input$end_year,
      location = input$location,
      exposure_factor = input$exposure_factor,
      maternal_mortality_factor = input$maternal_mortality_factor,
      primary_infertility = input$primary_infertility,
      lam_efficacy = input$lam_efficacy,
      pill_efficacy = input$pill_efficacy,
      iud_efficacy = input$iud_efficacy,
      inj_efficacy = input$inj_efficacy,
      impl_efficacy = input$impl_efficacy,
      use_education = input$use_education,
      use_empowerment = input$use_empowerment,
      rand_seed = input$rand_seed,
      enable_intervention = input$enable_intervention
    )
    
    # Add intervention parameters if enabled
    if (input$enable_intervention) {
      params$new_method_name <- input$new_method_name
      params$new_method_label <- input$new_method_label
      params$new_method_efficacy <- input$new_method_efficacy
      params$new_method_duration <- input$new_method_duration
      params$intervention_year <- input$intervention_year
      params$copy_from_method <- input$copy_from_method
      params$initial_share <- input$initial_share
    }
    
    # Run simulation with progress updates
    tryCatch({
      simulation_results$progress <- 30
      
      # Call Python simulation function or use mock data
      if (exists("python_available") && python_available) {
        result <- py$run_fp_simulation(params)
      } else {
        # Generate mock data when Python is not available
        result <- generate_mock_data(params)
      }
      
      simulation_results$progress <- 70
      
      # Store results
      simulation_results$data <- result
      if (exists("python_available") && python_available) {
        simulation_results$status <- "Simulation completed successfully"
      } else {
        simulation_results$status <- "Simulation completed (mock data - Python not available)"
      }
      simulation_results$progress <- 100
      
      showNotification("Simulation completed successfully!", type = "message")
      
    }, error = function(e) {
      simulation_results$status <- paste("Simulation failed:", e$message)
      simulation_results$progress <- 0
      showNotification(paste("Simulation failed:", e$message), type = "error")
    })
  })
  
  # Reset parameters
  observeEvent(input$reset_params, {
    updateSliderInput(session, "n_agents", value = 1000)
    updateSliderInput(session, "start_year", value = 2000)
    updateSliderInput(session, "end_year", value = 2020)
    updateSelectInput(session, "location", selected = "senegal")
    updateSliderInput(session, "exposure_factor", value = 1.0)
    updateSliderInput(session, "maternal_mortality_factor", value = 1.0)
    updateSliderInput(session, "primary_infertility", value = 0.05)
    updateSliderInput(session, "lam_efficacy", value = 0.98)
    updateSliderInput(session, "pill_efficacy", value = 0.945)
    updateSliderInput(session, "iud_efficacy", value = 0.986)
    updateSliderInput(session, "inj_efficacy", value = 0.983)
    updateSliderInput(session, "impl_efficacy", value = 0.994)
    updateCheckboxInput(session, "use_education", value = FALSE)
    updateCheckboxInput(session, "use_empowerment", value = FALSE)
    updateSliderInput(session, "rand_seed", value = 1)
    updateCheckboxInput(session, "enable_intervention", value = FALSE)
    updateTextInput(session, "new_method_name", value = "my_new_method")
    updateTextInput(session, "new_method_label", value = "MY-NEW-METHOD")
    updateSliderInput(session, "new_method_efficacy", value = 0.995)
    updateSliderInput(session, "new_method_duration", value = 12)
    updateSliderInput(session, "intervention_year", value = 2010)
    updateSelectInput(session, "copy_from_method", selected = "inj")
    updateSliderInput(session, "initial_share", value = 0.40)
    
    simulation_results$data <- NULL
    simulation_results$status <- "Parameters reset"
    simulation_results$progress <- 0
  })
  
  # Simulation status output
  output$simulation_status <- renderText({
    simulation_results$status
  })
  
  output$progress_text <- renderText({
    if (simulation_results$progress > 0 && simulation_results$progress < 100) {
      paste0("Progress: ", simulation_results$progress, "%")
    } else {
      ""
    }
  })
  
  # Population summary
  output$population_summary <- renderTable({
    if (!is.null(simulation_results$data)) {
      data.frame(
        Metric = c("Total Population", "Women of Reproductive Age", "Current CPR", "Current TFR", "Current Birth Rate"),
        Value = c(
          simulation_results$data$population_summary$total_pop,
          simulation_results$data$population_summary$women_reproductive_age,
          paste0(round(simulation_results$data$population_summary$current_cpr * 100, 2), "%"),
          round(simulation_results$data$population_summary$current_tfr, 2),
          paste0(round(simulation_results$data$population_summary$current_birth_rate, 1), " per 1000")
        )
      )
    } else {
      data.frame(Metric = "No simulation data", Value = "Run simulation first")
    }
  }, striped = TRUE, hover = TRUE, bordered = TRUE)
  
  # Quick plot
  output$quick_plot <- renderPlotly({
    if (!is.null(simulation_results$data)) {
      data <- simulation_results$data
      plot_ly(x = data$years, y = data$birth_rate, type = 'scatter', mode = 'lines+markers',
              line = list(color = 'steelblue', width = 3),
              marker = list(color = 'steelblue', size = 4),
              hovertemplate = 'Year: %{x}<br>Birth Rate: %{y:.1f} per 1000<extra></extra>') %>%
        layout(title = 'Birth Rate Over Time',
               xaxis = list(title = 'Year'),
               yaxis = list(title = 'Birth Rate (per 1000)'),
               hovermode = 'x unified',
               template = 'plotly_white')
    } else {
      plot_ly() %>% 
        add_annotations(text = "No simulation data available", 
                       x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(xaxis = list(showticklabels = FALSE, showgrid = FALSE),
               yaxis = list(showticklabels = FALSE, showgrid = FALSE))
    }
  })
  
  # Birth rate plot
  output$birth_rate_plot <- renderPlotly({
    if (!is.null(simulation_results$data)) {
      data <- simulation_results$data
      plot_ly(x = data$years, y = data$birth_rate, type = 'scatter', mode = 'lines',
              line = list(color = 'steelblue', width = 3),
              hovertemplate = 'Year: %{x}<br>Birth Rate: %{y:.1f} per 1000<extra></extra>') %>%
        layout(title = 'Birth Rate Over Time',
               xaxis = list(title = 'Year'),
               yaxis = list(title = 'Birth Rate (per 1000)'),
               hovermode = 'x unified',
               template = 'plotly_white')
    } else {
      plot_ly() %>% 
        add_annotations(text = "No simulation data available", 
                       x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(xaxis = list(showticklabels = FALSE, showgrid = FALSE),
               yaxis = list(showticklabels = FALSE, showgrid = FALSE))
    }
  })
  
  # CPR plot
  output$cpr_plot <- renderPlotly({
    if (!is.null(simulation_results$data)) {
      data <- simulation_results$data
      
      # Ensure numeric vectors
      cpr_values <- as.numeric(data$cpr) * 100
      mcpr_values <- as.numeric(data$mcpr) * 100
      
      # Remove any NA values
      valid_idx <- !is.na(cpr_values) & !is.na(mcpr_values)
      years_valid <- data$years[valid_idx]
      cpr_valid <- cpr_values[valid_idx]
      mcpr_valid <- mcpr_values[valid_idx]
      
      plot_ly() %>%
        add_trace(x = years_valid, y = cpr_valid, type = 'scatter', mode = 'lines',
                  line = list(color = 'green', width = 3),
                  name = 'Total CPR',
                  hovertemplate = 'Year: %{x}<br>CPR: %{y:.1f}%<extra></extra>') %>%
        add_trace(x = years_valid, y = mcpr_valid, type = 'scatter', mode = 'lines',
                  line = list(color = 'darkgreen', width = 3, dash = 'dash'),
                  name = 'Modern CPR',
                  hovertemplate = 'Year: %{x}<br>mCPR: %{y:.1f}%<extra></extra>') %>%
        layout(title = 'Contraceptive Prevalence Rate',
               xaxis = list(title = 'Year'),
               yaxis = list(title = 'CPR (%)'),
               hovermode = 'x unified',
               template = 'plotly_white',
               showlegend = TRUE)
    } else {
      plot_ly() %>% 
        add_annotations(text = "No simulation data available", 
                       x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(xaxis = list(showticklabels = FALSE, showgrid = FALSE),
               yaxis = list(showticklabels = FALSE, showgrid = FALSE))
    }
  })
  
  # TFR plot
  output$tfr_plot <- renderPlotly({
    if (!is.null(simulation_results$data)) {
      data <- simulation_results$data
      plot_ly(x = data$years, y = data$tfr, type = 'scatter', mode = 'lines',
              line = list(color = 'orange', width = 3),
              hovertemplate = 'Year: %{x}<br>TFR: %{y:.2f}<extra></extra>') %>%
        layout(title = 'Total Fertility Rate',
               xaxis = list(title = 'Year'),
               yaxis = list(title = 'TFR (births per woman)'),
               hovermode = 'x unified',
               template = 'plotly_white')
    } else {
      plot_ly() %>% 
        add_annotations(text = "No simulation data available", 
                       x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(xaxis = list(showticklabels = FALSE, showgrid = FALSE),
               yaxis = list(showticklabels = FALSE, showgrid = FALSE))
    }
  })
  
  # Method mix plot
  output$method_mix_plot <- renderPlotly({
    if (!is.null(simulation_results$data)) {
      data <- simulation_results$data
      method_names <- names(data$method_mix)
      method_values <- unlist(data$method_mix) * 100
      
      plot_ly(x = method_names, y = method_values, type = 'bar',
              marker = list(color = 'purple'),
              hovertemplate = 'Method: %{x}<br>Percentage: %{y:.1f}%<extra></extra>') %>%
        layout(title = 'Contraceptive Method Mix',
               xaxis = list(title = 'Method', tickangle = -45),
               yaxis = list(title = 'Percentage (%)'),
               hovermode = 'x unified',
               template = 'plotly_white')
    } else {
      plot_ly() %>% 
        add_annotations(text = "No simulation data available", 
                       x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(xaxis = list(showticklabels = FALSE, showgrid = FALSE),
               yaxis = list(showticklabels = FALSE, showgrid = FALSE))
    }
  })
  
  # Age-specific fertility rates
  output$asfr_plot <- renderPlotly({
    if (!is.null(simulation_results$data)) {
      data <- simulation_results$data
      age_groups <- names(data$asfr)
      asfr_values <- unlist(data$asfr)
      
      plot_ly(x = age_groups, y = asfr_values, type = 'bar',
              marker = list(color = 'coral'),
              hovertemplate = 'Age Group: %{x}<br>ASFR: %{y:.0f} per 1000<extra></extra>') %>%
        layout(title = 'Age-specific Fertility Rates',
               xaxis = list(title = 'Age Group'),
               yaxis = list(title = 'ASFR (per 1000 women)'),
               hovermode = 'x unified',
               template = 'plotly_white')
    } else {
      plot_ly() %>% 
        add_annotations(text = "No simulation data available", 
                       x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(xaxis = list(showticklabels = FALSE, showgrid = FALSE),
               yaxis = list(showticklabels = FALSE, showgrid = FALSE))
    }
  })
  
  # Maternal mortality plot
  output$maternal_mortality_plot <- renderPlotly({
    if (!is.null(simulation_results$data)) {
      data <- simulation_results$data
      plot_ly(x = data$years, y = data$maternal_mortality, type = 'scatter', mode = 'lines',
              line = list(color = 'red', width = 3),
              hovertemplate = 'Year: %{x}<br>MMR: %{y:.0f} per 100,000<extra></extra>') %>%
        layout(title = 'Maternal Mortality Ratio',
               xaxis = list(title = 'Year'),
               yaxis = list(title = 'MMR (per 100,000 live births)'),
               hovermode = 'x unified',
               template = 'plotly_white')
    } else {
      plot_ly() %>% 
        add_annotations(text = "No simulation data available", 
                       x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(xaxis = list(showticklabels = FALSE, showgrid = FALSE),
               yaxis = list(showticklabels = FALSE, showgrid = FALSE))
    }
  })
  
  # Unmet need plot
  output$unmet_need_plot <- renderPlotly({
    if (!is.null(simulation_results$data)) {
      data <- simulation_results$data
      
      # Ensure numeric vectors
      unmet_values <- as.numeric(data$unmet_need) * 100
      
      # Remove any NA values
      valid_idx <- !is.na(unmet_values)
      years_valid <- data$years[valid_idx]
      unmet_valid <- unmet_values[valid_idx]
      
      plot_ly(x = years_valid, y = unmet_valid, type = 'scatter', mode = 'lines',
              line = list(color = 'darkred', width = 3),
              hovertemplate = 'Year: %{x}<br>Unmet Need: %{y:.1f}%<extra></extra>') %>%
        layout(title = 'Unmet Need for Family Planning',
               xaxis = list(title = 'Year'),
               yaxis = list(title = 'Unmet Need (%)'),
               hovermode = 'x unified',
               template = 'plotly_white')
    } else {
      plot_ly() %>% 
        add_annotations(text = "No simulation data available", 
                       x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(xaxis = list(showticklabels = FALSE, showgrid = FALSE),
               yaxis = list(showticklabels = FALSE, showgrid = FALSE))
    }
  })
  
  # Birth spacing plot
  output$birth_spacing_plot <- renderPlotly({
    if (!is.null(simulation_results$data) && length(simulation_results$data$birth_spacing) > 0) {
      data <- simulation_results$data
      plot_ly(x = data$birth_spacing, type = 'histogram', 
              marker = list(color = 'lightblue'),
              hovertemplate = 'Birth Spacing: %{x:.1f} months<br>Count: %{y}<extra></extra>') %>%
        layout(title = 'Birth Spacing Distribution',
               xaxis = list(title = 'Birth Spacing (months)'),
               yaxis = list(title = 'Frequency'),
               hovermode = 'x unified',
               template = 'plotly_white')
    } else {
      plot_ly() %>% 
        add_annotations(text = "No birth spacing data available", 
                       x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(xaxis = list(showticklabels = FALSE, showgrid = FALSE),
               yaxis = list(showticklabels = FALSE, showgrid = FALSE))
    }
  })
  
  # Parity plot
  output$parity_plot <- renderPlotly({
    if (!is.null(simulation_results$data)) {
      data <- simulation_results$data
      parity_labels <- paste("Parity", 0:(length(data$parity_counts)-1))
      
      plot_ly(x = parity_labels, y = data$parity_counts, type = 'bar',
              marker = list(color = 'teal'),
              hovertemplate = 'Parity: %{x}<br>Count: %{y}<extra></extra>') %>%
        layout(title = 'Parity Distribution',
               xaxis = list(title = 'Number of Children'),
               yaxis = list(title = 'Number of Women'),
               hovermode = 'x unified',
               template = 'plotly_white')
    } else {
      plot_ly() %>% 
        add_annotations(text = "No simulation data available", 
                       x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(xaxis = list(showticklabels = FALSE, showgrid = FALSE),
               yaxis = list(showticklabels = FALSE, showgrid = FALSE))
    }
  })
  
  # Contraceptive switching plot (placeholder)
  output$switching_plot <- renderPlotly({
    if (!is.null(simulation_results$data)) {
      # Create a simple switching visualization
      methods <- c('None', 'Pill', 'IUD', 'Injectable', 'Implant')
      switching_rate <- runif(length(methods), 5, 25)
      
      plot_ly(x = methods, y = switching_rate, type = 'bar',
              marker = list(color = 'salmon'),
              hovertemplate = 'From Method: %{x}<br>Switching Rate: %{y:.1f}%<extra></extra>') %>%
        layout(title = 'Contraceptive Switching Rates',
               xaxis = list(title = 'Method'),
               yaxis = list(title = 'Annual Switching Rate (%)'),
               hovermode = 'x unified',
               template = 'plotly_white')
    } else {
      plot_ly() %>% 
        add_annotations(text = "No simulation data available", 
                       x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(xaxis = list(showticklabels = FALSE, showgrid = FALSE),
               yaxis = list(showticklabels = FALSE, showgrid = FALSE))
    }
  })
  
  # Population pyramid
  output$population_pyramid <- renderPlotly({
    if (!is.null(simulation_results$data)) {
      data <- simulation_results$data$population_pyramid
      age_labels <- paste0(data$age_bins, "-", data$age_bins + 4)
      
      # Ensure numeric and handle NA values
      male_values <- as.numeric(data$male)
      female_values <- as.numeric(data$female)
      male_values[is.na(male_values)] <- 0
      female_values[is.na(female_values)] <- 0
      
      plot_ly() %>%
        add_trace(x = -male_values, y = age_labels, type = 'bar', orientation = 'h',
                  name = 'Male', marker = list(color = 'steelblue'),
                  hovertemplate = 'Male: %{x}<br>Age: %{y}<extra></extra>') %>%
        add_trace(x = female_values, y = age_labels, type = 'bar', orientation = 'h',
                  name = 'Female', marker = list(color = 'pink'),
                  hovertemplate = 'Female: %{x}<br>Age: %{y}<extra></extra>') %>%
        layout(title = 'Population Pyramid',
               xaxis = list(title = 'Population'),
               yaxis = list(title = 'Age Group'),
               barmode = 'overlay',
               bargap = 0.1,
               template = 'plotly_white')
    } else {
      plot_ly() %>% 
        add_annotations(text = "No simulation data available", 
                       x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(xaxis = list(showticklabels = FALSE, showgrid = FALSE),
               yaxis = list(showticklabels = FALSE, showgrid = FALSE))
    }
  })
  
  # Pregnancy outcomes plot
  output$pregnancy_outcomes_plot <- renderPlotly({
    if (!is.null(simulation_results$data)) {
      data <- simulation_results$data$pregnancy_outcomes
      
      plot_ly() %>%
        add_trace(x = data$years, y = data$live_births, type = 'scatter', mode = 'lines',
                  line = list(color = 'green', width = 2),
                  name = 'Live Births') %>%
        add_trace(x = data$years, y = data$stillbirths, type = 'scatter', mode = 'lines',
                  line = list(color = 'orange', width = 2),
                  name = 'Stillbirths') %>%
        add_trace(x = data$years, y = data$miscarriages, type = 'scatter', mode = 'lines',
                  line = list(color = 'red', width = 2),
                  name = 'Miscarriages') %>%
        layout(title = 'Pregnancy Outcomes Over Time',
               xaxis = list(title = 'Year'),
               yaxis = list(title = 'Count'),
               hovermode = 'x unified',
               template = 'plotly_white',
               showlegend = TRUE)
    } else {
      plot_ly() %>% 
        add_annotations(text = "No simulation data available", 
                       x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(xaxis = list(showticklabels = FALSE, showgrid = FALSE),
               yaxis = list(showticklabels = FALSE, showgrid = FALSE))
    }
  })
  
  # Cumulative births plot
  output$cumulative_births_plot <- renderPlotly({
    if (!is.null(simulation_results$data)) {
      data <- simulation_results$data$pregnancy_outcomes
      cumulative_births <- cumsum(data$live_births)
      
      plot_ly(x = data$years, y = cumulative_births, type = 'scatter', mode = 'lines',
              line = list(color = 'darkgreen', width = 3),
              fill = 'tonexty',
              hovertemplate = 'Year: %{x}<br>Cumulative Births: %{y:.0f}<extra></extra>') %>%
        layout(title = 'Cumulative Births Over Time',
               xaxis = list(title = 'Year'),
               yaxis = list(title = 'Cumulative Births'),
               hovermode = 'x unified',
               template = 'plotly_white')
    } else {
      plot_ly() %>% 
        add_annotations(text = "No simulation data available", 
                       x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(xaxis = list(showticklabels = FALSE, showgrid = FALSE),
               yaxis = list(showticklabels = FALSE, showgrid = FALSE))
    }
  })
  
  # Parameters table
  output$parameters_table <- renderDT({
    if (!is.null(simulation_results$data)) {
      params_df <- data.frame(
        Parameter = names(simulation_results$data$parameters),
        Value = unlist(simulation_results$data$parameters)
      )
      datatable(params_df, options = list(pageLength = 20, scrollX = TRUE))
    } else {
      data.frame(Parameter = "No simulation data", Value = "Run simulation first")
    }
  })
  
  # Sensitivity plot
  output$sensitivity_plot <- renderPlotly({
    if (!is.null(simulation_results$data)) {
      data <- simulation_results$data
      params <- data$parameters
      
      # Select numeric parameters for display
      numeric_params <- params[sapply(params, is.numeric)]
      param_names <- names(numeric_params)
      param_values <- unlist(numeric_params)
      
      # Normalize for display
      normalized_values <- sapply(param_values, function(val) {
        if (val > 100) val / 100
        else if (val > 10) val / 10
        else if (val < 0.1) val * 10
        else val
      })
      
      plot_ly(x = param_names, y = normalized_values, type = 'bar',
              marker = list(color = 'lightcoral'),
              hovertemplate = 'Parameter: %{x}<br>Value: %{y:.2f}<extra></extra>') %>%
        layout(title = 'Parameter Values (Normalized for Display)',
               xaxis = list(title = 'Parameters', tickangle = -45),
               yaxis = list(title = 'Normalized Values'),
               hovermode = 'x unified',
               template = 'plotly_white')
    } else {
      plot_ly() %>% 
        add_annotations(text = "No simulation data available", 
                       x = 0.5, y = 0.5, showarrow = FALSE) %>%
        layout(xaxis = list(showticklabels = FALSE, showgrid = FALSE),
               yaxis = list(showticklabels = FALSE, showgrid = FALSE))
    }
  })
  
  # ===== INTERVENTION ANALYSIS TAB =====
  
  # Dynamic UI for intervention plot
  output$intervention_plot_ui <- renderUI({
    if (!is.null(simulation_results$data) && 
        !is.null(simulation_results$data$has_intervention) && 
        simulation_results$data$has_intervention) {
      
      # Generate plot based on selected type
      plot_type <- input$intervention_plot_type
      
      tryCatch({
        # Call Python to generate plot
        baseline_sim <- simulation_results$data$baseline_sim
        intervention_sim <- simulation_results$data$intervention_sim
        
        # Get parameters
        params <- list(
          start = input$start_year,
          end = input$end_year,
          location = input$location,
          intervention_year = input$intervention_year,
          new_method_name = input$new_method_name,
          new_method_label = input$new_method_label
        )
        
        # Generate plot via Python
        img_base64 <- py$generate_intervention_plot_data(
          baseline_sim, intervention_sim, plot_type, params
        )
        
        # Return HTML img tag
        tags$img(src = paste0("data:image/png;base64,", img_base64), 
                style = "width: 100%; height: auto;")
        
      }, error = function(e) {
        p(paste("Error generating plot:", e$message), style = "color: red;")
      })
      
    } else {
      p("No intervention data available. Run simulation with intervention enabled.",
        style = "font-style: italic; color: gray;")
    }
  })
  
  # Intervention statistics output
  output$intervention_stats <- renderText({
    if (!is.null(simulation_results$data) && 
        !is.null(simulation_results$data$intervention_stats)) {
      
      stats <- simulation_results$data$intervention_stats
      
      paste0(
        "=== INTERVENTION IMPACT SUMMARY ===\n\n",
        "Final Prevalence Rates (", stats$end_year, "):\n",
        sprintf("  Baseline mCPR:       %6.2f%%\n", stats$baseline_mcpr * 100),
        sprintf("  Intervention mCPR:   %6.2f%%\n", stats$interv_mcpr * 100),
        sprintf("  Change:             %+6.2f%%\n\n", stats$mcpr_change * 100),
        
        sprintf("  Baseline CPR:        %6.2f%%\n", stats$baseline_cpr * 100),
        sprintf("  Intervention CPR:    %6.2f%%\n", stats$interv_cpr * 100),
        sprintf("  Change:             %+6.2f%%\n\n", stats$cpr_change * 100),
        
        "Births After Intervention (", stats$intervention_year, "-", stats$end_year, "):\n",
        sprintf("  Baseline births:        %8d\n", stats$baseline_births),
        sprintf("  Intervention births:    %8d\n", stats$interv_births),
        sprintf("  Births averted:         %8d\n", stats$births_averted),
        sprintf("  Percent reduction:      %7.1f%%\n\n", stats$percent_reduction),
        
        "New Method Adoption:\n",
        sprintf("  Method: %s\n", stats$new_method_label),
        sprintf("  Adoption rate:          %7.2f%%\n", stats$new_method_adoption),
        sprintf("  Number of users:        %8d\n", stats$new_method_users)
      )
      
    } else {
      "No intervention statistics available.\nRun simulation with intervention enabled to see impact metrics."
    }
  })
}

