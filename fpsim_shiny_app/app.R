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
    title = "FPsim Interactive",
    icon = icon("play-circle"),
    layout_sidebar(
      sidebar = sidebar(
        width = 400,
        h4("Quick Start"),
        p("Welcome to FPsim Interactive! Configure your simulation and run it to see results."),
        hr(),
        actionButton(
          "quick_start",
          "Run Example Simulation",
          icon = icon("play"),
          class = "btn-primary btn-lg w-100"
        ),
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
  
  # Initialize Python/FPsim on startup
  observe({
    tryCatch({
      init_fpsim()
      showNotification("FPsim loaded successfully!", type = "message", duration = 3)
    }, error = function(e) {
      showNotification(
        paste("Error loading FPsim:", e$message),
        type = "error",
        duration = NULL
      )
    })
  })
  
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
}

# Run the application
shinyApp(ui = ui, server = server)

