# FPsim Shiny App - Multi-Intervention System Guide

## Overview

The FPsim Shiny App now supports **multiple intervention types** that can be combined in a single simulation run. This mirrors the functionality from `examples/example_method_intervention_usage.py` and allows comprehensive policy scenario analysis.

## Supported Intervention Types

### 1. **Add New Method**
Introduce a completely new contraceptive method (e.g., SC-DMPA, contraceptive ring).

**Parameters:**
- Method Name (lowercase): Internal identifier (e.g., `sc_dmpa`)
- Method Label (display): User-facing name (e.g., `SC-DMPA`)
- Method Efficacy: Contraceptive effectiveness (0.5-1.0)
- Duration (months): Average continuation time (1-60)
- Copy Matrix From: Base switching patterns on existing method
- Initial Share: Probability of staying on method (0-1)

**Example Use Case:**
```
Type: Add New Method
Year: 2010
Name: sc_dmpa
Label: SC-DMPA
Efficacy: 0.96
Duration: 6 months
Copy From: Injectables
Initial Share: 0.25
```

### 2. **Change Efficacy**
Improve or modify the efficacy of an existing method (e.g., quality improvement program).

**Parameters:**
- Target Method: Which method to modify (inj, pill, iud, impl, cond)
- New Efficacy: Updated effectiveness (0.5-1.0)

**Example Use Case:**
```
Type: Change Efficacy
Year: 2007
Target Method: Injectables
New Efficacy: 0.99  (99% - improved quality)
```

### 3. **Change Duration**
Modify the continuation/duration of an existing method (e.g., adherence support program).

**Parameters:**
- Target Method: Which method to modify
- New Duration (months): Updated continuation time (1-60)

**Example Use Case:**
```
Type: Change Duration  
Year: 2007
Target Method: Implants
New Duration: 48 months  (4 years - better continuation)
```

### 4. **Change Method Mix**
Adjust the share/proportion of users choosing a specific method (e.g., LARC promotion).

**Parameters:**
- Target Method: Which method to increase/decrease
- Target Share: Desired proportion (0-1)

**Example Use Case:**
```
Type: Change Method Mix
Year: 2007
Target Method: Implants
Target Share: 0.20  (20% - LARC promotion goal)
```

### 5. **Scale Switching Matrix**
Modify the probability of switching TO a method (e.g., improving access/referrals).

**Parameters:**
- Target Method: Method to affect switching patterns for
- Scale Factor: Multiplier for switching probability (0.5-2.0)

**Example Use Case:**
```
Type: Scale Switching Matrix
Year: 2007
Target Method: Injectables
Scale Factor: 1.2  (20% increase in switching probability)
```

## How to Use

### Step 1: Enable Interventions

1. In the sidebar, check **"Enable Interventions"**
2. The intervention builder will appear

### Step 2: Build Your Intervention Set

1. **Select Intervention Type** from the dropdown
2. **Set Intervention Year** (when it takes effect)
3. **Configure type-specific parameters** (forms adapt to intervention type)
4. Click **"Add Intervention"** button
5. **Repeat** to add more interventions

### Step 3: Review Added Interventions

- Added interventions appear in the **"Added Interventions"** list
- Each shows: Number, Description, Year
- Click **×** button to remove individual interventions
- Click **"Clear All"** to start over

### Step 4: Run Simulation

1. Set other simulation parameters (population, years, location)
2. Click **"Run Simulation"**
3. Wait for baseline + intervention simulations to complete

### Step 5: View Results

Navigate to **"Intervention Analysis"** tab to:
- Select from 7 different visualization types
- View intervention statistics
- Compare baseline vs. intervention scenarios

## Example Scenarios

### Scenario 1: Simple Quality Improvement
**Goal:** Improve injectable efficacy through better quality products

```
Intervention 1:
  Type: Change Efficacy
  Year: 2007
  Method: Injectables
  Efficacy: 0.99
```

**Expected Impact:** Reduced failure rates, fewer unintended pregnancies

---

### Scenario 2: LARC Promotion Program
**Goal:** Increase implant uptake and continuation

```
Intervention 1:
  Type: Change Method Mix
  Year: 2007
  Method: Implants
  Share: 0.20

Intervention 2:
  Type: Change Duration
  Year: 2007
  Method: Implants
  Duration: 48 months
```

**Expected Impact:** Higher implant share, longer continuation, increased mCPR

---

### Scenario 3: Comprehensive Injectable Program
**Goal:** Improve both efficacy and continuation for injectables

```
Intervention 1:
  Type: Change Efficacy
  Year: 2007
  Method: Injectables
  Efficacy: 0.992

Intervention 2:
  Type: Change Duration
  Year: 2007
  Method: Injectables
  Duration: 40 months
```

**Expected Impact:** Better outcomes through quality + adherence improvements

---

### Scenario 4: New Method Introduction + Access Improvement
**Goal:** Add SC-DMPA and improve switching to injectables

