# FPsim Interactive Shiny Application

An interactive web application for running and visualizing FPsim family planning simulations.

## Overview

This Shiny app provides a user-friendly interface to:
- Configure and run FPsim simulations
- Visualize population dynamics, contraceptive prevalence, and fertility trends
- Compare scenarios and interventions
- Export results for further analysis

**Current Version:** 0.1.0 (Phase 1 - Foundation)

## Features (Phase 1)

### Implemented
- ✅ Basic simulation configuration (location, agents, time period)
- ✅ Single simulation execution
- ✅ Real-time results visualization (population, deaths)
- ✅ Location selector (Kenya, Senegal, Ethiopia + 11 regions)
- ✅ Parameter sliders with validation
- ✅ Results export (CSV, JSON)
- ✅ Modern, responsive UI with bslib

### Coming Soon (Phase 2+)
- 🔄 Multiple simulations and comparison
- 🔄 Intervention builder
- 🔄 Advanced contraceptive method analysis
- 🔄 Geospatial visualizations
- 🔄 Calibration interface
- 🔄 Downloadable reports (PDF, HTML)

## Installation

### Prerequisites

1. **R** (version 4.0 or higher)
2. **Python** (version 3.8 or higher)
3. **FPsim** Python package (installed in virtual environment)

### R Packages

Install required R packages:

```r
install.packages(c(
  "shiny",
  "bslib",
  "reticulate",
  "plotly",
  "DT",
  "shinyjs",
  "jsonlite"
))
```

### Python Environment

Ensure FPsim is installed in the parent directory's virtual environment:

```bash
cd /Users/mine/fpgit/FORK-fpsim
source venv/bin/activate
pip install -e .
```

The app will automatically detect and use this virtual environment.

## Running the App

### Local Development

```r
# From R console or RStudio
setwd("/Users/mine/fpgit/FORK-fpsim/fpsim_shiny_app")
shiny::runApp()
```

Or from terminal:

```bash
cd /Users/mine/fpgit/FORK-fpsim/fpsim_shiny_app
R -e "shiny::runApp()"
```

The app will open in your default browser at `http://127.0.0.1:XXXX`

### Production Deployment

See `DEPLOYMENT.md` (coming soon) for instructions on deploying to:
- RStudio Connect
- Shiny Server
- shinyapps.io
- AWS/cloud infrastructure

## Project Structure

```
fpsim_shiny_app/
├── app.R                 # Main application file
├── global.R              # Global setup, Python/FPsim initialization
├── R/
│   ├── fpsim_interface.R # R-Python bridge functions
│   └── utils.R           # Utility functions
├── modules/              # (Future) Shiny modules
├── www/
│   ├── css/
│   │   └── custom.css    # Custom styles
│   ├── js/
│   │   └── custom.js     # Custom JavaScript
│   └── images/           # Logo, icons, etc.
├── data/                 # (Future) Cached location data
├── reports/              # (Future) Report templates
├── tests/                # (Future) Unit tests
└── README.md             # This file
```

## Usage Guide

### Quick Start

1. **Launch the app** and navigate to the **Dashboard** tab
2. Click **"Run Example Simulation"** to see a demo
3. View results in the **Results** tab

### Custom Simulation

1. Go to the **Configure** tab
2. Select a **Location** (e.g., Kenya, Senegal, or Ethiopia region)
3. Set **Number of Agents** (100 - 50,000)
4. Choose **Simulation Period** (years)
5. Adjust **Exposure Factor** if needed (default: 1.0)
6. Click **"Run Simulation"**
7. View results in the **Results** tab

### Exporting Data

From the **Results** tab:
- Click **"Download CSV"** for spreadsheet-friendly format
- Click **"Download JSON"** for programmatic access

## Configuration

### Performance Settings

Edit `global.R` to adjust performance limits:

```r
APP_CONFIG <- list(
  max_agents = 50000,      # Maximum agents per simulation
  max_years = 90,          # Maximum simulation duration
  default_agents = 5000,   # Default agent count
  # ...
)
```

### Python Environment

The app automatically detects the virtual environment at:
```
/Users/mine/fpgit/FORK-fpsim/venv
```

To use a different environment, edit `global.R`:

```r
venv_path <- "/path/to/your/venv"
use_virtualenv(venv_path, required = TRUE)
```

## Troubleshooting

### FPsim Not Loading

**Error:** `Failed to load FPsim: ModuleNotFoundError`

**Solution:**
1. Ensure Python virtual environment is activated
2. Install FPsim: `pip install -e .` (from repo root)
3. Check `global.R` for correct venv path

### Simulation Timeout

**Error:** Simulation appears to hang

**Solution:**
- Reduce number of agents
- Shorten simulation period
- Check R console for Python errors

### Plot Not Displaying

**Error:** Blank visualization area

**Solution:**
- Check browser console for JavaScript errors
- Ensure `plotly` package is installed
- Try refreshing the page

## Development

### Adding New Features

1. Create new R functions in `R/` directory
2. Update `app.R` to integrate new UI/server logic
3. Test thoroughly with various parameter combinations
4. Update this README with new features

### Code Style

- R: Follow [Tidyverse Style Guide](https://style.tidyverse.org/)
- Python: PEP 8
- JavaScript: ES6+ with semicolons

### Testing

(Coming in Phase 2)

```r
# Run tests
shiny::testApp("tests/")
```

## Roadmap

### Phase 1: Foundation (✅ Current)
- Basic simulation execution
- Single location, basic parameters
- Simple visualizations
- CSV/JSON export

### Phase 2: Enhanced Visualization (Next)
- Multiple simulations with comparison
- Advanced plotly charts (CPR, TFR, ASFR)
- Wealth quintile breakdown plots
- Method mix over time

### Phase 3: Interventions
- Intervention builder UI
- Scenario comparison
- What-if analysis tools

### Phase 4: Geospatial
- Interactive maps (Leaflet)
- Regional comparisons
- Choropleth visualizations

### Phase 5: Advanced Features
- Calibration interface
- Custom parameter files
- Batch simulation runner
- PDF report generation

### Phase 6: Production
- Performance optimization
- Cloud deployment
- User authentication
- Database integration

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request with clear description

## License

Same as FPsim main package (see parent LICENSE file)

## Support

- 📖 **Documentation:** [https://docs.fpsim.org](https://docs.fpsim.org)
- 🐛 **Issues:** [GitHub Issues](https://github.com/fpsim/fpsim/issues)
- 💬 **Discussions:** [GitHub Discussions](https://github.com/fpsim/fpsim/discussions)

## Credits

**Developed by:** Institute for Disease Modeling  
**FPsim Team:** See main repository contributors  
**Shiny App:** Phase 1 Implementation (October 2025)

---

**Version:** 0.1.0  
**Last Updated:** October 10, 2025  
**Status:** Phase 1 - Foundation Complete

