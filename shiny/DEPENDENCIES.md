# FPsim Shiny Web App - Dependencies Documentation

This document provides detailed information about all dependencies required for the FPsim Shiny Web App.

## R Dependencies

### Core Shiny Packages

1. **shiny** (>= 1.7.0)
   - Purpose: Core web application framework
   - Functions: UI elements, server logic, reactive programming
   - License: GPL-3
   - Installation: `install.packages("shiny")`

2. **shinydashboard** (>= 0.7.0)
   - Purpose: Dashboard layout and components
   - Functions: Dashboard page structure, boxes, sidebar menu
   - License: GPL-2
   - Installation: `install.packages("shinydashboard")`

3. **shinyWidgets** (>= 0.7.0)
   - Purpose: Extended UI widgets
   - Functions: Additional input controls and components
   - License: GPL-3
   - Installation: `install.packages("shinyWidgets")`

### Visualization Packages

4. **plotly** (>= 4.10.0)
   - Purpose: Interactive plots and visualizations
   - Functions: All charts and graphs in the app
   - Features: Zoom, pan, hover, export
   - License: MIT
   - Installation: `install.packages("plotly")`

5. **ggplot2** (>= 3.3.0)
   - Purpose: Static plotting (if needed)
   - Functions: Additional plotting capabilities
   - License: MIT
   - Installation: `install.packages("ggplot2")`

### Data Manipulation Packages

6. **dplyr** (>= 1.0.0)
   - Purpose: Data manipulation and transformation
   - Functions: Data frame operations, filtering, summarizing
   - License: MIT
   - Installation: `install.packages("dplyr")`

7. **DT** (>= 0.18)
   - Purpose: Interactive data tables
   - Functions: Parameter table display
   - Features: Sorting, filtering, pagination
   - License: GPL-3
   - Installation: `install.packages("DT")`

### Python Integration

8. **reticulate** (>= 1.20)
   - Purpose: R-Python integration
   - Functions: Call Python functions from R, data conversion
   - Critical: Required for FPsim simulation
   - License: Apache-2.0
   - Installation: `install.packages("reticulate")`

### Utility Packages

9. **htmltools** (>= 0.5.0)
   - Purpose: HTML generation and manipulation
   - Functions: Custom HTML in UI
   - License: GPL-2
   - Installation: `install.packages("htmltools")`

10. **jsonlite** (>= 1.7.0)
    - Purpose: JSON encoding/decoding
    - Functions: Data serialization, configuration files
    - License: MIT
    - Installation: `install.packages("jsonlite")`

11. **rstudioapi** (>= 0.13)
    - Purpose: RStudio IDE integration
    - Functions: IDE-specific features (optional)
    - License: MIT
    - Installation: `install.packages("rstudioapi")`

## Python Dependencies

### Core Scientific Computing

1. **numpy** (>= 1.20.0)
   - Purpose: Numerical computing
   - Functions: Array operations, mathematical functions
   - Required by: FPsim, plotting
   - License: BSD-3-Clause
   - Installation: `pip install numpy>=1.20.0`

2. **scipy** (>= 1.7.0)
   - Purpose: Scientific computing
   - Functions: Statistical distributions, optimization
   - Required by: FPsim
   - License: BSD-3-Clause
   - Installation: `pip install scipy`

3. **pandas** (>= 2.0.0)
   - Purpose: Data structures and analysis
   - Functions: DataFrames, time series, data manipulation
   - Required by: FPsim, result processing
   - License: BSD-3-Clause
   - Installation: `pip install pandas>=2.0.0`

### Starsim Framework

4. **starsim** (>= 3.0.0)
   - Purpose: Agent-based modeling framework
   - Functions: Core simulation engine, modules, demographics
   - Required by: FPsim (parent framework)
   - License: MIT
   - Installation: `pip install starsim>=3.0.0`

5. **sciris** (>= 3.1.0)
   - Purpose: Scientific utilities
   - Functions: Object handling, parallelization, file I/O
   - Required by: Starsim, FPsim
   - License: MIT
   - Installation: `pip install sciris>=3.1.0`

### Visualization

6. **plotly** (>= 5.0.0)
   - Purpose: Interactive visualizations (Python-side)
   - Functions: Plot generation in Python (optional)
   - Note: Mainly used on R side, but available in Python
   - License: MIT
   - Installation: `pip install plotly>=5.0.0`

7. **matplotlib** (>= 3.5.0)
   - Purpose: Static plotting (Python-side)
   - Functions: Additional plotting capabilities
   - License: PSF
   - Installation: `pip install matplotlib>=3.5.0`

8. **seaborn** (>= 0.11.0)
   - Purpose: Statistical visualizations
   - Functions: Enhanced plotting (optional)
   - License: BSD-3-Clause
   - Installation: `pip install seaborn`

### Data I/O

9. **openpyxl** (>= 3.0.0)
   - Purpose: Excel file reading/writing
   - Functions: Import/export Excel files
   - Required by: Data loading utilities
   - License: MIT
   - Installation: `pip install openpyxl`

10. **xlsxwriter** (>= 3.0.0)
    - Purpose: Excel file writing
    - Functions: Export results to Excel
    - License: BSD-2-Clause
    - Installation: `pip install xlsxwriter`

### FPsim Package

11. **fpsim** (local installation)
    - Purpose: Family planning simulation model
    - Functions: All simulation logic
    - Installation: `pip install -e ..` (from shiny/ directory)
    - Dependencies: All of the above

## System Requirements

### Operating Systems

