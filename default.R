# This file is responsible for generating default.nix.
# It sources the environment maintenance script and calls the main function.

source("R/setup/maintain_env.R")

maintain_env()