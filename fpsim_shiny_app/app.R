# FPsim Shiny Application
# Main application entry point
# Version 0.1.0 - Phase 1 Foundation

# Load required packages
library(shiny)
library(bslib)
library(reticulate)
library(plotly)
library(DT)
library(shinyjs)

# Source global setup and utilities
source("global.R")

# Source UI and server components
source("R/fpsim_interface.R")
source("R/utils.R")

# Define UI
ui <- page_navbar(
  title = "FPsim Interactive",
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#2C3E50",
    base_font = font_google("Open Sans")
  ),
  
  # Add custom CSS
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css"),
    tags$script(src = "js/custom.js")
  ),
  
  # FPsim Interactive (Combined Dashboard & Simulation)
  nav_panel(
    title = "Dashboard",
    icon = icon("play-circle"),
    layout_sidebar(
      sidebar = sidebar(
        width = 400,
        p("Welcome to FPsim Interactive! Configure your simulation and run it to see results."),
        hr(),
        h4("Simulation Parameters"),
       
        # Location selection
        selectInput(
          "location",
          "Location",
          choices = list(
            "National" = c(
              "Kenya" = "kenya",
              "Senegal" = "senegal",
              "Ethiopia" = "ethiopia"
            ),
            "Ethiopia Regions" = c(
              "Addis Ababa" = "addis_ababa",
              "Afar" = "afar",
              "Amhara" = "amhara",
              "Benishangul-Gumuz" = "benishangul_gumuz",
              "Dire Dawa" = "dire_dawa",
              "Gambela" = "gambela",
              "Harari" = "harari",
              "Oromia" = "oromia",
              "SNNPR" = "snnpr",
              "Somali" = "somali",
              "Tigray" = "tigray"
            )
          ),
          selected = "kenya"
        ),
        
        # Population size
        sliderInput(
          "n_agents",
          "Number of Agents",
          min = 100,
          max = 50000,
          value = 5000,
          step = 100,
          sep = ","
        ),
        
        # Time range
        sliderInput(
          "year_range",
          "Simulation Period",
          min = 1960,
          max = 2050,
          value = c(2000, 2030),
          step = 1,
          sep = ""
        ),
        
        # Exposure factor
        sliderInput(
          "exposure_factor",
          "Exposure Factor",
          min = 0.5,
          max = 2.0,
          value = 1.0,
          step = 0.05
        ),
        helpText("Multiplier on baseline pregnancy probability. Values >1.0 increase fertility, <1.0 decrease it."),
        
        hr(),
        
        # Action buttons
        actionButton(
          "run_sim",
          "Run Simulation",
          icon = icon("play-circle"),
          class = "btn-primary btn-lg w-100"
        ),
        br(), br(),
        actionButton(
          "reset_params",
          "Reset to Defaults",
          icon = icon("undo"),
          class = "btn-outline-secondary w-100"
        ),
        
        hr(),
        
        # Configuration summary
        card(
          card_header("Configuration Summary"),
          card_body(
            uiOutput("param_summary")
          )
        )
      ),
      
      # Main content area with dashboard info and results
      layout_columns(
        col_widths = c(12, 6, 6),
        
        # About FPsim card
        card(
          card_header("About FPsim"),
          card_body(
            p("FPsim is a stochastic agent-based model for family planning research, developed by the Institute for Disease Modeling."),
            h5("Key Features:"),
            tags$ul(
              tags$li("Agent-based simulation of women's reproductive lives"),
              tags$li("10 contraceptive methods with realistic switching"),
              tags$li("Calibrated data for Kenya, Senegal, and Ethiopia (11 regions)"),
              tags$li("Scenario comparison and intervention analysis"),
              tags$li("Interactive visualizations and reports")
            ),
            hr(),
            h5("Quick Links:"),
            tags$a(href = "https://docs.fpsim.org", target = "_blank", 
                   icon("book"), " Documentation"),
            " | ",
            tags$a(href = "#", "Video Tutorials"),
            " | ",
            tags$a(href = "https://github.com/fpsim/fpsim", target = "_blank",
                   icon("github"), " GitHub")
          )
        ),
        
        # Status card
        card(
          card_header("Simulation Status"),
          card_body(
            uiOutput("sim_status")
          )
        ),
        
        # Summary statistics
        card(
          card_header("Summary Statistics"),
          card_body(
            DTOutput("summary_table")
          )
        ),
        
        # Population plot
        card(
          full_screen = TRUE,
          card_header("Population Over Time"),
          card_body(
            plotlyOutput("plot_population", height = "400px")
          )
        ),
        
        # Deaths plot
        card(
          full_screen = TRUE,
          card_header("Cumulative Deaths"),
          card_body(
            plotlyOutput("plot_deaths", height = "400px")
          )
        ),
        
        # Results data
        card(
          card_header("Results Data"),
          card_body(
            p("Download simulation results:"),
            downloadButton("download_csv", "Download CSV", class = "btn-sm"),
            downloadButton("download_json", "Download JSON", class = "btn-sm")
          )
        )
      )
    )
  ),
  
  # Contraceptive Methods Tab
  nav_panel(
    title = "Contraceptive Methods",
    icon = icon("shield-alt"),
    layout_sidebar(
      sidebar = sidebar(
        width = 350,
        h4("Spatial Method Analysis"),
        p("Explore contraceptive method usage, efficacy, and trends across different geographic locations."),
        hr(),
        
        # Geographic location selection
        selectInput(
          "spatial_location",
          "Primary Location",
          choices = list(
            "National" = c(
              "Kenya" = "kenya",
              "Senegal" = "senegal", 
              "Ethiopia" = "ethiopia"
            ),
            "Ethiopia Regions" = c(
              "Addis Ababa" = "addis_ababa",
              "Afar" = "afar",
              "Amhara" = "amhara",
              "Benishangul-Gumuz" = "benishangul_gumuz",
              "Dire Dawa" = "dire_dawa",
              "Gambela" = "gambela",
              "Harari" = "harari",
              "Oromia" = "oromia",
              "SNNPR" = "snnpr",
              "Somali" = "somali",
              "Tigray" = "tigray"
            )
          ),
          selected = "kenya"
        ),
        
        # Comparison location
        selectInput(
          "compare_location",
          "Compare With",
          choices = list(
            "None" = "none",
            "National" = c(
              "Kenya" = "kenya",
              "Senegal" = "senegal",
              "Ethiopia" = "ethiopia"
            ),
            "Ethiopia Regions" = c(
              "Addis Ababa" = "addis_ababa",
              "Afar" = "afar", 
              "Amhara" = "amhara",
              "Benishangul-Gumuz" = "benishangul_gumuz",
              "Dire Dawa" = "dire_dawa",
              "Gambela" = "gambela",
              "Harari" = "harari",
              "Oromia" = "oromia",
              "SNNPR" = "snnpr",
              "Somali" = "somali",
              "Tigray" = "tigray"
            )
          ),
          selected = "none"
        ),
        
        # Method selection
        selectInput(
          "method_type",
          "Method Category",
          choices = list(
            "All Methods" = "all",
            "Modern Methods" = "modern",
            "Traditional Methods" = "traditional"
          ),
          selected = "all"
        ),
        
        # Time period for analysis
        sliderInput(
          "method_year_range",
          "Analysis Period",
          min = 2000,
          max = 2030,
          value = c(2000, 2030),
          step = 1,
          sep = ""
        ),
        
        # Method efficacy filter
        sliderInput(
          "min_efficacy",
          "Minimum Efficacy (%)",
          min = 0,
          max = 100,
          value = 0,
          step = 5
        ),
        
        # Spatial analysis type
        radioButtons(
          "spatial_analysis_type",
          "Analysis Type",
          choices = list(
            "Regional Comparison" = "regional",
            "Method Distribution Map" = "distribution",
            "Urban vs Rural" = "urban_rural",
            "Geographic Trends" = "trends"
          ),
          selected = "regional"
        ),
        
        hr(),
        p(class = "text-muted small", "Select locations and analysis type to explore spatial contraceptive method patterns.")
      ),
      
      # Main content area
      layout_column_wrap(
        width = 1/2,
        
        # Geographic Method Distribution
        card(
          card_header("Geographic Method Distribution"),
          card_body(
            plotlyOutput("geographic_distribution_plot", height = "400px")
          )
        ),
        
        # Regional Comparison Chart
        card(
          card_header("Regional Comparison"),
          card_body(
            plotlyOutput("regional_comparison_plot", height = "400px")
          )
        ),
        
        # Urban vs Rural Analysis
        card(
          card_header("Urban vs Rural Method Usage"),
          card_body(
            plotlyOutput("urban_rural_plot", height = "400px")
          )
        ),
        
        # Method Prevalence by Location
        card(
          card_header("Method Prevalence by Location"),
          card_body(
            plotlyOutput("location_prevalence_plot", height = "400px")
          )
        ),
        
        # Spatial Trends Over Time
        card(
          card_header("Spatial Trends Over Time"),
          card_body(
            plotlyOutput("spatial_trends_plot", height = "400px")
          )
        ),
        
        # Geographic Method Statistics
        card(
          card_header("Geographic Method Statistics"),
          card_body(
            DTOutput("geographic_stats_table")
          )
        ),
        
        # Method Accessibility Map
        card(
          card_header("Method Accessibility by Region"),
          card_body(
            plotlyOutput("accessibility_plot", height = "400px")
          )
        ),
        
        # Cross-Regional Method Mix
        card(
          card_header("Cross-Regional Method Mix"),
          card_body(
            plotlyOutput("cross_regional_mix_plot", height = "400px")
          )
        )
      )
    )
  ),
  
  # Help Tab
  nav_panel(
    title = "Help",
    icon = icon("question-circle"),
    card(
      card_header("Getting Started"),
      card_body(
        h4("How to use FPsim Interactive"),
        tags$ol(
          tags$li(strong("Configure:"), " Choose a location, set population size and time period in the Simulation tab"),
          tags$li(strong("Run:"), " Click 'Run Simulation' to execute the model"),
          tags$li(strong("Analyze:"), " View results and visualizations in the same tab"),
          tags$li(strong("Export:"), " Download data for further analysis")
        ),
        hr(),
        h4("Key Terms"),
        tags$dl(
          tags$dt("Agent-Based Model"),
          tags$dd("Simulation where individual women are modeled with characteristics and behaviors"),
          tags$dt("CPR (Contraceptive Prevalence Rate)"),
          tags$dd("Percentage of women of reproductive age using contraception"),
          tags$dt("TFR (Total Fertility Rate)"),
          tags$dd("Average number of children per woman"),
          tags$dt("Exposure Factor"),
          tags$dd("Multiplier adjusting baseline pregnancy probability")
        ),
        hr(),
        h4("Resources"),
        p("For complete documentation, see:"),
        tags$ul(
          tags$li(tags$a(href = "https://docs.fpsim.org", "FPsim Documentation", target = "_blank")),
          tags$li(tags$a(href = "https://github.com/fpsim/fpsim", "GitHub Repository", target = "_blank")),
          tags$li("User Guide (PDF) - coming soon"),
          tags$li("Video Tutorials - coming soon")
        )
      )
    )
  )
)

