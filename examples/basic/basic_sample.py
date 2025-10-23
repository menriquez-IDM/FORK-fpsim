#!/usr/bin/env python3
"""
Basic FPsim Sample - A comprehensive introduction to FPsim

This script demonstrates the core functionality of FPsim:
1. Simple simulation with default parameters
2. Custom simulation with specific parameters
3. Multiple location examples
4. Basic plotting and analysis
5. Experiment framework usage

Run this script to see FPsim in action!
"""

import sciris as sc
import fpsim as fp
from fpsim import plotting as plt

def main():
    print("=" * 60)
    print("FPsim Basic Sample - Family Planning Simulation")
    print("=" * 60)
    
    # Example 1: Simplest possible simulation
    print("\n1. Running simplest simulation (default parameters)...")
    sc.tic()
    sim1 = fp.Sim()
    sim1.run()
    elapsed = sc.toc()
    if elapsed is not None:
        print(f"✓ Completed in {elapsed:.2f} seconds")
    else:
        print("✓ Completed (timing not available)")
    
    # Example 2: Custom simulation with specific parameters
    print("\n2. Running custom simulation (Kenya, 1000 agents)...")
    pars = dict(
        location='kenya',
        n_agents=1000,
        start_year=2000,
        end_year=2020,
        exposure_factor=1.0
    )
    
    sc.tic()
    sim2 = fp.Sim(pars=pars)
    sim2.run()
    elapsed = sc.toc()
    if elapsed is not None:
        print(f"✓ Completed in {elapsed:.2f} seconds")
    else:
        print("✓ Completed (timing not available)")
    
    # Example 3: Different locations
    print("\n3. Running simulations for different locations...")
    locations = ['senegal', 'ethiopia']
    
    for location in locations:
        print(f"   Running {location} simulation...")
        sc.tic()
        pars_loc = dict(
            location=location,
            n_agents=500,  # Smaller for faster execution
            start_year=2000,
            end_year=2015
        )
        sim_loc = fp.Sim(pars=pars_loc)
        sim_loc.run()
        elapsed = sc.toc()
        if elapsed is not None:
            print(f"   ✓ {location.capitalize()} completed in {elapsed:.2f} seconds")
        else:
            print(f"   ✓ {location.capitalize()} completed (timing not available)")
    
    # Example 4: Basic plotting
    print("\n4. Generating plots...")
    try:
        # Plot the main simulation results
        fig1 = sim2.plot()
        print("✓ Main simulation plot generated")
        
        # Plot calibration results
        fig2 = plt.plot_calib(sim2)
        print("✓ Calibration plot generated")
        
    except Exception as e:
        print(f"⚠ Plotting failed: {e}")
        print("   (This is normal if running without display)")
    
    # Example 5: Experiment framework
    print("\n5. Running experiment framework...")
    try:
        sc.tic()
        exp = fp.Experiment()
        exp.run()
        elapsed = sc.toc()
        if elapsed is not None:
            print(f"✓ Experiment completed in {elapsed:.2f} seconds")
        else:
            print("✓ Experiment completed (timing not available)")
        
        # Show experiment summary
        df = exp.summarize()
        print("\nExperiment Summary:")
        if hasattr(df, 'to_string'):
            print(df.to_string())
        else:
            print(df)
        
    except Exception as e:
        print(f"⚠ Experiment failed: {e}")
        print("   (This may require additional setup)")
    
    # Example 6: Accessing results
    print("\n6. Accessing simulation results...")
    print(f"   Final population size: {sim2.results['n_alive'][-1]:,.0f}")
    print(f"   Total deaths: {sim2.results['cum_deaths'][-1]:,.0f}")
    print(f"   Urban population: {sim2.results['n_urban'][-1]:,.0f}")
    
    # Show available result keys
    print(f"\n   Available result keys: {list(sim2.results.keys())}")
    
    print("\n" + "=" * 60)
    print("Basic sample completed successfully!")
    print("=" * 60)
    print("\nNext steps:")
    print("- Try different locations: 'kenya', 'senegal', 'ethiopia'")
    print("- Adjust n_agents for different population sizes")
    print("- Modify start_year and end_year for different time periods")
    print("- Use fp.Experiment() for calibration and analysis")
    print("- Check examples/ directory for more advanced usage")

if __name__ == '__main__':
    main()
