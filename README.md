# example4

library(tidyverse)

# ============================================================
# CONFIG
# ============================================================

input_file <- "/domino/datasets/local/clinical-trial-data/77242113UC02001-ANTHEM-UC-UNBLINDED-WK78/load-3134/Data/_csv/77242113UC02001_anthem_wk78_ard_merged_20260810_ARD.csv"

output_file <- "/mnt/77242113UC02001_anthem_wk78_ard_slim.csv"


# ============================================================
# COLUMNS TO KEEP
# ============================================================

columns_to_keep <- c(
  "USUBJID",
  "AVISIT",
  "AVISITN",
  "ADHIST_T",
  "ADHIST_TF",
  "TRT02PN"
)


# ============================================================
# READ DATA
# ============================================================

ard <- read_csv(
  input_file,
  show_col_types = FALSE
)


# ============================================================
# CHECK COLUMNS
# ============================================================

missing_columns <- setdiff(columns_to_keep, names(ard))

if (length(missing_columns) > 0) {
  
  warning(
    paste(
      "The following columns were not found:",
      paste(missing_columns, collapse = ", ")
    )
  )
}


# ============================================================
# CREATE SLIM ARD
# ============================================================

ard_slim <- ard %>%
  select(any_of(columns_to_keep))


# ============================================================
# EXPORT
# ============================================================

write_csv(
  ard_slim,
  output_file
)


# ============================================================
# SUMMARY
# ============================================================

cat("\nSlim ARD created successfully!\n")
cat("Original columns:", ncol(ard), "\n")
cat("Slim columns:", ncol(ard_slim), "\n")
cat("Rows:", nrow(ard_slim), "\n")
cat("Output:", output_file, "\n")
