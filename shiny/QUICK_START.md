# FPsim Shiny Web App - Quick Start Guide

Get up and running with the FPsim Shiny Web App in 5 minutes!

## Prerequisites

Before you start, make sure you have:
- ✅ **R** (version 4.0 or higher) - [Download here](https://cran.r-project.org/)
- ✅ **Python** (version 3.9 or higher) - [Download here](https://www.python.org/)
- ✅ **Terminal/Command Prompt** access

## Quick Start (Fastest Method)

### macOS / Linux

Open Terminal and run:

```bash
cd path/to/FORK-fpsim/shiny
./start_app.sh
```

Wait 2-5 minutes for installation, then open your browser to:
**http://localhost:3031**

### Windows (PowerShell)

Open PowerShell and run:

```powershell
cd path\to\FORK-fpsim\shiny
.\start_app.ps1
```

Wait 2-5 minutes for installation, then open your browser to:
**http://localhost:3031**

### Windows (Command Prompt)

Open Command Prompt and run:

```cmd
cd path\to\FORK-fpsim\shiny
start_app.bat
```

Wait 2-5 minutes for installation, then open your browser to:
**http://localhost:3031**

## What the Script Does

The startup script automatically:
1. ✓ Checks for R and Python
2. ✓ Creates Python virtual environment
3. ✓ Installs Python packages (numpy, pandas, starsim, etc.)
4. ✓ Installs FPsim package
5. ✓ Installs R packages (shiny, plotly, reticulate, etc.)
6. ✓ Starts the Shiny app

**Note:** First-time setup takes 2-5 minutes. Subsequent starts are instant!

## Using the App

### 1. Set Your Parameters

Use the **left sidebar** to configure:
- **Population Size**: Number of people to simulate (e.g., 1000)
- **Time Period**: Start year (e.g., 2000) and end year (e.g., 2020)
- **Location**: Choose a country (Senegal, Kenya, Ethiopia, etc.)
- **Exposure Factor**: Affects conception probability (1.0 = baseline)

### 2. Run the Simulation

Click the big blue **"Run Simulation"** button in the sidebar.

Wait 10-30 seconds while the simulation runs.

### 3. View Results

Navigate through the tabs to see:
- **Simulation**: Quick preview and status
- **Results**: Birth rates, contraceptive use, fertility rates
- **Advanced Analytics**: Detailed analysis and distributions
- **Parameters**: Review all parameter values

### 4. Explore Visualizations

All plots are interactive! You can:
- 🖱️ **Hover** to see exact values
- 🔍 **Zoom** by clicking and dragging
- 📏 **Pan** by holding shift and dragging
- 💾 **Download** by clicking the camera icon

## Common Use Cases

### Run a Basic Simulation

1. Keep all default parameters
2. Click "Run Simulation"
3. View results in the "Results" tab

### Compare Different Locations

1. Run simulation for Senegal (default)
2. Note the results
3. Click "Reset Parameters"
4. Change location to Kenya
5. Run simulation again
6. Compare results

### Test Intervention Impact

1. Run baseline simulation (default parameters)
2. Note the contraceptive prevalence rate (CPR)
3. Click "Reset Parameters"
4. Increase contraceptive efficacy values (e.g., pill_efficacy to 0.98)
5. Run simulation
6. Compare CPR between runs

### Explore Population Dynamics

1. Run simulation with default parameters
2. Go to "Advanced Analytics" tab
3. View:
   - Birth spacing patterns
   - Population pyramid
   - Parity distribution

## Tips & Tricks

### 💡 Faster Simulations

- Use **smaller population sizes** (500-1000) for quick tests
- Use **shorter time periods** (10-15 years) for exploration
- Larger populations (5000+) give more stable results

### 💡 Better Visualizations

- **Maximize your browser window** for better viewing
- Use **full-screen mode** (F11) for presentations
- **Hover over plots** to see detailed information

### 💡 Parameter Experimentation

- Use **"Reset Parameters"** to quickly return to defaults
- Start with small changes to see their effects
- **Document your parameter changes** for reproducibility

### 💡 Saving Results

- Use the **camera icon** on plots to download as PNG
- Take **screenshots** of interesting results
- **Record your parameters** in the Parameters tab

## Troubleshooting

### App Won't Start

**Problem:** Error message about R or Python not found

**Solution:**
- Make sure R is installed: Open R and check version
- Make sure Python is installed: Run `python --version` in terminal
- Restart your terminal and try again

### Port Already in Use

**Problem:** Error about port 3031 being in use

**Solution:**
```bash
# macOS/Linux: Kill process on port 3031
lsof -ti :3031 | xargs kill -9

# Windows PowerShell: Kill process on port 3031
Get-Process -Id (Get-NetTCPConnection -LocalPort 3031).OwningProcess | Stop-Process -Force
```

### Python Import Error

**Problem:** Error about missing Python packages

**Solution:**
```bash
cd ..
source venv/bin/activate  # macOS/Linux
# OR
venv\Scripts\activate.bat  # Windows

pip install -r shiny/python/requirements.txt
pip install -e .
```

### R Package Error

**Problem:** Error about missing R packages

**Solution:**
```r
# In R console
source("install_dependencies.R")
```

### Simulation Fails

**Problem:** Error when running simulation

**Solutions:**
1. Check parameter values are reasonable
2. Try with default parameters (click "Reset Parameters")
3. Check R console for detailed error messages
4. Restart the app

## Advanced Options

### Custom Port

Edit `app.R` line 31:
```r
# Change from:
shinyApp(ui = ui, server = server, options = list(port = 3031, host = "0.0.0.0"))

# To:
shinyApp(ui = ui, server = server, options = list(port = 8080, host = "0.0.0.0"))
```

### Use Simple UI

Edit `app.R` to use the simplified interface:
```r
# Change from:
source("ui.R")

# To:
source("ui_simple.R")
```

### Run Without Python (Mock Data)

The app automatically falls back to mock data if Python is unavailable.
This lets you explore the interface without running real simulations.

## Next Steps

### Learn More

- 📖 Read **README.md** for detailed documentation
- 🏗️ Read **ARCHITECTURE.md** for technical details
- 📦 Read **DEPENDENCIES.md** for dependency information

### Customize

- Modify **ui.R** to change the interface
- Modify **server.R** to add new plots or analyses
- Modify **python/fp_simulator.py** to change simulation logic

### Get Help

- 🐛 Report issues on GitHub
- 📧 Email: info@idmod.org
- 📚 FPsim documentation: [Coming soon]

## Example Workflows

### Workflow 1: Explore a New Location

```
1. Select location: Ethiopia
2. Run simulation (default parameters)
3. Note: TFR = 4.5, CPR = 35%
4. Compare with Senegal (TFR = 4.0, CPR = 25%)
5. Understand differences in fertility dynamics
```

### Workflow 2: Test Contraceptive Improvement

```
1. Baseline: Run with default efficacy values
2. Note: Final CPR = 40%
3. Reset parameters
4. Increase all modern method efficacy by 0.05
5. Run simulation
6. Note: Final CPR = 48%
7. Conclusion: 5% efficacy improvement → 8% CPR increase
```

### Workflow 3: Policy Impact Assessment

```
1. Run baseline (2000-2020)
2. Note maternal mortality trend
3. Reset parameters
4. Increase exposure factor to 1.5 (better access)
5. Run simulation
6. Compare maternal mortality reduction
7. Estimate lives saved
```

## Keyboard Shortcuts

When app is running:
- **Ctrl+C** (Terminal): Stop the app
- **F5** (Browser): Refresh the page
- **F11** (Browser): Full screen mode
- **Ctrl+Plus/Minus** (Browser): Zoom in/out

## Best Practices

1. **Start Simple**: Use default parameters first
2. **Change One Thing**: Vary one parameter at a time
3. **Document**: Record your parameters and findings
4. **Validate**: Compare results with known data when possible
5. **Share**: Export plots and share with colleagues

## Video Tutorial

[Coming soon: Link to video walkthrough]

## FAQ

**Q: How long does a simulation take?**
A: 10-30 seconds for typical parameters (1000 agents, 20 years)

**Q: Can I run multiple simulations simultaneously?**
A: No, run them sequentially. Future versions may support this.

**Q: Can I save my parameter configurations?**
A: Not yet. Manually record parameters or take screenshots.

**Q: Is there a limit on population size?**
A: Technically no, but >10,000 agents may be slow. Recommended: 1000-5000.

**Q: Can I use my own location data?**
A: Not through the web interface. Use FPsim directly in Python for custom locations.

## Success!

You're now ready to use the FPsim Shiny Web App! 🎉

Have fun exploring family planning dynamics!

