# rArimaOption

ARIMA-Based Option Pricing R Package.

## Project Status

- **Repository**: [https://github.com/JohnGavin/rArimaOption](https://github.com/JohnGavin/rArimaOption)
- **Website**: [https://JohnGavin.github.io/rArimaOption](https://JohnGavin.github.io/rArimaOption) (Pending Deployment)
- **CI/CD**: Uses a reproducible Nix environment (via `rix`).

## Overview

This package implements a financial modeling workflow:
1.  **Simulation**: Simulate stock price paths under the physical measure (GBM, SVJD, Heston).
2.  **Risk Neutralization**: Fit ARIMA models to extract risk premiums and transform paths to the risk-neutral measure.
3.  **Pricing**: Price European options using the risk-neutral paths.

## Installation

This project uses **Nix** for reproducibility. 

```bash
# Enter the environment
nix-shell
# Start R
R
```

## Usage

```r
library(rArimaOption)

# 1. Simulate Physical Paths
paths <- sim_gbm(n = 100, h = 1, S0 = 100, mu = 0.05, sigma = 0.2)

# 2. Risk Neutralization (Coming Soon)
# ...

# 3. Pricing (Coming Soon)
# ...
```
