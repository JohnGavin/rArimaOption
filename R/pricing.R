#' Price European Option via Monte Carlo
#'
#' Calculates the price of a European option given simulated risk-neutral price paths.
#'
#' @param price_paths A matrix of simulated price paths (rows=steps, cols=paths).
#'   The last row is assumed to be the price at maturity S_T.
#' @param K Strike price.
#' @param r Risk-free rate (annualized).
#' @param maturity Time to maturity (in years).
#' @param type Option type: "call" or "put".
#'
#' @return A list containing:
#' \item{price}{Estimated option price.}
#' \item{std_error}{Standard error of the Monte Carlo estimate.}
#' \item{conf_int}{95\% confidence interval for the price.}
#' @export
price_european_option <- function(price_paths, K, r, maturity, type = c("call", "put")) {
  type <- match.arg(type)
  
  # Extract terminal prices
  S_T <- price_paths[nrow(price_paths), ]
  
  # Calculate Payoff
  if (type == "call") {
    payoff <- pmax(S_T - K, 0)
  } else {
    payoff <- pmax(K - S_T, 0)
  }
  
  # Discount factors
  df <- exp(-r * maturity)
  
  # Discounted Payoffs
  discounted_payoff <- df * payoff
  
  # Estimators
  price_est <- mean(discounted_payoff)
  std_err <- sd(discounted_payoff) / sqrt(length(discounted_payoff))
  
  return(list(
    price = price_est,
    std_error = std_err,
    conf_int = c(price_est - 1.96 * std_err, price_est + 1.96 * std_err)
  ))
}
