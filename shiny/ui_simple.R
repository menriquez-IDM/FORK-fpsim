# FPsim Family Planning Shiny Web App - Simple UI with Tab Panes
# Simplified user interface using tabsetPanel

ui <- fluidPage(
  titlePanel("FPsim Family Planning Model - Tab Panes Demo"),
  
  # Sidebar with parameters
  sidebarLayout(
    sidebarPanel(
      width = 3,
      h4("Simulation Parameters"),
      
      # Basic simulation parameters
      sliderInput("n_agents", "Population Size", value = 1000, min = 100, max = 10000, step = 100),
      sliderInput("start_year", "Start Year", value = 2000, min = 1980, max = 2020, step = 1),
      sliderInput("end_year", "End Year", value = 2020, min = 1990, max = 2030, step = 1),
      
      # Location selection
      selectInput("location", "Location", 
                  choices = c("senegal", "kenya", "ethiopia", "niger"), 
                  selected = "senegal"),
      
      # FP parameters
      h5("Family Planning Parameters"),
      sliderInput("exposure_factor", "Exposure Factor", value = 1.0, min = 0.1, max = 2.0, step = 0.1),
      sliderInput("maternal_mortality_factor", "Maternal Mortality Factor", value = 1.0, min = 0.5, max = 2.0, step = 0.1),
      
      # Action buttons
      br(),
      actionButton("run_simulation", "Run Simulation", class = "btn-primary", width = "100%"),
      br(), br(),
      actionButton("reset_params", "Reset Parameters", class = "btn-secondary", width = "100%")
    ),
    
    # Main content area with tab panels
    mainPanel(
      width = 9,
      tabsetPanel(
        id = "main_tabs",
        type = "tabs",
        
        # Simulation Tab
        tabPanel("Simulation", icon = icon("play"),
          h3("Simulation Control"),
          p("Configure and run your family planning simulation here."),
          
          # Status box
          wellPanel(
            h4("Simulation Status"),
            textOutput("simulation_status"),
            textOutput("progress_text")
          ),
          
          # Quick results
          fluidRow(
            column(6,
              wellPanel(
                h4("Quick Results"),
                plotlyOutput("quick_plot", height = "300px")
              )
            ),
            column(6,
              wellPanel(
                h4("Population Summary"),
                tableOutput("population_summary")
              )
            )
          )
        ),
        
        # Results Tab
        tabPanel("Results", icon = icon("chart-line"),
          h3("Simulation Results"),
          p("View detailed results and analysis from your simulation."),
          
          # Main birth rate plot
          wellPanel(
            h4("Birth Rate Over Time"),
            plotlyOutput("birth_rate_plot", height = "400px")
          ),
          
          # Secondary plots
          fluidRow(
            column(6,
              wellPanel(
                h4("CPR (Contraceptive Prevalence Rate)"),
                plotlyOutput("cpr_plot", height = "300px")
              )
            ),
            column(6,
              wellPanel(
                h4("Method Mix"),
                plotlyOutput("method_mix_plot", height = "300px")
              )
            )
          ),
          
          fluidRow(
            column(6,
              wellPanel(
                h4("Total Fertility Rate (TFR)"),
                plotlyOutput("tfr_plot", height = "300px")
              )
            ),
            column(6,
              wellPanel(
                h4("Age-specific Birth Rates"),
                plotlyOutput("asfr_plot", height = "300px")
              )
            )
          ),
          
          # Maternal health
          wellPanel(
            h4("Maternal Mortality"),
            plotlyOutput("maternal_mortality_plot", height = "300px")
          )
        ),
        
        # Parameters Tab
        tabPanel("Parameters", icon = icon("cog"),
          h3("Parameter Analysis"),
          p("Review current parameters and sensitivity analysis."),
          
          wellPanel(
            h4("Current Parameters"),
            DTOutput("parameters_table")
          ),
          
          wellPanel(
            h4("Parameter Sensitivity"),
            plotlyOutput("sensitivity_plot", height = "400px")
          )
        ),
        
        # About Tab
        tabPanel("About", icon = icon("info"),
          h3("About FPsim Family Planning Model"),
          
          wellPanel(
            h4("FPsim Web Application"),
            p("This web application provides an interactive interface for the FPsim family planning modeling framework."),
            p("FPsim is an agent-based modeling framework for simulating family planning dynamics, built on the Starsim architecture."),
            
            h5("Features:"),
            tags$ul(
              tags$li("Agent-based family planning simulation"),
              tags$li("Configurable contraceptive methods and efficacy"),
              tags$li("Multiple geographic locations"),
              tags$li("Intervention modeling (method updates, exposure changes)"),
              tags$li("Interactive visualizations"),
              tags$li("Parameter sensitivity analysis")
            ),
            
            h5("Model Components:"),
            tags$ul(
              tags$li("Contraceptive method selection and switching"),
              tags$li("Pregnancy and birth dynamics"),
              tags$li("Maternal and infant mortality"),
              tags$li("Age-specific fertility rates"),
              tags$li("Demographic processes")
            ),
            
            h5("Contact:"),
            p("For questions or support, please visit the FPsim GitHub repository or contact info@idmod.org"),
            
            h5("Version:"),
            p("FPsim - Shiny Web Interface v1.0")
          )
        )
      )
    )
  )
)

