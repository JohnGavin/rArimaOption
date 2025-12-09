# Implementation Plan - Phase 1: R Package for ARIMA-Based Option Pricing

This plan outlines the steps to create an R package `rArimaOption` that implements the financial modeling workflow described in the referenced material. The package will include functionalities for simulating stock price paths (GBM, SVJD, Heston), extracting risk premiums via ARIMA, transforming to risk-neutral paths, and pricing European options.

## User Review Required

> [!IMPORTANT]
> The packages `esgtoolkit` and `ahead` are hosted on GitHub (`Techtonique/esgtoolkit`, `Techtonique/ahead`). We will need to ensure these can be installed in your environment or added as `Remotes` in the package `DESCRIPTION`.

## Proposed Packages

The following packages are required:

```r
required_packages <- c(
  "esgtoolkit",   # Simulation of SVJD, Heston (GitHub: Techtonique/esgtoolkit)
  "ahead",        # Residual resampling (GitHub: Techtonique/ahead)
  "forecast",     # ARIMA modeling (CRAN)
  "targets",      # Workflow management (CRAN)
  "tarchetypes",  # Targets helpers (CRAN)
  "ggplot2",      # Visualization (CRAN)
  "dplyr",        # Data manipulation (CRAN)
  "stats"         # Statistics (Base)
)
```

## Proposed Changes

### Setup

#### [NEW] `rArimaOption` Structure
- Initialize a new R package using `usethis::create_package`.
- Configure `DESCRIPTION` with dependencies and Remotes for `esgtoolkit` and `ahead`.

### Simulation Implementation

#### [NEW] `R/simulate.R`
- Functions to wrap `esgtoolkit` simulations for consistent output.
- `sim_gbm(n, h, frequency, S0, mu, sigma)`
- `sim_svjd(n, r0, ...)`
- `sim_heston(n, r0, ...)`

### Risk Neutral Transformation

#### [NEW] `R/risk_neural.R`
- `fit_arima_increments(martingale_increments)`: Fits ARIMA models to increments.
- `generate_risk_neutral_paths(arima_models, residuals, n_sim, S0, r, maturity)`: Implements the residual resampling and path generation logic.

### Pricing

#### [NEW] `R/pricing.R`
- `price_european_option(paths, strikes, r, maturity)`: Calculates option prices from terminal values.
- `bs_price(...)`: Black-Scholes analytical formula for verification.

### Workflow

#### [NEW] `_targets.R`
- Define targets for:
    - Simulation parameters.
    - Physical path generation (GBM, SVJD, Heston).
    - Martingale difference calculation.
    - ARIMA fitting.
    - Risk-neutral path generation.
    - Option pricing.
    - Plotting results.

### Documentation

#### [NEW] `vignettes/simulation_pricing.Rmd`
- A vignette illustrating the entire workflow using the implemented functions.

## Verification Plan

### Automated Tests
- Run `devtools::check()` to verify package integrity.
- Run `tar_make()` to execute the pipeline.
- Create a test file `tests/testthat/test-pricing.R` to verify:
    - Black-Scholes pricing matches analytical formula for GBM cases (approx).
    - Dimensions of simulated paths.

### Manual Verification
- Inspect the generated plots in the targets output or vignette.
- Check if the risk-neutral terminal mean aligns with S0 * exp(rT).
