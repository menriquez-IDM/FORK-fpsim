# FPsim Family Planning Shiny Web App - Architecture Documentation

## Overview

The FPsim Family Planning Shiny Web App is a sophisticated web application that provides an interactive interface for running family planning simulations using the FPsim modeling framework. The application combines R/Shiny for the user interface with Python/FPsim for the simulation engine.

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                FPsim Family Planning Shiny Web App              │
├─────────────────────────────────────────────────────────────────┤
│  Frontend (R/Shiny)           │  Backend (Python/FPsim)         │
│  ┌─────────────────────────┐  │  ┌──────────────────────────┐  │
│  │     User Interface      │  │  │   Simulation Engine      │  │
│  │   - Sliders/Controls    │  │  │   - FPsim Framework      │  │
│  │   - Interactive Plots   │  │  │   - Contraceptive Models │  │
│  │   - Dashboard Layout    │  │  │   - Pregnancy Dynamics   │  │
│  └─────────────────────────┘  │  │   - Demographics         │  │
│  ┌─────────────────────────┐  │  └──────────────────────────┘  │
│  │     R Server Logic      │  │  ┌──────────────────────────┐  │
│  │   - Parameter Handling  │  │  │   Data Processing        │  │
│  │   - Plot Generation     │  │  │   - Result Extraction    │  │
│  │   - State Management    │  │  │   - Data Formatting      │  │
│  └─────────────────────────┘  │  └──────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
                    ┌─────────────────┐
                    │   Reticulate    │
                    │   Integration   │
                    │   Layer         │
                    └─────────────────┘
```

## Component Breakdown

### 1. Frontend Layer (R/Shiny)

#### **User Interface (`ui.R` and `ui_simple.R`)**

Two UI versions are provided:
- **`ui.R`**: Full dashboard layout using `shinydashboard` with comprehensive controls
- **`ui_simple.R`**: Simplified tabbed interface for basic demonstrations

**Main UI Components:**
```r
# Dashboard structure
ui <- dashboardPage(
  dashboardHeader(title = "FPsim Family Planning Model"),
  dashboardSidebar(width = 350, ...),  # Wide sidebar for parameters
  dashboardBody(...)                   # Main content area with tabs
)

# Parameter controls
sliderInput("n_agents", "Population Size", 
           value = 1000, min = 100, max = 10000, step = 100)
selectInput("location", "Location", 
           choices = c("senegal", "kenya", ...))
```

**Key Features:**
- Wide sidebar (350px) for better parameter visibility
- Collapsible parameter boxes organized by category
- Multiple tabs for different visualization types
- Responsive layout that adapts to screen size

#### **Server Logic (`server.R`)**

Handles all server-side processing:
- **Parameter Collection**: Gathers user inputs
- **Simulation Orchestration**: Manages simulation workflow
- **Result Processing**: Formats data for visualization
- **Plot Generation**: Creates interactive Plotly visualizations
- **State Management**: Tracks simulation status

**Key Server Functions:**
```r
# Simulation execution
observeEvent(input$run_simulation, {
  # Validate parameters
  errors <- validate_parameters()
  
  # Prepare parameters for Python
  params <- list(
    n_agents = as.integer(input$n_agents),
    start = input$start_year,
    end = input$end_year,
    location = input$location,
    # ... more parameters
  )
  
  # Call Python simulation or use mock data
  if (python_available) {
    result <- py$run_fp_simulation(params)
  } else {
    result <- generate_mock_data(params)
  }
  
  # Store and display results
  simulation_results$data <- result
})
```

### 2. Integration Layer (Reticulate)

#### **Python Environment Setup (`app.R`)**

The `reticulate` package provides seamless R-Python integration:

```r
# Set up Python environment with error handling
python_available <- FALSE
tryCatch({
  use_python("../venv/bin/python", required = FALSE)
  source_python("python/fp_simulator.py")
  python_available <<- TRUE
}, error = function(e) {
  cat("Python integration not available\n")
})
```

**How Reticulate Works:**
1. **`use_python()`**: Specifies which Python interpreter to use
2. **`source_python()`**: Loads Python file and makes functions available via `py$`
3. **`py$function_name()`**: Calls Python functions from R
4. **Automatic Data Conversion**: Converts R objects (lists, vectors) to Python (dicts, arrays) and vice versa

#### **Data Flow Between R and Python**
```
R Parameters (list) → Python Dictionary → FPsim Simulation → 
Python Results (dict) → R List → Plotly Visualizations
```

### 3. Backend Layer (Python/FPsim)

#### **Simulation Engine (`python/fp_simulator.py`)**

**Main Function:**
```python
def run_fp_simulation(params):
    """Run family planning simulation with given parameters"""
    
    # Extract parameters from R
    n_agents = params.get('n_agents', 1000)
    start_year = params.get('start', 2000)
    end_year = params.get('end', 2020)
    location = params.get('location', 'senegal')
    
    # Build FPsim parameters
    pars = {
        'n_agents': int(n_agents),
        'start': start_year,
        'end_year': end_year,
        'location': location,
    }
    
    fp_pars = {
        'exposure_factor': params.get('exposure_factor', 1.0),
        'maternal_mortality_factor': params.get('maternal_mortality_factor', 1.0),
        # ... more FP-specific parameters
    }
    
    # Create and run simulation
    sim = fp.Sim(pars=pars, fp_pars=fp_pars)
    sim.run(verbose=0.1)
    
    # Extract and return results
    return extract_simulation_results(sim, params)
