# FPsim Family Planning Shiny Web App

This is a Shiny web application that provides an interactive interface for the FPsim family planning modeling framework.

## Features

- **Interactive Family Planning Simulation**: Run agent-based family planning simulations with customizable parameters
- **Real-time Visualization**: View contraceptive prevalence, total fertility rate, birth rates, and other key metrics
- **Parameter Control**: Adjust demographic parameters, contraceptive efficacy, and intervention settings
- **Multiple Plot Types**: Birth rates, CPR/mCPR trends, method mix, age-specific fertility rates, and more
- **Location-Specific Data**: Run simulations for multiple geographic locations (Senegal, Kenya, Ethiopia, Niger, etc.)
- **Advanced Analytics**: Birth spacing, parity distribution, population pyramids, and pregnancy outcomes

## Installation

### Prerequisites

1. **R and RStudio** (or R command line) - version 4.0 or higher
2. **Python 3.9+** with pip
3. **FPsim** installed in Python environment

### Automatic Installation (Recommended)

#### Option 1: Using Startup Script (Simplest)

**macOS/Linux:**
```bash
cd shiny
./start_app.sh
```

**Windows (PowerShell):**
```powershell
cd shiny
.\start_app.ps1
```

**Windows (Command Prompt):**
```cmd
cd shiny
start_app.bat
```

These scripts will automatically:
- Install all R packages
- Set up Python virtual environment
- Install Python dependencies
- Install FPsim package
- Start the Shiny app

#### Option 2: Using R Installer

```bash
cd shiny
Rscript install_all_dependencies.R
```

This will install all R packages, Python dependencies, and FPsim automatically.

### Manual Installation

#### R Dependencies

Install required R packages:

```r
source("install_dependencies.R")
```

Or manually:
```r
install.packages(c("shiny", "shinydashboard", "plotly", "DT", "reticulate", "dplyr", "ggplot2", "shinyWidgets", "htmltools", "jsonlite", "rstudioapi"))
```

#### Python Dependencies

Install Python dependencies:

```bash
pip install -r python/requirements.txt
```

#### FPsim Installation

Install FPsim in editable mode from the project root:

```bash
cd ..
pip install -e .
cd shiny
```

## Usage

### Running the App

1. **From Command Line** (Recommended):
   ```bash
   cd shiny
   Rscript app.R
   ```
   The app will be available at http://localhost:3031

2. **From RStudio**: Open `app.R` and click "Run App"

3. **From R Console**:
   ```r
   setwd("path/to/shiny")
   source("app.R")
   ```

### Using the Interface

1. **Set Parameters**: Use the sidebar controls to configure simulation parameters
   - Basic parameters: population size, start/end years, location
   - Family planning parameters: exposure factor, maternal mortality factor
   - Contraceptive parameters: efficacy of different methods
   - Advanced options: education module, empowerment connector

2. **Run Simulation**: Click "Run Simulation" to start the model

3. **View Results**: 
   - **Simulation Tab**: Quick preview of results
   - **Results Tab**: Comprehensive visualizations of all indicators
   - **Advanced Analytics Tab**: Detailed analysis of birth spacing, parity, population structure
   - **Parameters Tab**: Review and analyze parameter values

4. **Reset Parameters**: Click "Reset Parameters" to return to default values

## Parameters

### Simulation Parameters
- **Population Size**: Number of agents in the simulation (100-10,000)
- **Start Year**: Beginning of simulation period (1980-2020)
- **End Year**: End of simulation period (1990-2030)
- **Location**: Geographic location with location-specific data

### Family Planning Parameters
- **Exposure Factor**: Overall exposure factor affecting conception probability (0.1-3.0)
- **Maternal Mortality Factor**: Multiplier for maternal mortality rates (0.5-2.0)
- **Primary Infertility**: Rate of primary infertility in population (0-0.2)
- **LAM Efficacy**: Efficacy of lactational amenorrhea method (0.8-1.0)

### Contraceptive Parameters
- **Pill Efficacy**: Effectiveness of oral contraceptive pills (0.5-1.0)
- **IUD Efficacy**: Effectiveness of intrauterine devices (0.5-1.0)
- **Injectable Efficacy**: Effectiveness of injectable contraceptives (0.5-1.0)
- **Implant Efficacy**: Effectiveness of contraceptive implants (0.5-1.0)

### Advanced Parameters
- **Education Module**: Include education effects on contraceptive use
- **Empowerment Module**: Include women's empowerment effects
- **Random Seed**: Seed for random number generation (1-100)

## Output Visualizations

