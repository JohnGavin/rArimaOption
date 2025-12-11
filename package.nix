{ pkgs ? import (fetchTarball "https://github.com/rstats-on-nix/nixpkgs/archive/2025-02-24.tar.gz") {} }:

pkgs.rPackages.buildRPackage {
  name = "rArimaOption";
  src = ./.;

  propagatedBuildInputs = with pkgs.rPackages; [
    esgtoolkit
  ];

  nativeBuildInputs = with pkgs.rPackages; [
    knitr
    rmarkdown
    forecast
    targets
    tarchetypes
    dplyr
    ggplot2
    ahead
    quarto
    testthat
  ];
}

