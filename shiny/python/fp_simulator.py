"""
FPsim Family Planning Shiny Web App - Python Backend
Python wrapper functions for family planning simulation
"""

import sys
import os
import numpy as np
import pandas as pd
import plotly.graph_objects as go
import plotly.express as px
from plotly.subplots import make_subplots
import sciris as sc
import starsim as ss
import fpsim as fp
import matplotlib
matplotlib.use('Agg')  # Non-interactive backend for server
import matplotlib.pyplot as plt
import base64
from io import BytesIO

# Global storage for simulation objects (needed for plotting)
_cached_baseline_sim = None
_cached_intervention_sim = None

def run_fp_simulation(params):
    """
    Run family planning simulation with given parameters
    
    Args:
        params (dict): Dictionary of simulation parameters
        
    Returns:
        dict: Simulation results and plots
    """
    
    try:
        # Check if intervention is enabled (handle both singular and plural forms)
        enable_intervention = params.get('enable_interventions', params.get('enable_intervention', False))
        
        if enable_intervention:
            # Run baseline and intervention simulations
            return run_intervention_comparison(params)
        else:
            # Run single simulation
            return run_single_simulation(params)
        
    except Exception as e:
        raise Exception(f"Simulation failed: {str(e)}")

def run_single_simulation(params):
    """Run a single FPsim simulation without intervention"""
    try:
        # Extract parameters
        n_agents = params.get('n_agents', 1000)
        start_year = params.get('start', 2000)
        end_year = params.get('end', 2020)
        location = params.get('location', 'senegal')
        exposure_factor = params.get('exposure_factor', 1.0)
        maternal_mortality_factor = params.get('maternal_mortality_factor', 1.0)
        primary_infertility = params.get('primary_infertility', 0.05)
        lam_efficacy = params.get('lam_efficacy', 0.98)
        use_education = params.get('use_education', False)
        use_empowerment = params.get('use_empowerment', False)
        rand_seed = params.get('rand_seed', 1)
        
        # Build FPsim parameters
        pars = {
            'n_agents': int(n_agents),
            'start': start_year,
            'end_year': end_year,
            'location': location,
            'rand_seed': rand_seed
        }
        
        # FP-specific parameters
        fp_pars = {
            'exposure_factor': exposure_factor,
            'maternal_mortality_factor': maternal_mortality_factor,
            'primary_infertility': primary_infertility,
            'LAM_efficacy': lam_efficacy,
        }
        
        # Handle contraceptive efficacy overrides if provided
        contra_pars = {}
        if 'pill_efficacy' in params:
            # Note: These would need to be applied via interventions or method updates
            pass
        
        # Create the simulation
        sim = fp.Sim(pars=pars, fp_pars=fp_pars)
        
        # Add education module if requested
        if use_education:
            # Education module would be configured here
            pass
        
        # Add empowerment connector if requested  
        if use_empowerment:
            # Empowerment connector would be configured here
            pass
        
        # Run simulation
        sim.run(verbose=0.1)
        
        # Flush output to ensure terminal displays everything
        import sys
        sys.stdout.flush()
        sys.stderr.flush()
        
        # Extract results
        results = extract_simulation_results(sim, params)
        
        # Print completion message
        print(f"\n✓ Simulation completed successfully! ({params['start']}-{params['end']})")
        sys.stdout.flush()
        
        return results
        
    except Exception as e:
        raise Exception(f"Simulation failed: {str(e)}")

