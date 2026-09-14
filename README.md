# example4

# Output folder in Domino workspace.
# /mnt is usually writable, but this will fall back to the working directory.
output_dir <- "/mnt"
if (!dir.exists(output_dir) || file.access(output_dir, 2) != 0) {
  output_dir <- file.path(getwd(), "figaro_uc301_mapping_output")
}
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# Optional curated configuration.
# The scanner works even when this file is absent.
config_candidates <- c(
  "00_figaro_uc301_mapping_config.csv",
  "/mnt/00_figaro_uc301_mapping_config.csv",
  file.path(getwd(), "00_figaro_uc301_mapping_config.csv")
)
mapping_config_file <- config_candidates[file.exists(config_candidates)][1]
if (length(mapping_config_file) == 0 || is.na(mapping_config_file)) {
  mapping_config_file <- NA_character_
}
