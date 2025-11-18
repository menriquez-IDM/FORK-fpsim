# Complete Method Modification Guide

## Overview

The FPsim Shiny App now supports **all 9 contraceptive methods** with comprehensive modification capabilities. You can update multiple parameters for any method using the new "Update Method" intervention type.

## All 9 Available Contraceptive Methods

| # | Method Name | Code | Type | Category |
|---|-------------|------|------|----------|
| 1 | **Pills** | `pill` | Short-acting | Modern |
| 2 | **IUD** | `iud` | LARC | Modern |
| 3 | **Injectables** | `inj` | Short-acting | Modern |
| 4 | **Condoms** | `cond` | Barrier | Modern |
| 5 | **BTL (Tubal Ligation)** | `btl` | Permanent | Modern |
| 6 | **Withdrawal** | `wdraw` | Traditional | Traditional |
| 7 | **Implants** | `impl` | LARC | Modern |
| 8 | **Other Traditional** | `othtrad` | Traditional | Traditional |
| 9 | **Other Modern** | `othmod` | Modern | Modern |

## Modifiable Parameters

Each method can be modified in 4 ways:

### 1. **Efficacy** (Contraceptive Effectiveness)
- **Range:** 0.5 - 1.0 (50% - 100%)
- **Meaning:** Probability of preventing pregnancy per use
- **Example:** Improve injectable efficacy from 98% to 99%

### 2. **Duration** (Continuation Time)
- **Range:** 1 - 60 months
- **Meaning:** Average time users stay on the method
- **Example:** Increase implant duration from 36 to 48 months

### 3. **Method Mix** (User Share)
- **Range:** 0.0 - 1.0 (0% - 100%)
- **Meaning:** Proportion of contraceptive users choosing this method
- **Example:** Set implant share to 20% (LARC promotion)

### 4. **Switching Matrix** (Transition Probability)
- **Range:** 0.5 - 2.0× (scale factor)
- **Meaning:** Modify probability of switching TO this method
- **Example:** Scale injectable switching by 1.2× (20% increase)

## Using "Update Method" (Recommended)

The **"Update Method"** intervention type allows you to modify **multiple parameters simultaneously** for a single method. This is the most efficient way to implement comprehensive programs.

### How to Use:

1. Select **"Update Method (Multiple Parameters)"** from intervention type
2. Choose the **target method** (pill, iud, inj, etc.)
3. Check which parameters you want to update:
   - ☑ **Update Efficacy** → Set new efficacy value
   - ☑ **Update Duration** → Set new duration value
   - ☑ **Update Method Mix** → Set new method share
4. Click **"Add Intervention"**

### Example: Comprehensive Injectable Program

```
Intervention Type: Update Method
Target Method: Injectables (inj)
Year: 2007

Parameters:
☑ Update Efficacy: 0.992 (99.2%)
☑ Update Duration: 40 months
☐ Update Method Mix: (not modified)

Description: "Update INJ: eff=99.2%, dur=40mo (2007)"
```

**Result:** Improved quality AND adherence in a single intervention.

## Single-Parameter Interventions

For simpler changes or when you want to separate effects, use:

### Change Efficacy Only
- Quick efficacy update
- Good for quality improvement programs

### Change Duration Only
- Focus on continuation/adherence
- Good for counseling/support programs

### Change Method Mix Only
- Adjust market share
- Good for promotion campaigns

### Scale Switching Matrix
- Modify transition patterns
- Good for access/referral improvements

## Complete Usage Examples

### Example 1: Update Pills (Multiple Parameters)

```
Type: Update Method
Method: Pills
Year: 2008

☑ Efficacy: 0.96
☑ Duration: 18 months
☑ Method Mix: 0.15

Result: Improved pill program with quality, adherence, and uptake
```

---

### Example 2: Update IUD (LARC Promotion)

```
Type: Update Method
Method: IUD
Year: 2010

☐ Efficacy: (keep default)
☑ Duration: 60 months
☑ Method Mix: 0.25

Result: Longer continuation + increased market share
```

---

### Example 3: Update Implants (Comprehensive LARC)

```
Type: Update Method
Method: Implants
Year: 2012

☑ Efficacy: 0.998
☑ Duration: 48 months
☑ Method Mix: 0.30

Result: Top-quality LARC with maximum impact
```

---

### Example 4: Update BTL (Permanent Method Access)

```
Type: Update Method
Method: BTL (Tubal Ligation)
Year: 2005

☐ Efficacy: (already near 100%)
☐ Duration: (permanent method)
☑ Method Mix: 0.10

Result: Increased access to permanent contraception
```

