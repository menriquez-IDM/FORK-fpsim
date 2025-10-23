# FPsim: Family Planning Simulator - Understanding Guide

## Overview

FPsim is an open-source family planning simulation tool developed by the Institute for Disease Modeling (IDM). It's designed to model complex family planning dynamics in populations, allowing researchers to examine how individual-level changes lead to macro-level outcomes over women's life courses.

## What is FPsim?

FPsim is a **microsimulation model** that tracks individual women through their reproductive lives, modeling:

- **Contraceptive choices** and method switching
- **Pregnancy outcomes** (live births, stillbirths, miscarriages, abortions)
- **Mortality** (maternal, infant, general)
- **Demographic transitions** and population dynamics
- **Educational attainment** and its effects on fertility
- **Socioeconomic factors** (wealth quintiles, urban/rural residence)

## Key Design Principles

### 1. Life-Course Approach
FPsim follows individual women through their entire reproductive lives, capturing:
- Age at sexual debut
- Contraceptive method choices and switching
- Pregnancy and birth outcomes
- Educational progression
- Partnership formation

### 2. Data-Driven Parameters
The model uses real-world data from sources like:
- **Demographic and Health Surveys (DHS)**
- **Performance Monitoring and Accountability (PMA)**
- **UN and World Bank data**
- Country-specific demographic data

### 3. Modular Architecture
FPsim is built on the Starsim framework with several key modules:
- **Sim**: Core simulation engine
- **People**: Individual agent management
- **FPmod**: Family planning events and outcomes
- **Methods**: Contraceptive method definitions
- **Education**: Educational progression
- **Demographics**: Urban/rural, wealth, partnership status

## Core Components

### 1. Simulation Engine (`Sim` class)
The main simulation class that orchestrates the entire model:

```python
import fpsim as fp

# Basic simulation
sim = fp.Sim()
sim.run()

# With custom parameters
sim = fp.Sim(
    n_agents=10000,
    location='kenya',
    start_year=2000,
    end_year=2020
)
sim.run()
```

### 2. People (`People` class)
Represents individual women in the simulation with attributes:
- **Age, sex, fertility status**
- **Contraceptive method use**
- **Pregnancy and birth history**
- **Educational attainment**
- **Socioeconomic status** (wealth quintile, urban/rural)
- **Partnership status**

### 3. Family Planning Module (`FPmod`)
Models reproductive health events:
- **Conception** based on fecundity, contraception, and sexual activity
- **Pregnancy outcomes** (live births, stillbirths, miscarriages, abortions)
- **Maternal and infant mortality**
- **Lactational amenorrhea method (LAM)**
- **Postpartum periods**

### 4. Contraceptive Methods (`Methods`)
Defines available contraceptive methods with:
- **Efficacy rates**
- **Duration of use**
- **Method switching probabilities**
- **Age-specific preferences**

Standard methods include:
- Modern methods: Pill, IUD, Injectables, Implants, Condoms, BTL
- Traditional methods: Withdrawal, Other traditional
- No method

## Key Parameters

### Basic Parameters
- `n_agents`: Population size (default: 1,000)
- `location`: Geographic location (e.g., 'kenya', 'senegal')
- `start_year`/`end_year`: Simulation timeframe
- `rand_seed`: Random seed for reproducibility

### Age Limits
- `method_age`: Minimum age for contraceptive use (default: 15)
- `age_limit_fecundity`: Maximum age for pregnancy (default: 50)
- `max_age`: Maximum age in simulation (default: 99)

### Demographics
- `urban_prop`: Proportion living in urban areas
- `wealth_quintile`: Wealth distribution
- `use_partnership`: Whether to model partnership formation

### Durations (in months)
- `preg_dur_low`/`preg_dur_high`: Pregnancy duration range
- `postpartum_dur`: Postpartum period
- `breastfeeding_dur_mean`/`breastfeeding_dur_sd`: Breastfeeding duration
- `max_lam_dur`: Maximum LAM duration (5 months)

## Usage Examples

### 1. Basic Simulation
```python
import fpsim as fp

# Create and run simulation
sim = fp.Sim(n_agents=5000, location='senegal')
sim.run()

# Plot results
sim.plot()
```

### 2. Custom Parameters
```python
pars = dict(
    n_agents=10000,
    location='kenya',
    start_year=2000,
    end_year=2020,
    exposure_factor=1.0,  # Overall pregnancy probability scale
    use_partnership=True,  # Model partnership formation
)

sim = fp.Sim(pars)
sim.run()
```

