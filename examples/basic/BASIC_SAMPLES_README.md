# FPsim Basic Samples

This directory contains basic sample scripts to help you get started with FPsim quickly.

## Available Samples

### 1. Python Script (`basic_sample.py`)
A comprehensive Python script that demonstrates:
- Simple simulation with default parameters
- Custom simulation with specific parameters  
- Multiple location examples
- Basic plotting and analysis
- Experiment framework usage

**Run it:**
```bash
python basic_sample.py
```

### 2. R Script (`basic_sample.R`)
An R version of the basic sample for R users:
- Uses `reticulate` to call Python FPsim functions
- Demonstrates the same functionality as the Python version
- Includes R-specific plotting with `ggplot2`

**Run it:**
```r
Rscript basic_sample.R
```

### 3. Jupyter Notebook (`basic_sample.ipynb`)
An interactive notebook version:
- Step-by-step execution
- Inline plots and results
- Perfect for learning and experimentation

**Run it:**
```bash
jupyter notebook basic_sample.ipynb
```

## Quick Start

1. **Choose your preferred format** (Python script, R script, or Jupyter notebook)
2. **Run the sample** to see FPsim in action
3. **Modify parameters** to experiment with different settings
4. **Explore the examples/** directory for more advanced usage

## What You'll Learn

- How to create and run FPsim simulations
- How to customize parameters (location, population size, time period)
- How to access and interpret simulation results
- How to create basic plots and visualizations
- How to use the experiment framework for calibration

## Available Locations

- `kenya` - Kenya (national level)
- `senegal` - Senegal (national level)  
- `ethiopia` - Ethiopia (national level)
- Regional locations available for Ethiopia (see `fpsim/locations/ethiopia/regions/`)

## Key Parameters

- `location`: Geographic location for the simulation
- `n_agents`: Number of individuals in the population
- `start_year`: Beginning of simulation period
- `end_year`: End of simulation period
- `exposure_factor`: Overall scale factor on pregnancy probability

## Next Steps

After running the basic samples:

1. **Explore examples/**: More advanced usage patterns
2. **Check docs/tutorials/**: Detailed tutorials and guides
3. **Try the Shiny app**: Interactive web interface (`fpsim_shiny_app/`)
4. **Read the documentation**: Comprehensive guides in `docs/`

## Troubleshooting

- **Import errors**: Make sure FPsim is properly installed
- **Plotting issues**: May need display/GUI setup for interactive plots
- **Memory issues**: Reduce `n_agents` for smaller populations
- **Slow execution**: Use smaller populations or shorter time periods for testing

## Support

- Check the main README.md for installation instructions
- Review the documentation in `docs/`
- Look at examples in `examples/` directory
- Check the Shiny app documentation in `fpsim_shiny_app/`