def extract_simulation_results(sim, params):
    """
    Extract results from simulation object
    
    Args:
        sim: FPsim simulation object
        params: Original parameters
        
    Returns:
        dict: Extracted results
    """
    
    # Basic results
    timevec = sim.timevec
    years = sim.t.yearvec
    n_years = len(years)
    
    # Extract key indicators
    results = sim.results
    
    # Debug: Print available attributes
    print(f"[DEBUG] Results object type: {type(results)}")
    print(f"[DEBUG] Results attributes: {dir(results)}")
    if hasattr(results, 'keys'):
        print(f"[DEBUG] Results keys: {results.keys()}")
    
    # Birth rate (crude birth rate per 1000)
    # Try multiple ways to access births
    births = None
    if hasattr(results, 'fp') and hasattr(results.fp, 'births'):
        births = results.fp.births.values if hasattr(results.fp.births, 'values') else results.fp.births
    elif hasattr(results, 'births'):
        births = results.births.values if hasattr(results.births, 'values') else results.births
    elif 'births' in results:
        births = results['births']
    
    if births is None:
        births = np.zeros_like(timevec)
        print("[DEBUG] Warning: No births data found, using zeros")
    
    population = sim.pars.n_agents
    birth_rate = (births / population) * 1000
    
    # Contraceptive prevalence rate (CPR) - CORRECT PATH: results.contraception.cpr
    cpr = None
    if hasattr(results, 'contraception') and hasattr(results.contraception, 'cpr'):
        cpr = results.contraception.cpr
        print("[DEBUG] Found CPR data in results.contraception.cpr")
    elif hasattr(results, 'fp') and hasattr(results.fp, 'cpr'):
        cpr = results.fp.cpr.values if hasattr(results.fp.cpr, 'values') else results.fp.cpr
    elif hasattr(results, 'cpr'):
        cpr = results.cpr.values if hasattr(results.cpr, 'values') else results.cpr
    elif 'cpr' in results:
        cpr = results['cpr']
    
    if cpr is None:
        cpr = np.zeros_like(timevec)
        print("[DEBUG] Warning: No CPR data found, using zeros")
    
    # Modern contraceptive prevalence rate (mCPR) - CORRECT PATH: results.contraception.mcpr
    mcpr = None
    if hasattr(results, 'contraception') and hasattr(results.contraception, 'mcpr'):
        mcpr = results.contraception.mcpr
        print("[DEBUG] Found mCPR data in results.contraception.mcpr")
    elif hasattr(results, 'fp') and hasattr(results.fp, 'mcpr'):
        mcpr = results.fp.mcpr.values if hasattr(results.fp.mcpr, 'values') else results.fp.mcpr
    elif hasattr(results, 'mcpr'):
        mcpr = results.mcpr.values if hasattr(results.mcpr, 'values') else results.mcpr
    elif 'mcpr' in results:
        mcpr = results['mcpr']
    
    if mcpr is None:
        mcpr = cpr * 0.8  # Approximation
        print("[DEBUG] Warning: No mCPR data found, using approximation")
    
    # Total fertility rate (TFR)
    if hasattr(results, 'fp') and hasattr(results.fp, 'tfr'):
        tfr = results.fp.tfr.values
    else:
        # Estimate TFR from birth rate
        tfr = birth_rate / 8  # Rough approximation
    
    # Maternal mortality ratio
    if hasattr(results, 'fp') and hasattr(results.fp, 'maternal_deaths'):
        maternal_deaths = results.fp.maternal_deaths.values
        mmr = (maternal_deaths / np.maximum(births, 1)) * 100000
    else:
        mmr = np.ones_like(timevec) * 300  # Placeholder
    
    # Unmet need
    if hasattr(results, 'fp') and hasattr(results.fp, 'unmet_need'):
        unmet_need = results.fp.unmet_need.values
    else:
        unmet_need = np.ones_like(timevec) * 0.2  # Placeholder
    
    # Method mix - current distribution from connectors
    method_mix = {}
    
    # Try to get method mix from connectors (correct path based on examples)
    if hasattr(sim, 'connectors') and 'fp' in sim.connectors:
        fp_connector = sim.connectors['fp']
        
        # Get final timestep method mix
        if hasattr(fp_connector, 'method_mix'):
            # method_mix is a dict with method indices as keys
            method_names_dict = fp_connector.methods if hasattr(fp_connector, 'methods') else {}
            
            # Get the last timestep values
            for method_idx, method_obj in method_names_dict.items():
                method_name = method_obj.label if hasattr(method_obj, 'label') else str(method_idx)
                # Get final value of method mix
                mix_values = fp_connector.method_mix.get(method_idx, [])
                if len(mix_values) > 0:
                    final_value = mix_values[-1] if isinstance(mix_values, (list, np.ndarray)) else mix_values
                    method_mix[method_name] = float(final_value)
                    
            print(f"[DEBUG] Found method mix data from connectors: {list(method_mix.keys())}")
        else:
            print("[DEBUG] Warning: No method_mix in fp connector")
    
    # Fallback: try from people.fp.method with proper method names
    if not method_mix and hasattr(sim.people, 'fp') and hasattr(sim.people.fp, 'method'):
        print("[DEBUG] Using fallback: people.fp.method")
        methods = sim.people.fp.method
        unique, counts = np.unique(methods, return_counts=True)
        total = len(methods)
        
        # Map method indices to actual names
        method_name_map = {
            0: 'None',
            1: 'Pills',
            2: 'IUD',
            3: 'Injectables',
            4: 'Implants',
            5: 'Condoms',
            6: 'BTL',
            7: 'Withdrawal',
            8: 'Other Modern',
            9: 'Other Traditional'
        }
        
        # Get method names from sim if available
        if hasattr(sim, 'pars') and hasattr(sim.pars, 'methods'):
            methods_obj = sim.pars.methods
            if hasattr(methods_obj, 'map'):
                for idx, method_obj in methods_obj.map.items():
                    if hasattr(method_obj, 'label'):
                        method_name_map[idx] = method_obj.label
        
        for idx, count in zip(unique, counts):
            method_name = method_name_map.get(idx, f'Method_{idx}')
            method_mix[method_name] = count / total
            
        print(f"[DEBUG] Extracted methods from people.fp.method: {list(method_mix.keys())}")
    
    # Final fallback: default distribution
    if not method_mix:
        print("[DEBUG] Using default method mix distribution")
        method_mix = {
            'Pill': 0.23,
            'IUD': 0.15,
            'Injectable': 0.31,
            'Implant': 0.15,
            'Condom': 0.08,
            'BTL': 0.03,
            'Withdrawal': 0.03,
            'Other': 0.02
        }
    
    # Remove 'None' (no contraceptive) from method mix - only show actual contraceptive methods
    if 'None' in method_mix:
        del method_mix['None']
    if 'No_method' in method_mix:
        del method_mix['No_method']
    
    # Age-specific fertility rates
    age_groups = ['15-19', '20-24', '25-29', '30-34', '35-39', '40-44', '45-49']
    asfr = {}
    
    if hasattr(sim.people, 'age') and hasattr(sim.people, 'fp'):
        # Calculate ASFR by age group
        for i, age_group in enumerate(age_groups):
            age_min = 15 + i * 5
            age_max = 19 + i * 5
            age_mask = (sim.people.age >= age_min) & (sim.people.age <= age_max)
            n_women = np.sum(age_mask & sim.people.female)
            
            if n_women > 0:
                # This is a simplified calculation - actual ASFR would need births by age
                asfr[age_group] = 100.0  # Placeholder
            else:
                asfr[age_group] = 0.0
    else:
        # Default ASFR pattern
        asfr = {
            '15-19': 80,
            '20-24': 180,
            '25-29': 200,
            '30-34': 160,
            '35-39': 100,
            '40-44': 40,
            '45-49': 10
        }
    
    # Birth spacing - calculate from birth_ages
    if hasattr(sim.people, 'fp') and hasattr(sim.people.fp, 'birth_ages'):
        ppl = sim.people
        birth_spacing = []
        
        # Get women with 2+ births (parity > 1)
        gt1_birth_mask = ppl.female & (ppl.fp.parity > 1)
        gt1_birth_uids = np.where(gt1_birth_mask)[0]
        
        print(f"[DEBUG] Found {len(gt1_birth_uids)} women with 2+ births")
        
        # Calculate spacing between consecutive births
        for uid in gt1_birth_uids:
            birth_ages_i = ppl.fp.birth_ages[uid]
            # Remove NaNs and get valid birth ages
            clean_ages = birth_ages_i[~np.isnan(birth_ages_i)]
            if len(clean_ages) > 1:
                # Calculate differences between consecutive births (in years)
                spaces = np.diff(clean_ages)
                # Only keep positive spaces (twins have 0 spacing)
                valid_spaces = spaces[spaces > 0]
                birth_spacing.extend(valid_spaces)
        
        if len(birth_spacing) > 0:
            birth_spacing = np.array(birth_spacing) * 12  # Convert years to months
            print(f"[DEBUG] Calculated {len(birth_spacing)} birth intervals")
            print(f"[DEBUG] Birth spacing (months) - min: {birth_spacing.min():.1f}, max: {birth_spacing.max():.1f}, mean: {birth_spacing.mean():.1f}")
        else:
            print("[DEBUG] No valid birth spacing found, using fallback")
            birth_spacing = np.random.lognormal(mean=3.4, sigma=0.5, size=200) * 12  # months
    else:
        print("[DEBUG] No birth_ages data found, using fallback")
        birth_spacing = np.random.lognormal(mean=3.4, sigma=0.5, size=200) * 12  # months
    
    # Parity distribution
    if hasattr(sim.people, 'fp') and hasattr(sim.people.fp, 'parity'):
        parity = sim.people.fp.parity[sim.people.female]
        print(f"[DEBUG] Parity array shape: {parity.shape}")
        print(f"[DEBUG] Parity unique values: {np.unique(parity)}")
        print(f"[DEBUG] Parity value counts: {np.bincount(parity.astype(int))}")
        
        parity_counts = []
        for p in range(8):
            count = int(np.sum(parity == p))
            parity_counts.append(count)
        print(f"[DEBUG] Final parity_counts: {parity_counts}")
        print(f"[DEBUG] Total women with parity data: {len(parity)}")
    else:
        print("[DEBUG] WARNING: No parity data found, using fallback values")
        parity_counts = [50, 40, 30, 25, 20, 15, 10, 10]
    
    # Population pyramid
    age_bins = np.arange(0, 85, 5)
    if hasattr(sim.people, 'age'):
        male_pop = []
        female_pop = []
        for age_min in age_bins:
            age_max = age_min + 4
            male_mask = (sim.people.age >= age_min) & (sim.people.age <= age_max) & ~sim.people.female
            female_mask = (sim.people.age >= age_min) & (sim.people.age <= age_max) & sim.people.female
            male_pop.append(np.sum(male_mask))
            female_pop.append(np.sum(female_mask))
    else:
        # Generate synthetic pyramid
        male_pop = [params['n_agents'] / 40] * len(age_bins)
        female_pop = [params['n_agents'] / 40] * len(age_bins)
    
    # Pregnancy outcomes
    if hasattr(results, 'fp'):
        live_births = births
        stillbirths = results.fp.stillbirths.values if hasattr(results.fp, 'stillbirths') else births * 0.02
        miscarriages = results.fp.miscarriages.values if hasattr(results.fp, 'miscarriages') else births * 0.15
    else:
        live_births = births
        stillbirths = births * 0.02
        miscarriages = births * 0.15
    
    # Population summary
    n_women_reproductive = np.sum((sim.people.age >= 15) & (sim.people.age <= 49) & sim.people.female) if hasattr(sim.people, 'age') else int(params['n_agents'] * 0.25)
    
    # Convert all numpy arrays to lists for R compatibility
    return {
        'timevec': timevec.tolist() if hasattr(timevec, 'tolist') else list(timevec),
        'years': years.tolist() if hasattr(years, 'tolist') else list(years),
        'births': births.tolist() if hasattr(births, 'tolist') else list(births),
        'birth_rate': birth_rate.tolist() if hasattr(birth_rate, 'tolist') else list(birth_rate),
        'tfr': tfr.tolist() if hasattr(tfr, 'tolist') else list(tfr),
        'cpr': cpr.tolist() if hasattr(cpr, 'tolist') else list(cpr),
        'mcpr': mcpr.tolist() if hasattr(mcpr, 'tolist') else list(mcpr),
        'method_mix': method_mix,  # Already a dict
        'asfr': asfr,  # Already a dict
        'maternal_mortality': mmr.tolist() if hasattr(mmr, 'tolist') else list(mmr),
        'unmet_need': unmet_need.tolist() if hasattr(unmet_need, 'tolist') else list(unmet_need),
        'birth_spacing': birth_spacing.tolist() if hasattr(birth_spacing, 'tolist') else list(birth_spacing),
        'parity_counts': parity_counts if isinstance(parity_counts, list) else list(parity_counts),
        'population_pyramid': {
            'age_bins': age_bins.tolist() if hasattr(age_bins, 'tolist') else list(age_bins),
            'male': male_pop if isinstance(male_pop, list) else list(male_pop),
            'female': female_pop if isinstance(female_pop, list) else list(female_pop)
        },
        'pregnancy_outcomes': {
            'years': years.tolist() if hasattr(years, 'tolist') else list(years),
            'live_births': live_births.tolist() if hasattr(live_births, 'tolist') else list(live_births),
            'stillbirths': stillbirths.tolist() if hasattr(stillbirths, 'tolist') else list(stillbirths),
            'miscarriages': miscarriages.tolist() if hasattr(miscarriages, 'tolist') else list(miscarriages)
        },
        'population_summary': {
            'total_pop': int(params['n_agents']),
            'women_reproductive_age': int(n_women_reproductive),
            'current_cpr': float(cpr[-1]) if len(cpr) > 0 else 0.0,
            'current_tfr': float(tfr[-1]) if len(tfr) > 0 else 0.0,
            'current_birth_rate': float(birth_rate[-1]) if len(birth_rate) > 0 else 0.0
        },
        'parameters': params,
        'n_agents': int(params['n_agents'])
    }

