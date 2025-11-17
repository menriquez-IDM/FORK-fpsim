# FPsim Family Planning Shiny Web App - User Interface
# UI with Tab Panels and Light/Dark Mode

library(shinyjs)

ui <- fluidPage(
  
  # Enable shinyjs
  useShinyjs(),
  
  # Theme toggle and custom CSS
  tags$head(
    tags$style(HTML("
      /* Light mode (default) */
      .light-mode {
        background-color: #f5f5f5;
        color: #333;
      }
      
      .light-mode .well {
        background-color: #fff;
        border: 1px solid #ddd;
      }
      
      .light-mode .box {
        background-color: #fff;
        border: 1px solid #ddd;
      }
      
      /* Dark mode */
      .dark-mode {
        background-color: #1e1e1e;
        color: #e0e0e0;
      }
      
      .dark-mode .well {
        background-color: #2d2d2d;
        border: 1px solid #444;
        color: #e0e0e0;
      }
      
      .dark-mode .box {
        background-color: #2d2d2d;
        border: 1px solid #444;
        color: #e0e0e0;
      }
      
      .dark-mode .nav-tabs > li > a {
        background-color: #2d2d2d;
        color: #e0e0e0;
        border: 1px solid #444;
      }
      
      .dark-mode .nav-tabs > li.active > a {
        background-color: #3d3d3d;
        color: #fff;
        border: 1px solid #555;
      }
      
      .dark-mode .table {
        color: #e0e0e0;
        background-color: #2d2d2d;
      }
      
      .dark-mode .form-control {
        background-color: #3d3d3d;
        color: #e0e0e0;
        border: 1px solid #555;
      }
      
      .dark-mode label {
        color: #e0e0e0;
      }
      
      /* Theme toggle button */
      .theme-toggle {
        position: fixed;
        top: 10px;
        right: 10px;
        z-index: 1000;
      }
      
      /* Sidebar styling */
      .sidebar {
        background-color: inherit;
        padding: 20px;
        border-right: 1px solid #ddd;
      }
      
      .dark-mode .sidebar {
        border-right: 1px solid #444;
      }
      
      /* Better spacing */
      .well h4, .well h5 {
        margin-top: 0;
      }
      
      .main-content {
        padding: 20px;
      }
      
      /* Tab content styling */
      .tab-content {
        padding: 20px;
        border: 1px solid #ddd;
        border-top: none;
        background-color: #fff;
      }
      
      .dark-mode .tab-content {
        background-color: #2d2d2d;
        border-color: #444;
      }
    "))
  ),
  
  # Theme toggle button
  div(class = "theme-toggle",
      actionButton("theme_toggle", "🌓 Toggle Theme", class = "btn-sm")
  ),
  
  # Title
  titlePanel("FPsim Family Planning Model"),
  
  # Main layout with sidebar
  sidebarLayout(
    
    # Sidebar Panel
    sidebarPanel(
      width = 3,
      class = "sidebar",
      
      h4("Simulation Parameters"),
      
      # Basic Parameters
      wellPanel(
        h5("Basic Parameters"),
        sliderInput("n_agents", "Population Size", 
                    value = 1000, min = 100, max = 10000, step = 100),
        sliderInput("start_year", "Start Year", 
                    value = 2000, min = 1980, max = 2020, step = 1),
        sliderInput("end_year", "End Year", 
                    value = 2020, min = 1990, max = 2030, step = 1),
        selectInput("location", "Location", 
                    choices = c("senegal", "kenya", "ethiopia", "niger", 
                               "cotedivoire", "nigeria_lagos", "nigeria_kano", "pakistan_sindh"), 
                    selected = "senegal")
      ),
      
      # Family Planning Parameters
      wellPanel(
        h5("Family Planning Parameters"),
        sliderInput("exposure_factor", "Exposure Factor", 
                    value = 1.0, min = 0.1, max = 3.0, step = 0.1),
        sliderInput("maternal_mortality_factor", "Maternal Mortality Factor", 
                    value = 1.0, min = 0.5, max = 2.0, step = 0.1),
        sliderInput("primary_infertility", "Primary Infertility Rate", 
                    value = 0.05, min = 0.0, max = 0.2, step = 0.01),
        sliderInput("lam_efficacy", "LAM Efficacy", 
                    value = 0.98, min = 0.8, max = 1.0, step = 0.01)
      ),
      
      # Contraceptive Parameters (collapsible)
      wellPanel(
        h5("Contraceptive Parameters"),
        sliderInput("pill_efficacy", "Pill Efficacy", 
                    value = 0.945, min = 0.5, max = 1.0, step = 0.01),
        sliderInput("iud_efficacy", "IUD Efficacy", 
                    value = 0.986, min = 0.5, max = 1.0, step = 0.01),
        sliderInput("inj_efficacy", "Injectable Efficacy", 
                    value = 0.983, min = 0.5, max = 1.0, step = 0.01),
        sliderInput("impl_efficacy", "Implant Efficacy", 
                    value = 0.994, min = 0.5, max = 1.0, step = 0.01)
      ),
      
      # Advanced Parameters (collapsible)
      wellPanel(
        h5("Advanced Parameters"),
        checkboxInput("use_education", "Include Education Module", value = FALSE),
        checkboxInput("use_empowerment", "Include Empowerment Module", value = FALSE),
        sliderInput("rand_seed", "Random Seed", 
                    value = 1, min = 1, max = 100, step = 1)
      ),
      
      # Action Buttons
      br(),
      actionButton("run_simulation", "Run Simulation", 
                   class = "btn-primary btn-lg", 
                   style = "width: 100%; margin-bottom: 10px;"),
      actionButton("reset_params", "Reset Parameters", 
                   class = "btn-secondary", 
                   style = "width: 100%;")
    ),
    
    # Main Panel with Tabs
    mainPanel(
      width = 9,
      class = "main-content",
      
      tabsetPanel(
        id = "main_tabs",
        type = "tabs",
        
        # ===== SIMULATION TAB =====
        tabPanel(
          "Simulation", 
          icon = icon("play"),
          
          br(),
          
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
                h4("Quick Preview: Birth Rate"),
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
        
        # ===== RESULTS TAB =====
        tabPanel(
          "Results", 
          icon = icon("chart-line"),
          
          br(),
          
          # Main birth rate plot
          wellPanel(
            h4("Birth Rate Over Time"),
            plotlyOutput("birth_rate_plot", height = "400px")
          ),
          
          # Secondary plots
          fluidRow(
            column(6,
              wellPanel(
                h4("Contraceptive Prevalence Rate (CPR)"),
                plotlyOutput("cpr_plot", height = "300px")
              )
            ),
            column(6,
              wellPanel(
                h4("Total Fertility Rate (TFR)"),
                plotlyOutput("tfr_plot", height = "300px")
              )
            )
          ),
          
          fluidRow(
            column(6,
              wellPanel(
                h4("Method Mix Distribution"),
                plotlyOutput("method_mix_plot", height = "300px")
              )
            ),
            column(6,
              wellPanel(
                h4("Age-specific Fertility Rates"),
                plotlyOutput("asfr_plot", height = "300px")
              )
            )
          ),
          
          fluidRow(
            column(6,
              wellPanel(
                h4("Maternal Mortality Rate"),
                plotlyOutput("maternal_mortality_plot", height = "300px")
              )
            ),
            column(6,
              wellPanel(
                h4("Unmet Need for Family Planning"),
                plotlyOutput("unmet_need_plot", height = "300px")
              )
            )
          )
        ),
        
        # ===== ADVANCED ANALYTICS TAB =====
        tabPanel(
          "Advanced Analytics", 
          icon = icon("chart-bar"),
          
          br(),
          
          fluidRow(
            column(6,
              wellPanel(
                h4("Birth Spacing Distribution"),
                plotlyOutput("birth_spacing_plot", height = "300px")
              )
            ),
            column(6,
              wellPanel(
                h4("Parity Distribution"),
                plotlyOutput("parity_plot", height = "300px")
              )
            )
          ),
          
          fluidRow(
            column(6,
              wellPanel(
                h4("Contraceptive Switching Patterns"),
                plotlyOutput("switching_plot", height = "300px")
              )
            ),
            column(6,
              wellPanel(
                h4("Population Pyramid"),
                plotlyOutput("population_pyramid", height = "300px")
              )
            )
          ),
          
          fluidRow(
            column(6,
              wellPanel(
                h4("Stillbirths and Miscarriages"),
                plotlyOutput("pregnancy_outcomes_plot", height = "300px")
              )
            ),
            column(6,
              wellPanel(
                h4("Cumulative Births Over Time"),
                plotlyOutput("cumulative_births_plot", height = "300px")
              )
            )
          )
        ),
        
        # ===== PARAMETERS TAB =====
        tabPanel(
          "Parameters", 
          icon = icon("cog"),
          
          br(),
          
          wellPanel(
            h4("Current Parameters"),
            DTOutput("parameters_table")
          ),
          
          wellPanel(
            h4("Parameter Sensitivity"),
            plotlyOutput("sensitivity_plot", height = "400px")
          )
        ),
        
        # ===== ABOUT TAB =====
        tabPanel(
          "About", 
          icon = icon("info"),
          
          br(),
          
          wellPanel(
            h3("About FPsim Family Planning Model"),
            
            h4("FPsim Web Application"),
            p("This web application provides an interactive interface for the FPsim family planning modeling framework."),
            p("FPsim is an agent-based modeling framework for simulating family planning dynamics, contraceptive use, 
               fertility, and related health outcomes. Built on the Starsim architecture, it provides a flexible platform 
               for exploring family planning interventions and policies."),
            
            h4("Features:"),
            tags$ul(
              tags$li("Agent-based family planning simulation with individual-level modeling"),
              tags$li("Configurable contraceptive methods with customizable efficacy and duration"),
              tags$li("Multiple geographic locations with location-specific parameters"),
              tags$li("Intervention modeling (method mix changes, exposure modifications)"),
              tags$li("Interactive visualizations of key indicators"),
              tags$li("Parameter sensitivity analysis"),
              tags$li("Light and dark mode support")
            ),
            
            h4("Model Components:"),
            tags$ul(
              tags$li("Contraceptive method selection and switching dynamics"),
              tags$li("Pregnancy and birth processes"),
              tags$li("Maternal and infant mortality modeling"),
              tags$li("Age-specific fertility rates"),
              tags$li("Demographic processes (births, deaths, aging)"),
              tags$li("Optional education and empowerment modules")
            ),
            
            h4("Available Contraceptive Methods:"),
            tags$ul(
              tags$li("Modern methods: Pills, IUDs, Injectables, Implants, Condoms, Female Sterilization"),
              tags$li("Traditional methods: Withdrawal, Other traditional"),
              tags$li("None (no method)")
            ),
            
            h4("Key Indicators:"),
            tags$ul(
              tags$li("Total Fertility Rate (TFR)"),
              tags$li("Contraceptive Prevalence Rate (CPR)"),
              tags$li("Modern Contraceptive Prevalence Rate (mCPR)"),
              tags$li("Unmet Need for Family Planning"),
              tags$li("Age-specific Fertility Rates (ASFR)"),
              tags$li("Maternal Mortality Ratio"),
              tags$li("Birth Spacing and Parity Distribution")
            ),
            
            h4("Contact:"),
            p("For questions or support:"),
            tags$ul(
              tags$li("FPsim GitHub: https://github.com/fpsim/fpsim"),
              tags$li("Email: info@idmod.org")
            ),
            
            h4("Version:"),
            p("FPsim - Shiny Web Interface v1.0"),
            p("Built with Starsim, R Shiny, and Python")
          )
        )
      )
    )
  )
)
