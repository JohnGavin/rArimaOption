
# Initialize R package
tryCatch({
  # Create package structure (non-interactive)
  usethis::create_package(".", check_name = FALSE, rstudio = FALSE, open = FALSE, fields = list(Package = "rArimaOption"))
  
  # Add dependencies
  usethis::use_package("forecast", type = "Imports")
  usethis::use_package("targets", type = "Imports")
  usethis::use_package("tarchetypes", type = "Imports")
  usethis::use_package("dplyr", type = "Imports")
  usethis::use_package("ggplot2", type = "Imports")
  
  # External dependencies (available in Nix environment)
  usethis::use_package("esgtoolkit", type = "Imports")
  usethis::use_package("ahead", type = "Imports")
  
  # Configure Remotes for GitHub packages
  desc <- desc::desc(file = "DESCRIPTION")
  desc$set_remotes(c("Techtonique/esgtoolkit", "Techtonique/ahead"))
  desc$write()

  # Setup git ignore including common R, Nix, and targets files
  usethis::use_git_ignore(c(
    ".Rproj.user",
    ".Rhistory",
    ".RData",
    ".Ruserdata",
    "_targets/",
    "_targets_r/",
    "*.tar.gz",
    "result"
  ))
  
  message("Package initialization complete.")
  
}, error = function(e) {
  message("FAILED: ", e$message)
  quit(status = 1)
})