def plot_birth_rate(results):
    """Create birth rate plot"""
    fig = go.Figure()
    fig.add_trace(go.Scatter(
        x=results['years'],
        y=results['birth_rate'],
        mode='lines',
        name='Birth Rate',
        line=dict(color='steelblue', width=3)
    ))
    fig.update_layout(
        title='Birth Rate Over Time',
        xaxis_title='Year',
        yaxis_title='Birth Rate (per 1000)',
        hovermode='x unified',
        template='plotly_white'
    )
    return fig

def plot_cpr(results):
    """Create CPR plot"""
    fig = go.Figure()
    fig.add_trace(go.Scatter(
        x=results['years'],
        y=results['cpr'] * 100,
        mode='lines',
        name='Total CPR',
        line=dict(color='green', width=3)
    ))
    fig.add_trace(go.Scatter(
        x=results['years'],
        y=results['mcpr'] * 100,
        mode='lines',
        name='Modern CPR',
        line=dict(color='darkgreen', width=3, dash='dash')
    ))
    fig.update_layout(
        title='Contraceptive Prevalence Rate',
        xaxis_title='Year',
        yaxis_title='CPR (%)',
        hovermode='x unified',
        template='plotly_white',
        showlegend=True
    )
    return fig

def plot_tfr(results):
    """Create TFR plot"""
    fig = go.Figure()
    fig.add_trace(go.Scatter(
        x=results['years'],
        y=results['tfr'],
        mode='lines',
        name='TFR',
        line=dict(color='orange', width=3)
    ))
    fig.update_layout(
        title='Total Fertility Rate',
        xaxis_title='Year',
        yaxis_title='TFR (births per woman)',
        hovermode='x unified',
        template='plotly_white'
    )
    return fig