```

#### **FPsim Components Used**

**Core Modules:**
- **`fp.Sim`**: Main simulation class
- **`fp.FPmod`**: Family planning module with contraceptive dynamics
- **`fp.methods`**: Contraceptive method definitions and properties
- **Demographics**: Pregnancy, births, deaths, aging

**Contraceptive Methods:**
- Pills, IUDs, Injectables, Implants, Condoms
- Female sterilization (BTL)
- Withdrawal and other traditional methods
- Method switching and discontinuation

**Key Processes:**
- **Contraceptive Choice**: Initial method selection and switching
- **Pregnancy Model**: Fecundity, exposure, conception probability
- **Birth Outcomes**: Live births, stillbirths, miscarriages
- **Maternal Health**: Maternal mortality based on location data

**Optional Modules:**
- **Education Module**: Effects of education on contraceptive use
- **Empowerment Connector**: Women's empowerment effects

## Data Flow Architecture

### 1. User Input Flow
```
User Interface (Sliders/Dropdowns) → 
Input Validation → 
R Parameter List → 
Python Dictionary → 
FPsim Parameters
```

### 2. Simulation Execution Flow
```
FPsim Sim Object Creation → 
Module Initialization → 
Simulation Run Loop → 
Result Extraction → 
Python Dictionary
```

### 3. Results Processing Flow
```
Python Results → 
Reticulate Conversion → 
R List → 
Plotly Plot Objects → 
Rendered in Browser
```

## File Structure

```
shiny/
├── app.R                          # Main application entry point
├── ui.R                           # Full dashboard user interface
├── ui_simple.R                    # Simplified user interface
├── server.R                       # Server logic and reactive functions
├── README.md                      # User documentation
├── ARCHITECTURE.md                # This document
├── DEPENDENCIES.md                # Dependency documentation
├── QUICK_START.md                 # Quick start guide
├── install_dependencies.R         # R package installer
├── install_all_dependencies.R     # Comprehensive installer
├── start_app.sh                   # Startup script (macOS/Linux)
├── start_app.bat                  # Startup script (Windows CMD)
├── start_app.ps1                  # Startup script (Windows PowerShell)
├── .gitignore                     # Git ignore patterns
└── python/
    ├── fp_simulator.py            # Python simulation engine
    └── requirements.txt           # Python dependencies
