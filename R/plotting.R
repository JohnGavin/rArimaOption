#' Plot Simulated Paths
#'
#' Visualizes simulated price paths using ggplot2.
#'
#' @param paths Matrix or time series object of simulated paths (rows = time, cols = paths).
#' @param title Character string for the plot title.
#'
#' @return A ggplot object.
#' @importFrom ggplot2 ggplot aes geom_line labs theme_minimal theme
#' @importFrom reshape2 melt
#' @export
plot_simulations <- function(paths, title = "Simulated Paths") {
  # Convert to matrix if needed
  mat <- as.matrix(paths)
  
  # Melt for ggplot
  # Row indices are Time, Col indices are Path
  df <- reshape2::melt(mat)
  colnames(df) <- c("Time", "Path", "Price")
  
  ggplot2::ggplot(df, ggplot2::aes(x = Time, y = Price, group = Path)) +
    ggplot2::geom_line(alpha = 0.5, color = "steelblue") +
    ggplot2::labs(title = title, x = "Time Step", y = "Price") +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "none")
}