- **macOS**: 10.13 (High Sierra) or later
- **Windows**: Windows 10 or later (64-bit)
- **Linux**: Ubuntu 18.04+ or equivalent

### Software Requirements

1. **R** (>= 4.0.0)
   - Download: https://cran.r-project.org/
   - Recommended: R 4.2.0 or later

2. **Python** (>= 3.9)
   - Download: https://www.python.org/
   - Recommended: Python 3.10 or 3.11
   - Note: Python 3.12 may work but is less tested

3. **RStudio** (optional but recommended)
   - Download: https://www.rstudio.com/
   - Version: 2022.02.0 or later

### Hardware Requirements

**Minimum:**
- CPU: Dual-core processor
- RAM: 4 GB
- Disk: 2 GB free space
- Display: 1280x720 resolution

**Recommended:**
- CPU: Quad-core processor or better
- RAM: 8 GB or more
- Disk: 5 GB free space
- Display: 1920x1080 resolution or better

## Installation Methods

### Method 1: Automatic Installation (Recommended)

Use the provided installation scripts:

**macOS/Linux:**
```bash
./start_app.sh
```

**Windows:**
```cmd
start_app.bat
```

These scripts will:
1. Check for R and Python
2. Create Python virtual environment
3. Install all Python dependencies
4. Install FPsim package
5. Install all R packages
6. Start the app

### Method 2: Manual Installation

#### Step 1: Install R Packages
```r
source("install_dependencies.R")
```

#### Step 2: Set Up Python Environment
```bash
# Create virtual environment
cd ..
python3 -m venv venv
source venv/bin/activate  # macOS/Linux
# OR
venv\Scripts\activate.bat  # Windows

# Install Python dependencies
pip install -r shiny/python/requirements.txt

# Install FPsim
pip install -e .
```

#### Step 3: Verify Installation
```r
# In R console
library(shiny)
library(reticulate)
py_config()  # Should show correct Python and packages
```

### Method 3: Using R Only
```r
source("install_all_dependencies.R")
```

This R script will install both R and Python dependencies.

## Dependency Management

### Virtual Environment

**Why use a virtual environment?**
- Isolates Python packages from system installation
- Avoids version conflicts
- Easy to reproduce environment

**Location:** `../venv/` (one level up from shiny/)

### Package Versions

**Minimum versions are specified** to ensure compatibility:
- Use `>=` for minimum version requirements
- Update regularly for security and bug fixes

**Checking versions:**
```r
# R packages
packageVersion("shiny")

# Python packages (from R)
reticulate::py_run_string("import fpsim; print(fpsim.__version__)")
```

## Troubleshooting Dependencies

### R Package Issues

**Problem:** Package installation fails
```r
# Solution 1: Try with dependencies
install.packages("package_name", dependencies = TRUE)

# Solution 2: Update all packages
update.packages(ask = FALSE)

# Solution 3: Install from source
install.packages("package_name", type = "source")
```

**Problem:** Package not found
```r
# Check repository
options(repos = c(CRAN = "https://cran.r-project.org"))
install.packages("package_name")
```

### Python Package Issues

**Problem:** pip install fails
```bash
# Solution 1: Upgrade pip
pip install --upgrade pip

# Solution 2: Use verbose mode
pip install -v package_name

# Solution 3: Install from source
pip install --no-binary :all: package_name
```

**Problem:** Permission denied
```bash
# Use virtual environment (recommended)
python3 -m venv venv
source venv/bin/activate
pip install package_name

# OR use user install (not recommended)
pip install --user package_name
```

### Reticulate Issues

**Problem:** Reticulate can't find Python
```r
# Solution: Specify Python path
library(reticulate)
use_python("/path/to/python", required = TRUE)
```

**Problem:** Wrong Python version
```r
# List available Python
py_discover_config()

# Set specific Python
Sys.setenv(RETICULATE_PYTHON = "/path/to/python")
```

**Problem:** Module not found
```r
# Check Python configuration
py_config()

# Verify package installation
py_run_string("import sys; print(sys.path)")
```

## Version Compatibility Matrix

| R Version | Python Version | Starsim | FPsim | Shiny | Status |
|-----------|----------------|---------|-------|-------|--------|
| 4.0.x     | 3.9            | 3.0.x   | dev   | 1.7.x | ✓      |
| 4.1.x     | 3.9, 3.10      | 3.0.x   | dev   | 1.7.x | ✓      |
| 4.2.x     | 3.9, 3.10, 3.11| 3.0.x   | dev   | 1.7.x | ✓✓     |
| 4.3.x     | 3.10, 3.11     | 3.0.x   | dev   | 1.8.x | ✓✓     |

✓✓ = Recommended, ✓ = Supported, ⚠ = May work with issues

## Updating Dependencies

### Updating R Packages
```r
# Update all packages
update.packages(ask = FALSE)

# Update specific package
install.packages("shiny")
```

### Updating Python Packages
```bash
# Update all packages
pip install --upgrade -r python/requirements.txt

# Update specific package
pip install --upgrade fpsim
```

### Updating FPsim
```bash
cd ..
git pull  # If using git
pip install -e . --upgrade
```

## License Compatibility

All dependencies are compatible with open-source use:
- **MIT License**: Most permissive, allows commercial use
- **BSD License**: Permissive, similar to MIT
- **GPL-2/GPL-3**: Copyleft, requires source distribution
- **Apache 2.0**: Permissive with patent grant

The FPsim Shiny app inherits the most restrictive license (GPL-3) from Shiny.

## Support

For dependency-related issues:
1. Check this documentation
2. Consult R/Python package documentation
3. Check GitHub issues for FPsim
4. Contact: info@idmod.org

