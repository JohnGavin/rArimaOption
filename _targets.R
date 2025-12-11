library(targets)
library(tarchetypes)

# Source R functions
tar_source("R/")

tar_option_set(
  packages = c("dplyr", "ggplot2", "esgtoolkit", "ahead", "forecast")
)

list(
  # ============================================================================
  # Infrastructure: Nix Environment Management
  # ============================================================================
  tar_target(description_file, "DESCRIPTION", format = "file"),
  tar_target(maintain_script, "../../R/setup/maintain_env.R", format = "file"),

  tar_target(
    nix_env_update,
    {
      # Dependencies
      description_file
      maintain_script
      
      # Run the script to generate default.nix and packages.R
      # We source the script locally to ensure we have the function
      source("../../R/setup/maintain_env.R")
      maintain_env()
      
      # Return the paths to the generated files
      c("default.nix", "packages.R")
    },
    format = "file"
  ),

  # ============================================================================
  # Simulation Parameters
  # ============================================================================
  tar_target(n_sim, 250),           # Number of time steps
  tar_target(horizon, 5),           # Horizon in years
  tar_target(freq, "daily"),
  tar_target(s0, 100),              # Initial price
  tar_target(mu_p, 0.08),           # Drift under Physical measure (P)
  tar_target(sigma, 0.04),          # Volatility (for GBM)
  tar_target(r_riskfree, 0.05),     # Risk-free rate
  tar_target(maturity, 5),          # Maturity for options

  # ============================================================================
  # Physical Measure Simulations
  # ============================================================================
  
  # Geometric Brownian Motion
  tar_target(gbm_paths, 
             sim_gbm(n = n_sim, h = horizon, frequency = freq, 
                     S0 = s0, mu = mu_p, sigma = sigma)),
  
  # Stochastic Volatility with Jump Diffusion
  tar_target(sim_svjd_data,
             sim_svjd(n = n_sim, r0 = mu_p)),
  
  # Heston Model (SVJD without jumps)
  tar_target(sim_heston_data,
              sim_heston(n = n_sim, r0 = mu_p)),
              
  tar_target(
    plot_heston,
    plot_simulations(sim_heston_data, "Heston Model Paths")
  ),
  
  # --- Phase 2: Risk Neutralization & Pricing ---
  
  # 1. Simulate "Physical" History (1 path, 1 year)
  tar_target(
    physical_history,
    {
      # n = number of paths (must be > 1 for esgtoolkit)
      # h = horizon in years (1)
      paths <- sim_gbm(n = 2, h = 1, S0 = 100, mu = 0.08, sigma = 0.2)
      as.numeric(paths[, 1]) # Take first path
    }
  ),
  
  # 2. Fit ARIMA to Physical History
  tar_target(
    arima_model,
    fit_arima_returns(physical_history)
  ),
  
  # 3. Generate Risk Neutral Paths for Pricing (at end of history)
  tar_target(
    rn_paths,
    generate_risk_neutral_paths(
      arima_model, 
      n_paths = 1000, 
      h = 63, # 3 months 
      S0 = tail(physical_history, 1), 
      r = 0.03, 
      dt = 1/252
    )
  ),
  
  # 4. Price European Call Option (K=Strike relative to S0 observed)
  tar_target(
    option_price,
    price_european_option(
      rn_paths, 
      K = 100, 
      r = 0.03, 
      maturity = 0.25, # 3 months in years
      type = "call"
    )
  ),

  # 5. Report
  tar_target(
    risk_neutral_report_output,
    {
      # Ensure inst/doc directory exists
      if (!dir.exists("inst/doc")) {
        dir.create("inst/doc")
      }
      
      # Render the Quarto document. It will output to the same directory.
      quarto::quarto_render(input = "vignettes/risk_neutral_pricing.qmd")
      
      # Move the rendered HTML to inst/doc
      file.rename(
        from = "vignettes/risk_neutral_pricing.html",
        to = "inst/doc/risk_neutral_pricing.html"
      )
      
      "inst/doc/risk_neutral_pricing.html" # Return path to rendered file
    },
    format = "file"
  ),
  
  tar_target(
    pricing_methods_output,
    {
      if (!dir.exists("inst/doc")) {
        dir.create("inst/doc")
      }
      quarto::quarto_render(input = "vignettes/pricing_methods.qmd")
      file.rename(
        from = "vignettes/pricing_methods.html",
        to = "inst/doc/pricing_methods.html"
      )
      "inst/doc/pricing_methods.html"
    },
    format = "file"
  ),
  
  tar_target(
    risk_neutral_transformation_output,
    {
      if (!dir.exists("inst/doc")) {
        dir.create("inst/doc")
      }
      quarto::quarto_render(input = "vignettes/risk_neutral_transformation.qmd")
      file.rename(
        from = "vignettes/risk_neutral_transformation.html",
        to = "inst/doc/risk_neutral_transformation.html"
      )
      "inst/doc/risk_neutral_transformation.html"
    },
    format = "file"
  ),
  
  tar_target(
    simulations_output,
    {
      if (!dir.exists("inst/doc")) {
        dir.create("inst/doc")
      }
      quarto::quarto_render(input = "vignettes/simulations.qmd")
      file.rename(
        from = "vignettes/simulations.html",
        to = "inst/doc/simulations.html"
      )
      "inst/doc/simulations.html"
    },
    format = "file"
  ),

  # ============================================================================
  # Verification / Plots
  # ============================================================================
  tar_target(plot_gbm, 
             {
               # Save plot to file or return plot object if possible (esgplotbands defaults to base plot?)
               # esgplotbands uses base graphics. We can wrap it in png()
               NULL 
             })
)
