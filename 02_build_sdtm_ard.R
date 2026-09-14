# ============================================================
# FIGARO UC301 - BUILD SDTM-BASED ARD
# ============================================================
# Purpose:
#   Build an analysis-ready wide dataset directly from CONFIRMED OBSERVED
#   SDTM mappings. This is NOT an official reconstructed ADaM dataset.
#
# Key design:
#   one row per USUBJID + AVISIT (VISIT as the SDTM visit label)
#   one column per PARAMCD
#
# Safety rule:
#   only STATUS == OBSERVED_CONFIRMED is included automatically.
#   DERIVABLE_NEEDS_RULE and REVIEW_CANDIDATE are excluded until reviewed.
# ============================================================

suppressPackageStartupMessages({
  library(haven)
  library(dplyr)
  library(purrr)
  library(stringr)
  library(tidyr)
  library(readr)
  library(tibble)
})

# ----------------------------
# CONFIGURATION
# ----------------------------
sdtm_dir <- "/domino/datasets/local/clinical-trial-data/SHP647C301-FIGARO-UC-1/clinical/rawdata/shp647_301"
mapping_file <- "00_figaro_uc301_mapping_config.csv"
output_dir <- "figaro_uc301_ard_output"
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

# Preserve traceability columns in a long companion file.
write_long_traceability <- TRUE

# ----------------------------
# HELPERS
# ----------------------------
blank_to_na <- function(x) {
  x <- as.character(x)
  x[str_trim(x) == ""] <- NA_character_
  x
}

# Avoid ugly floating representations for integer-like clinical scores.
format_num <- function(x) {
  x <- suppressWarnings(as.numeric(x))
  ifelse(
    is.na(x), NA_character_,
    ifelse(abs(x - round(x)) < 1e-10,
           as.character(as.integer(round(x))),
           format(x, scientific = FALSE, trim = TRUE, digits = 15))
  )
}

collapse_unique <- function(x) {
  x <- blank_to_na(x)
  x <- unique(x[!is.na(x)])
  if (length(x) == 0) return(NA_character_)
  paste(x, collapse = " | ")
}

.domain_cache <- new.env(parent = emptyenv())
read_domain <- function(dataset) {
  if (exists(dataset, envir = .domain_cache, inherits = FALSE)) {
    return(get(dataset, envir = .domain_cache, inherits = FALSE))
  }
  path <- file.path(sdtm_dir, paste0(dataset, ".xpt"))
  if (!file.exists(path)) stop("Dataset not found: ", path)
  x <- read_xpt(path)
  assign(dataset, x, envir = .domain_cache)
  x
}

# ----------------------------
# READ MAPPING
# ----------------------------
map <- read_csv(mapping_file, show_col_types = FALSE) %>%
  mutate(across(everything(), ~na_if(as.character(.x), "")))

confirmed <- map %>%
  filter(STATUS == "OBSERVED_CONFIRMED")

if (nrow(confirmed) == 0) stop("No OBSERVED_CONFIRMED mappings found.")

# ----------------------------
# EXTRACT ONE PARAMCD
# ----------------------------
extract_param <- function(row) {
  dataset <- row$DATASET
  paramcd <- row$PARAMCD
  df <- read_domain(dataset)

  required <- c("USUBJID", row$TESTCD_VAR, row$VISIT_VAR)
  required <- required[!is.na(required)]
  missing_req <- setdiff(required, names(df))
  if (length(missing_req) > 0) {
    stop(paramcd, ": missing required variables in ", dataset, ": ", paste(missing_req, collapse = ", "))
  }

  # Filter by TESTCD.
  if (!is.na(row$TESTCD_VAR) && !is.na(row$TESTCD)) {
    df <- df %>% filter(as.character(.data[[row$TESTCD_VAR]]) == row$TESTCD)
  }

  # Optional extra filter, e.g. MOCAT == 'Endoscopy Outcome'.
  if (!is.na(row$FILTER_COL) && !is.na(row$FILTER_VALUE)) {
    if (!row$FILTER_COL %in% names(df)) {
      stop(paramcd, ": filter column not found: ", row$FILTER_COL)
    }
    df <- df %>% filter(as.character(.data[[row$FILTER_COL]]) == row$FILTER_VALUE)
  }

  # Numeric preferred; character is fallback.
  val_num <- if (!is.na(row$VALUE_NUM) && row$VALUE_NUM %in% names(df)) {
    format_num(df[[row$VALUE_NUM]])
  } else {
    rep(NA_character_, nrow(df))
  }

  val_chr <- if (!is.na(row$VALUE_CHAR) && row$VALUE_CHAR %in% names(df)) {
    blank_to_na(df[[row$VALUE_CHAR]])
  } else {
    rep(NA_character_, nrow(df))
  }

  value <- ifelse(!is.na(val_num), val_num, val_chr)

  test_label <- if (!is.na(row$TEST_VAR) && row$TEST_VAR %in% names(df)) {
    as.character(df[[row$TEST_VAR]])
  } else {
    rep(NA_character_, nrow(df))
  }

  visit <- if (!is.na(row$VISIT_VAR) && row$VISIT_VAR %in% names(df)) {
    as.character(df[[row$VISIT_VAR]])
  } else {
    rep(NA_character_, nrow(df))
  }

  visitnum <- if (!is.na(row$VISITNUM_VAR) && row$VISITNUM_VAR %in% names(df)) {
    suppressWarnings(as.numeric(df[[row$VISITNUM_VAR]]))
  } else {
    rep(NA_real_, nrow(df))
  }

  tibble(
    USUBJID = as.character(df$USUBJID),
    AVISIT = visit,
    AVISITN = visitnum,
    PARAMCD = paramcd,
    VALUE = value,
    SOURCE_DATASET = dataset,
    SOURCE_TESTCD = if (!is.na(row$TESTCD)) row$TESTCD else NA_character_,
    SOURCE_TEST = test_label
  ) %>%
    filter(!is.na(USUBJID), !is.na(AVISIT), !is.na(VALUE))
}

