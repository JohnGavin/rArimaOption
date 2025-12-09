library(targets)
library(tarchetypes)

# Source R functions
tar_source("R/")

tar_option_set(
  packages = c("dplyr", "ggplot2", "esgtoolkit", "ahead", "forecast")
)

list(
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
  tar_target(svjd_paths,
             sim_svjd(n = n_sim, r0 = mu_p)),
  
  # Heston Model (SVJD without jumps)
  tar_target(heston_paths,
             sim_heston(n = n_sim, r0 = mu_p)),

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
