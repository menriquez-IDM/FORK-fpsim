# FPsim Shiny App - Intervention Analysis Guide

## Overview

The FPsim Shiny App now includes a powerful **Intervention Analysis** feature that allows you to:
- Add new contraceptive methods to simulations
- Compare baseline vs. intervention scenarios
- Visualize intervention impacts with professional plots
- Analyze key metrics like CPR, mCPR, births averted, and method adoption

This feature replicates the functionality from `examples/example_add_new_method.py` directly in the web interface.

## How to Use

### 1. Enable Method Intervention

In the sidebar under **"Method Intervention (Optional)"**:
1. Check **"Enable New Method Intervention"**
2. Configure your new method parameters:

#### New Method Configuration

| Parameter | Description | Example |
|-----------|-------------|---------|
| **Method Name** | Internal identifier (lowercase) | `my_new_method` |
| **Method Label** | Display name (uppercase) | `MY-NEW-METHOD` |
| **Method Efficacy** | Contraceptive efficacy (0-1) | `0.995` (99.5%) |
| **Duration (months)** | How long users stay on method | `12` months |
| **Intervention Year** | When method is introduced | `2010` |
| **Copy Matrix From** | Base switching patterns on | `Injectables` |
| **Initial Share** | Staying probability (0-1) | `0.40` (40%) |

### 2. Run the Simulation

1. Set your other simulation parameters (population, years, location)
2. Click **"Run Simulation"**
3. Wait for both baseline and intervention simulations to complete

### 3. View Results

Navigate to the **"Intervention Analysis"** tab to:

#### Choose Visualization Type

Select from the dropdown menu:

1. **Summary Figure (Comprehensive)** - Multi-panel overview showing:
   - New method adoption over time
   - Injectable & new methods trends
   - Total injectable share increase
   - Method substitution effects
   - Top methods ranking
   - All methods comparison

2. **Injectable Methods Comparison** - Detailed view of:
   - Individual injectable methods trends
   - Total injectable share (baseline vs. intervention)
   - Percentage point increase

3. **Method Mix Evolution** - Stacked area chart showing:
   - How method mix changes over time
   - When new method appears
   - Overall contraceptive landscape

4. **New Method Adoption** - Focused view on:
   - New method uptake over time
   - Final adoption rate
   - Number of users

5. **Method Comparison Bar Chart** - Side-by-side bars comparing:
   - Final usage of each method
   - Baseline vs. intervention
   - New method highlighted

6. **CPR Comparison** - Dual panel showing:
   - Modern CPR (mCPR) trends
   - Total CPR trends
   - Impact of intervention

7. **Births Comparison** - Analysis of:
   - Monthly births over time
   - Cumulative births after intervention
   - Births averted
   - Percent reduction

#### View Statistics

Below the plot, see detailed statistics including:
- **Final Prevalence Rates**: mCPR and CPR changes
- **Births After Intervention**: Total baseline births, intervention births, births averted, percent reduction
- **New Method Adoption**: Final adoption rate and number of users

## Example Scenarios

### Scenario 1: Adding a Self-Injectable (SC-DMPA)

```
Method Name: sc_dmpa
Method Label: SC-DMPA
Efficacy: 0.96
Duration: 6 months
Intervention Year: 2010
Copy From: Injectables
Initial Share: 0.25
```

**Expected Impact**: Increased injectable use, potential method switching from pills/condoms

### Scenario 2: Adding a Contraceptive Ring

```
Method Name: ring
Method Label: Contraceptive Ring
Efficacy: 0.93
Duration: 18 months
Intervention Year: 2015
Copy From: Pills
Initial Share: 0.20
```

**Expected Impact**: New short-acting option, may draw from pill users

### Scenario 3: High-Efficacy Long-Acting Method

```
Method Name: new_implant
Method Label: NEW-IMPLANT
Efficacy: 0.999
Duration: 36 months
Intervention Year: 2012
Copy From: Implants
Initial Share: 0.50
```

**Expected Impact**: High adoption, significant births averted, mCPR increase

## Tips for Analysis

### Choosing Copy-From Method
- **Injectables**: For methods requiring provider visits (e.g., injections)
- **Pills**: For user-controlled, short-acting methods
- **IUD/Implants**: For long-acting, provider-dependent methods
- **Condoms**: For barrier methods

### Interpreting Initial Share
- **Low (0.1-0.3)**: Conservative introduction, gradual adoption
- **Medium (0.3-0.5)**: Moderate program, balanced uptake
- **High (0.5-0.8)**: Aggressive program, rapid uptake

### Key Metrics to Watch
1. **mCPR Increase**: Primary indicator of program success
2. **Births Averted**: Public health impact measure
3. **Method Mix Changes**: Which methods gained/lost share
4. **New Method Adoption**: Final uptake rate

## Technical Details

### How It Works

1. **Baseline Simulation**: Run without the new method
2. **Intervention Simulation**: Run with new method added at intervention year
3. **Comparison**: Calculate differences and generate visualizations
4. **Plotting**: Use matplotlib-based functions from `plots.py`

### Files Involved

- `shiny/python/fp_simulator_intervention.py` - Intervention logic
- `shiny/python/plots.py` - Plotting functions (copied from examples)
- `shiny/ui.R` - UI elements for intervention parameters
- `shiny/server.R` - Server logic for intervention analysis

### Performance Notes

- Running TWO simulations takes approximately 2x as long
- Larger populations increase computation time
- Plot generation adds ~5-10 seconds

## Troubleshooting

### No plots appearing?
- Ensure intervention is enabled in sidebar
- Check that simulation completed successfully
- Look for error messages in "Intervention Statistics" panel

### Python errors?
- Verify Python dependencies are installed: `matplotlib`, `seaborn`, `fpsim`
- Run `Rscript install_all_dependencies.R` to reinstall

### Plots look strange?
- Check parameter ranges (efficacy 0-1, duration > 0, valid year)
- Ensure intervention year is between start_year and end_year
- Try different plot types to see different perspectives

## Related Resources

- **Example Script**: `examples/example_add_new_method.py`
- **Plotting Module**: `examples/plots.py`
- **FPsim Documentation**: [https://docs.idmod.org/projects/fpsim](https://docs.idmod.org/projects/fpsim)

## Future Enhancements

Potential additions:
- Multiple interventions at once (like example with SC-DMPA + Ring)
- Scenario comparison (3+ scenarios side-by-side)
- Download plots as PNG/PDF
- Export statistics as CSV
- Interactive plotly versions of matplotlib plots

---

**Questions or Issues?** Open an issue on the FPsim GitHub repository.

