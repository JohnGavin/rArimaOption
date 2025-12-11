# default.R
# Sources the maintenance script to regenerate the environment

source("../../R/setup/maintain_env.R")
generate_all_nix_files()