---

### Example 5: Multiple Methods Updated (Phased Program)

```
Intervention 1:
  Type: Update Method
  Method: Injectables
  Year: 2005
  ☑ Efficacy: 0.99

Intervention 2:
  Type: Update Method
  Method: Implants
  Year: 2010
  ☑ Duration: 48 months
  ☑ Method Mix: 0.20

Intervention 3:
  Type: Update Method
  Method: IUD
  Year: 2015
  ☑ Method Mix: 0.15

Result: Sequential LARC promotion with quality improvements
```

## Method-Specific Considerations

### Short-Acting Methods (Pills, Injectables, Condoms)
- **Efficacy:** Can be significantly improved with quality programs
- **Duration:** Highly responsive to adherence support
- **Mix:** Sensitive to access and convenience factors

### LARC Methods (IUD, Implants)
- **Efficacy:** Already very high, less room for improvement
- **Duration:** Can be extended with better counseling
- **Mix:** Promotion campaigns can have large impact

### Permanent Methods (BTL)
- **Efficacy:** Nearly 100%, little improvement possible
- **Duration:** Not applicable (permanent)
- **Mix:** Access barriers are main target

### Traditional Methods (Withdrawal, Other Traditional)
- **Efficacy:** Lower baseline, education can help
- **Duration:** Variable, depends on alternative availability
- **Mix:** Often decrease when modern methods promoted

## Built-In Reference

In the app, click **"Show/Hide All 9 Contraceptive Methods"** to see:
- Complete method list
- Method codes for interventions
- Method types and categories
- Modifiable parameters summary

## Best Practices

### 1. Start with Most Impactful Methods
- Prioritize methods with high baseline use
- Target methods with most room for improvement
- Consider cost-effectiveness

### 2. Combine Parameters Thoughtfully
- **Efficacy + Duration**: Quality + adherence programs
- **Duration + Method Mix**: Promotion + support
- **Method Mix + Switching**: Access + referral systems

### 3. Use Realistic Values
- Base on evidence from similar programs
- Consider baseline values for the location
- Account for implementation capacity

### 4. Phased Rollout
- Start with achievable improvements
- Add more ambitious targets over time
- Allow methods to mature before adding more

### 5. Monitor Substitution
- Watch which methods lose share
- Ensure overall CPR increases
- Check for unintended transitions

## Comparison with Example Scripts

This system fully replicates `example_method_intervention_usage.py`:

| Example Function | App Equivalent |
|-----------------|----------------|
| `run_simple_usecase` | Change Efficacy Only |
| `run_with_method_mix_adjustment` | Update Method (duration + mix) |
| `run_with_efficacy_and_duration_changes` | Update Method (efficacy + duration) |
| `run_with_switching_matrix_scaling` | Scale Switching Matrix |

**Plus:** The app adds more flexibility with any parameter combination!

## Technical Notes

### Method Codes

Always use lowercase short codes in interventions:
- ✅ `inj` (correct)
- ❌ `Inj` or `INJ` (incorrect)
- ❌ `Injectables` (incorrect)

### Parameter Ranges

- **Efficacy**: Must be 0.5-1.0 (enforced by sliders)
- **Duration**: Must be 1-60 months (enforced by sliders)
- **Method Mix**: Must be 0-1 (enforced by sliders)
- **Switching Scale**: Must be 0.5-2.0× (enforced by sliders)

### Multiple Updates to Same Method

You can add multiple interventions to the same method at different years:

```
Year 2005: Update INJ efficacy to 0.97
Year 2010: Update INJ duration to 36 months
Year 2015: Update INJ method mix to 0.25
```

Each intervention builds on previous ones!

## Troubleshooting

### "Update Method" not working?
- Ensure at least one parameter checkbox is checked
- Verify method code is correct
- Check year is within simulation range

### No effect seen in results?
- Confirm intervention year is between start_year and end_year
- Check if baseline value already matches target
- Try larger parameter changes for more visible effects

### Unexpected substitution patterns?
- Review method mix targets - do they sum reasonably?
- Check if switching matrix changes conflict
- Consider baseline method availability in location

## References

- **Method Intervention API**: FPsim documentation
- **Example Scripts**: `examples/example_method_intervention_usage.py`
- **Multi-Intervention Guide**: `MULTI_INTERVENTION_GUIDE.md`

---

**All 9 methods are now fully accessible for modification through the Shiny app!** 🎉

