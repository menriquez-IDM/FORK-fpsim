"""
FPsim Intervention Module for Shiny App
Handles method interventions and comparative analysis
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import fpsim as fp
from io import BytesIO
import base64

def fig_to_base64(fig):
    """Convert matplotlib figure to base64 string for embedding in HTML"""
    buf = BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    img_base64 = base64.b64encode(buf.read()).decode('utf-8')
    plt.close(fig)
    return img_base64

def run_baseline_simulation(params):
    """Run baseline simulation without intervention"""
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

def run_intervention_simulation(params):
    """Run simulation with new method intervention"""
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
    
    # Create new method
    new_method = fp.Method(
        name=params.get('new_method_name', 'my_new_method'),
        label=params.get('new_method_label', 'MY-NEW-METHOD'),
        efficacy=params.get('new_method_efficacy', 0.995),
        modern=True,
        dur_use=fp.methods.ln(6, 2.5),
        csv_name=params.get('new_method_label', 'MY-NEW-METHOD')
    )
    
    # Create intervention
    intervention_year = params.get('intervention_year', 2010)
    mod = fp.MethodIntervention(year=intervention_year, label=f'{new_method.label} Program')
    
    # Add method
    copy_from = params.get('copy_from_method', 'inj')
    initial_share = params.get('initial_share', 0.40)
    
    mod.add_method(
        method=new_method,
        copy_from_row=copy_from,
        copy_from_col=copy_from,
        initial_share=initial_share
    )
    
    # Set duration and efficacy
    duration_months = params.get('new_method_duration', 12)
    mod.set_duration_months(new_method.name, duration_months)
    mod.set_efficacy(new_method.name, new_method.efficacy)
    
    # Build intervention
    intv = mod.build()
    
    # Run simulation
    sim = fp.Sim(pars=pars, fp_pars=fp_pars, interventions=intv, 
                 label=f'With {new_method.label}')
    sim.run(verbose=0.1)
    return sim

def generate_intervention_plot(baseline_sim, intervention_sim, plot_type, params):
    """
    Generate intervention comparison plot
    
    Args:
        baseline_sim: Baseline simulation
        intervention_sim: Intervention simulation
        plot_type: Type of plot to generate
        params: Original parameters
    
    Returns:
        Base64 encoded PNG image
    """
    start_year = params['start']
    end_year = params['end']
    intervention_year = params.get('intervention_year', 2010)
    location = params['location']
    
    # Import plotting functions
    from plots import (
        create_summary_figure,
        plot_injectable_methods_comparison,
        plot_method_mix_evolution,
        plot_new_method_adoption,
        plot_method_comparison_bar,
        plot_cpr_comparison,
        plot_births_comparison,
        # New individual plot functions
        plot_new_method_adoption_rate,
        plot_injectable_new_method_trends,
        plot_total_injectable_share,
        plot_method_substitution_effects,
        plot_top_methods_by_usage,
        plot_all_methods_final_comparison
    )
    
    try:
        # All plot functions now return figures without saving them
        # We pass save_path=None to prevent auto-saving
        if plot_type == 'summary':
            fig = create_summary_figure(
                baseline_sim, intervention_sim,
                start_year, end_year, intervention_year, location,
                save_path=None
            )
        # New individual plots from the 4-row summary figure
        elif plot_type == 'adoption_rate':
            fig = plot_new_method_adoption_rate(
                baseline_sim, intervention_sim,
                start_year, end_year, intervention_year, location,
                save_path=None
            )
        elif plot_type == 'injectable_trends':
            fig = plot_injectable_new_method_trends(
                baseline_sim, intervention_sim,
                start_year, end_year, intervention_year, location,
                save_path=None
            )
        elif plot_type == 'total_injectable':
            fig = plot_total_injectable_share(
                baseline_sim, intervention_sim,
                start_year, end_year, intervention_year, location,
                save_path=None
            )
        elif plot_type == 'substitution':
            fig = plot_method_substitution_effects(
                baseline_sim, intervention_sim,
                start_year, end_year, intervention_year, location,
                save_path=None
            )
        elif plot_type == 'top_methods':
            fig = plot_top_methods_by_usage(
                baseline_sim, intervention_sim,
                start_year, end_year, intervention_year, location,
                save_path=None
            )
        elif plot_type == 'all_methods':
            fig = plot_all_methods_final_comparison(
                baseline_sim, intervention_sim,
                start_year, end_year, intervention_year, location,
                save_path=None
            )
        # Original plot types
        elif plot_type == 'injectables':
            fig = plot_injectable_methods_comparison(
                baseline_sim, intervention_sim,
                start_year, end_year, location, intervention_year,
                save_path=None
            )
        elif plot_type == 'method_mix':
            fig = plot_method_mix_evolution(
                intervention_sim, start_year, end_year, intervention_year, location,
                save_path=None
            )
        elif plot_type == 'adoption':
            fig = plot_new_method_adoption(
                intervention_sim, start_year, end_year, intervention_year, location,
                save_path=None
            )
        elif plot_type == 'method_bar':
            fig = plot_method_comparison_bar(
                baseline_sim, intervention_sim,
                start_year, end_year, intervention_year, location,
                save_path=None
            )
        elif plot_type == 'cpr':
            fig = plot_cpr_comparison(
                baseline_sim, intervention_sim,
                start_year, end_year, intervention_year, location,
                save_path=None
            )
        elif plot_type == 'births':
            fig = plot_births_comparison(
                baseline_sim, intervention_sim,
                start_year, end_year, intervention_year, location,
                save_path=None
            )
        else:
            # Default to summary
            fig = create_summary_figure(
                baseline_sim, intervention_sim,
                start_year, end_year, intervention_year, location,
                save_path=None
            )
        
        return fig_to_base64(fig)
    
    except Exception as e:
        # Return error plot
        fig, ax = plt.subplots(figsize=(10, 6))
        ax.text(0.5, 0.5, f'Error generating plot:\n{str(e)}',
                ha='center', va='center', fontsize=12, color='red', wrap=True)
        ax.axis('off')
        return fig_to_base64(fig)

def calculate_intervention_statistics(baseline_sim, intervention_sim, params):
    """Calculate key statistics comparing baseline and intervention"""
    start_year = params['start']
    end_year = params['end']
    intervention_year = params.get('intervention_year', 2010)
    
    # Final CPR/mCPR
    baseline_mcpr = baseline_sim.results.contraception.mcpr[-1]
    interv_mcpr = intervention_sim.results.contraception.mcpr[-1]
    baseline_cpr = baseline_sim.results.contraception.cpr[-1]
    interv_cpr = intervention_sim.results.contraception.cpr[-1]
    
    # Total births after intervention
    years_numeric = np.linspace(start_year, end_year, len(baseline_sim.results.timevec))
    years_mask = years_numeric >= intervention_year
    baseline_births = np.sum(baseline_sim.results.fp.births[years_mask])
    interv_births = np.sum(intervention_sim.results.fp.births[years_mask])
    births_averted = baseline_births - interv_births
    
    # New method adoption
    new_method_name = params.get('new_method_name', 'my_new_method')
    new_method_label = params.get('new_method_label', 'MY-NEW-METHOD')
    
    fp_mod = intervention_sim.connectors['fp']
    method_mix = fp_mod.method_mix
    methods = intervention_sim.connectors.contraception.methods
    
    final_adoption = 0
    n_users = 0
    if new_method_name in methods:
        method = methods[new_method_name]
        final_adoption = method_mix[method.idx, -1] * 100
        ppl = intervention_sim.people
        n_users = np.sum(ppl.fp.method == method.idx)
    
    stats = {
        'baseline_mcpr': baseline_mcpr,
        'interv_mcpr': interv_mcpr,
        'mcpr_change': interv_mcpr - baseline_mcpr,
        'baseline_cpr': baseline_cpr,
        'interv_cpr': interv_cpr,
        'cpr_change': interv_cpr - baseline_cpr,
        'baseline_births': int(baseline_births),
        'interv_births': int(interv_births),
        'births_averted': int(births_averted),
        'percent_reduction': 100 * births_averted / baseline_births if baseline_births > 0 else 0,
        'new_method_label': new_method_label,
        'new_method_adoption': final_adoption,
        'new_method_users': int(n_users),
        'intervention_year': intervention_year,
        'end_year': end_year
    }
    
    return stats