```

## Key Integration Points

### 1. R-Python Bridge
- **Entry Point**: `app.R` line 18: `source_python("python/fp_simulator.py")`
- **Function Call**: `server.R`: `py$run_fp_simulation(params)`
- **Data Conversion**: Automatic via reticulate

### 2. Parameter Mapping
R slider inputs are mapped to FPsim parameters:
```r
# R Input → Python Parameter → FPsim Parameter
input$n_agents → params['n_agents'] → pars['n_agents']
input$location → params['location'] → pars['location']
input$exposure_factor → params['exposure_factor'] → fp_pars['exposure_factor']
```

### 3. Result Processing
Python simulation results are processed for R visualization:
```python
# Python returns dictionary with all results
return {
    'timevec': timevec,
    'years': years,
    'birth_rate': birth_rate,
    'tfr': tfr,
    'cpr': cpr,
    'method_mix': method_mix,
    'asfr': asfr,
    # ... more results
}
```

```r
# R processes results for plotting
plot_ly(x = data$years, y = data$birth_rate, ...)
```

## Error Handling

### 1. Python Integration Errors
- **Fallback Mode**: If Python/FPsim unavailable, uses mock data generator
- **Error Messages**: Clear notifications to user about simulation status
- **Graceful Degradation**: App continues to function with limited features

Mock data generator provides realistic synthetic data:
```r
generate_mock_data <- function(params) {
  # Generate realistic birth rates, TFR, CPR trends
  # Uses statistical distributions and trends
  # Returns same structure as Python simulation
}
```

### 2. Parameter Validation
```r
validate_parameters <- function() {
  errors <- c()
  if (input$n_agents < 100) {
    errors <- c(errors, "Population size must be at least 100")
  }
  if (input$start_year >= input$end_year) {
    errors <- c(errors, "Start year must be before end year")
  }
  return(errors)
}
```

### 3. Simulation Errors
- **Exception Handling**: Catches and reports simulation failures
- **Progress Tracking**: Shows simulation progress and status
- **Recovery**: Allows retry with different parameters

## Performance Considerations

### 1. Simulation Scaling
- **Population Size**: Configurable from 100 to 10,000 agents
  - Larger populations provide more stable statistics
  - Smaller populations run faster but have more noise
- **Time Duration**: Up to 50 years of simulation
  - Longer durations show long-term trends
  - Monthly timesteps (dt = 1/12 year)
- **Progress Tracking**: Real-time progress updates via reactive values

### 2. Memory Management
- **Efficient Data Structures**: Uses appropriate R and Python data types
- **Result Caching**: Stores simulation results in reactive values
- **Cleanup**: Proper memory management for large simulations
- **Lazy Evaluation**: Plots only rendered when tab is viewed

### 3. User Experience
- **Responsive UI**: Non-blocking interface during simulation
- **Progress Indicators**: Status messages and progress percentage
- **Interactive Plots**: Plotly provides zoom, pan, hover interactions
- **Fast Parameter Reset**: Instant return to defaults

## Security and Reliability

### 1. Input Sanitization
- **Parameter Validation**: All inputs validated before use
- **Range Limits**: Prevents invalid parameter values
- **Type Safety**: Ensures correct data types (integers, floats, strings)

### 2. Error Recovery
- **Graceful Failures**: App continues running after errors
- **User Notifications**: Clear error messages via `showNotification()`
- **Fallback Modes**: Mock data when simulation unavailable

### 3. Resource Management
- **Process Isolation**: Python simulations run in separate process space
- **Memory Limits**: Reasonable limits on simulation size
- **Port Management**: Handles port conflicts gracefully

## Deployment Considerations

### 1. Dependencies
- **R Packages**: All listed in `install_dependencies.R`
- **Python Packages**: All listed in `python/requirements.txt`
- **FPsim Package**: Installed in editable mode from parent directory

### 2. Environment Setup
- **Python Virtual Environment**: Isolated Python environment in `../venv/`
- **R Environment**: Standard R package installation
- **Cross-Platform**: Works on Windows, macOS, and Linux

### 3. Configuration
- **Port Configuration**: Configurable server port (default: 3031)
- **Host Binding**: Configurable host address (default: 0.0.0.0)
- **Logging**: Console output for debugging

## Future Enhancements

### 1. Additional Features
- **Scenario Comparison**: Run and compare multiple scenarios side-by-side
- **Intervention Builder**: GUI for creating custom interventions
- **Data Upload**: Allow users to upload custom location data
- **Calibration Interface**: Interactive calibration tools
- **Export Features**: Download results as CSV, Excel, or PDF

### 2. Performance Improvements
- **Parallel Processing**: Run multiple simulations in parallel
- **Caching**: Cache results for repeated simulations
- **Optimization**: Faster result extraction and processing

### 3. User Experience
- **Tutorial Mode**: Guided walkthrough for new users
- **Parameter Presets**: Save and load parameter configurations
- **Collaboration**: Share simulation configurations via URL
- **Mobile Responsive**: Improved mobile device support

## Conclusion

The FPsim Family Planning Shiny Web App represents a sophisticated integration of modern web technologies with advanced epidemiological modeling. The architecture provides:

- **Clean Separation of Concerns**: R handles UI, Python handles simulation
- **Seamless Integration**: Reticulate bridges R and Python smoothly
- **Robust Error Handling**: Graceful degradation and clear error messages
- **Extensible Design**: Easy to add new features and visualizations
- **User-Friendly**: Intuitive interface for complex modeling

The application successfully bridges the gap between complex scientific modeling and user-friendly web interfaces, making advanced family planning modeling accessible to researchers, program managers, and policymakers worldwide.

