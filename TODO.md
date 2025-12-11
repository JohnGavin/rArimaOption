# Issues for rArimaOption (cts_gbm_stoc_vol)

## Group 1: Infrastructure & Reproducibility (Priority)
**Difficulty: Medium**
Critical for ensuring the project builds and runs consistently in the Nix environment.

1.  **Refactor Environment & Fix Dependencies**
    *   **Goal:** Enforce single source of truth for environment setup and fix missing runtime dependencies.
    *   **Tasks:**
        *   Update `finance/cts_gbm_stoc_vol/default.R` to source the shared `../../R/setup/maintain_env.R`.
        *   Remove the local duplicate `finance/cts_gbm_stoc_vol/R/setup/maintain_env.R`.
        *   **Fix DESCRIPTION:** Move `forecast` package from `Suggests` to `Imports`.
        *   Regenerate `default.nix` and `packages.R` using the updated maintenance script.
2.  **Verify Tests**
    *   **Goal:** Ensure current implementation is stable.
    *   **Tasks:**
        *   Run `devtools::test()` in the Nix shell.
        *   Verify that `test-pricing.R` and `test-risk_neutral.R` pass.

## Group 2: Documentation & Targets Pipeline
**Difficulty: Medium**
Ensuring documentation builds correctly.

3.  **Finalize Targets Pipeline for Vignettes**
    *   **Goal:** Ensure `risk_neutral_pricing.qmd` and others can be rendered via targets.
    *   **Tasks:**
        *   Review/Update `_targets.R` to define vignette objects.
        *   Implement `tar_target` calls that output HTML to `inst/doc/` (avoiding pkgdown rendering issues).
4.  **Build Pkgdown Site**
    *   **Goal:** Generate the project website locally.
    *   **Tasks:**
        *   Configure `_pkgdown.yml` to use pre-built articles (`build_articles: false`).
        *   Configure `.Rbuildignore` to exclude source vignettes.
        *   Run `pkgdown::build_site()` (or a `pkgdown_site` target) and verify.

## Group 3: Core Quantitative Refinement
**Difficulty: Hard**
Advanced features planned for Phase 2.

5.  **Implement Advanced Risk-Neutral Transformation (Ahead Integration)**
    *   **Goal:** Improve simulation realism.
    *   **Tasks:**
        *   Refactor `generate_risk_neutral_paths` to support block bootstrap or `ahead` package methods.
6.  **Implement Explicit Risk Premium Extraction**
    *   **Goal:** Provide clear output for extracted risk premium.
    *   **Tasks:**
        *   Create explicit function/return value for risk premium from `fit_arima_returns`.

## Group 4: Documentation & Expansion (Future)
**Difficulty: Medium**

7.  **GitHub Website Deployment**
    *   **Goal:** Deploy pkgdown site to GitHub Pages.
8.  **Repository Wiki Creation**
    *   **Goal:** Establish comprehensive documentation hub.
