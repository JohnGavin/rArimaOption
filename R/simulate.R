#' Simulate Geometric Brownian Motion
#'
#' @param n Number of time steps
#' @param h Horizon in years
#' @param frequency Frequency of simulation (e.g. "daily")
#' @param S0 Initial price
#' @param mu Drift
#' @param sigma Volatility
#' @param ... Additional arguments passed to esgtoolkit::simdiff
#' 
#' @return A time series object of simulated paths
#' @export
sim_gbm <- function(n, h, frequency = "daily", S0 = 100, mu = 0.05, sigma = 0.2, ...) {
  esgtoolkit::simdiff(n = n, horizon = h, frequency = frequency, 
                      x0 = S0, theta1 = mu, theta2 = sigma, ...)
}

#' Simulate Stochastic Volatility with Jumps (SVJD)
#'
#' @param n Number of time steps
#' @param r0 Initial return/drift parameter
#' @param ... Additional arguments passed to esgtoolkit::rsvjd
#'
#' @return A time series object of simulated paths
#' @export
sim_svjd <- function(n, r0 = 0.05, ...) {
  esgtoolkit::rsvjd(n = n, r0 = r0, ...)
}

#' Simulate Heston Model
#'
#' Uses SVJD with lambda=0 (no jumps).
#'
#' @param n Number of time steps
#' @param r0 Initial return/drift parameter
#' @param ... Additional arguments passed to esgtoolkit::rsvjd
#'
#' @return A time series object of simulated paths
#' @export
sim_heston <- function(n, r0 = 0.05, ...) {
  esgtoolkit::rsvjd(n = n, r0 = r0, lambda = 0, mu_J = 0, sigma_J = 0, ...)
}
