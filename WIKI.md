# Project Wiki: Lessons Learned & Issues

## Architecture & Environment
### Nix Architecture Mismatch (Fixed)
- **Issue**: `esgtoolkit` and `ahead` packages installed from GitHub contained pre-compiled binaries (`.o`, `.so`) likely built on x86_64, causing linking errors on macOS Apple Silicon (arm64).
- **Fix**: Added `postPatch = "rm -f src/*.o src/*.so src/*.dll";` to the Nix derivations in `default.nix` to force clean recompilation.

### R CMD Check "Notes"
- **Issue**: `R CMD check` reports "Non-standard file/directory found at top level: '$HOME'".
- **Context**: This typically happens when `$HOME` is set to the current directory or a temp dir that isn't properly isolated, or when artifacts are leaked into the build dir.
- **Status**: **Pending Fix**. Needs investigation into `default.nix` environment variables or `.Rbuildignore` configuration.

## Tooling & Workflow
### Interactive vs script-based tools
- **Issue**: `usethis::create_package` failed because it tried to prompt for user input in a non-interactive environment.
- **Lesson**: Use non-interactive alternatives or manually create files (`DESCRIPTION`, `NAMESPACE`) when automating package creation.
- **Fix**: Manually created basic package structure.

### Regex in .Rbuildignore
- **Issue**: `usethis::use_build_ignore` added `^*.json$` which is an invalid regex (quantifier `*` not following an item).
- **Fix**: Corrected to `^.*\.json$`.

## Future Work
- **Wiki Migration**: This content should be moved to the GitHub Repo Wiki once created.
