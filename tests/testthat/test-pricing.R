test_that("price_european_option calculates correct payoff for known paths", {
  # Deterministic paths
  # 3 paths with S_T = 90, 100, 110
  price_paths <- matrix(c(100, 90, 100, 100, 100, 110), nrow = 2, byrow = FALSE)
  
  K <- 100
  r <- 0
  maturity <- 1
  
  # Call: max(90-100,0)=0, max(100-100,0)=0, max(110-100,0)=10
  # Mean = 10/3 = 3.333...
  res_call <- price_european_option(price_paths, K, r, maturity, "call")
  expect_equal(res_call$price, 10/3)
  
  # Put: max(100-90,0)=10, 0, 0
  # Mean = 10/3
  res_put <- price_european_option(price_paths, K, r, maturity, "put")
  expect_equal(res_put$price, 10/3)
})

test_that("price_european_option handles discounting", {
  price_paths <- matrix(c(100, 110), nrow = 2) # 1 path S_T=110
  K <- 100
  r <- 0.1
  maturity <- 1
  
  # Call Payoff = 10
  # Price = 10 * exp(-0.1)
  res <- price_european_option(price_paths, K, r, maturity, "call")
  expect_equal(res$price, 10 * exp(-0.1))
})
