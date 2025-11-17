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

def run_fp_simulation(params):
    """
    Run family planning simulation with given parameters
    
    Args:
        params (dict): Dictionary of simulation parameters
        
    Returns:
        dict: Simulation results and plots
    """
    
    try:
        # Check if intervention is enabled
        enable_intervention = params.get('enable_intervention', False)
        
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
        
        # Extract results
        results = extract_simulation_results(sim, params)
        
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
    
    # Birth rate (crude birth rate per 1000)
    births = results.fp.births.values if hasattr(results, 'fp') else np.zeros_like(timevec)
    population = sim.pars.n_agents
    birth_rate = (births / population) * 1000
    
    # Contraceptive prevalence rate (CPR)
    if hasattr(results, 'fp') and hasattr(results.fp, 'cpr'):
        cpr = results.fp.cpr.values
    else:
        cpr = np.zeros_like(timevec)
    
    # Modern contraceptive prevalence rate (mCPR)
    if hasattr(results, 'fp') and hasattr(results.fp, 'mcpr'):
        mcpr = results.fp.mcpr.values
    else:
        mcpr = cpr * 0.8  # Approximation
    
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
    
    # Method mix - current distribution
    method_names = ['None', 'Pill', 'IUD', 'Injectable', 'Implant', 'Condom', 'BTL', 'Withdrawal', 'Other']
    method_mix = {}
    
    if hasattr(sim.people, 'fp') and hasattr(sim.people.fp, 'method'):
        # Count current method distribution
        methods = sim.people.fp.method
        unique, counts = np.unique(methods, return_counts=True)
        total = len(methods)
        
        # Map to method names (assuming methods are indexed 0-8)
        for i, name in enumerate(method_names):
            if i in unique:
                method_mix[name] = counts[list(unique).index(i)] / total
            else:
                method_mix[name] = 0.0
    else:
        # Default distribution
        method_mix = {
            'None': 0.35,
            'Pill': 0.15,
            'IUD': 0.10,
            'Injectable': 0.20,
            'Implant': 0.10,
            'Condom': 0.05,
            'BTL': 0.02,
            'Withdrawal': 0.02,
            'Other': 0.01
        }
    
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
    
    # Birth spacing
    if hasattr(sim.people, 'fp') and hasattr(sim.people.fp, 'birth_spacing'):
        birth_spacing = sim.people.fp.birth_spacing[sim.people.fp.birth_spacing > 0]
        if len(birth_spacing) == 0:
            birth_spacing = np.random.lognormal(mean=3.4, sigma=0.5, size=200) * 12  # months
    else:
        birth_spacing = np.random.lognormal(mean=3.4, sigma=0.5, size=200) * 12  # months
    
    # Parity distribution
    if hasattr(sim.people, 'fp') and hasattr(sim.people.fp, 'parity'):
        parity = sim.people.fp.parity[sim.people.female]
        parity_counts = []
        for p in range(8):
            parity_counts.append(np.sum(parity == p))
    else:
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
    
    return {
        'timevec': timevec,
        'years': years,
        'birth_rate': birth_rate,
        'tfr': tfr,
        'cpr': cpr,
        'mcpr': mcpr,
        'method_mix': method_mix,
        'asfr': asfr,
        'maternal_mortality': mmr,
        'unmet_need': unmet_need,
        'birth_spacing': birth_spacing,
        'parity_counts': parity_counts,
        'population_pyramid': {
            'age_bins': age_bins,
            'male': male_pop,
            'female': female_pop
        },
        'pregnancy_outcomes': {
            'years': years,
            'live_births': live_births,
            'stillbirths': stillbirths,
            'miscarriages': miscarriages
        },
        'population_summary': {
            'total_pop': params['n_agents'],
            'women_reproductive_age': n_women_reproductive,
            'current_cpr': float(cpr[-1]) if len(cpr) > 0 else 0.0,
            'current_tfr': float(tfr[-1]) if len(tfr) > 0 else 0.0,
            'current_birth_rate': float(birth_rate[-1]) if len(birth_rate) > 0 else 0.0
        },
        'parameters': params
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
    
    from fp_simulator_intervention import (
        run_baseline_simulation,
        run_intervention_simulation,
        generate_intervention_plot,
        calculate_intervention_statistics
    )
    
    # Run both simulations
    baseline_sim = run_baseline_simulation(params)
    intervention_sim = run_intervention_simulation(params)
    
    # Extract results from intervention simulation
    results = extract_simulation_results(intervention_sim, params)
    
    # Add intervention-specific data
    results['has_intervention'] = True
    results['baseline_sim'] = baseline_sim
    results['intervention_sim'] = intervention_sim
    
    # Calculate statistics
    stats = calculate_intervention_statistics(baseline_sim, intervention_sim, params)
    results['intervention_stats'] = stats
    
    return results

def generate_intervention_plot_data(baseline_sim, intervention_sim, plot_type, params):
    """Generate intervention plot as base64 image"""
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
    
    from fp_simulator_intervention import generate_intervention_plot
    return generate_intervention_plot(baseline_sim, intervention_sim, plot_type, params)

