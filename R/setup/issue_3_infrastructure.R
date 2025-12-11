# R/setup/issue_3_infrastructure.R
# Log for Issue #3: Infrastructure & Reproducibility
# 2025-12-11

# 1. Branch created
# usethis::pr_init("fix-issue-3-infrastructure")

# 2. Fixed R/setup/maintain_env.R
# - Updated to correctly extract dependencies from DESCRIPTION
# - Fixed shell_hook escaping to prevent $HOME artifact bug (Issue #9 ref)
# - Removed git_pkgs manual definition as packages are in rstats-on-nix
# - Updated rix call to use ide = "none"

# 3. Updated default.R
# - Sources R/setup/maintain_env.R

# 4. Updated _targets.R
# - Added file tracking for DESCRIPTION and maintain_env.R
# - Refactored nix_env_update target

# 5. Generated environment files
# source("R/setup/maintain_env.R")
# maintain_env()
# # Generated packages.R and default.nix

# 6. Verification
# - default.nix contains correct shellHook (mkdir -p $HOME)
# - default.nix contains required packages (ahead, esgtoolkit)

# 7. Next Steps:
# - Commit and Push
# - PR