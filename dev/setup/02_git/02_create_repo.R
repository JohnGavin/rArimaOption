# R/setup/02_git/02_create_repo.R

library(gh)
library(gert)

message("Starting GitHub repository setup...")

repo_name <- "rArimaOption"
username <- "JohnGavin" 

# 1. Check if repo exists
message(sprintf("Checking if repo %s/%s exists...", username, repo_name))
repo_exists <- tryCatch({
  gh::gh("GET /repos/{owner}/{repo}", owner = username, repo = repo_name)
  TRUE
}, error = function(e) {
  FALSE
})

if (repo_exists) {
  message("Repository already exists.")
} else {
  message("Creating repository...")
  new_repo <- gh::gh("POST /user/repos", name = repo_name, private = FALSE, has_wiki = TRUE, has_downloads = TRUE)
  message(sprintf("Repository created: %s", new_repo$html_url))
}

# 2. Configure Remote
# Check if remote 'origin' exists
remotes <- gert::git_remote_list()
if (!"origin" %in% remotes$name) {
  message("Adding remote 'origin'...")
  remote_url <- paste0("https://github.com/", username, "/", repo_name, ".git")
  # Correct signature: git_remote_add(url, name = "origin")
  gert::git_remote_add(remote_url, name = "origin") 
  message(sprintf("Remote added: %s", remote_url))
} else {
  message("Remote 'origin' already exists.")
}

# 3. Push to main
message("Pushing to remote 'origin'...")
tryCatch({
    gert::git_push(remote = "origin", set_upstream = TRUE)
    message("Successfully pushed to main.")
}, error = function(e) {
    message(sprintf("Push warning (maybe already pushed): %s", e$message))
})

# 4. Enable GitHub Pages (if not checked in creation)
message("Configuring GitHub Pages...")
tryCatch({
    message("Skipping specific Pages config for now (wait for pkgdown deploy).")
}, error = function(e) {
    message(sprintf("Pages config warning: %s", e$message))
})

message("GitHub setup complete.")
