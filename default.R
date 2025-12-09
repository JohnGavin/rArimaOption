# default.R
library(rix)

# Read packages from packages.R
pkgs_lines <- readLines("packages.R")
r_pkgs <- gsub("library\\((.*)\\)", "\\1", grep("^library", pkgs_lines, value = TRUE))
r_pkgs <- trimws(r_pkgs)

# Add development packages
dev_pkgs <- c("devtools", "usethis", "testthat", "pkgdown", "rix")
r_pkgs <- unique(c(r_pkgs, dev_pkgs))

# Define Git packages
git_pkgs_list <- list(
  list(
    package_name = "misc",
    repo_url = "https://github.com/thierrymoudiki/misc",
    commit = "6327354f0d4cce895031e59421ceb5fafed4c1a7",
    sha256 = "113cjnyw11wd9as459b8abg6yd27xd0fzr9r9vgw2wvv9l2zjygx"
  ),
  list(
    package_name = "esgtoolkit",
    repo_url = "https://github.com/Techtonique/esgtoolkit",
    commit = "0a9ad8ed1d52de4a66a997dc48e930aa49560a2b",
    sha256 = "14hi77029dx5dvbn2k562sha88ny1s81riry2ls907bg18yh00zj"
  ),
  list(
    package_name = "ahead",
    repo_url = "https://github.com/Techtonique/ahead",
    commit = "290c76194890faa629de57a29e17a2dce95a9cbe",
    sha256 = "1zf747nfw9fddn1vshfysighkhkbvdkvprsn454s2axb5rpcpamx"
  )
)

# CRITICAL FIX: Remove git packages from r_pkgs to prevent upstream lookup errors
git_pkg_names <- sapply(git_pkgs_list, function(x) x$package_name)
r_pkgs <- setdiff(r_pkgs, git_pkg_names)

# Define system packages
system_pkgs <- c(
  "awscli2", "bc", "btop", "cacert", "clang", "cmdstan", "curlMinimal", "direnv", "duckdb", 
  "gcc", "gettext", "gh", "git", "glibcLocales", "gnupg", "htop", "jq", "less", "libgcc", 
  "libiconv", "locale", "nano", "nix", "nodejs", "ollama", "pandoc", "positron-bin", "quarto", 
  "R", "texliveBasic", "toybox", "tree", "typst", "unzip", "which"
)

# Shell Hook with escaped quotes
shell_hook <- '
mkdir -p $HOME/.config/positron
NIX_SHELL_PATH=$(readlink /Users/johngavin/docs_gh/rix.setup/nix-shell-root)
if [ -z \\"$NIX_SHELL_PATH\\" ]; then NIX_SHELL_PATH=\\"$out\\"; fi

cat > $HOME/.config/positron/nix-terminal-wrapper.sh <<EOF
#!/bin/bash
printf \\"%s\\\\n\\" \\"Activating Nix shell environment...\\"
true && source $NIX_SHELL_PATH/etc/profile.d/nix-shell.sh

if declare -f __start_nix_shell_environment > /dev/null; then
    __start_nix_shell_environment
fi

printf \\"%s\\\\n\\" \\"Nix environment fully sourced.\\"

