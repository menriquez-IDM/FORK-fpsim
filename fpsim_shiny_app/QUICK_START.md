# FPsim Shiny App - Quick Start Guide

## Prerequisites Check

Before starting, ensure you have:
- ✅ R (version 4.0+) installed
- ✅ Python (version 3.8+) installed  
- ✅ FPsim Python package installed in virtual environment
- ✅ All R packages installed

## Step 1: Install R Packages

From R console or RStudio:

```r
# Navigate to the app directory
setwd("/Users/mine/fpgit/FORK-fpsim/fpsim_shiny_app")

# Run the installation script
source("install_packages.R")
```

## Step 2: Verify Setup

Run the test script to verify everything is configured correctly:

```r
# From the app directory
source("test_setup.R")
```

You should see:
```
✓ ALL TESTS PASSED
The Shiny app is ready to run!
```

## Step 3: Launch the App

### Option A: From RStudio
1. Open `app.R` in RStudio
2. Click the "Run App" button in the top-right
3. The app will open in a new window or browser

### Option B: From R Console
```r
setwd("/Users/mine/fpgit/FORK-fpsim/fpsim_shiny_app")
shiny::runApp()
```

### Option C: From Terminal
```bash
cd /Users/mine/fpgit/FORK-fpsim/fpsim_shiny_app
R -e "shiny::runApp()"
```

## Step 4: Run Your First Simulation

1. **Navigate to the Dashboard** tab
2. Click **"Run Example Simulation"** to see a quick demo
3. Go to the **Results** tab to view outputs
4. Try the **Configure** tab to customize parameters

## Common Tasks

### Run a Custom Simulation

1. Go to **Configure** tab
2. Select a **Location** (e.g., Kenya)
3. Set **Number of Agents** (100-50,000)
4. Choose **Simulation Period** years
5. Adjust **Exposure Factor** if needed
6. Click **"Run Simulation"**
7. View results in **Results** tab

### Export Data

From the **Results** tab:
- Click **"Download CSV"** for Excel/spreadsheet analysis
- Click **"Download JSON"** for programmatic use

### Change Location

The app supports:
- **National:** Kenya, Senegal, Ethiopia
- **Regional (Ethiopia):** 11 regions including Addis Ababa, Oromia, SNNPR, etc.

## Troubleshooting

### FPsim Not Loading

**Error:** `Failed to load FPsim`

**Solution:**
```bash
cd /Users/mine/fpgit/FORK-fpsim
source venv/bin/activate
pip install -e .
```

### Missing R Packages

**Error:** `there is no package called 'X'`

**Solution:**
```r
install.packages("X")
```

### Simulation Timeout

**Issue:** Simulation takes too long

**Solution:**
- Reduce number of agents (try 1,000-5,000)
- Shorten simulation period
- Check system resources

### Port Already in Use

**Error:** `address already in use`

**Solution:**
```r
# Specify a different port
shiny::runApp(port = 8080)
```

## Performance Tips

1. **Start small:** Use 1,000-5,000 agents for testing
2. **Limit time range:** Shorter periods run faster
3. **Close unused apps:** Free up system memory
4. **Use modern hardware:** M1/M2 Macs or recent Intel CPUs work best

## Expected Runtime

| Agents | Years | Estimated Time |
|--------|-------|----------------|
| 500    | 5     | < 1 second     |
| 1,000  | 10    | 1-2 seconds    |
| 5,000  | 30    | 4-6 seconds    |
| 10,000 | 50    | 15-20 seconds  |
| 50,000 | 50    | 2-3 minutes    |

## App Features (Phase 1)

### ✅ Implemented
- Basic simulation configuration
- Location selector (national + regional)
- Parameter sliders (agents, years, exposure)
- Real-time simulation execution
- Population and death visualizations
- Results export (CSV/JSON)
- Responsive UI with modern design

### 🔄 Coming Soon (Phase 2+)
- Multiple simulation comparison
- Intervention builder
- Advanced contraceptive method analysis
- Geospatial visualizations
- Calibration interface
- PDF report generation

## Keyboard Shortcuts

- **Ctrl/Cmd + R:** Run simulation (when focused on Run button)
- **Ctrl/Cmd + K:** Reset parameters

## Support

If you encounter issues:

1. Check this guide first
2. Run `test_setup.R` to diagnose problems
3. Review error messages in R console
4. Check Python environment is activated
5. Verify FPsim version compatibility

## Next Steps

Once comfortable with basics:
1. Explore different locations
2. Try various parameter combinations
3. Export and analyze results
4. Read the full [README.md](README.md) for advanced features
5. Check [implementation plan](SHINY_APP_IMPLEMENTATION_PLAN.md) for roadmap

## Resources

- **FPsim Documentation:** https://docs.fpsim.org
- **GitHub Issues:** https://github.com/fpsim/fpsim/issues
- **Tutorial Videos:** Coming soon
- **API Documentation:** See `R/fpsim_interface.R` for function details

---

**Version:** 0.1.0 (Phase 1)  
**Last Updated:** October 10, 2025  
**Status:** Production Ready ✅

