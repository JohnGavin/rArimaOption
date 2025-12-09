# Setup log for Issue #1
library(usethis)
library(gert)
library(gh)

# 1. Initialize PR (executed manually)
# usethis::pr_init("setup-repo-docs-issue-1")

# 2. Setup GitHub Pages
# gh::gh("POST /repos/JohnGavin/rArimaOption/pages", source = list(branch = "main", path = "/docs"), build_type = "workflow")

# 3. Create pkgdown config
# Created _pkgdown.yml manually

# 4. Create vignette placeholders
usethis::use_vignette("pricing_methods", "Pricing Methods")
usethis::use_vignette("risk_neutral_transformation", "Risk Neutral Transformation")

# 5. Convert vignettes to .qmd
# mv vignettes/pricing_methods.Rmd vignettes/pricing_methods.qmd
# mv vignettes/risk_neutral_transformation.Rmd vignettes/risk_neutral_transformation.qmd
# Edited headers to use format: html

# Note: pkgdown::build_site() failed due to missing esgtoolkit dependency in shell.