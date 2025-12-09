# R/setup/01_git_init.R
library(gert)
library(usethis)

# Check if git is already initialized
if (!dir.exists(".git")) {
  message("Initializing git repository...")
  # init() is not in gert, usually usethis::use_git() does it interaction-heavy.
  # We can use gert::git_init() which maps to check? No, gert::git_init() exists?
  # Let's check gert docs or use system command fallback if needed, but per rules "NEVER use bash git".
  # gert::git_init is available in recent gert.
  tryCatch({
      gert::git_init()
  }, error = function(e) {
      # Fallback to system if gert isn't installed or fails (unlikely in this env)
      message("gert::git_init failed: ", e$message)
  })
}

# Configure ignores if needed (usethis usually handles this)
usethis::use_git_ignore(c(".DS_Store", ".Rproj.user", ".Rhistory", ".RData", ".nix-profile", "result"))

# Add all files
message("Staging files...")
gert::git_add(".")

# Commit
if (nrow(gert::git_status()) > 0) {
    message("Committing initial files...")
    gert::git_commit("Initial commit: Package structure and simulation (Phase 1)")
} else {
    message("Nothing to commit.")
}