echo \\"set -o emacs\\" > ~/.nix-shell-bashrc
echo \\"bind \\\\\\"\\\\\\\\e[A\\\\\\": history-search-backward\\\\\\"\\" >> ~/.nix-shell-bashrc
echo \\"bind \\\\\\"\\\\\\\\e[B\\\\\\": history-search-forward\\\\\\"\\" >> ~/.nix-shell-bashrc
if [ -f ~/.bashrc ]; then source ~/.bashrc; fi

exec /usr/bin/env bash --rcfile ~/.nix-shell-bashrc -i
EOF

chmod +x $HOME/.config/positron/nix-terminal-wrapper.sh
export RSTUDIO_TERM_EXEC=$HOME/.config/positron/nix-terminal-wrapper.sh
export R_MAKEVARS_USER=/dev/null
unset CI
printf \\"Setup complete\\\\n\\"
'

# Generate
rix(
  date = "2025-11-03",
  r_pkgs = r_pkgs,
  system_pkgs = system_pkgs,
  git_pkgs = git_pkgs_list,
  ide = "positron",
  project_path = ".",
  overwrite = TRUE,
  shell_hook = shell_hook
)

# Post-processing
nix_lines <- readLines("default.nix")

add_post_patch <- function(lines, pkg_name) {
  idx <- grep(paste0('name = "', pkg_name, '";'), lines)
  if (length(idx) > 0) {
    # Insert postPatch after this line
    patch_line <- '    postPatch = "rm -f src/*.o src/*.so src/*.dll";'
    lines <- append(lines, patch_line, after = idx)
  }
  return(lines)
}

nix_lines <- add_post_patch(nix_lines, "misc")
nix_lines <- add_post_patch(nix_lines, "esgtoolkit")
nix_lines <- add_post_patch(nix_lines, "ahead")

# Remove ForecastComb entirely (definition and usage)
# 1. Usage in ahead: "ForecastComb" inside the list
nix_lines <- gsub("ForecastComb", "", nix_lines)

# 2. Definition block: ForecastComb = ...
# This is harder to remove cleanly with regex blindly, leaving empty assignment " = ..."
# But if "ForecastComb" variable name is removed, " = ..." remains.
# e.g. "     = (pkgs.rPackages..."
# This is syntax error.
# We need to find the block and nuke it, OR simpler:
# Just let it define " = ..." ?? No.
# If we change the name to "unused_var"?
# "unused_var = (pkgs..."
# And if it still tries to inherit 'ahead' from upstream?
# The definition of ForecastComb (even if unused) might contain "inherit (pkgs.rPackages) ... ahead".
# This will still error if 'ahead' is missing in upstream.

# Robust fix: Find the block and remove the "ahead" dependency from IT.
# And allow it to exist (even if unused).
# Re-add "ForecastComb" name? No, I already gsubbed it out.
# So I must execute a more targeted gsub.
# First reload lines since I haven't saved.

nix_lines <- readLines("default.nix")
nix_lines <- add_post_patch(nix_lines, "misc")
nix_lines <- add_post_patch(nix_lines, "esgtoolkit")
nix_lines <- add_post_patch(nix_lines, "ahead")

# 1. Remove usage in ahead
# Find line containing "ForecastComb" inside strict list context?
# Or just gsub in the file, but NOT the definition name?
# Definition: "    ForecastComb = (pkgs..."
# Usage: "++ [ misc ForecastComb ];"

# Let's simple remove "ahead" from ForecastComb's inputs first.
# "          ahead" inside "inherit (pkgs.rPackages)" block.
# We can filter lines that match "          ahead" (whitespace ahead).
# But "ahead" derivation also has "name = ahead".
# Be careful.
# If we remove "ForecastComb" usage from "ahead" derivation:
nix_lines <- gsub("ForecastComb", "", nix_lines)
# This breaks "ForecastComb = ..." line.
# Correction: Don't gsub globally yet.

# Identify ForecastComb definition start/end?
# If rix put ForecastComb, it's lines X to Y.
# Too complex for quick script.

# Strategy:
# 1. Allow ForecastComb definition to stay (it might be valid if 'ahead' upstream exists? But we know it's missing).
# 2. If 'ahead' is missing upstream, lines "inherit (pkgs.rPackages) ... ahead" fail.
# 3. So we MUST remove "ahead" from upstream inheritance blocks.
#    Since we are providing 'ahead' custom, we don't want ANYONE inheriting upstream 'ahead'.
#    So: remove "ahead" from ANY "inherit (pkgs.rPackages)" block.
#    Scan for "          ahead" lines and check context?
#    Or just "gsub('          ahead', '', nix_lines)"? Assuming indentation matches rix output.
#    rix output uses standard indentation.
#    "      ahead" or "          ahead".
#    Let's remove "ahead" from lines that look like list items in inherit.

nix_lines <- gsub("^\\s+ahead$", "", nix_lines) # Lines with just "ahead" and spaces
# Nix list items usually assume semicolons only at end of block.
# inherit (pkgs.rPackages) \n pkg1 \n pkg2;
# So items DO NOT have semicolons.

# Remove usage of ForecastComb from 'ahead' derivation inputs
# "++ [ misc ForecastComb ];"
nix_lines <- gsub("ForecastComb", "", nix_lines)
# This breaks the definition name "ForecastComb = ...".
# Repair it?
nix_lines <- gsub("^\\s+= \\(pkgs", "    ForecastComb = (pkgs", nix_lines) # Hacky heuristic?
# Or just accept broken " = ..." if it's in a 'let' block and unused.
# "let ... = ... in ..."
# "var1 = ...; = ...; in ..." is invalid syntax.

# COMPLETE OVERRIDE STRATEGY:
# If I can't easily patch it, I will define `overrides` or `overlay` in Rix?
# Rix doesn't expose overlays easily in `rix()` args.

# BACKUP PLAN:
# Delete the lines corresponding to ForecastComb completely if I can find them.
# grep "ForecastComb =" -A 20? 
# Risky.

# Let's go with:
# 1. Remove "ahead" from "r_pkgs" input (Done).
# 2. This prevents `rpkgs` variable from containing upstream 'ahead'.
# 3. `ForecastComb` relies on `inherit (pkgs.rPackages) ahead`.
#    If I remove "ahead" from that inherit block, `ForecastComb` breaks (missing input).
#    So I must remove `ForecastComb` too.

# Loop through lines. 
# If I see "ForecastComb =", start delete mode until I see "});".
lines_out <- c()
skip <- FALSE
for (line in nix_lines) {
  if (grepl("ForecastComb =", line)) {
    skip <- TRUE
  }
  if (!skip) {
    # Check if this line is adding ForecastComb to list
    # "++ [ misc ForecastComb ];"
    if (grepl("ForecastComb", line)) {
      line <- gsub("ForecastComb", "", line)
    }
    lines_out <- c(lines_out, line)
  }
  if (skip && grepl("}\\);", line)) {
    skip <- FALSE
  }
}
nix_lines <- lines_out

writeLines(nix_lines, "default.nix")
message("default.nix generated, patched, and cleaned.")
