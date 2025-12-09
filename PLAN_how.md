# PLAN: HOW

## Workflow Strategy
- Use `R/setup/` scripts for all operations (git, checks, builds).
- Organize `R/setup/` into subfolders mapping to the workflow steps.
- Use `targets` for ALL outputs (simulations, pricing, vignettes, nix files).

## 1. Environment & Reproducibility
- **Packages**:
    - Create `R/setup/maintain_env.R`.
    - Function to read `DESCRIPTION`, extract dependencies, write to `packages.R`.
    - `default.R` reads `packages.R` and calls `rix::rix()` to generate `default.nix`.
    - Add to `_targets.R` to automate `default.nix` regeneration on DESCRIPTION change.

## 2. Risk Premium Extraction (ARIMA)
- **Method**: Use `forecast::auto.arima` or `ahead` package.
- **Function**: `extract_risk_premium(price_paths)`
    - Input: Time series of simulated prices (physical measure).
    - Logic: Fit ARIMA, extract residuals/drift.

## 3. Risk-Neutral Transformation
- **Method**: Empirical Martingale Simulation / Residual Resampling.
- **Function**: `transform_risk_neutral(physical_paths, risk_free_rate)`
    - Adjust drift to $r$.
    - Resample residuals to preserve distribution shape.

## 4. Option Pricing
- **Function**: `price_option(risk_neutral_paths, strike, maturity, type = "call")`
    - Discount expected payoff: $e^{-rT} E[\max(S_T - K, 0)]$.

## 5. Website & Docs
- **Pkgdown**: Configure `_pkgdown.yml`.
- **Target**: Add `tar_target(website, pkgdown::build_site())`.

## 6. Verification
- **R CMD Check**: strict 0 errors, 0 warnings, 0 notes.
    - Fix `$HOME` artifact issue (check `.Rbuildignore` or `default.nix` hook).
    - Initialize git repo properly.
