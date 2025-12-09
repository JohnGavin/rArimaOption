# R/setup/02_setup_structure.R
dir.create("R/setup/01_env", showWarnings = FALSE)
dir.create("R/setup/02_git", showWarnings = FALSE)
dir.create("R/setup/03_dev_workflow", showWarnings = FALSE)
dir.create("R/setup/04_checks", showWarnings = FALSE)
dir.create("R/setup/05_simulate", showWarnings = FALSE)
dir.create("R/setup/06_pricing", showWarnings = FALSE)
dir.create("R/setup/07_docs", showWarnings = FALSE)

# Move existing setup scripts if any
if (file.exists("R/setup/01_git_init.R")) {
  file.rename("R/setup/01_git_init.R", "R/setup/02_git/01_git_init.R")
}
if (file.exists("setup_pkg.R")) {
    file.rename("setup_pkg.R", "R/setup/01_env/00_setup_pkg.R")
}