### Main Results
- **Birth Rate**: Crude birth rate over time (per 1000 population)
- **Contraceptive Prevalence Rate (CPR)**: Total and modern CPR trends
- **Total Fertility Rate (TFR)**: Average number of children per woman
- **Method Mix**: Distribution of contraceptive methods in use
- **Age-specific Fertility Rates (ASFR)**: Fertility rates by age group
- **Maternal Mortality Ratio**: Maternal deaths per 100,000 live births
- **Unmet Need**: Percentage with unmet need for family planning

### Advanced Analytics
- **Birth Spacing Distribution**: Histogram of inter-birth intervals
- **Parity Distribution**: Distribution of number of children per woman
- **Contraceptive Switching**: Patterns of method switching
- **Population Pyramid**: Age and sex distribution of population
- **Pregnancy Outcomes**: Live births, stillbirths, and miscarriages
- **Cumulative Births**: Total births over simulation period

## Available Locations

The app supports the following locations with location-specific parameters:
- Senegal
- Kenya
- Ethiopia
- Niger
- Côte d'Ivoire
- Nigeria (Lagos, Kano, Kaduna states)
- Pakistan (Sindh province)

## File Structure

```
shiny/
├── app.R                          # Main Shiny application
├── ui.R                           # User interface definition (full dashboard)
├── ui_simple.R                    # Simplified user interface
├── server.R                       # Server logic and reactive functions
├── README.md                      # This file
├── ARCHITECTURE.md                # Technical architecture documentation
├── DEPENDENCIES.md                # Dependency documentation
├── QUICK_START.md                 # Quick start guide
├── install_dependencies.R         # R package installer
├── install_all_dependencies.R     # Comprehensive installer
├── start_app.sh                   # Startup script (macOS/Linux)
├── start_app.bat                  # Startup script (Windows CMD)
├── start_app.ps1                  # Startup script (Windows PowerShell)
├── .gitignore                     # Git ignore file
└── python/
    ├── fp_simulator.py            # Python backend functions
    └── requirements.txt           # Python dependencies
```

## Troubleshooting

### Common Issues

1. **Python Not Found**: Ensure Python is installed and accessible from R
   - Check Python installation: `python3 --version`
   - Ensure reticulate can find Python: `reticulate::py_config()`

2. **FPsim Import Error**: Verify FPsim is installed in the correct Python environment
   - Check installation: `pip show fpsim`
   - Reinstall if needed: `pip install -e ..`

3. **Port Already in Use**: Another process is using port 3031
   - Kill the process or change the port in `app.R`
   - macOS/Linux: `lsof -ti :3031 | xargs kill -9`
   - Windows: `netstat -ano | findstr :3031` then `taskkill /F /PID <PID>`

4. **Plot Not Displaying**: Check browser console for JavaScript errors
   - Ensure all R packages are up to date
   - Clear browser cache

5. **Simulation Fails**: Verify parameter values are within valid ranges
   - Check error messages in R console
   - Ensure location data is available

### Debug Mode

To run in debug mode:

```r
options(shiny.error = browser)
shiny::runApp(display.mode = "showcase")
```

### Mock Data Mode

If Python/FPsim is not available, the app will run in mock data mode:
- Generates synthetic data for demonstration
- All UI elements remain functional
- Useful for testing interface without full simulation

## Model Details

This application uses the FPsim family planning model, which includes:

- **Agent-based simulation** with individual-level modeling
- **Contraceptive method dynamics** with initiation, switching, and discontinuation
- **Pregnancy and birth processes** including fecundity, exposure, and conception
- **Maternal and infant health outcomes**
- **Demographic processes** including births, deaths, and aging
- **Optional modules** for education and empowerment effects

### Contraceptive Methods

FPsim models the following contraceptive methods:
- None (no method)
- Modern methods: Pills, IUDs, Injectables, Implants, Condoms, Female sterilization (BTL)
- Traditional methods: Withdrawal, Other traditional
- Other modern methods

### Key Indicators

The model tracks standard family planning indicators:
- **CPR**: Contraceptive Prevalence Rate (% of women using any method)
- **mCPR**: Modern Contraceptive Prevalence Rate (% using modern methods)
- **TFR**: Total Fertility Rate (average lifetime births per woman)
- **ASFR**: Age-Specific Fertility Rates
- **Unmet Need**: % of women with unmet need for family planning
- **MMR**: Maternal Mortality Ratio (deaths per 100,000 live births)
- **Birth Rate**: Crude birth rate (births per 1000 population)

## Contact

For questions or support:
- FPsim GitHub: https://github.com/fpsim/fpsim
- Documentation: https://docs.fpsim.org
- Email: info@idmod.org

## License

This application is provided under the MIT License, consistent with the FPsim framework.

## Citation

If you use this application or FPsim in your research, please cite:

[FPsim citation to be added]

## Version

FPsim Shiny Web Interface v1.0  
Built with Starsim, R Shiny, and Python

Last updated: November 2025