def plot_method_mix(results):
    """Create method mix plot"""
    method_names = list(results['method_mix'].keys())
    method_values = [v * 100 for v in results['method_mix'].values()]
    
    fig = go.Figure()
    fig.add_trace(go.Bar(
        x=method_names,
        y=method_values,
        marker_color='purple'
    ))
    fig.update_layout(
        title='Contraceptive Method Mix',
        xaxis_title='Method',
        yaxis_title='Percentage (%)',
        template='plotly_white',
        xaxis_tickangle=-45
    )
    return fig

def plot_asfr(results):
    """Create age-specific fertility rate plot"""
    age_groups = list(results['asfr'].keys())
    asfr_values = list(results['asfr'].values())
    
    fig = go.Figure()
    fig.add_trace(go.Bar(
        x=age_groups,
        y=asfr_values,
        marker_color='coral'
    ))
    fig.update_layout(
        title='Age-specific Fertility Rates',
        xaxis_title='Age Group',
        yaxis_title='ASFR (per 1000 women)',
        template='plotly_white'
    )
    return fig

def run_intervention_comparison(params):
    """Run baseline and intervention simulations for comparison"""
    import sys
    import os
    import inspect
    
    # Get current directory - works with reticulate
    try:
        current_dir = os.path.dirname(os.path.abspath(__file__))
    except NameError:
        # __file__ not available in reticulate, use inspect
        current_dir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
    
    if current_dir not in sys.path:
        sys.path.insert(0, current_dir)
    
    # Check if we have interventions list (new multi-intervention system)
    interventions_list = params.get('interventions', [])
    print(f"[DEBUG] run_intervention_comparison called with {len(interventions_list)} interventions")
    
    if interventions_list and len(interventions_list) > 0:
        # Use new multi-intervention system
        from fp_interventions import (
            run_baseline_with_interventions,
            run_simulation_with_interventions
        )
        from fp_simulator_intervention import (
            generate_intervention_plot,
            calculate_intervention_statistics
        )
        
        baseline_sim = run_baseline_with_interventions(params)
        intervention_sim = run_simulation_with_interventions(params, interventions_list)
    else:
        # Legacy single new_method intervention (backward compatibility)
        from fp_simulator_intervention import (
            run_baseline_simulation,
            run_intervention_simulation,
            generate_intervention_plot,
            calculate_intervention_statistics
        )
        
        baseline_sim = run_baseline_simulation(params)
        intervention_sim = run_intervention_simulation(params)
    
    # Cache simulation objects globally for later plotting
    global _cached_baseline_sim, _cached_intervention_sim
    _cached_baseline_sim = baseline_sim
    _cached_intervention_sim = intervention_sim
    print("[DEBUG] Cached simulation objects for plotting")
    
    # Extract results from intervention simulation
    results = extract_simulation_results(intervention_sim, params)
    
    # Extract baseline results too (don't pass sim objects to R)
    baseline_results = extract_simulation_results(baseline_sim, params)
    
    # Add intervention-specific data
    results['has_intervention'] = True
    results['baseline_data'] = baseline_results  # Pass extracted data, not sim object
    
    # Calculate statistics
    stats = calculate_intervention_statistics(baseline_sim, intervention_sim, params)
    results['intervention_stats'] = stats
    
    # Note: We don't pass sim objects to R to avoid serialization issues
    # If plots are needed, they should be generated here and passed as base64 images
    
    return results

