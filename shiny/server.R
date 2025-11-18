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
  
  # Reactive values to store interventions
  interventions_list <- reactiveValues(
    items = list()
  )
  
  # Add intervention button observer
  observeEvent(input$add_intervention, {
    # Create intervention object based on type
    intv <- list(
      type = input$intervention_type,
      year = input$intervention_year,
      id = paste0("intv_", length(interventions_list$items) + 1)
    )
    
    if (input$intervention_type == "new_method") {
      intv$name <- input$new_method_name
      intv$label <- input$new_method_label
      intv$efficacy <- input$new_method_efficacy
      intv$duration <- input$new_method_duration
      intv$copy_from <- input$copy_from_method
      intv$initial_share <- input$initial_share
      intv$description <- paste0("Add ", input$new_method_label, " (", input$intervention_year, ")")
    } else if (input$intervention_type == "update_method") {
      intv$method <- input$update_method_target
      intv$params <- list()
      desc_parts <- c()
      
      if (input$update_efficacy_enable) {
        intv$params$efficacy <- input$update_efficacy_value
        desc_parts <- c(desc_parts, paste0("eff=", round(input$update_efficacy_value * 100, 1), "%"))
      }
      if (input$update_duration_enable) {
        intv$params$duration <- input$update_duration_value
        desc_parts <- c(desc_parts, paste0("dur=", input$update_duration_value, "mo"))
      }
      if (input$update_method_mix_enable) {
        intv$params$method_mix <- input$update_method_mix_value
        desc_parts <- c(desc_parts, paste0("mix=", round(input$update_method_mix_value * 100, 1), "%"))
      }
      
      intv$description <- paste0("Update ", toupper(input$update_method_target), ": ", 
                                  paste(desc_parts, collapse=", "), " (", input$intervention_year, ")")
    } else if (input$intervention_type == "efficacy") {
      intv$method <- input$efficacy_method
      intv$value <- input$efficacy_value
      intv$description <- paste0("Set ", toupper(input$efficacy_method), " efficacy to ", 
                                  round(input$efficacy_value * 100, 1), "% (", input$intervention_year, ")")
    } else if (input$intervention_type == "duration") {
      intv$method <- input$duration_method
      intv$value <- input$duration_value
      intv$description <- paste0("Set ", toupper(input$duration_method), " duration to ", 
                                  input$duration_value, " months (", input$intervention_year, ")")
    } else if (input$intervention_type == "method_mix") {
      intv$method <- input$method_mix_method
      intv$value <- input$method_mix_share
      intv$description <- paste0("Set ", toupper(input$method_mix_method), " share to ", 
                                  round(input$method_mix_share * 100, 1), "% (", input$intervention_year, ")")
    } else if (input$intervention_type == "switching") {
      intv$method <- input$switching_method
      intv$value <- input$switching_scale
      intv$description <- paste0("Scale ", toupper(input$switching_method), " switching by ", 
                                  input$switching_scale, "x (", input$intervention_year, ")")
    }
    
    # Add to list
    interventions_list$items[[length(interventions_list$items) + 1]] <- intv
  })
  
  # Clear interventions button observer
  observeEvent(input$clear_interventions, {
    interventions_list$items <- list()
  })
  
  # Render intervention list
  output$intervention_list <- renderUI({
    if (length(interventions_list$items) == 0) {
      return(p("No interventions added yet.", style = "font-style: italic; color: gray;"))
    }
    
    lapply(seq_along(interventions_list$items), function(i) {
      intv <- interventions_list$items[[i]]
      div(
        style = "background-color: #f8f9fa; padding: 8px; margin-bottom: 5px; border-radius: 4px; border-left: 3px solid #007bff;",
        tags$strong(paste0(i, ". ")), 
        intv$description,
        actionButton(paste0("remove_", intv$id), "×", 
                    class = "btn-danger btn-xs",
                    style = "float: right; padding: 0px 6px; font-size: 14px;",
                    onclick = sprintf("Shiny.setInputValue('remove_intervention', '%s', {priority: 'event'})", intv$id))
      )
    })
  })
  
  # Handle individual intervention removal
  observeEvent(input$remove_intervention, {
    id_to_remove <- input$remove_intervention
    interventions_list$items <- Filter(function(x) x$id != id_to_remove, interventions_list$items)
  })
  
  # Output flag for conditionalPanel
  output$has_interventions <- reactive({
    length(interventions_list$items) > 0
  })
  outputOptions(output, "has_interventions", suspendWhenHidden = FALSE)
  
  # Helper function to create empty plotly plot with message (suppresses warnings)
  create_empty_plot <- function(message) {
    plot_ly(type = 'scatter', mode = 'markers') %>%
      add_annotations(
        text = message,
        x = 0.5, 
        y = 0.5, 
        xref = "paper",
        yref = "paper",
        showarrow = FALSE,
        font = list(size = 14, color = "#666")
      ) %>%
      layout(
        xaxis = list(showticklabels = FALSE, showgrid = FALSE, zeroline = FALSE),
        yaxis = list(showticklabels = FALSE, showgrid = FALSE, zeroline = FALSE),
        showlegend = FALSE
      )
  }
  
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
      enable_interventions = input$enable_interventions
    )
    
    # Add interventions list if enabled
    if (input$enable_interventions && length(interventions_list$items) > 0) {
      params$interventions <- interventions_list$items
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
    updateCheckboxInput(session, "enable_interventions", value = FALSE)
    updateSelectInput(session, "intervention_type", selected = "new_method")
    updateSliderInput(session, "intervention_year", value = 2010)
    
    # Clear interventions list
    interventions_list$items <- list()
    
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
      create_empty_plot("No simulation data available")
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
      create_empty_plot("No simulation data available")
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
      create_empty_plot("No simulation data available")
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
      create_empty_plot("No simulation data available")
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
      create_empty_plot("No simulation data available")
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
      create_empty_plot("No simulation data available")
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
      create_empty_plot("No simulation data available")
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
      create_empty_plot("No simulation data available")
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
      create_empty_plot("No birth spacing data available")
    }
  })
  
  # Parity plot
  output$parity_plot <- renderPlotly({
    if (!is.null(simulation_results$data)) {
      data <- simulation_results$data
      
      # Debug output
      cat("[R DEBUG] Parity counts received:", data$parity_counts, "\n")
      cat("[R DEBUG] Length:", length(data$parity_counts), "\n")
      cat("[R DEBUG] Sum:", sum(data$parity_counts), "\n")
      
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
      create_empty_plot("No simulation data available")
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
      create_empty_plot("No simulation data available")
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
      create_empty_plot("No simulation data available")
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
      create_empty_plot("No simulation data available")
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
      create_empty_plot("No simulation data available")
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
      create_empty_plot("No simulation data available")
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
  
  # ===== METHOD UPDATES TAB OUTPUTS =====
  
  # Method Mix Comparison Plot
  output$method_updates_comparison <- renderPlotly({
    if (!is.null(simulation_results$data) && 
        !is.null(simulation_results$data$has_intervention) && 
        simulation_results$data$has_intervention) {
      
      tryCatch({
        baseline_data <- simulation_results$data$baseline_data
        interv_data <- simulation_results$data
        
        # Get method mix for both
        baseline_mix <- baseline_data$method_mix
        interv_mix <- interv_data$method_mix
        
        method_names <- names(baseline_mix)
        baseline_pct <- as.numeric(baseline_mix) * 100
        interv_pct <- as.numeric(interv_mix) * 100
        
        plot_ly() %>%
          add_trace(x = method_names, y = baseline_pct, type = 'bar', 
                    name = 'Baseline', marker = list(color = '#2E86AB')) %>%
          add_trace(x = method_names, y = interv_pct, type = 'bar', 
                    name = 'With Interventions', marker = list(color = '#A23B72')) %>%
          layout(title = 'Method Mix: Baseline vs. Intervention',
                 xaxis = list(title = 'Contraceptive Method', tickangle = -45),
                 yaxis = list(title = 'Percentage (%)'),
                 barmode = 'group',
                 template = 'plotly_white')
        
      }, error = function(e) {
        create_empty_plot(paste("Error:", e$message))
      })
      
    } else {
      create_empty_plot("Run simulation with interventions to see comparison")
    }
  })
  
  # CPR Comparison Plot
  output$method_updates_cpr <- renderPlotly({
    if (!is.null(simulation_results$data) && 
        !is.null(simulation_results$data$has_intervention) && 
        simulation_results$data$has_intervention) {
      
      tryCatch({
        baseline_data <- simulation_results$data$baseline_data
        interv_data <- simulation_results$data
        
        years <- interv_data$years
        
        plot_ly() %>%
          add_trace(x = years, y = as.numeric(baseline_data$cpr) * 100, 
                    type = 'scatter', mode = 'lines', name = 'Baseline CPR',
                    line = list(color = '#2E86AB', width = 2)) %>%
          add_trace(x = years, y = as.numeric(interv_data$cpr) * 100, 
                    type = 'scatter', mode = 'lines', name = 'Intervention CPR',
                    line = list(color = '#A23B72', width = 2)) %>%
          layout(title = 'Contraceptive Prevalence Rate Over Time',
                 xaxis = list(title = 'Year'),
                 yaxis = list(title = 'CPR (%)'),
                 template = 'plotly_white')
        
      }, error = function(e) {
        create_empty_plot(paste("Error:", e$message))
      })
      
    } else {
      create_empty_plot("No intervention data")
    }
  })
  
  # Births Comparison Plot
  output$method_updates_births <- renderPlotly({
    if (!is.null(simulation_results$data) && 
        !is.null(simulation_results$data$has_intervention) && 
        simulation_results$data$has_intervention) {
      
      tryCatch({
        baseline_data <- simulation_results$data$baseline_data
        interv_data <- simulation_results$data
        
        years <- interv_data$years
        
        plot_ly() %>%
          add_trace(x = years, y = as.numeric(baseline_data$births), 
                    type = 'scatter', mode = 'lines', name = 'Baseline',
                    line = list(color = '#2E86AB', width = 2)) %>%
          add_trace(x = years, y = as.numeric(interv_data$births), 
                    type = 'scatter', mode = 'lines', name = 'With Interventions',
                    line = list(color = '#A23B72', width = 2)) %>%
          layout(title = 'Births Over Time',
                 xaxis = list(title = 'Year'),
                 yaxis = list(title = 'Births per Timestep'),
                 template = 'plotly_white')
        
      }, error = function(e) {
        create_empty_plot(paste("Error:", e$message))
      })
      
    } else {
      create_empty_plot("No intervention data")
    }
  })
  
  # Final Method Distribution
  output$method_updates_final <- renderPlotly({
    if (!is.null(simulation_results$data) && 
        !is.null(simulation_results$data$has_intervention) && 
        simulation_results$data$has_intervention) {
      
      tryCatch({
        baseline_data <- simulation_results$data$baseline_data
        interv_data <- simulation_results$data
        
        baseline_mix <- baseline_data$method_mix
        interv_mix <- interv_data$method_mix
        
        method_names <- names(baseline_mix)
        differences <- (as.numeric(interv_mix) - as.numeric(baseline_mix)) * 100
        
        colors <- ifelse(differences >= 0, '#28A745', '#DC3545')
        
        plot_ly() %>%
          add_trace(x = differences, y = method_names, type = 'bar', orientation = 'h',
                    marker = list(color = colors),
                    text = paste0(sprintf("%+.1f", differences), "%"),
                    textposition = 'outside') %>%
          layout(title = 'Change in Method Mix (Intervention - Baseline)',
                 xaxis = list(title = 'Percentage Point Change'),
                 yaxis = list(title = 'Method'),
                 template = 'plotly_white')
        
      }, error = function(e) {
        create_empty_plot(paste("Error:", e$message))
      })
      
    } else {
      create_empty_plot("No intervention data")
    }
  })
  
  # Method Updates Statistics
  output$method_updates_stats <- renderText({
    if (!is.null(simulation_results$data) && 
        !is.null(simulation_results$data$intervention_stats)) {
      
      stats <- simulation_results$data$intervention_stats
      
      paste0(
        "=== METHOD UPDATES IMPACT SUMMARY ===\n\n",
        "Contraceptive Prevalence:\n",
        sprintf("  Baseline CPR:         %6.2f%%\n", stats$baseline_cpr * 100),
        sprintf("  Intervention CPR:     %6.2f%%\n", stats$interv_cpr * 100),
        sprintf("  Change:              %+6.2f pp\n\n", stats$cpr_change * 100),
        
        sprintf("  Baseline mCPR:        %6.2f%%\n", stats$baseline_mcpr * 100),
        sprintf("  Intervention mCPR:    %6.2f%%\n", stats$interv_mcpr * 100),
        sprintf("  Change:              %+6.2f pp\n\n", stats$mcpr_change * 100),
        
        "Birth Impact:\n",
        sprintf("  Baseline births:      %8d\n", stats$baseline_births),
        sprintf("  Intervention births:  %8d\n", stats$interv_births),
        sprintf("  Births averted:       %8d\n", stats$births_averted),
        sprintf("  Reduction:            %7.1f%%\n\n", stats$percent_reduction),
        
        "Intervention Details:\n",
        sprintf("  Number of interventions: %d\n", length(interventions_list$items)),
        sprintf("  Intervention period: %d-%d\n", stats$intervention_year, stats$end_year)
      )
      
    } else {
      "No statistics available.\nRun simulation with interventions to see impact summary."
    }
  })
  
  # ===== CONTRACEPTIVE METHODS TAB OUTPUTS =====
  
  # Detailed Method Mix Plot
  output$method_mix_detailed <- renderPlotly({
    if (!is.null(simulation_results$data) && !is.null(simulation_results$data$method_mix)) {
      
      method_mix <- simulation_results$data$method_mix
      method_names <- names(method_mix)
      method_values <- as.numeric(method_mix) * 100
      
      # Create a color palette
      colors <- c('#1f77b4', '#ff7f0e', '#2ca02c', '#d62728', '#9467bd', 
                  '#8c564b', '#e377c2', '#7f7f7f', '#bcbd22', '#17becf')
      
      # Sort by percentage for better visualization
      sort_idx <- order(method_values, decreasing = TRUE)
      method_names_sorted <- method_names[sort_idx]
      method_values_sorted <- method_values[sort_idx]
      colors_sorted <- colors[sort_idx]
      
      # Create interactive hover text
      hover_text <- paste0(
        "<b>", method_names_sorted, "</b><br>",
        "Percentage: ", round(method_values_sorted, 2), "%<br>",
        "Rank: ", 1:length(method_names_sorted),
        "<extra></extra>"
      )
      
      plot_ly(x = method_names_sorted, y = method_values_sorted, type = 'bar',
              marker = list(
                color = colors_sorted[1:length(method_names_sorted)],
                line = list(color = 'rgb(8,48,107)', width = 1.5)
              ),
              text = paste0(round(method_values_sorted, 1), "%"),
              textposition = 'outside',
              textfont = list(size = 11, color = 'black'),
              hovertemplate = hover_text) %>%
        layout(
          title = list(
            text = 'Contraceptive Method Mix (% of Users)',
            font = list(size = 16, weight = 'bold')
          ),
          xaxis = list(
            title = 'Contraceptive Method', 
            tickangle = -45,
            tickfont = list(size = 11)
          ),
          yaxis = list(
            title = 'Percentage (%)', 
            range = c(0, max(method_values_sorted) * 1.2),
            gridcolor = 'rgba(0,0,0,0.1)'
          ),
          template = 'plotly_white',
          showlegend = FALSE,
          hovermode = 'closest',
          plot_bgcolor = 'rgba(240,240,240,0.5)'
        ) %>%
        config(
          displayModeBar = TRUE,
          modeBarButtonsToRemove = c('select2d', 'lasso2d'),
          displaylogo = FALSE,
          toImageButtonOptions = list(
            format = 'png',
            filename = 'method_mix',
            height = 600,
            width = 1000
          )
        )
      
    } else {
      create_empty_plot("No contraceptive data available")
    }
  })
  
  # CPR Trend Detailed
  output$cpr_trend_detailed <- renderPlotly({
    if (!is.null(simulation_results$data)) {
      
      years <- simulation_results$data$years
      cpr <- as.numeric(simulation_results$data$cpr) * 100
      mcpr <- as.numeric(simulation_results$data$mcpr) * 100
      
      plot_ly() %>%
        add_trace(x = years, y = cpr, type = 'scatter', mode = 'lines',
                  name = 'Total CPR', line = list(color = '#2E86AB', width = 3)) %>%
        add_trace(x = years, y = mcpr, type = 'scatter', mode = 'lines',
                  name = 'Modern CPR', line = list(color = '#A23B72', width = 3, dash = 'dash')) %>%
        layout(title = 'Contraceptive Prevalence Rate Over Time',
               xaxis = list(title = 'Year'),
               yaxis = list(title = 'CPR (%)'),
               template = 'plotly_white',
               hovermode = 'x unified')
      
    } else {
      create_empty_plot("No simulation data available")
    }
  })
  
  # Method Usage Over Time - Estimated users per method
  output$method_usage_time <- renderPlotly({
    if (!is.null(simulation_results$data) && !is.null(simulation_results$data$method_mix)) {
      
      method_mix <- simulation_results$data$method_mix
      method_names <- names(method_mix)
      method_proportions <- as.numeric(method_mix)
      n_agents <- simulation_results$data$n_agents
      
      # Method mix is already the proportion of users per method
      # Multiply by total population to get estimated users
      method_users <- method_proportions * n_agents
      
      # Sort by number of users
      sort_idx <- order(method_users, decreasing = TRUE)
      method_names_sorted <- method_names[sort_idx]
      method_users_sorted <- method_users[sort_idx]
      
      # Create hover text
      hover_text <- paste0(
        "<b>", method_names_sorted, "</b><br>",
        "Est. Users: ", round(method_users_sorted, 0), "<br>",
        "Percentage: ", round(method_proportions[sort_idx] * 100, 2), "%",
        "<extra></extra>"
      )
      
      plot_ly(x = method_names_sorted, y = method_users_sorted, type = 'bar',
              marker = list(color = '#28A745', line = list(color = 'darkgreen', width = 1)),
              hovertemplate = hover_text) %>%
        layout(title = 'Estimated Contraceptive Users by Method',
               xaxis = list(title = 'Method', tickangle = -45),
               yaxis = list(title = 'Estimated Number of Users'),
               template = 'plotly_white',
               hovermode = 'closest')
      
    } else {
      create_empty_plot("No contraceptive data available")
    }
  })
  
  # Method Categories (Modern vs Traditional)
  output$method_categories <- renderPlotly({
    if (!is.null(simulation_results$data) && !is.null(simulation_results$data$method_mix)) {
      
      method_mix <- simulation_results$data$method_mix
      
      # Categorize methods - use case-insensitive partial matching
      # Modern methods keywords
      modern_keywords <- c('pill', 'iud', 'inject', 'inj', 'impl', 'implant', 'condom', 'cond', 
                           'btl', 'tubal', 'steril', 'modern')
      # Traditional methods keywords  
      trad_keywords <- c('withdraw', 'wdraw', 'rhythm', 'traditional', 'othtrad')
      
      modern_pct <- 0
      trad_pct <- 0
      
      for (method_name in names(method_mix)) {
        method_lower <- tolower(method_name)
        value <- as.numeric(method_mix[[method_name]])
        
        # Check if it matches modern keywords
        is_modern <- any(sapply(modern_keywords, function(kw) grepl(kw, method_lower, fixed = TRUE)))
        # Check if it matches traditional keywords
        is_trad <- any(sapply(trad_keywords, function(kw) grepl(kw, method_lower, fixed = TRUE)))
        
        if (is_modern) {
          modern_pct <- modern_pct + value
        } else if (is_trad) {
          trad_pct <- trad_pct + value
        } else {
          # Default: if not explicitly traditional, assume modern
          modern_pct <- modern_pct + value
        }
      }
      
      modern_pct <- modern_pct * 100
      trad_pct <- trad_pct * 100
      
      # Only create plot if we have data
      if (modern_pct + trad_pct > 0) {
        plot_ly(labels = c('Modern Methods', 'Traditional Methods'),
                values = c(modern_pct, trad_pct),
                type = 'pie',
                marker = list(colors = c('#2E86AB', '#E8A87C')),
                textinfo = 'label+percent',
                hovertemplate = '<b>%{label}</b><br>%{value:.2f}%<br>%{percent}<extra></extra>') %>%
          layout(title = 'Modern vs. Traditional Contraceptive Methods',
                 template = 'plotly_white',
                 showlegend = TRUE)
      } else {
        create_empty_plot("No method category data available")
      }
      
    } else {
      create_empty_plot("No contraceptive data available")
    }
  })
  
  # Unmet Need Detailed
  output$unmet_need_detailed <- renderPlotly({
    if (!is.null(simulation_results$data)) {
      
      years <- simulation_results$data$years
      unmet_need <- as.numeric(simulation_results$data$unmet_need) * 100
      
      plot_ly(x = years, y = unmet_need, type = 'scatter', mode = 'lines',
              fill = 'tozeroy',
              line = list(color = '#DC3545', width = 3),
              fillcolor = 'rgba(220, 53, 69, 0.2)') %>%
        layout(title = 'Unmet Need for Family Planning Over Time',
               xaxis = list(title = 'Year'),
               yaxis = list(title = 'Unmet Need (%)'),
               template = 'plotly_white')
      
    } else {
      create_empty_plot("No simulation data available")
    }
  })
  
  # Contraceptive Summary Statistics
  output$contraceptive_summary_stats <- renderText({
    if (!is.null(simulation_results$data)) {
      
      data <- simulation_results$data
      method_mix <- data$method_mix
      
      # Get final values
      final_cpr <- tail(as.numeric(data$cpr), 1) * 100
      final_mcpr <- tail(as.numeric(data$mcpr), 1) * 100
      final_unmet <- tail(as.numeric(data$unmet_need), 1) * 100
      
      # Find most popular method
      max_method_idx <- which.max(as.numeric(method_mix))
      most_popular <- names(method_mix)[max_method_idx]
      most_popular_pct <- as.numeric(method_mix[[most_popular]]) * 100
      
      # Calculate modern method percentage
      modern_methods <- c('pill', 'iud', 'inj', 'impl', 'cond', 'btl', 'othmod')
      modern_pct <- sum(as.numeric(method_mix[names(method_mix) %in% modern_methods])) * 100
      
      paste0(
        "=== CONTRACEPTIVE USE SUMMARY ===\n\n",
        "Final Year Indicators:\n",
        sprintf("  Total CPR:              %6.2f%%\n", final_cpr),
        sprintf("  Modern CPR:             %6.2f%%\n", final_mcpr),
        sprintf("  Unmet Need:             %6.2f%%\n\n", final_unmet),
        
        "Method Mix:\n",
        sprintf("  Most popular method:    %s (%5.1f%%)\n", toupper(most_popular), most_popular_pct),
        sprintf("  Modern methods share:   %6.2f%%\n", modern_pct),
        sprintf("  Traditional share:      %6.2f%%\n\n", 100 - modern_pct),
        
        "Available Methods:\n",
        sprintf("  Total methods tracked:  %d\n", length(method_mix)),
        sprintf("  Methods in use:         %d\n", sum(as.numeric(method_mix) > 0)),
        "\nMethod Distribution:\n",
        paste(sapply(names(method_mix), function(m) {
          sprintf("  %-15s: %5.1f%%", toupper(m), as.numeric(method_mix[[m]]) * 100)
        }), collapse = "\n")
      )
      
    } else {
      "No simulation data available.\nRun a simulation to see contraceptive statistics."
    }
  })
}

