#' Fit ARIMA to Price Paths (Log-Returns)
#'
#' Fits an ARIMA model to the log-returns of a price series to capture the physical measure dynamics.
#'
#' @param prices Numeric vector or time series of prices.
#' @param ... Arguments passed to \code{forecast::auto.arima}.
#'
#' @return An object of class \code{forecast_ARIMA}.
#' @importFrom forecast auto.arima arimaorder
#' @importFrom stats residuals coef simulate rnorm diff
#' @export
fit_arima_returns <- function(prices, ...) {
  if (any(prices <= 0)) stop("Prices must be positive for log-returns.")
  log_returns <- diff(log(prices))
  # Heuristic: method="CSS-ML" is often faster/stable for simulation loops?
  # Defaulting to auto.arima defaults.
  model <- forecast::auto.arima(log_returns, ...)
  return(model)
}

#' Generate Risk-Neutral Paths via Residual Resampling
#'
#' Transforms a physical measure ARIMA process to a risk-neutral process by adjusting the drift
#' and resampling residuals.
#'
#' @param arima_model A fitted ARIMA model (from \code{fit_arima_returns}).
#' @param n_paths Number of paths to simulate.
#' @param h Time horizon (number of steps).
#' @param S0 Initial stock price.
#' @param r Risk-free rate (annualized).
#' @param dt Time step size (e.g., 1/252 for daily).
#'
#' @return A matrix of simulated price paths (n_paths x h).
#' @export
generate_risk_neutral_paths <- function(arima_model, n_paths, h, S0, r, dt) {
  # 1. Extract residuals from the fitted model
  resids <- residuals(arima_model)
  
  # 2. Bootstrap residuals
  # We use simple sampling with replacement. 
  # For 'ahead' or block bootstrap, we might need dependencies, 
  # but here we implement simple i.i.d. resampling as a baseline.
  boot_resids <- matrix(sample(resids, n_paths * h, replace = TRUE), nrow = h, ncol = n_paths)
  
  # 3. Simulate process
  # ARIMA structure: phi(B)(1-B)^d X_t = theta(B) epsilon_t
  # But we are working with log-returns directly fitted.
  # If d=0 (stationary returns), model is ARMA on returns.
  # If d=1, model is ARIMA on returns (integrated returns?). 
  # Usually returns are stationary, so d=0.
  
  # Note: auto.arima on log-returns usually yields ARMA(p,q).
  
  # The drift in the Physical Measure is the intercept 'c' (or mean).
  # The drift in the Risk Neutral Measure implies E[S_T] = S_0 * exp(rT).
  # For log-returns r_t = ln(S_t/S_{t-1}):
  # E[r_t] should correspond to (r - 0.5 * sigma^2) * dt ? 
  # Or simply force the sample mean of simulated log-returns to match the risk-free drift.
  
  # APPROACH:
  # 1. Simulate *centered* paths using the ARIMA structure (no intercept).
  # 2. Add the Risk-Neutral Drift explicitly.
  
  # Simulate ARIMA paths using `simulate` from stats/forecast?
  # `simulate.Arima` creates one path. We need multiple.
  # And we want to inject our SPECIFIC bootstrapped residuals.
  # Base R `arima.sim` or `filter`?
  # `stats::filter` allows custom innovation input?
  
  # Let's assume ARMA(p,q) for returns:
  # y_t = c + phi*y_{t-1} + ... + theta*eps_{t-1} + ... + eps_t
  
  # Risk Neutral Transformation:
  # Replace 'c' (physical drift) with 'c_rn' (risk neutral drift).
  # c_rn should be such that Mean(log_return) ~ (r - 0.5 * sigma^2) * dt.
  
  # Estimate sigma from residuals
  sigma2 <- var(resids, na.rm=TRUE) 
  # If dt is small? sigma is per step.
  # r is annualized. r_step = r * dt.
  # Target Mean Log Return = r * dt - 0.5 * sigma2
  
  mu_rn <- r * dt - 0.5 * sigma2
  
  # Extract coefficients
  coefs <- coef(arima_model)
  # Remove intercept/mean if present
  ar_coefs <- coefs[grep("^ar", names(coefs))]
  ma_coefs <- coefs[grep("^ma", names(coefs))]
  
  # Simulation Loop (vectorized over paths?)
  # `arima.sim` uses innovations.
  # We can iterate over paths.
  
  sim_log_returns <- matrix(0, nrow = h, ncol = n_paths)
  
  for (i in 1:n_paths) {
    # Bootstrap innovations for this path
    innov <- boot_resids[, i]
    
    # Simulate ARMA with mean 0 (centered)
    # We use arima.sim logic but passing custom innovations is tricky with standard arima.sim
    # because it generates its own.
    # But `arima.sim(..., n, innov=...)` works!
    
    # Construct model list
    model_list <- list(order = forecast::arimaorder(arima_model))
    if(length(ar_coefs) > 0) model_list$ar <- ar_coefs
    if(length(ma_coefs) > 0) model_list$ma <- ma_coefs
    
    # Simulate centered returns
    sim_centered <- stats::arima.sim(model = model_list, n = h, innov = innov)
    
    # Add Risk Neutral Drift
    sim_log_returns[, i] <- as.numeric(sim_centered) + mu_rn
  }
  
  # Reconstruct Prices
  # P_t = P_0 * exp(cumsum(log_returns))
  price_paths <- matrix(0, nrow = h + 1, ncol = n_paths)
  price_paths[1, ] <- S0
  
  for (i in 1:n_paths) {
    price_paths[2:(h+1), i] <- S0 * exp(cumsum(sim_log_returns[, i]))
  }
  
  return(price_paths)
}