```
Intervention 1:
  Type: Add New Method
  Year: 2010
  Name: sc_dmpa
  Label: SC-DMPA
  Efficacy: 0.96
  Duration: 6
  Copy From: Injectables
  Initial Share: 0.25

Intervention 2:
  Type: Scale Switching Matrix
  Year: 2010
  Method: Injectables
  Scale Factor: 1.2
```

**Expected Impact:** New method uptake + improved access to injectable family

---

### Scenario 5: Multi-Year Phased Program
**Goal:** Sequential rollout of interventions

```
Intervention 1:
  Type: Change Efficacy
  Year: 2005
  Method: Injectables
  Efficacy: 0.97

Intervention 2:
  Type: Add New Method
  Year: 2010
  Method: sc_dmpa
  ...

Intervention 3:
  Type: Change Method Mix
  Year: 2015
  Method: Implants
  Share: 0.25
```

**Expected Impact:** Staged improvements over time

## Tips for Effective Use

### Combining Interventions

- **Same Year, Different Methods**: Multiple methods can be improved simultaneously
- **Same Year, Same Method**: Multiple changes to one method (e.g., efficacy + duration)
- **Different Years**: Phased rollout of program components

### Interpreting Results

1. **Method Mix Changes**: Which methods gained/lost share?
2. **CPR/mCPR Trends**: Overall contraceptive prevalence impact
3. **Births Averted**: Public health impact measure
4. **Continuation Rates**: Are users staying on methods longer?
5. **Switching Patterns**: Are women moving to more effective methods?

### Best Practices

1. **Start Simple**: Try single interventions first to understand individual effects
2. **Build Gradually**: Add interventions one at a time to see cumulative impact
3. **Use Realistic Values**: Base parameters on evidence from similar programs
4. **Consider Context**: Location-specific baseline matters for intervention impact
5. **Compare Scenarios**: Run multiple simulations with different intervention sets

## Visualization Options

All 7 plot types work with multi-interventions:

1. **Summary Figure** - Best for comprehensive overview
2. **Injectable Methods Comparison** - Good if targeting injectable family
3. **Method Mix Evolution** - Shows transitions over time
4. **New Method Adoption** - Highlights uptake of new methods
5. **Method Comparison Bar** - Final state comparison
6. **CPR Comparison** - Focus on prevalence trends
7. **Births Comparison** - Public health impact

## Technical Details

### How It Works

1. **Intervention Builder**: UI collects intervention specifications
2. **Intervention List**: R stores interventions as list of dictionaries
3. **Python Backend**: `fp_interventions.py` converts to FPsim intervention objects
4. **Grouping**: Interventions at same year are combined into single MethodIntervention
5. **Execution**: FPsim runs baseline + intervention simulations
6. **Comparison**: Results analyzed and plotted

### Files Involved

- `shiny/ui.R` - Intervention builder UI
- `shiny/server.R` - Intervention management logic
- `shiny/python/fp_interventions.py` - Multi-intervention handler (NEW)
- `shiny/python/fp_simulator.py` - Routing to intervention system
- `shiny/python/plots.py` - Visualization functions

### Method Names Reference

Use these canonical names when specifying methods:

| Short Name | Display Name    |
|------------|-----------------|
| `pill`     | Pills           |
| `iud`      | IUD             |
| `inj`      | Injectables     |
| `impl`     | Implants        |
| `cond`     | Condoms         |
| `btl`      | BTL (tubal)     |
| `wdraw`    | Withdrawal      |
| `othtrad`  | Other Trad      |
| `othmod`   | Other Modern    |

## Troubleshooting

### "No interventions added" warning
- Make sure you clicked "Add Intervention" button
- Check that "Enable Interventions" is checked

### Simulation runs but no intervention effect
- Verify intervention year is between start_year and end_year
- Check intervention parameters are realistic
- Ensure interventions were added to list before running

### Plot shows "No intervention data"
- Confirm interventions were enabled when simulation ran
- Check that simulation completed successfully
- Try different plot types

### Unexpected results
- Review intervention list - are all parameters correct?
- Try running interventions individually to isolate effects
- Check that method names match canonical names
- Verify year values are realistic

## Advanced Usage

### Replicating Example Scripts

The multi-intervention system replicates these examples:
- ✅ Simple efficacy improvement (`run_simple_usecase`)
- ✅ Method mix adjustment (`run_with_method_mix_adjustment`)
- ✅ Efficacy and duration changes (`run_with_efficacy_and_duration_changes`)
- ✅ Switching matrix scaling (`run_with_switching_matrix_scaling`)
- ✅ Multiple interventions together (any combination)

### Comparing Scenarios

To compare different intervention strategies:
1. Run simulation with first intervention set
2. Save/note results
3. Clear interventions
4. Add second intervention set
5. Run simulation again
6. Compare metrics manually

(Future: Side-by-side scenario comparison feature)

## References

- **Example Script**: `examples/example_method_intervention_usage.py`
- **FPsim Documentation**: Method intervention API
- **Original Guide**: `INTERVENTION_GUIDE.md` (single new method)

---

**Questions?** Open an issue on the FPsim GitHub repository.