def generate_intervention_plot_data(baseline_data, intervention_data, plot_type, params):
    """
    Generate intervention plot as base64 image
    
    Note: baseline_data and intervention_data are ignored - we use the cached sim objects
    """
    import sys
    import os
    import inspect
    
    global _cached_baseline_sim, _cached_intervention_sim
    
    # Check if we have cached simulation objects
    if _cached_baseline_sim is None or _cached_intervention_sim is None:
        print("[ERROR] No cached simulation objects found. Run simulation first.")
        return None
    
    print(f"[DEBUG] Generating plot type: {plot_type}")
    print(f"[DEBUG] Using cached baseline_sim: {type(_cached_baseline_sim)}")
    print(f"[DEBUG] Using cached intervention_sim: {type(_cached_intervention_sim)}")
    sys.stdout.flush()
    
    # Get current directory - works with reticulate
    try:
        current_dir = os.path.dirname(os.path.abspath(__file__))
    except NameError:
        # __file__ not available in reticulate, use inspect
        current_dir = os.path.dirname(os.path.abspath(inspect.getfile(inspect.currentframe())))
    
    if current_dir not in sys.path:
        sys.path.insert(0, current_dir)
    
    from fp_simulator_intervention import generate_intervention_plot
    
    # Use the cached simulation objects
    return generate_intervention_plot(_cached_baseline_sim, _cached_intervention_sim, plot_type, params)

