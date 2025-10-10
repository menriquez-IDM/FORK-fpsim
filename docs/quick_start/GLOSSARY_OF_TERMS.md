# FPsim Shiny Application - Glossary of Terms
## Technical, Demographic, and Statistical Terminology

**Version:** 1.0  
**Date:** October 2, 2025  
**Audience:** Researchers, Mathematicians, Policy Makers, Software Engineers

---

## How to Use This Glossary

- **Bold terms** are essential for all users
- *Italic terms* are for technical/advanced users

---

## Table of Contents

1. [Demographic & Family Planning Terms](#1-demographic--family-planning-terms)
2. [Statistical & Mathematical Terms](#2-statistical--mathematical-terms)
3. [Software & Technical Terms](#3-software--technical-terms)
4. [FPsim-Specific Terms](#4-fpsim-specific-terms)
5. [Data & Survey Terms](#5-data--survey-terms)
6. [Visualization Terms](#6-visualization-terms)
7. [Model & Simulation Terms](#7-model--simulation-terms)

---

## 1. Demographic & Family Planning Terms

| Term | Abbreviation | Definition | Example / Usage |
|------|--------------|------------|-----------------|
| **Age-Specific Fertility Rate** | **ASFR** | Number of births per 1,000 women in a specific age group (typically 5-year intervals: 15-19, 20-24, etc.) | ASFR for 20-24 year olds in Kenya 2020 = 145 births per 1,000 women |
| **Total Fertility Rate** | **TFR** | Average number of children a woman would have if she experienced current age-specific fertility rates throughout her reproductive years | TFR of 2.1 = replacement level (stable population) |
| **Contraceptive Prevalence Rate** | **CPR** | Percentage of women of reproductive age (15-49) using any method of contraception | Ethiopia CPR 2019 = 41% (all women) |
| **Modern Contraceptive Prevalence Rate** | **mCPR** | Percentage of women using modern contraceptive methods (excludes traditional methods like withdrawal) | mCPR = CPR - traditional method users |
| **Age at First Birth** | **AFB** | Age of a woman when she has her first live birth | Median AFB in Senegal = 21.3 years |
| **Parity** | - | Number of children a woman has given birth to (including stillbirths) | Parity 0 = nulliparous (no births), Parity 3 = three children |
| **Unmet Need** | - | Women who want to avoid or delay pregnancy but are not using contraception | Unmet need = (women wanting to space/limit - users) / (women wanting to space/limit) |
| **Lactational Amenorrhea Method** | **LAM** | Natural contraception through exclusive breastfeeding (prevents ovulation for ~6 months postpartum) | LAM effective if: exclusive breastfeeding, <6 months postpartum, amenorrhea |
| **Postpartum Period** | - | Time after childbirth, typically first 6-24 months; characterized by lactation, reduced fertility | Postpartum contraception uptake is key FP indicator |
| **Birth Spacing** | - | Time interval between consecutive births (measured in months) | Healthy birth spacing = 24-36 months between births |
| **Maternal Mortality Ratio** | **MMR** | Number of maternal deaths per 100,000 live births | Ethiopia MMR 2017 = 401 per 100,000 (very high) |
| **Infant Mortality Rate** | **IMR** | Number of deaths of children under 1 year per 1,000 live births | Kenya IMR 2019 = 32 per 1,000 (moderate) |
| **Sexual Debut** | - | Age at first sexual intercourse | Early sexual debut (<18) associated with higher fertility |
| **Fecundity** | - | Biological capacity to conceive and carry a pregnancy to term | Fecundity declines with age, especially after 35 |
| **Primary Infertility** | - | Inability to conceive after 12 months of trying (never pregnant before) | Primary infertility rate ~2-8% in Sub-Saharan Africa |
| **Exposure Factor** | - | Multiplier on baseline pregnancy probability; accounts for sexual activity, biological factors | Exposure factor = 1.0 (baseline), >1.0 (higher activity), <1.0 (lower) |
| **Method Mix** | - | Distribution of contraceptive users across different methods | Method mix: Pills 20%, Injectables 30%, IUDs 15%, etc. |
| **Long-Acting Reversible Contraceptives** | **LARCs** | Contraceptive methods lasting >3 years: IUDs, implants | LARCs have highest efficacy (>99%) and lowest discontinuation |
| **Short-Acting Methods** | - | Contraceptives requiring frequent action: pills, condoms, injectables (<3 months) | Pills require daily adherence; injectables every 3 months |
| **Bilateral Tubal Ligation** | **BTL** | Surgical sterilization for women (permanent contraception) | BTL efficacy >99%, but irreversible |
| **Age-Parity Distribution** | - | Two-dimensional distribution showing population by age and number of children | High parity at young ages indicates early/rapid childbearing |
| **Demographic Transition** | - | Shift from high mortality/high fertility to low mortality/low fertility | Most SSA countries in Stage 2-3 of transition |
| **Replacement-Level Fertility** | - | TFR needed to replace population (no growth/decline), typically ~2.1 in developed countries | Below 2.1 = population decline; above 2.1 = growth |

---

## 2. Statistical & Mathematical Terms

| Term | Abbreviation | Definition | Example / Usage |
|------|--------------|------------|-----------------|
| **Root Mean Square Error** | **RMSE** | Measure of difference between predicted and observed values; lower = better fit | RMSE = √(Σ(predicted - observed)² / n); RMSE < 5% is good fit |
| **Mean Absolute Error** | **MAE** | Average absolute difference between predicted and observed values | MAE = Σ\|predicted - observed\| / n; less sensitive to outliers than RMSE |
| **Goodness-of-Fit** | **GOF** | Statistical measure of how well a model matches observed data | High GOF means model reproduces reality well |
| **Calibration** | - | Process of adjusting model parameters to match observed data | Calibrate Kenya model to DHS 2022 data by adjusting exposure_factor |
| **Validation** | - | Testing model on held-out data not used in calibration | Train on 2014-2019 data, validate on 2020-2022 |
| **Sensitivity Analysis** | **SA** | Examining how model outputs change when inputs are varied | "How sensitive is TFR to exposure_factor changes?" |
| **Partial Rank Correlation Coefficient** | **PRCC** | Measure of monotonic relationship between parameter and outcome (sensitivity metric) | PRCC = 0.78 means strong positive correlation (controlling for other parameters) |
| **Latin Hypercube Sampling** | **LHS** | Efficient method for sampling multi-dimensional parameter space | LHS generates 100 diverse parameter combinations for sensitivity analysis |
| **Confidence Interval** | **CI** | Range of values that likely contains true parameter (e.g., 95% CI) | CPR = 45% (95% CI: 42-48%) means 95% confident true value is 42-48% |
| **Uncertainty Quantification** | **UQ** | Characterizing uncertainty in model parameters and predictions | UQ shows range of possible outcomes given parameter uncertainty |
| **Monte Carlo Simulation** | **MC** | Running many simulations with random parameter sampling to assess uncertainty | 1000 MC runs generate distribution of outcomes |
| **Percentile** | - | Value below which a given percentage of observations fall | 95th percentile = value exceeded by only 5% of observations |
| **Residual** | - | Difference between observed and predicted value | Residual = observed - predicted; plot residuals to check model fit |
| **Correlation Coefficient** | *r* | Measure of linear relationship between two variables (-1 to +1) | r = 0.85 means strong positive linear relationship |
| **P-Value** | *p* | Probability of observing data if null hypothesis is true | p < 0.05 typically considered "statistically significant" |
| **Standard Deviation** | **SD** or σ | Measure of spread in data; average distance from mean | SD = 2.5 means most values within ±2.5 of mean |
| **Variance** | σ² | Square of standard deviation; measure of variability | Variance = SD² |
| **Mean** | μ or x̄ | Average value; sum divided by count | Mean TFR = (3.2 + 3.5 + 3.1) / 3 = 3.27 |
| **Median** | - | Middle value when data sorted; 50th percentile | Median age at first birth = value splitting distribution in half |
| **Distribution** | - | Pattern describing frequency of different values | Normal distribution (bell curve), lognormal (skewed right), uniform (flat) |
| **Lognormal Distribution** | - | Distribution where log of variable is normally distributed; used for durations | Duration of contraceptive use follows lognormal(mean=2, sd=3) years |
| **Exponential Distribution** | - | Distribution describing time until event; memoryless | Time to discontinuation ~ exponential(rate=0.1) |
| **Gamma Distribution** | - | Flexible distribution for positive continuous values (shape, scale parameters) | Duration ~ gamma(shape=2, scale=1.5) |
| **Bernoulli Distribution** | - | Binary outcome (success/failure) with probability p | Pregnancy this month ~ Bernoulli(p=0.08) |
| **Threshold Effect** | - | Non-linear change where effect suddenly increases/decreases at critical value | Fertility decline accelerates when CPR > 50% (threshold) |
| **R-Squared** | R² | Proportion of variance explained by model (0 to 1) | R² = 0.85 means model explains 85% of variance in data |

---

## 3. Software & Technical Terms

| Term | Abbreviation | Definition | Example / Usage |
|------|--------------|------------|-----------------|
| **R Shiny** | - | Web application framework for R programming language | Shiny creates interactive dashboards and apps using R |
| **Python** | - | High-level programming language; FPsim is written in Python | Python 3.10+ required for FPsim 3.3.1 |
| **Reticulate** | - | R package enabling R-Python integration | Reticulate allows Shiny app (R) to call FPsim (Python) |
| **Agent-Based Model** | **ABM** | Simulation where individual agents (people) are modeled with rules and interactions | FPsim is ABM: each woman is agent with age, parity, method use, etc. |
| **Stochastic Model** | - | Model with random elements; outcomes vary across runs | FPsim is stochastic: each run produces slightly different results |
| **Simulation** | **Sim** | Computer model mimicking real-world system over time | Run simulation: model 5000 women from 2000-2030 |
| **Parameter** | - | Input value that controls model behavior | Parameters: n_agents=5000, exposure_factor=1.0, location='kenya' |
| **Timestep** | **dt** | Length of time between simulation updates | FPsim default timestep = 1/12 year (monthly) |
| **Initialization** | - | Setting starting conditions for simulation | Initialize population with age pyramid, assign contraceptive use |
| **Iteration** | - | One pass through simulation loop (one timestep) | Each month is one iteration in FPsim |
| **Asynchronous** | **Async** | Operations that run in background without blocking UI | Async simulation lets user navigate app while sim runs |
| **Reactive Programming** | - | Programming paradigm where changes propagate automatically | Shiny reactives: change slider → automatically re-plot |
| **Docker** | - | Platform for running applications in isolated containers | Docker packages app + dependencies for easy deployment |
| **API** | - | Application Programming Interface; way for programs to communicate | FPsim API: functions to create sims, set parameters, run, get results |
| **JSON** | - | JavaScript Object Notation; text format for data interchange | Export parameters as JSON: {"location": "kenya", "n_agents": 5000} |
| **CSV** | - | Comma-Separated Values; spreadsheet file format | Export results as CSV: time, cpr, tfr, births, deaths, ... |
| **Git** | - | Version control system for tracking code changes | FPsim code hosted on GitHub using git |
| **GitHub** | - | Web platform for hosting git repositories | https://github.com/fpsim/fpsim |
| **Virtual Environment** | **venv** | Isolated Python environment with specific package versions | Create venv to avoid conflicts between projects |
| **Dependency** | - | Software package required by another package | FPsim dependencies: numpy, scipy, pandas, matplotlib, etc. |
| **Parallel Processing** | - | Running multiple tasks simultaneously on different CPU cores | Run 10 simulations in parallel to speed up batch jobs |
| **Caching** | - | Storing computed results to avoid recalculating | Cache location data: load once per session, reuse |
| **Session** | - | Period of user interaction with app from login to logout | Shiny session: stores user's simulations, plots, settings |
| **Endpoint** | - | URL where API can be accessed | API endpoint: POST /api/simulate to submit simulation job |
| **Load Balancer** | - | Distributes incoming requests across multiple servers | Load balancer routes users to available server instances |
| **Scalability** | - | Ability to handle increased workload (more users, data, etc.) | Horizontal scalability: add more servers as users increase |

---

## 4. FPsim-Specific Terms

| Term | Abbreviation | Definition | Example / Usage |
|------|--------------|------------|-----------------|
| **Sim Class** | - | Main FPsim object representing a simulation | `sim = fp.Sim(location='kenya')` creates simulation |
| **People Class** | - | FPsim object managing population of agents | `sim.people.age` returns ages of all agents |
| **FPmod** | - | FPsim module handling family planning events | `sim.pars.fp` contains FP-specific parameters |
| **Method** | - | Contraceptive method with properties (efficacy, duration, etc.) | Method('Pill', efficacy=0.945, modern=True, dur_use=lognormal(2,3)) |
| **Intervention** | - | Change to simulation at specified time (e.g., new program) | `fp.update_methods(year=2025, eff={'Pill': 0.98})` increases pill efficacy |
| **Experiment** | - | FPsim class for running simulations with calibration | `exp = fp.Experiment()` creates calibration experiment |
| **Fit** | - | FPsim class calculating goodness-of-fit metrics | `fit = exp.fit` accesses fit object with RMSE, MAE |
| **Scenario** | - | Simulation with specific intervention(s) to test policy | Scenario A: baseline; Scenario B: injectable scale-up |
| **ContraceptiveChoice** | - | FPsim module determining how women choose methods | RandomChoice, SimpleChoice, StandardChoice (matrix-based) |
| **Location** | - | Geographic area with calibrated data (country or region) | Locations: kenya, senegal, ethiopia, oromia (Ethiopia region) |
| **Validation Data** | - | Observed data used to assess model fit | Kenya validation data: DHS 2014, 2022; PMA 2014-2022 |
| **Results Object** | - | FPsim object storing simulation outputs | `sim.results.fp.cpr` returns CPR over time |
| **Connectors** | - | Starsim modules linking different parts of model | `sim.connectors.contraception` accesses contraception module |
| **Agent State** | - | Characteristics of individual agent (age, parity, method, etc.) | Agent 123: age=28, parity=2, on_contra=True, method='IUD' |
| **update_methods()** | - | FPsim intervention to change method properties or uptake | Most common intervention in app |
| **change_par()** | - | FPsim intervention to change any parameter at specified time(s) | `change_par(par='exposure_factor', years=2025, vals=0.8)` |
| **plot_calib()** | - | FPsim function creating 10-panel calibration comparison plot | Shows simulated vs. observed for 10 targets |
| **Regional Model** | - | Subnational FPsim model (e.g., Ethiopia regions) | Ethiopia has 11 regional models with separate data files |

---

## 5. Data & Survey Terms

| Term | Abbreviation | Definition | Example / Usage |
|------|--------------|------------|-----------------|
| **Demographic and Health Survey** | **DHS** | Large-scale household survey on health and demographics (funded by USAID) | Kenya DHS 2014, 2022 provide CPR, TFR, method mix data |
| **Performance Monitoring for Action** | **PMA** | Survey measuring family planning and reproductive health (phone-based) | PMA data collected every 6-12 months (more frequent than DHS) |
| **World Bank** | **WB** | International financial institution providing development data | World Bank data: GDP, population, health expenditure |
| **United Nations Population Division** | **UNPD** | UN department providing population estimates and projections | UN World Population Prospects 2022: TFR, ASFR data |
| **Census** | - | Complete count of population at specific time | Kenya Census 2019: age pyramid, urbanization rates |
| **Age Pyramid** | - | Bar chart showing population distribution by age and sex | Age pyramid data needed to initialize FPsim simulations |
| **Cross-Sectional Data** | - | Data collected at single point in time (snapshot) | DHS 2022 is cross-sectional: surveys at one time |
| **Longitudinal Data** | - | Data collected repeatedly over time (panel data) | PMA tracks same households over multiple rounds |
| **Survey Weights** | - | Adjustments to make survey sample representative of population | Apply weights so rural/urban proportions match census |
| **Sampling Error** | - | Variation in estimates due to surveying sample vs. full population | CPR = 42% ± 3% (sampling error at 95% CI) |
| **Missing Data** | - | Observations without values for some variables | Handle missing data: imputation, complete case analysis, or sensitivity analysis |
| **Data Quality** | - | Accuracy, completeness, and reliability of data | Low data quality → high uncertainty in model projections |
| **Metadata** | - | Data about data (source, collection method, date, definitions) | Metadata for CPR: source=DHS 2022, definition=all women 15-49 |
| **Indicator** | - | Measurable variable representing phenomenon of interest | Key indicators: CPR, TFR, MMR, IMR |
| **Target** | - | Desired value for indicator (often used in policy) | FP2030 target: 75% demand satisfied by 2030 |

---

## 6. Visualization Terms

| Term | Abbreviation | Definition | Example / Usage |
|------|--------------|------------|-----------------|
| **Plotly** | - | JavaScript library for interactive plots; R package wraps it | Plotly plots: zoom, pan, hover, download, toggle series |
| **echarts4r** | - | R package for Apache ECharts visualizations (Sankey, 3D, etc.) | echarts4r creates advanced plots like Sankey diagrams |
| **Leaflet** | - | JavaScript library for interactive maps; R package wraps it | Leaflet map showing Ethiopia regions colored by CPR |
| **ggplot2** | - | R package for static statistical graphics (Grammar of Graphics) | ggplot2 creates publication-quality plots |
| **Time Series Plot** | - | Line plot showing variable over time | CPR time series: x-axis=years, y-axis=CPR (%), line shows trend |
| **Scatter Plot** | - | Plot showing relationship between two continuous variables | Scatter: x=exposure_factor, y=TFR, points=simulation runs |
| **Bar Chart** | - | Plot with rectangular bars representing categories | Birth spacing bar chart: x=interval (months), y=percentage |
| **Histogram** | - | Bar chart showing frequency distribution of continuous variable | Age at first birth histogram: x=age, y=count of women |
| **Stacked Area Chart** | - | Area plot with multiple series stacked on top of each other | Method mix stacked area: different colors for each method over time |
| **Heatmap** | - | 2D plot with colors representing values | ASFR heatmap: x=time, y=age group, color=fertility rate |
| **Choropleth Map** | - | Map with regions colored by data values | Ethiopia map: regions colored by CPR (dark=high, light=low) |
| **Sankey Diagram** | - | Flow diagram showing quantities moving between categories | Method switching Sankey: flows from old method to new method |
| **Sunburst Chart** | - | Hierarchical pie chart with nested rings | Sunburst: inner=age, middle=parity, outer=method |
| **Bubble Chart** | - | Scatter plot with bubble size representing third variable | Bubbles: x=age, y=parity, size=population count |
| **3D Surface Plot** | - | 3D plot showing function of two variables | Surface: x=exposure, y=postpartum_dur, z=TFR |
| **Tornado Plot** | - | Horizontal bar chart showing sensitivity (parameters ranked by impact) | Tornado plot: bars show PRCC for each parameter |
| **Box Plot** | - | Plot showing distribution via quartiles (box) and outliers (dots) | Box plot shows median, 25th/75th percentiles, min/max |
| **Violin Plot** | - | Combination of box plot and density plot | Violin plot shows full distribution shape |
| **Hover Tooltip** | - | Information displayed when mouse hovers over plot element | Hover over line → shows year and exact CPR value |
| **Legend** | - | Key explaining plot symbols, colors, line styles | Legend: Blue line=Baseline, Red line=Scenario A |
| **Facet** | - | Splitting plot into multiple panels by category | Facet by region: 11 small plots, one per Ethiopian region |
| **Animation** | - | Plot that changes over time with play button | Animated map: press play to see CPR change 2000-2030 |

---

## 7. Model & Simulation Terms

| Term | Abbreviation | Definition | Example / Usage |
|------|--------------|------------|-----------------|
| **Deterministic Model** | - | Model with no randomness; same inputs always give same outputs | Cohort-component model is deterministic |
| **Stochastic Model** | - | Model with random elements; outputs vary across runs | FPsim is stochastic: each run produces different results |
| **Agent-Based Model** | **ABM** | Model where individuals (agents) are simulated with rules | FPsim ABM: each woman is agent with characteristics |
| **Microsimulation** | - | Simulation of individual units (people, households) | FPsim is microsimulation: tracks each woman separately |
| **Compartmental Model** | - | Model dividing population into discrete states (compartments) | SIR model: Susceptible → Infected → Recovered compartments |
| **Life-Course Approach** | - | Modeling individuals across their entire lifespan | FPsim life-course: tracks women from age 15 to 50 |
| **Baseline Scenario** | - | Reference simulation with no interventions (current trends) | Compare interventions against baseline to measure impact |
| **Counterfactual** | - | "What would have happened if..." scenario | Counterfactual: births averted = baseline births - intervention births |
| **Projection** | - | Forecast of future values based on model | Project Kenya TFR 2025-2030 assuming current CPR trends |
| **Extrapolation** | - | Extending trends beyond observed data | Extrapolating 2000-2020 trends to predict 2030 (risky!) |
| **Initialization** | - | Setting up starting conditions for simulation | Initialize with 2020 age pyramid, CPR, method mix |
| **Burn-In Period** | - | Initial simulation time discarded to let model stabilize | Run 5 years burn-in (1995-2000), analyze 2000-2030 |
| **Convergence** | - | When iterative process reaches stable solution | Calibration converges when RMSE stops decreasing |
| **Run Time** | - | Computer time required to execute simulation | FPsim runtime: 5 seconds for 5K agents, 20 years |
| **Steady State** | - | Condition where system no longer changes over time | Stable population: births = deaths (steady state) |
| **Feedback Loop** | - | When model outputs affect future inputs (circular causation) | High birth rate → low resources → higher infant mortality → feedback |
| **Exogenous Variable** | - | Variable determined outside model (external input) | Exogenous: policy changes, economic shocks, pandemics |
| **Endogenous Variable** | - | Variable determined within model (internal output) | Endogenous: CPR, TFR, births (emerge from model rules) |
| **Boundary Conditions** | - | Constraints on model behavior at edges of domain | Age boundary: women exit model at age 50 |
| **Absorbing State** | - | State that cannot be exited once entered | Death is absorbing state (no return) |

---

## Acronym Quick Reference

**Family Planning & Demographics:**
- ASFR - Age-Specific Fertility Rate
- AFB - Age at First Birth
- BTL - Bilateral Tubal Ligation
- CPR - Contraceptive Prevalence Rate
- DHS - Demographic and Health Survey
- IMR - Infant Mortality Rate
- LAM - Lactational Amenorrhea Method
- LARCs - Long-Acting Reversible Contraceptives
- mCPR - Modern Contraceptive Prevalence Rate
- MMR - Maternal Mortality Ratio
- PMA - Performance Monitoring for Action
- TFR - Total Fertility Rate
- UNFPA - UN Population Fund
- UNPD - UN Population Division
- USAID - US Agency for International Development
- WB - World Bank

**Statistical & Mathematical:**
- CI - Confidence Interval
- GOF - Goodness-of-Fit
- LHS - Latin Hypercube Sampling
- MAE - Mean Absolute Error
- MC - Monte Carlo
- PRCC - Partial Rank Correlation Coefficient
- RMSE - Root Mean Square Error
- SA - Sensitivity Analysis
- SD - Standard Deviation
- UQ - Uncertainty Quantification

**Software & Technical:**
- ABM - Agent-Based Model
- API - Application Programming Interface
- CSV - Comma-Separated Values
- JSON - JavaScript Object Notation
- UI - User Interface
- UX - User Experience
- venv - Virtual Environment

---

## Learning Path by Role

### For Policy Makers & Program Managers:
**Essential Terms (Learn First):**
1. CPR, mCPR, TFR, ASFR, AFB, Parity
2. Baseline Scenario, Intervention, Scenario, Counterfactual
3. RMSE, Calibration, Validation
4. DHS, PMA, World Bank
5. Method Mix, LARCs, Short-Acting Methods

**Nice to Know:**
- Unmet Need, Birth Spacing, Exposure Factor
- Confidence Interval, Projection
- Agent-Based Model, Simulation

---

### For Researchers & Academics:
**Essential Terms (Learn First):**
1. All demographic terms (CPR, TFR, ASFR, etc.)
2. All statistical terms (RMSE, MAE, PRCC, LHS, CI, etc.)
3. Calibration, Validation, Goodness-of-Fit
4. Agent-Based Model, Stochastic Model, Microsimulation
5. DHS, PMA, Validation Data

**Advanced Terms:**
- Partial Rank Correlation Coefficient (PRCC)
- Latin Hypercube Sampling (LHS)
- Threshold Effect, Feedback Loop
- Endogenous vs. Exogenous Variables
- Burn-In Period, Convergence

---

### For Software Engineers & Data Scientists:
**Essential Terms (Learn First):**
1. R Shiny, Python, Reticulate
2. Agent-Based Model, Stochastic Model
3. API, JSON, CSV, Docker
4. Asynchronous, Caching, Session
5. Parameter, Simulation, Timestep

**Advanced Terms:**
- Reactive Programming, Load Balancer
- Parallel Processing, Scalability
- Virtual Environment (venv), Dependency
- Git, GitHub, Endpoint

---

### For Mathematicians & Demographers:
**Essential Terms (Learn First):**
1. All demographic terms
2. All statistical terms
3. Deterministic vs. Stochastic Models
4. Life-Course Approach, Microsimulation
5. Sensitivity Analysis, Uncertainty Quantification

**Advanced Terms:**
- PRCC, Tornado Plot, Response Surface
- Threshold Effect, Non-Linear Dynamics
- Convergence, Steady State
- Distribution types (Lognormal, Gamma, Exponential, Bernoulli)

---

## Additional Resources

**Learn More About:**

1. **Demographic Methods:**
   - Preston, Heuveline, Guillot (2001) "Demography: Measuring and Modeling Population Processes"
   - UN World Population Prospects methodology: https://population.un.org/wpp/

2. **Family Planning Indicators:**
   - DHS Program: https://dhsprogram.com/topics/family-planning/
   - FP2030: https://fp2030.org/

3. **Agent-Based Modeling:**
   - Railsback & Grimm (2019) "Agent-Based and Individual-Based Modeling"
   - NetLogo tutorials: https://ccl.northwestern.edu/netlogo/

4. **R Shiny:**
   - Shiny from RStudio: https://shiny.posit.co/r/getstarted/
   - Mastering Shiny (book): https://mastering-shiny.org/

5. **Sensitivity Analysis:**
   - Saltelli et al. (2008) "Global Sensitivity Analysis: The Primer"
   - R sensitivity package: https://cran.r-project.org/package=sensitivity

6. **FPsim Documentation:**
   - FPsim docs: https://docs.fpsim.org
   - GitHub: https://github.com/fpsim/fpsim
   - Tutorials: See docs/tutorials/ folder

---

## Glossary Maintenance

This glossary should be updated when:
- New FPsim features are added
- New terminology emerges in field
- Users request clarification on terms
- Shiny app adds new functionality

**Version History:**
- v1.0 (2025-10-02): Initial glossary for Shiny app implementation plan

**Contributors:**
- Technical Writing Team
- FPsim Development Team
- User Experience Team

**Feedback:**
- Submit corrections or suggestions via GitHub Issues
- Email: info@fpsim.org

---

**Document Status:** Ready for Distribution  
**Last Updated:** October 2, 2025

