read https://thierrymoudiki.github.io//blog/2025/12/07/r/forecasting/ARIMA-Pricing
read references
https://github.com/thierrymoudiki/2025-12-07-risk-neutralization-with-ARIMA/blob/main/main.R
https://www.researchgate.net/publication/398427354_An_ARIMA-Based_Semi-Parametric_Approach_to_Market_Price_of_Risk_estimation_and_Risk-Neutral_Pricing/citation/download?_tp=eyJjb250ZXh0Ijp7ImZpcnN0UGFnZSI6InB1YmxpY2F0aW9uIiwicGFnZSI6InB1YmxpY2F0aW9uIn19

Read projects background instructions from claude_rix/AGENTS.md and from ./*.md files.
All commands should be run nix shell with all the R packages installed.
which is provided by the ./default.sh file in the root directory.

replicate  using our standard workflow pattern, how to 
Simulate stock price paths under three different models (GBM, SVJD, Heston) using the physical measure
Extract the risk premium using ARIMA modeling
Transform physical paths to risk-neutral paths through residual resampling
Price European options under the risk-neutral measure

Targets should include all outputs and inputs,
including all .qmd vignettes.
The R pkgdown packages should be used to locally generate a website, 
in prepartation for submitting it to GH Pages website.


phase 1 is to produce an R package 
with functionality to simulate each of the models.
use targets to store all simulation related inputs and outputs.
create vignettes to illustrate the models, including the non-parametric model.

Start by listing all the packages needed and a brief reason why.
Also, output the list of packages as an R vector e.g. c("pkg1", "pkg2")
but exclude standard R packages like dplyr, tidyr, tibble, ggplot2

plan all steps of what to do into PLAN_what.md and summarise for approval before proceeding.
Plan all steps of how to do it in the PLAN_how.md file.

Raise an issue to create a GH website. Which will require .github/workflows/*.yml to replicate all the tests, checks etc done locally.

Raise an issue to create a repo wiki. 
Migrate all the details in ./*.md files into the wiki, consolidate the ./*.md files, include heavy cross referencing links between them. 
The wiki should include a FAQ. This page can include one  or more questions on each material mistake (e.g. a major error, or a repeated minor error that took time to fix) or lesson learnt (e.g. plan_what or plan_how issue didnt work and we have to abandon it).

The nix shell produced by the ./default_dev.sh file should be used to run all development commands, as it contains all the required R packages else stop and ask for help.
The DESCRIPTION file should be the source from which to extract the list of packages needed for users using the package. 
This list can go into a ./packages.R file in the root directory, in the form """
library(dplyr)
library(ggplot2)
...
"""
This R package list should be used by a ./default.R file that uses the rix package to create a nix shell with all the required R packages, called default.nix. 
So changes to DESCRIPTION should update default.R and default.nix via a targets plan.
When running .github/workflows/*.yml files, default.nix should be used to create a nix shell with all the required R packages, to reproducue the users production environment, which will not contain development packages, only the minimum required to run the R code in the project package.

 Remember to enforce reproducitility, so R scripts should be used for each task, as much as possible, with the documented scripts, stored in ./R/setup/, organised into suitably organised subfolders.
e.g. a subfolder for each of the 9-steps in the workflow plan, or something similar.