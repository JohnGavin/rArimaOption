test_that("fit_arima_returns works on simulated GBM returns", {
  set.seed(123)
  n <- 500
  S0 <- 100
  mu <- 0.05
  sigma <- 0.2
  h <- 1/252 # daily
  
  # Simulate log prices: ln(S_t) - ln(S_{t-1}) ~ N((mu - 0.5*sigma^2)*h, sigma*sqrt(h))
  log_returns <- rnorm(n, mean = (mu - 0.5*sigma^2)*h, sd = sigma*sqrt(h))
  prices <- S0 * exp(cumsum(log_returns))
  
  model <- fit_arima_returns(prices)
  
  expect_s3_class(model, "Arima")
  expect_true(length(residuals(model)) == n - 1)
})

test_that("generate_risk_neutral_paths returns correct dimensions and basic properties", {
  set.seed(456)
  n_sim <- 50
  n_paths <- 10
  h <- 1/252
  S0 <- 100
  r <- 0.03
  
  # create dummy ARIMA model (white noise)
  # prices <- 100 * exp(cumsum(rnorm(n_sim) * 0.01))
  # model <- fit_arima_returns(prices)
  
  # Better: Mock an Arima object or just fit one quickly
  dummy_returns <- rnorm(100, 0, 0.01)
  dummy_prices <- 100 * exp(cumsum(dummy_returns))
  model <- forecast::auto.arima(diff(log(dummy_prices)))
  
  paths <- generate_risk_neutral_paths(model, n_paths = n_paths, h = n_sim, S0 = S0, r = r, dt = h)
  
  expect_true(is.matrix(paths))
  expect_equal(dim(paths), c(n_sim + 1, n_paths))
  expect_equal(paths[1, ], rep(S0, n_paths))
  expect_true(all(paths > 0)) # Prices should remain positive
})
