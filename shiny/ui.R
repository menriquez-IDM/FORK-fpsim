# FPsim Family Planning Shiny Web App - User Interface
# UI with Tab Panels and Light/Dark Mode

library(shinyjs)
library(shinybusy)

ui <- fluidPage(
  
  # Enable shinyjs
  useShinyjs(),
  
  # Enable shinybusy for loading indicators
  # This adds the necessary JavaScript and CSS
  # We'll use show_modal_spinner() in server to control when it appears
  use_busy_spinner(
    spin = "fading-circle",
    color = "#3498db",
    position = "top-right"
  ),
  
  # Theme toggle and custom CSS
  tags$head(
    # Enable Bootstrap tooltips
    tags$script(HTML("
      $(document).ready(function(){
        $('[data-toggle=\"tooltip\"]').tooltip({
          html: true,
          trigger: 'hover'
        });
      });
    ")),
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
      
      # Family Planning Parameters (collapsible)
      wellPanel(
        tags$div(
          style = "cursor: pointer; margin-bottom: 10px;",
          actionLink("toggle_fp_params", 
                     tags$span(
                       tags$i(class = "fa fa-chevron-right", id = "fp_chevron"),
                       " Family Planning Parameters"
                     ),
                     style = "font-size: 14px; font-weight: bold; color: #333; text-decoration: none;")
        ),
        tags$script(HTML("
          $(document).on('click', '#toggle_fp_params', function() {
            $('#fp_chevron').toggleClass('fa-chevron-right fa-chevron-down');
          });
        ")),
        conditionalPanel(
          condition = "input.toggle_fp_params % 2 == 1",
          br(),
          sliderInput("exposure_factor", "Exposure Factor", 
                      value = 1.0, min = 0.1, max = 3.0, step = 0.1),
          sliderInput("maternal_mortality_factor", "Maternal Mortality Factor", 
                      value = 1.0, min = 0.5, max = 2.0, step = 0.1),
          sliderInput("primary_infertility", "Primary Infertility Rate", 
                      value = 0.05, min = 0.0, max = 0.2, step = 0.01),
          sliderInput("lam_efficacy", "LAM Efficacy", 
                      value = 0.98, min = 0.8, max = 1.0, step = 0.01)
        )
      ),
      
      # Contraceptive Parameters (collapsible)
      wellPanel(
        tags$div(
          style = "cursor: pointer; margin-bottom: 10px;",
          actionLink("toggle_contra_params", 
                     tags$span(
                       tags$i(class = "fa fa-chevron-right", id = "contra_chevron"),
                       " Contraceptive Method Efficacy"
                     ),
                     style = "font-size: 14px; font-weight: bold; color: #333; text-decoration: none;")
        ),
        tags$script(HTML("
          $(document).on('click', '#toggle_contra_params', function() {
            $('#contra_chevron').toggleClass('fa-chevron-right fa-chevron-down');
          });
        ")),
        conditionalPanel(
          condition = "input.toggle_contra_params % 2 == 1",
          br(),
          sliderInput("pill_efficacy", "Pill Efficacy", 
                      value = 0.945, min = 0.5, max = 1.0, step = 0.01),
          sliderInput("iud_efficacy", "IUD Efficacy", 
                      value = 0.986, min = 0.5, max = 1.0, step = 0.01),
          sliderInput("inj_efficacy", "Injectable Efficacy", 
                      value = 0.983, min = 0.5, max = 1.0, step = 0.01),
          sliderInput("impl_efficacy", "Implant Efficacy", 
                      value = 0.994, min = 0.5, max = 1.0, step = 0.01)
        )
      ),
      
      # Method Intervention Parameters
      wellPanel(
        h5("Method Interventions (Optional)"),
        checkboxInput("enable_interventions", "Enable Interventions", value = FALSE),
        conditionalPanel(
          condition = "input.enable_interventions == true",
          
          # Intervention builder
          h6("Add Interventions:", style = "font-weight: bold; margin-top: 10px;"),
          selectInput("intervention_type", "Intervention Type:",
                     choices = c(
                       "Add New Method" = "new_method",
                       "Update Method (Multiple Parameters)" = "update_method",
                       "Change Efficacy Only" = "efficacy",
                       "Change Duration Only" = "duration",
                       "Change Method Mix Only" = "method_mix",
                       "Scale Switching Matrix" = "switching"
                     ),
                     selected = "update_method"),
          
          sliderInput("intervention_year", "Intervention Year", 
                      value = 2010, min = 1985, max = 2025, step = 1),
          
          # Type-specific parameters
          conditionalPanel(
            condition = "input.intervention_type == 'new_method'",
            textInput("new_method_name", "Method Name (lowercase)", value = "my_new_method"),
            textInput("new_method_label", "Method Label (display)", value = "MY-NEW-METHOD"),
            sliderInput("new_method_efficacy", "Method Efficacy", 
                        value = 0.995, min = 0.5, max = 1.0, step = 0.005),
            sliderInput("new_method_duration", "Duration (months)", 
                        value = 12, min = 1, max = 60, step = 1),
            selectInput("copy_from_method", "Copy Matrix From", 
                        choices = c("Injectables" = "inj", "Pills" = "pill", "IUD" = "iud", 
                                   "Implants" = "impl", "Condoms" = "cond"),
                        selected = "inj"),
            sliderInput("initial_share", "Initial Share", 
                        value = 0.40, min = 0.0, max = 1.0, step = 0.05)
          ),
          
          conditionalPanel(
            condition = "input.intervention_type == 'update_method'",
            selectInput("update_method_target", "Target Method:",
                       choices = c(
                         "Pills" = "pill",
                         "IUD" = "iud",
                         "Injectables" = "inj",
                         "Condoms" = "cond",
                         "BTL (Tubal Ligation)" = "btl",
                         "Withdrawal" = "wdraw",
                         "Implants" = "impl",
                         "Other Traditional" = "othtrad",
                         "Other Modern" = "othmod"
                       ),
                       selected = "inj"),
            h6("Select parameters to update:", style = "margin-top: 10px;"),
            checkboxInput("update_efficacy_enable", "Update Efficacy", value = TRUE),
            conditionalPanel(
              condition = "input.update_efficacy_enable",
              sliderInput("update_efficacy_value", "New Efficacy", 
                          value = 0.99, min = 0.5, max = 1.0, step = 0.005)
            ),
            checkboxInput("update_duration_enable", "Update Duration", value = FALSE),
            conditionalPanel(
              condition = "input.update_duration_enable",
              sliderInput("update_duration_value", "New Duration (months)", 
                          value = 12, min = 1, max = 60, step = 1)
            ),
            checkboxInput("update_method_mix_enable", "Update Method Mix", value = FALSE),
            conditionalPanel(
              condition = "input.update_method_mix_enable",
              sliderInput("update_method_mix_value", "Target Share", 
                          value = 0.20, min = 0.0, max = 1.0, step = 0.05)
            )
          ),
          
          conditionalPanel(
            condition = "input.intervention_type == 'efficacy'",
            selectInput("efficacy_method", "Target Method:",
                       choices = c(
                         "Pills" = "pill",
                         "IUD" = "iud",
                         "Injectables" = "inj",
                         "Condoms" = "cond",
                         "BTL (Tubal Ligation)" = "btl",
                         "Withdrawal" = "wdraw",
                         "Implants" = "impl",
                         "Other Traditional" = "othtrad",
                         "Other Modern" = "othmod"
                       ),
                       selected = "inj"),
            sliderInput("efficacy_value", "New Efficacy", 
                        value = 0.99, min = 0.5, max = 1.0, step = 0.005)
          ),
          
          conditionalPanel(
            condition = "input.intervention_type == 'duration'",
            selectInput("duration_method", "Target Method:",
                       choices = c(
                         "Pills" = "pill",
                         "IUD" = "iud",
                         "Injectables" = "inj",
                         "Condoms" = "cond",
                         "BTL (Tubal Ligation)" = "btl",
                         "Withdrawal" = "wdraw",
                         "Implants" = "impl",
                         "Other Traditional" = "othtrad",
                         "Other Modern" = "othmod"
                       ),
                       selected = "inj"),
            sliderInput("duration_value", "New Duration (months)", 
                        value = 12, min = 1, max = 60, step = 1)
          ),
          
          conditionalPanel(
            condition = "input.intervention_type == 'method_mix'",
            selectInput("method_mix_method", "Target Method:",
                       choices = c(
                         "Pills" = "pill",
                         "IUD" = "iud",
                         "Injectables" = "inj",
                         "Condoms" = "cond",
                         "BTL (Tubal Ligation)" = "btl",
                         "Withdrawal" = "wdraw",
                         "Implants" = "impl",
                         "Other Traditional" = "othtrad",
                         "Other Modern" = "othmod"
                       ),
                       selected = "impl"),
            sliderInput("method_mix_share", "Target Share", 
                        value = 0.20, min = 0.0, max = 1.0, step = 0.05)
          ),
          
          conditionalPanel(
            condition = "input.intervention_type == 'switching'",
            selectInput("switching_method", "Target Method:",
                       choices = c(
                         "Pills" = "pill",
                         "IUD" = "iud",
                         "Injectables" = "inj",
                         "Condoms" = "cond",
                         "BTL (Tubal Ligation)" = "btl",
                         "Withdrawal" = "wdraw",
                         "Implants" = "impl",
                         "Other Traditional" = "othtrad",
                         "Other Modern" = "othmod"
                       ),
                       selected = "inj"),
            sliderInput("switching_scale", "Scale Factor", 
                        value = 1.2, min = 0.5, max = 2.0, step = 0.1)
          ),
          
          actionButton("add_intervention", "Add Intervention", 
                      class = "btn-success btn-sm", 
                      style = "margin-top: 10px; margin-bottom: 10px;"),
          
          # Display added interventions
          h6("Added Interventions:", style = "font-weight: bold; margin-top: 15px;"),
          uiOutput("intervention_list"),
          
          conditionalPanel(
            condition = "output.has_interventions",
            actionButton("clear_interventions", "Clear All", 
                        class = "btn-warning btn-sm")
          ),
          
          # Method reference info
          hr(),
          h6("📋 Available Methods Reference:", style = "font-weight: bold; margin-top: 15px;"),
          actionLink("show_methods_ref", "Show/Hide All 9 Contraceptive Methods"),
          conditionalPanel(
            condition = "input.show_methods_ref % 2 == 1",
            wellPanel(
              style = "background-color: #f8f9fa; font-size: 11px; margin-top: 10px;",
              tags$table(
                class = "table table-sm table-striped",
                tags$thead(
                  tags$tr(
                    tags$th("#"),
                    tags$th("Name"),
                    tags$th("Code"),
                    tags$th("Type")
                  )
                ),
                tags$tbody(
                  tags$tr(tags$td("1"), tags$td("Pills"), tags$td(tags$code("pill")), tags$td("Short-acting")),
                  tags$tr(tags$td("2"), tags$td("IUD"), tags$td(tags$code("iud")), tags$td("LARC")),
                  tags$tr(tags$td("3"), tags$td("Injectables"), tags$td(tags$code("inj")), tags$td("Short-acting")),
                  tags$tr(tags$td("4"), tags$td("Condoms"), tags$td(tags$code("cond")), tags$td("Barrier")),
                  tags$tr(tags$td("5"), tags$td("BTL (Tubal)"), tags$td(tags$code("btl")), tags$td("Permanent")),
                  tags$tr(tags$td("6"), tags$td("Withdrawal"), tags$td(tags$code("wdraw")), tags$td("Traditional")),
                  tags$tr(tags$td("7"), tags$td("Implants"), tags$td(tags$code("impl")), tags$td("LARC")),
                  tags$tr(tags$td("8"), tags$td("Other Traditional"), tags$td(tags$code("othtrad")), tags$td("Traditional")),
                  tags$tr(tags$td("9"), tags$td("Other Modern"), tags$td(tags$code("othmod")), tags$td("Modern"))
                )
              ),
              p(tags$strong("Modifiable Parameters per Method:"), style = "margin-top: 10px;"),
              tags$ul(
                tags$li(tags$strong("Efficacy:"), " Contraceptive effectiveness (0.5-1.0)"),
                tags$li(tags$strong("Duration:"), " Average continuation time (months)"),
                tags$li(tags$strong("Method Mix:"), " Share of users (0-1)"),
                tags$li(tags$strong("Switching Matrix:"), " Probability of switching to method")
              ),
              p(tags$em("Use 'Update Method' to modify multiple parameters at once, or single-parameter types for targeted changes."),
                style = "font-size: 10px; color: #666; margin-top: 10px;")
            )
          )
        )
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
          )
        ),
        
        # ===== CONTRACEPTIVE METHODS TAB =====
        tabPanel(
          "Contraceptive Methods", 
          icon = icon("pills"),
          
          br(),
          
          wellPanel(
            h4("Contraceptive Method Overview"),
            p("This tab shows detailed information about contraceptive use in the simulation.",
              style = "color: #666;")
          ),
          
          # Method Mix - Primary visualization
          wellPanel(
            h4("1. Method Mix Distribution"),
            p("Percentage of contraceptive users by method type", style = "font-size: 12px; color: #666;"),
            plotlyOutput("method_mix_detailed", height = "450px")
          ),
          
          # CPR and mCPR trends
          fluidRow(
            column(6,
              wellPanel(
                h4("2. Contraceptive Prevalence Rate (CPR)"),
                p("Total CPR and modern CPR over time", style = "font-size: 12px; color: #666;"),
                plotlyOutput("cpr_trend_detailed", height = "350px")
              )
            ),
            column(6,
              wellPanel(
                h4("3. Estimated Users by Method"),
                p("Approximate number of people using each contraceptive method", style = "font-size: 12px; color: #666;"),
                plotlyOutput("method_usage_time", height = "350px")
              )
            )
          ),
          
          # Method categories breakdown
          wellPanel(
            h4("4. Modern vs. Traditional Methods"),
            p("Distribution by method category", style = "font-size: 12px; color: #666;"),
            plotlyOutput("method_categories", height = "400px")
          ),
          
          # Summary statistics
          wellPanel(
            h4("5. Contraceptive Statistics Summary"),
            verbatimTextOutput("contraceptive_summary_stats")
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
                tags$div(
                  style = "display: flex; align-items: center; margin-bottom: 5px;",
                  h4("Birth Spacing Distribution", style = "margin: 0; margin-right: 8px;"),
                  tags$span(
                    icon("info-circle"),
                    style = "color: #337ab7; cursor: help; font-size: 16px;",
                    title = "Birth spacing (inter-birth interval) is the time elapsed between consecutive live births. Optimal spacing (24-60 months) improves maternal and child health outcomes. Too short spacing increases health risks.",
                    `data-toggle` = "tooltip",
                    `data-placement` = "top"
                  )
                ),
                tags$p(
                  "Time between consecutive births (months)",
                  style = "font-size: 12px; color: #666; margin-top: 5px; margin-bottom: 10px;"
                ),
                plotlyOutput("birth_spacing_plot", height = "300px"),
                tags$div(
                  style = "font-size: 11px; color: #666; margin-top: 10px; padding: 8px; background-color: #f8f9fa; border-left: 3px solid #28A745;",
                  tags$strong("How it's calculated:"),
                  tags$ul(
                    style = "margin: 5px 0 0 0; padding-left: 20px;",
                    tags$li("Measures months between consecutive live births"),
                    tags$li("Only includes women with 2+ births (parous women)"),
                    tags$li("Calculated from birth dates in simulation history"),
                    tags$li("Affected by contraceptive use, breastfeeding (LAM), and postpartum amenorrhea"),
                    tags$li("WHO recommends: 24-60 months for optimal health")
                  )
                )
              )
            ),
            column(6,
              wellPanel(
                tags$div(
                  style = "display: flex; align-items: center; margin-bottom: 5px;",
                  h4("Parity Distribution", style = "margin: 0; margin-right: 8px;"),
                  tags$span(
                    icon("info-circle"),
                    style = "color: #337ab7; cursor: help; font-size: 16px;",
                    title = "Parity is the number of children a woman has given birth to. This shows the distribution of women by their total number of live births. Parity 0 = nulliparous (no children), Parity 1+ = parous (has given birth).",
                    `data-toggle` = "tooltip",
                    `data-placement` = "top"
                  )
                ),
                tags$p(
                  "Number of women by total live births",
                  style = "font-size: 12px; color: #666; margin-top: 5px; margin-bottom: 10px;"
                ),
                plotlyOutput("parity_plot", height = "300px"),
                tags$div(
                  style = "font-size: 11px; color: #666; margin-top: 10px; padding: 8px; background-color: #f8f9fa; border-left: 3px solid #337ab7;",
                  tags$strong("How it's calculated:"),
                  tags$ul(
                    style = "margin: 5px 0 0 0; padding-left: 20px;",
                    tags$li("Counts all reproductive-age women (15-49 years)"),
                    tags$li("Groups by cumulative number of live births"),
                    tags$li("Higher parity indicates more children born"),
                    tags$li("Influenced by fertility rates, contraceptive use, and demographics")
                  )
                )
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
        
        # ===== INTERVENTION ANALYSIS TAB (for new methods) =====
        tabPanel(
          "New Method Analysis", 
          icon = icon("flask"),
          
          br(),
          
          conditionalPanel(
            condition = "input.enable_interventions == false",
            wellPanel(
              h4("No Interventions Enabled"),
              p("To use this feature, enable 'Interventions' in the sidebar parameters."),
              p("This tab shows analysis for 'Add New Method' interventions."),
              p("For other intervention types, see the 'Method Updates' tab.")
            )
          ),
          
          conditionalPanel(
            condition = "input.enable_interventions == true",
            
            # Top section: Plot selector in 3 columns (collapsible)
            wellPanel(
              style = "background-color: #f8f9fa; margin-bottom: 15px;",
              
              # Collapsible header
              tags$div(
                style = "cursor: pointer; margin-bottom: 15px;",
                actionLink("toggle_plot_selector", 
                           tags$span(
                             tags$i(class = "fa fa-chevron-down", id = "plot_selector_chevron"),
                             " Select Visualizations"
                           ),
                           style = "font-size: 18px; font-weight: bold; color: #2c3e50; text-decoration: none;")
              ),
              
              # JavaScript to toggle chevron
              tags$script(HTML("
                $(document).on('click', '#toggle_plot_selector', function() {
                  $('#plot_selector_chevron').toggleClass('fa-chevron-right fa-chevron-down');
                });
              ")),
              
              # Collapsible content (default: expanded)
              conditionalPanel(
                condition = "input.toggle_plot_selector % 2 == 0",
                
                fluidRow(
                  # Column 1: Summary
                  column(
                    width = 4,
                    div(
                      style = "background-color: white; padding: 12px; border-radius: 4px; border-left: 3px solid #3498db;",
                      h5(strong("SUMMARY"), style = "margin-top: 0; margin-bottom: 10px; color: #3498db;"),
                      checkboxInput("show_summary", 
                                   "Summary (All 6 Panels)", 
                                   value = TRUE),
                      checkboxInput("show_statistics", 
                                   "Impact Statistics", 
                                   value = FALSE)
                    )
                  ),
                  
                  # Column 2: Individual Panels
                  column(
                    width = 4,
                    div(
                      style = "background-color: white; padding: 12px; border-radius: 4px; border-left: 3px solid #27ae60;",
                      h5(strong("INDIVIDUAL PANELS"), style = "margin-top: 0; margin-bottom: 10px; color: #27ae60;"),
                      checkboxGroupInput("intervention_plot_types", NULL,
                                        choices = c(
                                          "1. Adoption Rate" = "adoption_rate",
                                          "2. Injectable Trends" = "injectable_trends",
                                          "3. Injectable Share" = "total_injectable",
                                          "4. Substitution Effects" = "substitution",
                                          "5. Top 6 Methods" = "top_methods",
                                          "6. All Methods" = "all_methods"
                                        ),
                                        selected = NULL)
                    )
                  ),
                  
                  # Column 3: Other Analyses
                  column(
                    width = 4,
                    div(
                      style = "background-color: white; padding: 12px; border-radius: 4px; border-left: 3px solid #e67e22;",
                      h5(strong("OTHER ANALYSES"), style = "margin-top: 0; margin-bottom: 10px; color: #e67e22;"),
                      checkboxGroupInput("intervention_plot_types_other", NULL,
                                        choices = c(
                                          "Injectable Comparison" = "injectables",
                                          "Method Mix Evolution" = "method_mix",
                                          "Adoption (Legacy)" = "adoption",
                                          "Method Bar Chart" = "method_bar",
                                          "CPR Comparison" = "cpr",
                                          "Births Comparison" = "births"
                                        ),
                                        selected = NULL),
                      p("Note: For 'Add New Method' interventions.", 
                        style = "font-size: 10px; color: #999; font-style: italic; margin-top: 15px; margin-bottom: 0;")
                    )
                  )
                )
              )
            ),
            
            # Bottom section: Plots (full width)
            wellPanel(
              style = "min-height: 400px;",
              h4("New Method Impact Visualization", style = "margin-top: 0; color: #2c3e50;"),
              hr(),
              uiOutput("intervention_plot_ui")
            )
          )
        ),
        
        # ===== METHOD UPDATES TAB (for standard interventions) =====
        tabPanel(
          "Method Updates", 
          icon = icon("wrench"),
          
          br(),
          
          conditionalPanel(
            condition = "input.enable_interventions == false",
            wellPanel(
              h4("No Interventions Enabled"),
              p("To use this feature, enable 'Interventions' in the sidebar parameters."),
              p("This tab shows analysis for:"),
              tags$ul(
                tags$li("Update Method interventions"),
                tags$li("Efficacy changes"),
                tags$li("Duration changes"),
                tags$li("Method mix changes"),
                tags$li("Switching matrix changes")
              )
            )
          ),
          
          conditionalPanel(
            condition = "input.enable_interventions == true",
            
            wellPanel(
              h4("Baseline vs. Intervention Comparison"),
              p("Visual comparison of method mix, CPR, and births between baseline and intervention scenarios.",
                style = "color: #666;")
            ),
            
            # Method Mix Comparison
            wellPanel(
              h4("1. Method Mix Comparison"),
              plotlyOutput("method_updates_comparison", height = "500px")
            ),
            
            # CPR/mCPR Comparison
            fluidRow(
              column(6,
                wellPanel(
                  h4("2. CPR Trends"),
                  plotlyOutput("method_updates_cpr", height = "350px")
                )
              ),
              column(6,
                wellPanel(
                  h4("3. Births Comparison"),
                  plotlyOutput("method_updates_births", height = "350px")
                )
              )
            ),
            
            # Method-specific details
            wellPanel(
              h4("4. Final Method Distribution"),
              plotlyOutput("method_updates_final", height = "400px")
            ),
            
            # Summary statistics
            wellPanel(
              h4("5. Impact Summary"),
              verbatimTextOutput("method_updates_stats")
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
