"""
FPsim Multiple Interventions Module for Shiny App
Handles various intervention types: efficacy, duration, method_mix, switching, new_method
"""

import numpy as np
import fpsim as fp

def build_interventions(params, interventions_list):
    """
    Build FPsim interventions from the interventions list.
    
    Args:
        params: Base simulation parameters
        interventions_list: List of intervention dictionaries from R
    
    Returns:
        List of built FPsim intervention objects
    """
    if not interventions_list or len(interventions_list) == 0:
        return []
    
    # Group interventions by year
    interventions_by_year = {}
    for intv_dict in interventions_list:
        year = intv_dict['year']
        if year not in interventions_by_year:
            interventions_by_year[year] = []
        interventions_by_year[year].append(intv_dict)
    
    # Build interventions for each year
    built_interventions = []
    
    for year, year_interventions in sorted(interventions_by_year.items()):
        # Create a single MethodIntervention for this year
        label = f"Interventions at {year}"
        if len(year_interventions) == 1:
            label = year_interventions[0].get('description', label)
        
        mod = fp.MethodIntervention(year=float(year), label=label)
        
        # Apply each intervention to this mod
        for intv_dict in year_interventions:
            intv_type = intv_dict['type']
            
            if intv_type == 'new_method':
                _add_new_method(mod, intv_dict)
            elif intv_type == 'update_method':
                _update_method(mod, intv_dict, params)
            elif intv_type == 'efficacy':
                _set_efficacy(mod, intv_dict)
            elif intv_type == 'duration':
                _set_duration(mod, intv_dict)
            elif intv_type == 'method_mix':
                _set_method_mix(mod, intv_dict, params)
            elif intv_type == 'switching':
                _scale_switching(mod, intv_dict, params)
        
        # Build and add to list
        built_interventions.append(mod.build())
    
    return built_interventions


def _add_new_method(mod, intv_dict):
    """Add a new contraceptive method"""
    new_method = fp.Method(
        name=intv_dict['name'],
        label=intv_dict['label'],
        efficacy=intv_dict['efficacy'],
        modern=True,
        dur_use=fp.methods.ln(6, 2.5),
        csv_name=intv_dict['label']
    )
    
    copy_from = intv_dict['copy_from']
    initial_share = intv_dict['initial_share']
    
    mod.add_method(
        method=new_method,
        copy_from_row=copy_from,
        copy_from_col=copy_from,
        initial_share=initial_share
    )
    
    # Set duration and efficacy
    mod.set_duration_months(intv_dict['name'], intv_dict['duration'])
    mod.set_efficacy(intv_dict['name'], intv_dict['efficacy'])


def _update_method(mod, intv_dict, params):
    """Update multiple parameters of an existing method"""
    method = intv_dict['method']
    params_dict = intv_dict.get('params', {})
    
    # Apply each parameter update
    if 'efficacy' in params_dict:
        mod.set_efficacy(method, params_dict['efficacy'])
    
    if 'duration' in params_dict:
        mod.set_duration_months(method, params_dict['duration'])
    
    if 'method_mix' in params_dict:
        # Need temporary sim for method mix
        temp_sim = fp.Sim(
            pars={
                'n_agents': params['n_agents'],
                'location': params['location'],
                'start_year': params['start'],
                'end_year': params['end']
            },
            label='Temp baseline for method mix'
        )
        temp_sim.init()
        mod.set_method_mix(method, params_dict['method_mix'], 
                          baseline_sim=temp_sim, print_method_mix=False)


def _set_efficacy(mod, intv_dict):
    """Set method efficacy"""
    method = intv_dict['method']
    value = intv_dict['value']
    mod.set_efficacy(method, value)


def _set_duration(mod, intv_dict):
    """Set method duration"""
    method = intv_dict['method']
    value = intv_dict['value']
    mod.set_duration_months(method, value)


def _set_method_mix(mod, intv_dict, params):
    """Set method mix share"""
    method = intv_dict['method']
    value = intv_dict['value']
    
    # Need to create a temporary sim to get baseline method mix
    temp_sim = fp.Sim(
        pars={
            'n_agents': params['n_agents'],
            'location': params['location'],
            'start_year': params['start'],
            'end_year': params['end']
        },
        label='Temp baseline for method mix'
    )
    temp_sim.init()
    
    mod.set_method_mix(method, value, baseline_sim=temp_sim, print_method_mix=False)


def _scale_switching(mod, intv_dict, params):
    """Scale switching matrix"""
    method = intv_dict['method']
    scale = intv_dict['value']
    
    # Need to create a temporary sim to get switching matrix
    temp_sim = fp.Sim(
        pars={
            'n_agents': params['n_agents'],
            'location': params['location'],
            'start_year': params['start'],
            'end_year': params['end']
        },
        label='Temp baseline for switching'
    )
    temp_sim.init()
    
    mod.scale_switching_matrix(temp_sim, target_method=method, scale_factor=scale)


def run_baseline_with_interventions(params):
    """Run baseline simulation"""
    pars = {
        'n_agents': int(params['n_agents']),
        'start_year': params['start'],
        'end_year': params['end'],
        'location': params['location'],
        'rand_seed': params.get('rand_seed', 1)
    }
    
    fp_pars = {
        'exposure_factor': params.get('exposure_factor', 1.0),
        'maternal_mortality_factor': params.get('maternal_mortality_factor', 1.0),
        'primary_infertility': params.get('primary_infertility', 0.05),
        'LAM_efficacy': params.get('lam_efficacy', 0.98),
    }
    
    sim = fp.Sim(pars=pars, fp_pars=fp_pars, label='Baseline')
    sim.run(verbose=0.1)
    return sim


def run_simulation_with_interventions(params, interventions_list):
    """Run simulation with multiple interventions"""
    pars = {
        'n_agents': int(params['n_agents']),
        'start_year': params['start'],
        'end_year': params['end'],
        'location': params['location'],
        'rand_seed': params.get('rand_seed', 1)
    }
    
    fp_pars = {
        'exposure_factor': params.get('exposure_factor', 1.0),
        'maternal_mortality_factor': params.get('maternal_mortality_factor', 1.0),
        'primary_infertility': params.get('primary_infertility', 0.05),
        'LAM_efficacy': params.get('lam_efficacy', 0.98),
    }
    
    # Build all interventions
    built_interventions = build_interventions(params, interventions_list)
    
    # Run simulation
    sim = fp.Sim(pars=pars, fp_pars=fp_pars, interventions=built_interventions,
                 label='With Interventions')
    sim.run(verbose=0.1)
    return sim