long_raw <- map_dfr(seq_len(nrow(confirmed)), function(i) {
  extract_param(as.list(confirmed[i, ]))
})

# ----------------------------
# DUPLICATE CHECK
# ----------------------------
# A subject/visit/PARAMCD can have >1 observed value. We report this before
# collapsing so the user can review whether concatenation is appropriate.
duplicate_report <- long_raw %>%
  group_by(USUBJID, AVISIT, PARAMCD) %>%
  summarise(
    N_RECORDS = n(),
    N_UNIQUE_VALUES = n_distinct(VALUE),
    VALUES = collapse_unique(VALUE),
    .groups = "drop"
  ) %>%
  filter(N_RECORDS > 1 | N_UNIQUE_VALUES > 1) %>%
  arrange(PARAMCD, USUBJID, AVISIT)

write_csv(duplicate_report, file.path(output_dir, "01_duplicate_review.csv"), na = "")

# ----------------------------
# COLLAPSE + WIDE ARD
# ----------------------------
long_collapsed <- long_raw %>%
  group_by(USUBJID, AVISIT, PARAMCD) %>%
  summarise(
    AVISITN = suppressWarnings(min(AVISITN, na.rm = TRUE)),
    VALUE = collapse_unique(VALUE),
    SOURCE_DATASET = collapse_unique(SOURCE_DATASET),
    SOURCE_TESTCD = collapse_unique(SOURCE_TESTCD),
    SOURCE_TEST = collapse_unique(SOURCE_TEST),
    .groups = "drop"
  ) %>%
  mutate(AVISITN = ifelse(is.infinite(AVISITN), NA_real_, AVISITN))

# Visit-number lookup can differ slightly across source domains.
# Use minimum nonmissing visit number per USUBJID + AVISIT only as a sorting aid.
visit_key <- long_collapsed %>%
  group_by(USUBJID, AVISIT) %>%
  summarise(
    AVISITN = suppressWarnings(min(AVISITN, na.rm = TRUE)),
    .groups = "drop"
  ) %>%
  mutate(AVISITN = ifelse(is.infinite(AVISITN), NA_real_, AVISITN))

ard <- long_collapsed %>%
  select(USUBJID, AVISIT, PARAMCD, VALUE) %>%
  pivot_wider(names_from = PARAMCD, values_from = VALUE) %>%
  left_join(visit_key, by = c("USUBJID", "AVISIT")) %>%
  relocate(USUBJID, AVISIT, AVISITN) %>%
  arrange(USUBJID, AVISITN, AVISIT)

write_csv(ard, file.path(output_dir, "FIGARO_UC301_SDTM_based_ARD.csv"), na = "")

if (write_long_traceability) {
  write_csv(long_collapsed, file.path(output_dir, "02_ARD_traceability_long.csv"), na = "")
}

# ----------------------------
# COVERAGE SUMMARY
# ----------------------------
coverage <- confirmed %>%
  select(PARAMCD, DESCRIPTION, DATASET, TESTCD, NOTES) %>%
  left_join(
    long_collapsed %>%
      group_by(PARAMCD) %>%
      summarise(
        N_SUBJECTS = n_distinct(USUBJID),
        N_SUBJECT_VISITS = n_distinct(paste(USUBJID, AVISIT, sep = "|")),
        N_VALUES = sum(!is.na(VALUE)),
        .groups = "drop"
      ),
    by = "PARAMCD"
  ) %>%
  mutate(across(c(N_SUBJECTS, N_SUBJECT_VISITS, N_VALUES), ~replace_na(.x, 0L)))

write_csv(coverage, file.path(output_dir, "03_ARD_coverage_summary.csv"), na = "")

cat("\nARD created successfully.\n")
cat("Rows: ", nrow(ard), "\n", sep = "")
cat("Columns: ", ncol(ard), "\n", sep = "")
cat("Output folder: ", normalizePath(output_dir), "\n", sep = "")