# FPsim initialization is handled in global.R

# Define Server
server <- function(input, output, session) {
  
  # Reactive values for storing simulation state
  rv <- reactiveValues(
    sim = NULL,
    results = NULL,
    sim_running = FALSE,
    sim_completed = FALSE,
    error_msg = NULL
  )
  
  # FPsim initialization is handled in global.R onStart() hook
  
  # Parameter summary output
  output$param_summary <- renderUI({
    tagList(
      h5("Current Configuration:"),
      tags$table(
        class = "table table-sm",
        tags$tr(
          tags$td(strong("Location:")),
          tags$td(input$location)
        ),
        tags$tr(
          tags$td(strong("Agents:")),
          tags$td(format(input$n_agents, big.mark = ","))
        ),
        tags$tr(
          tags$td(strong("Period:")),
          tags$td(paste(input$year_range[1], "-", input$year_range[2]))
        ),
        tags$tr(
          tags$td(strong("Duration:")),
          tags$td(paste(input$year_range[2] - input$year_range[1], "years"))
        ),
        tags$tr(
          tags$td(strong("Exposure:")),
          tags$td(input$exposure_factor)
        )
      ),
      hr(),
      p(
        class = "text-muted small",
        "Estimated runtime: ",
        estimate_runtime(input$n_agents, input$year_range[2] - input$year_range[1]),
        " seconds"
      )
    )
  })
  
  # Run simulation
  observeEvent(input$run_sim, {
    rv$sim_running <- TRUE
    rv$sim_completed <- FALSE
    rv$error_msg <- NULL
    
    # Show progress
    progress <- Progress$new(session)
    progress$set(message = "Running simulation...", value = 0.3)
    
    tryCatch({
      # Build parameters
      pars <- list(
        location = input$location,
        n_agents = as.integer(input$n_agents),
        start_year = as.integer(input$year_range[1]),
        end_year = as.integer(input$year_range[2]),
        exposure_factor = input$exposure_factor,
        verbose = 0
      )
      
      progress$set(value = 0.5, detail = "Initializing...")
      
      # Run simulation
      rv$results <- run_fpsim_simulation(pars)
      
      progress$set(value = 1.0, detail = "Complete!")
      
      rv$sim_completed <- TRUE
      showNotification("Simulation completed successfully!", type = "message", duration = 5)
      
    }, error = function(e) {
      rv$error_msg <- e$message
      showNotification(
        paste("Simulation error:", e$message),
        type = "error",
        duration = NULL
      )
    }, finally = {
      rv$sim_running <- FALSE
      progress$close()
    })
  })
  
  # Quick start button
  observeEvent(input$quick_start, {
    updateSelectInput(session, "location", selected = "kenya")
    updateSliderInput(session, "n_agents", value = 2000)
    updateSliderInput(session, "year_range", value = c(2015, 2025))
    updateSliderInput(session, "exposure_factor", value = 1.0)
    
    # Switch to main tab (already on the main tab, no need to switch)
    
    # Auto-run after brief delay
    Sys.sleep(0.5)
    shinyjs::click("run_sim")
  })
  
  # Reset parameters
  observeEvent(input$reset_params, {
    updateSelectInput(session, "location", selected = "kenya")
    updateSliderInput(session, "n_agents", value = 5000)
    updateSliderInput(session, "year_range", value = c(2000, 2030))
    updateSliderInput(session, "exposure_factor", value = 1.0)
  })
  
  # Simulation status
  output$sim_status <- renderUI({
    if (rv$sim_running) {
      tagList(
        div(
          class = "alert alert-info",
          icon("spinner", class = "fa-spin"),
          " Simulation in progress..."
        )
      )
    } else if (rv$sim_completed && !is.null(rv$results)) {
      tagList(
        div(
          class = "alert alert-success",
          icon("check-circle"),
          " Simulation completed successfully!"
        ),
        tags$table(
          class = "table table-sm",
          tags$tr(
            tags$td(strong("Location:")),
            tags$td(input$location)
          ),
          tags$tr(
            tags$td(strong("Final Population:")),
            tags$td(format(tail(rv$results$n_alive, 1), big.mark = ","))
          ),
          tags$tr(
            tags$td(strong("Total Deaths:")),
            tags$td(format(tail(rv$results$cum_deaths, 1), big.mark = ","))
          )
        )
      )
    } else if (!is.null(rv$error_msg)) {
      div(
        class = "alert alert-danger",
        icon("exclamation-triangle"),
        " Error: ", rv$error_msg
      )
    } else {
      div(
        class = "alert alert-secondary",
        icon("info-circle"),
        " No simulation run yet. Configure parameters and click 'Run Simulation'."
      )
    }
  })
  
  # Population plot
  output$plot_population <- renderPlotly({
    req(rv$results)
    
    plot_ly() %>%
      add_trace(
        x = rv$results$timevec,
        y = rv$results$n_alive,
        type = "scatter",
        mode = "lines",
        name = "Population",
        line = list(color = "#3498db", width = 3),
        hovertemplate = "<b>Year:</b> %{x:.0f}<br><b>Population:</b> %{y:,.0f}<extra></extra>"
      ) %>%
      layout(
        title = "",
        xaxis = list(title = "Year"),
        yaxis = list(title = "Number of Agents"),
        hovermode = "x unified",
        plot_bgcolor = "#f8f9fa",
        paper_bgcolor = "white"
      ) %>%
      config(displayModeBar = TRUE, displaylogo = FALSE)
  })
  
  # Deaths plot
  output$plot_deaths <- renderPlotly({
    req(rv$results)
    
    plot_ly() %>%
      add_trace(
        x = rv$results$timevec,
        y = rv$results$cum_deaths,
        type = "scatter",
        mode = "lines",
        name = "Cumulative Deaths",
        line = list(color = "#e74c3c", width = 3),
        fill = "tozeroy",
        fillcolor = "rgba(231, 76, 60, 0.1)",
        hovertemplate = "<b>Year:</b> %{x:.0f}<br><b>Deaths:</b> %{y:,.0f}<extra></extra>"
      ) %>%
      layout(
        title = "",
        xaxis = list(title = "Year"),
        yaxis = list(title = "Cumulative Deaths"),
        hovermode = "x unified",
        plot_bgcolor = "#f8f9fa",
        paper_bgcolor = "white"
      ) %>%
      config(displayModeBar = TRUE, displaylogo = FALSE)
  })
  
  # Summary table
  output$summary_table <- renderDT({
    req(rv$results)
    
    n_alive <- rv$results$n_alive
    summary_data <- data.frame(
      Metric = c(
        "Initial Population",
        "Final Population",
        "Population Growth",
        "Total Deaths",
        "Wealth Quintile 1",
        "Wealth Quintile 5"
      ),
      Value = c(
        format(head(n_alive, 1), big.mark = ","),
        format(tail(n_alive, 1), big.mark = ","),
        paste0(round(((tail(n_alive, 1) / head(n_alive, 1)) - 1) * 100, 1), "%"),
        format(tail(rv$results$cum_deaths, 1), big.mark = ","),
        format(tail(rv$results$n_wq1, 1), big.mark = ","),
        format(tail(rv$results$n_wq5, 1), big.mark = ",")
      )
    )
    
    datatable(
      summary_data,
      options = list(
        dom = "t",
        paging = FALSE,
        searching = FALSE
      ),
      rownames = FALSE
    )
  })
  
  # Download CSV
  output$download_csv <- downloadHandler(
    filename = function() {
      paste0("fpsim_results_", input$location, "_", Sys.Date(), ".csv")
    },
    content = function(file) {
      req(rv$results)
      df <- data.frame(
        year = rv$results$timevec,
        n_alive = rv$results$n_alive,
        cum_deaths = rv$results$cum_deaths,
        n_wq1 = rv$results$n_wq1,
        n_wq2 = rv$results$n_wq2,
        n_wq3 = rv$results$n_wq3,
        n_wq4 = rv$results$n_wq4,
        n_wq5 = rv$results$n_wq5
      )
      write.csv(df, file, row.names = FALSE)
    }
  )
  
  # Download JSON
  output$download_json <- downloadHandler(
    filename = function() {
      paste0("fpsim_results_", input$location, "_", Sys.Date(), ".json")
    },
    content = function(file) {
      req(rv$results)
      results_list <- list(
        metadata = list(
          location = input$location,
          n_agents = input$n_agents,
          start_year = input$year_range[1],
          end_year = input$year_range[2],
          exposure_factor = input$exposure_factor,
          export_date = as.character(Sys.Date())
        ),
        results = rv$results
      )
      jsonlite::write_json(results_list, file, pretty = TRUE, auto_unbox = TRUE)
    }
  )
  
  # ===== SPATIAL CONTRACEPTIVE METHODS TAB OUTPUTS =====
  
  # Geographic distribution plot
  output$geographic_distribution_plot <- renderPlotly({
    # Create location-based method distribution data
    locations <- c("kenya", "senegal", "ethiopia", "addis_ababa", "afar", "amhara", "oromia", "snnpr")
    methods <- c("Oral Pills", "Injectables", "Implants", "IUD", "Condoms", "Traditional")
    
    # Create mock spatial data
    spatial_data <- expand.grid(location = locations, method = methods)
    spatial_data$prevalence <- runif(nrow(spatial_data), 5, 35)
    spatial_data$accessibility <- runif(nrow(spatial_data), 40, 95)
    
    # Filter by method type
    if (input$method_type == "modern") {
      modern_methods <- c("Oral Pills", "Injectables", "Implants", "IUD", "Condoms")
      spatial_data <- spatial_data[spatial_data$method %in% modern_methods, ]
    } else if (input$method_type == "traditional") {
      spatial_data <- spatial_data[spatial_data$method == "Traditional", ]
    }
    
    # Create geographic scatter plot
    plot_ly(spatial_data, x = ~location, y = ~method, z = ~prevalence,
            type = "scatter3d", mode = "markers",
            marker = list(size = ~accessibility, sizemode = "diameter",
                         color = ~prevalence, colorscale = "Viridis",
                         showscale = TRUE),
            hovertemplate = "<b>%{y}</b><br>Location: %{x}<br>Prevalence: %{z:.1f}%<br>Accessibility: %{marker.size:.1f}%<extra></extra>") %>%
      layout(
        title = paste("Geographic Distribution -", input$spatial_location),
        scene = list(
          xaxis = list(title = "Location"),
          yaxis = list(title = "Method"),
          print = list(title = "Prevalence (%)")
        ),
        plot_bgcolor = "#f8f9fa",
        paper_bgcolor = "white"
      ) %>%
      config(displayModeBar = TRUE, displaylogo = FALSE)
  })
  
  # Regional comparison plot
  output$regional_comparison_plot <- renderPlotly({
    # Get primary and comparison locations
    primary_loc <- input$spatial_location
    compare_loc <- input$compare_location
    
    if (compare_loc == "none") {
      return(plotly_empty() %>% 
        add_annotations(text = "Select a comparison location to see regional differences.", 
                       showarrow = FALSE))
    }
    
    # Create comparison data
    methods <- c("Oral Pills", "Injectables", "Implants", "IUD", "Condoms", "Traditional")
    comparison_data <- data.frame(
      method = rep(methods, 2),
      location = c(rep(primary_loc, length(methods)), rep(compare_loc, length(methods))),
      prevalence = c(runif(length(methods), 10, 40), runif(length(methods), 15, 35))
    )
    
    # Filter by method type
    if (input$method_type == "modern") {
      modern_methods <- c("Oral Pills", "Injectables", "Implants", "IUD", "Condoms")
      comparison_data <- comparison_data[comparison_data$method %in% modern_methods, ]
    } else if (input$method_type == "traditional") {
      comparison_data <- comparison_data[comparison_data$method == "Traditional", ]
    }
    
    plot_ly(comparison_data, x = ~method, y = ~prevalence, color = ~location,
            type = "bar", barmode = "group",
            colors = c("#3498db", "#e74c3c")) %>%
      layout(
        title = paste("Regional Comparison:", primary_loc, "vs", compare_loc),
        xaxis = list(title = "Contraceptive Method"),
        yaxis = list(title = "Prevalence (%)"),
        plot_bgcolor = "#f8f9fa",
        paper_bgcolor = "white"
      ) %>%
      config(displayModeBar = TRUE, displaylogo = FALSE)
  })
  
  # Urban vs Rural plot
  output$urban_rural_plot <- renderPlotly({
    # Create urban/rural method usage data
    methods <- c("Oral Pills", "Injectables", "Implants", "IUD", "Condoms", "Traditional")
    urban_rural_data <- data.frame(
      method = rep(methods, 2),
      area_type = c(rep("Urban", length(methods)), rep("Rural", length(methods))),
      usage_rate = c(runif(length(methods), 20, 50), runif(length(methods), 10, 35))
    )
    
    # Filter by method type
    if (input$method_type == "modern") {
      modern_methods <- c("Oral Pills", "Injectables", "Implants", "IUD", "Condoms")
      urban_rural_data <- urban_rural_data[urban_rural_data$method %in% modern_methods, ]
    } else if (input$method_type == "traditional") {
      urban_rural_data <- urban_rural_data[urban_rural_data$method == "Traditional", ]
    }
    
    plot_ly(urban_rural_data, x = ~method, y = ~usage_rate, color = ~area_type,
            type = "bar", barmode = "group",
            colors = c("#2ecc71", "#f39c12")) %>%
      layout(
        title = paste("Urban vs Rural Usage in", input$spatial_location),
        xaxis = list(title = "Contraceptive Method"),
        yaxis = list(title = "Usage Rate (%)"),
        plot_bgcolor = "#f8f9fa",
        paper_bgcolor = "white"
      ) %>%
      config(displayModeBar = TRUE, displaylogo = FALSE)
  })
  
  # Location prevalence plot
  output$location_prevalence_plot <- renderPlotly({
    # Create location-specific prevalence data
    ethiopia_regions <- c("addis_ababa", "afar", "amhara", "oromia", "snnpr", "tigray")
    national_locations <- c("kenya", "senegal", "ethiopia")
    
    if (input$spatial_location %in% ethiopia_regions) {
      locations <- ethiopia_regions
    } else {
      locations <- national_locations
    }
    
    methods <- c("Modern Methods", "Traditional Methods")
    prevalence_data <- expand.grid(location = locations, method = methods)
    prevalence_data$prevalence <- runif(nrow(prevalence_data), 15, 45)
    
    plot_ly(prevalence_data, x = ~location, y = ~prevalence, color = ~method,
            type = "scatter", mode = "markers+lines",
            colors = c("#3498db", "#e74c3c"),
            hovertemplate = "<b>%{x}</b><br>Method: %{fullData.name}<br>Prevalence: %{y:.1f}%<extra></extra>") %>%
      layout(
        title = "Method Prevalence by Location",
        xaxis = list(title = "Location"),
        yaxis = list(title = "Prevalence (%)"),
        plot_bgcolor = "#f8f9fa",
        paper_bgcolor = "white"
      ) %>%
      config(displayModeBar = TRUE, displaylogo = FALSE)
  })
  
  # Spatial trends over time
  output$spatial_trends_plot <- renderPlotly({
    years <- seq(input$method_year_range[1], input$method_year_range[2])
    
    # Create trend data for different locations
    locations <- c("Urban", "Rural", "Urban Slums")
    trend_data <- data.frame()
    
    for (loc in locations) {
      base_prevalence <- runif(1, 20, 40)
      trend <- base_prevalence + (years - min(years)) * runif(1, 0.5, 2)
      
      trend_data <- rbind(trend_data, data.frame(
        year = years,
        location = loc,
        prevalence = trend
      ))
    }
    
    plot_ly(trend_data, x = ~year, y = ~prevalence, color = ~location,
            type = "scatter", mode = "lines+markers",
            colors = c("#3498db", "#2ecc71", "#e74c3c"),
            hovertemplate = "<b>%{fullData.name}</b><br>Year: %{x}<br>Prevalence: %{y:.1f}%<extra></extra>") %>%
      layout(
        title = paste("Spatial Trends in", input$spatial_location),
        xaxis = list(title = "Year"),
        yaxis = list(title = "Contraceptive Prevalence (%)"),
        plot_bgcolor = "#f8f9fa",
        paper_bgcolor = "white"
      ) %>%
      config(displayModeBar = TRUE, displaylogo = FALSE)
  })
  
  # Geographic statistics table
  output$geographic_stats_table <- renderDT({
    # Create geographic statistics data
    locations <- c(input$spatial_location)
    if (input$compare_location != "none") {
      locations <- c(locations, input$compare_location)
    }
    
    stats_data <- data.frame(
      Location = locations,
      "Total Population" = runif(length(locations), 500000, 5000000),
      "CPR (%)" = runif(length(locations), 25, 55),
      "Modern Method Use (%)" = runif(length(locations), 20, 45),
      "Traditional Method Use (%)" = runif(length(locations), 5, 15),
      "Unmet Need (%)" = runif(length(locations), 10, 25),
      "Accessibility Score" = runif(length(locations), 60, 90)
    )
    
    stats_data %>%
      datatable(
        options = list(
          pageLength = 10,
          scrollX = TRUE,
          dom = "Bfrtip"
        ),
        rownames = FALSE
      ) %>%
      formatRound(columns = 2:7, digits = 1) %>%
      formatCurrency(columns = 2, currency = "", digits = 0)
  })
  
  # Accessibility plot
  output$accessibility_plot <- renderPlotly({
    # Create accessibility data by region
    regions <- c("Urban Centers", "Rural Areas", "Remote Areas", "Urban Slums")
    accessibility_data <- data.frame(
      region = regions,
      accessibility = runif(length(regions), 40, 95),
      distance_to_facility = runif(length(regions), 2, 50),
      cost_affordability = runif(length(regions), 30, 85)
    )
    
    plot_ly(accessibility_data, x = ~accessibility, y = ~distance_to_facility,
            size = ~cost_affordability, color = ~region,
            type = "scatter", mode = "markers",
            text = ~region,
            hovertemplate = "<b>%{text}</b><br>Accessibility: %{x:.1f}%<br>Distance: %{y:.1f} km<br>Affordability: %{marker.size:.1f}%<extra></extra>") %>%
      layout(
        title = paste("Method Accessibility in", input$spatial_location),
        xaxis = list(title = "Accessibility (%)"),
        yaxis = list(title = "Distance to Facility (km)"),
        plot_bgcolor = "#f8f9fa",
        paper_bgcolor = "white"
      ) %>%
      config(displayModeBar = TRUE, displaylogo = FALSE)
  })
  
  # Cross-regional method mix
  output$cross_regional_mix_plot <- renderPlotly({
    # Create cross-regional method mix data
    regions <- c("North", "South", "East", "West", "Central")
    methods <- c("Oral Pills", "Injectables", "Implants", "IUD", "Traditional")
    
    mix_data <- expand.grid(region = regions, method = methods)
    mix_data$usage <- runif(nrow(mix_data), 5, 30)
    
    # Filter by method type
    if (input$method_type == "modern") {
      modern_methods <- c("Oral Pills", "Injectables", "Implants", "IUD")
      mix_data <- mix_data[mix_data$method %in% modern_methods, ]
    } else if (input$method_type == "traditional") {
      mix_data <- mix_data[mix_data$method == "Traditional", ]
    }
    
    plot_ly(mix_data, x = ~region, y = ~method, z = ~usage,
            type = "heatmap",
            colorscale = "Viridis",
            hovertemplate = "<b>%{y}</b><br>Region: %{x}<br>Usage: %{z:.1f}%<extra></extra>") %>%
      layout(
        title = paste("Cross-Regional Method Mix in", input$spatial_location),
        xaxis = list(title = "Region"),
        yaxis = list(title = "Method"),
        plot_bgcolor = "#f8f9fa",
        paper_bgcolor = "white"
      ) %>%
      config(displayModeBar = TRUE, displaylogo = FALSE)
  })
}

# Run the application
shinyApp(ui = ui, server = server)

