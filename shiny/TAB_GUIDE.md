# FPsim Shiny App - Tab Guide

## 📊 Understanding the Tab Structure

The FPsim Shiny app now has **separate tabs** for different types of analysis, making it easier to visualize and understand your simulation results.

---

## 🧭 Tab Overview

### 1. **Overview** 📈
Quick summary of simulation results with key metrics:
- Population statistics
- Contraceptive prevalence rates (CPR, mCPR)
- Unmet need
- Method mix distribution
- Birth statistics

**Best for:** Getting a high-level view of your simulation.

---

### 2. **New Method Analysis** 🔬 (Flask Icon)
Specialized visualizations for **"Add New Method"** interventions:
- Summary figures showing new method adoption
- Injectable methods comparison
- Method mix evolution with new methods highlighted
- New method adoption curves
- CPR and births comparisons

**Best for:** 
- Analyzing the impact of introducing a **new contraceptive method**
- Understanding how a new method is adopted over time
- Comparing scenarios with and without the new method

**Works with:**
- "Add New Method" intervention type only

---

### 3. **Method Updates** 🔧 (Wrench Icon) **NEW!**
Comprehensive visualizations for **standard interventions**:

#### Available Plots:
1. **Method Mix Comparison** - Side-by-side bar chart showing baseline vs intervention method distribution
2. **CPR Trends** - Line chart showing Contraceptive Prevalence Rate over time for both scenarios
3. **Births Comparison** - Line chart comparing births over time
4. **Final Method Distribution** - Horizontal bar chart showing percentage point changes per method
5. **Impact Summary** - Text statistics with detailed numbers

**Best for:**
- Analyzing changes to **existing methods**
- Understanding how updating method parameters affects outcomes
- Comparing multiple intervention effects

**Works with:**
- "Update Method (Multiple Parameters)"
- "Change Efficacy Only"
- "Change Duration Only"
- "Change Method Mix Only"
- "Scale Switching Matrix"

**Key Features:**
- All plots compare **Baseline** (blue) vs **With Interventions** (magenta/red)
- Green bars = increase in usage, Red bars = decrease in usage
- Statistics show births averted, CPR changes, and mCPR changes

---

### 4. **Time Series** 📉
Detailed time-based plots:
- CPR over time
- mCPR over time
- Unmet need trends
- Method usage trends

**Best for:** Understanding trends and patterns over the simulation period.

---

### 5. **Population Pyramid** 👥
Interactive age-sex population pyramid showing demographic structure.

**Best for:** Understanding population composition by age and sex.

---

### 6. **Parameters** ⚙️
View all current simulation settings including:
- Location and time period
- Population size
- Birth and death rates
- Method parameters
- Intervention details (if enabled)

**Best for:** Reviewing and verifying your simulation configuration.

---

## 🎯 How to Use

### For New Method Interventions:
1. Enable interventions in the sidebar
2. Select **"Add New Method"** as intervention type
3. Configure the new method parameters
4. Add the intervention
5. Run simulation
6. View results in **"New Method Analysis"** tab

### For Standard Method Updates:
1. Enable interventions in the sidebar
2. Select any of:
   - **"Update Method"** (multiple parameters at once)
   - **"Change Efficacy Only"**
   - **"Change Duration Only"**
   - **"Change Method Mix Only"**
   - **"Scale Switching Matrix"**
3. Configure parameters for the intervention
4. Add the intervention (can add multiple!)
5. Run simulation
6. View results in **"Method Updates"** tab

---

## 💡 Tips

- **Multiple Interventions:** You can add multiple interventions before running. They will all be applied in the specified years.

- **Comparing Results:** The "Method Updates" tab always shows baseline vs intervention, making it easy to see the impact of your changes.

- **Tab Navigation:** Each tab updates automatically when you run a new simulation. No need to refresh!

- **Intervention Types:** 
  - Use **"New Method Analysis"** tab when adding a brand new contraceptive method
  - Use **"Method Updates"** tab for all other intervention types

---

## 🔍 Understanding the Plots

### Method Mix Comparison (Bar Chart)
- **X-axis:** Contraceptive methods
- **Y-axis:** Percentage of users
- **Blue bars:** Baseline scenario
- **Magenta bars:** With interventions
- **Interpretation:** Taller intervention bars = method usage increased

### CPR Trends (Line Chart)
- **X-axis:** Years
- **Y-axis:** CPR (%)
- **Blue line:** Baseline CPR over time
- **Magenta line:** CPR with interventions
- **Interpretation:** Gap between lines shows intervention impact

### Final Method Distribution (Horizontal Bar Chart)
- **X-axis:** Percentage point change
- **Y-axis:** Methods
- **Green bars:** Method usage increased
- **Red bars:** Method usage decreased
- **Interpretation:** Longer bars = bigger impact

---

## 📚 Related Documentation

- `MULTI_INTERVENTION_GUIDE.md` - How to use multiple interventions
- `ALL_METHODS_GUIDE.md` - List of all 9 contraceptive methods
- `INTERVENTION_GUIDE.md` - Detailed intervention parameter guide
- `QUICK_START.md` - Getting started with the app

---

**Last Updated:** November 17, 2025