### 3. Scenario Analysis
```python
# Create scenarios with different interventions
scens = fp.Scenarios(pars=pars, repeats=5)

# Baseline scenario
scens.add_scen(label='Baseline')

# Intervention scenario
intervention = fp.make_scen(
    label='Increase injectable use',
    year=2025,
    probs=[dict(copy_from='Injectables', init_factor=2.0)]
)
scens.add_scen(intervention)

# Run scenarios
scens.run()
scens.plot()
```

### 4. Calibration
```python
# Run calibration experiment
exp = fp.Experiment()
exp.run()

# View calibration results
df = exp.summarize()
print(df)
```

## Key Results

FPsim tracks numerous outcomes:

### Contraceptive Prevalence
- **mCPR**: Modern contraceptive prevalence rate
- **CPR**: Contraceptive prevalence rate (includes traditional methods)
- **aCPR**: Active contraceptive prevalence rate

### Fertility Outcomes
- **TFR**: Total fertility rate
- **ASFR**: Age-specific fertility rates
- **Birth spacing**: Short birth intervals
- **Age at first birth**

### Pregnancy Outcomes
- **Live births**
- **Stillbirths**
- **Miscarriages**
- **Abortions**

### Mortality
- **Maternal mortality ratio**
- **Infant mortality rate**
- **General mortality trends**

### Method Mix
- **Method usage patterns** over time
- **Method switching** between contraceptive types

## Advanced Features

### 1. Educational Module
Models educational progression and its impact on:
- Contraceptive use
- Fertility preferences
- Method choice

### 2. Empowerment Module
Tracks women's empowerment indicators:
- Educational attainment
- Economic status
- Decision-making autonomy

### 3. Subnational Modeling
Supports modeling at subnational levels with:
- Regional demographic differences
- Varying contraceptive access
- Different cultural contexts

### 4. Novel Method Introduction
Allows testing of new contraceptive methods:
```python
# Add new method
pars.add_method(name='new injectables', eff=0.983)

# Create scenario with new method
scen = fp.make_scen(
    label='Introduce new method',
    year=2030,
    probs=[dict(copy_from='Injectables', init_factor=1.5)]
)
```

## Data Sources and Calibration

FPsim is calibrated to real-world data from:

### Demographic Data
- **Age pyramids** from census data
- **Mortality rates** from vital statistics
- **Fertility rates** from DHS surveys

### Family Planning Data
- **Contraceptive prevalence** from DHS/PMA
- **Method mix** from survey data
- **Unmet need** for family planning

### Educational Data
- **School enrollment** rates
- **Educational attainment** by age
- **Literacy rates**

## Best Practices

### 1. Parameter Validation
- Always validate parameters against known data
- Use appropriate population sizes for your research question
- Consider computational time vs. accuracy trade-offs

### 2. Scenario Design
- Start with baseline scenarios
- Test one intervention at a time
- Use multiple runs for uncertainty quantification

### 3. Results Interpretation
- Compare results to observed data
- Consider confidence intervals from multiple runs
- Validate against external benchmarks

### 4. Model Limitations
- FPsim cannot predict exogenous events (conflicts, pandemics)
- Results depend on input data quality
- Not a replacement for descriptive statistics

## Installation and Setup

```bash
# Clone repository
git clone https://github.com/fpsim/fpsim.git
cd fpsim

# Install
pip install -e .

# Verify installation
python -c "import fpsim as fp; print('FPsim installed successfully')"
```

## Getting Started

1. **Install FPsim** following the instructions above
2. **Run a basic simulation**:
   ```python
   import fpsim as fp
   sim = fp.Sim()
   sim.run()
   sim.plot()
   ```
3. **Explore examples** in the `examples/` directory
4. **Read tutorials** in `docs/tutorials/`
5. **Check documentation** at https://docs.fpsim.org

## Support and Resources

- **Documentation**: https://docs.fpsim.org
- **GitHub Repository**: https://github.com/fpsim/fpsim
- **Examples**: `examples/` directory
- **Tutorials**: `docs/tutorials/` directory
- **Issues**: GitHub Issues for bug reports and feature requests

## Conclusion

FPsim is a powerful tool for family planning research that combines individual-level modeling with population-level outcomes. Its modular design, data-driven parameters, and comprehensive results make it suitable for a wide range of research questions in reproductive health, demography, and public policy.

The model's strength lies in its ability to capture the complexity of reproductive decision-making while remaining computationally tractable for policy analysis and scenario testing.
