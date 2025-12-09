# PLAN: WHAT

## Goal
Create an R package `rArimaOption` that implements option pricing using ARIMA-based risk neutralization.

## Deliverables

### Phase 1: Package Structure & Simulation (Completed)
- [x] R Package `rArimaOption` initialized.
- [x] Simulation functions implemented: `sim_gbm`, `sim_svjd`, `sim_heston`.
- [x] `targets` pipeline for simulations.
- [x] Quarto vignettes for simulations.

### Phase 2: Pricing & Risk Neutralization (Current Focus)
- [ ] **Risk Premium Extraction**: Implement ARIMA-based risk premium extraction.
- [ ] **Risk-Neutral Transformation**: Transform physical paths to risk-neutral paths via residual resampling (`ahead` package?).
- [ ] **Option Pricing**: functions to price European options on these paths.
- [ ] **Reproducibility**:
    - [ ] `R/setup/` folder with numbered scripts for the 9-step workflow.
    - [ ] `packages.R` in root generated from DESCRIPTION.
    - [ ] `default.R` using `rix` to generate `default.nix`.
- [ ] **Documentation**:
    - [ ] Quarto vignettes for pricing and risk neutralization.
    - [ ] `pkgdown` site generated locally.

### Phase 3: Documentation & Expansion (Future)
- [ ] **GitHub Website**: Issue to create GH Pages site, including workflows.
- [ ] **Wiki**: Issue to create repo wiki, migrate `*.md` files, FAQ.
