# ============================================================
# FIGARO UC301 - SDTM -> GAP ANALYSIS + TRACEABILITY + ARD
# ============================================================
#
# INPUTS
#   1) FIGARO UC301 SDTM XPT folder
#   2) 03_mapping_candidates_automatic.csv produced by Script 01
#
# OUTPUTS
#   01_gap_analysis.csv
#   02_traceability_summary.csv
#   03_traceability_long.csv
#   04_duplicate_review.csv
#   05_FIGARO_UC301_SDTM_based_ARD.csv
#   06_mapping_used_for_ARD.csv
#
# IMPORTANT
#   Script 01 produces discovery candidates and may contain false positives.
#   This script does NOT blindly choose the highest SCORE.
#
#   Instead, it:
#     - reads Script 01 output,
#     - applies a conservative reviewed mapping table,
#     - extracts only directly observed SDTM values into the ARD,
#     - keeps derived/review/not-identified variables out of the ARD values,
#     - still includes all 37 PARAMCD columns in the final ARD.
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

# ============================================================
# 1. CONFIGURATION
# ============================================================

candidate_sdtm_dirs <- c(
  "/domino/datasets/local/clinical-trial-data/SHP647UC301-FIGARO-UC-1/clinical/rawdata/shp647_301",
  "/domino/datasets/local/clinical-trial-data/SHP647C301-FIGARO-UC-1/clinical/rawdata/shp647_301"
)

candidate_mapping_files <- c(
  "03_mapping_candidates_automatic.csv",
  "/mnt/03_mapping_candidates_automatic.csv",
  file.path(getwd(), "03_mapping_candidates_automatic.csv")
)

output_dir <- "/mnt"
if (!dir.exists(output_dir) || file.access(output_dir, 2) != 0) {
  output_dir <- file.path(getwd(), "figaro_uc301_ard_output")
}
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

find_sdtm_dir <- function(paths) {
  for (p in paths) {
    if (dir.exists(p)) {
      f <- list.files(
        p,
        pattern = "\\.xpt$",
        full.names = TRUE,
        ignore.case = TRUE
      )
      if (length(f) > 0) return(p)
    }
  }
  NA_character_
}

sdtm_dir <- find_sdtm_dir(candidate_sdtm_dirs)

if (is.na(sdtm_dir)) {
  stop(
    "Could not find the FIGARO UC301 SDTM XPT folder.\nChecked:\n",
    paste(candidate_sdtm_dirs, collapse = "\n")
  )
}

mapping_file <- candidate_mapping_files[file.exists(candidate_mapping_files)][1]

if (length(mapping_file) == 0 || is.na(mapping_file)) {
  stop(
    "03_mapping_candidates_automatic.csv was not found.\n",
    "Place it in the working directory or /mnt."
  )
}

cat("\nUsing SDTM folder:\n", sdtm_dir, "\n", sep = "")
cat("\nUsing candidate mapping file:\n", mapping_file, "\n", sep = "")

# ============================================================
# 2. VARIABLES OF INTEREST
# ============================================================

voi <- tribble(
  ~PARAMCD, ~DESCRIPTION,
  "MAYO", "Mayo Score",
  "ENSCORE", "Endoscopy Final Score",
  "RBSCORE", "Rectal Bleeding Score",
  "SFSCORE", "Stool Frequency Score",
  "ENCSCORE", "Endoscopy Central Score (Primary Reader)",
  "ENLSCORE", "Endoscopy Local Score",
  "UCEISP", "Total UCEIS Score (Primary ICE Approach)",
  "BLEEDP", "Bleeding (Primary ICE Approach)",
  "EROSP", "Erosions and Ulcers (Primary ICE Approach)",
  "VASCP", "Vascular Pattern (Primary ICE Approach)",
  "CRESPP", "Clin Resp (Primary Estimand Approach)",
  "HEHL", "Histo-Endo Mucosal Heal",
  "HIHL", "Histo Healing",
  "ENHLP", "Endoscopic Healing (Primary Estimand Approach)",
  "CREMP", "Clin Remiss (Primary Estimand Approach)",
  "PMRESPP", "Partial Mayo Resp (Primary ICE Approach)",
  "ARCHCH", "Architectural Change (Grade 0)",
  "CHRIINF", "Chronic Inflammatory Infiltrate (Grade 1)",
  "EOS", "Eosinophils (10^9/L)",
  "NEUTLP", "Neutrophils Lamina Propria (Grade 2B)",
  "NEUTEP", "Neutrophils Epithelium (Grade 3)",
  "CRYPTDES", "Crypt Destruction (Grade 4)",
  "ULCER", "Erosion or Ulceration (Grade 5)",
  "CRPP", "C Reactive Protein (mg/L) (Primary ICE Approach)",
  "CALPPP", "Fecal Calprotectin (mg/kg) (Primary ICE Approach)",
  "CORTBL", "Induction Baseline Corticosteroid Use",
  "IBDQTOT", "IBDQ Total Score",
  "PGSCORE", "Physician Global Assessment Score",
  "MOTEST", "Modified Mayo Score",
  "IBREMP", "IBDQ Remission (Primary Estimand Approach)",
  "HEHLP", "Histo-Endo Mucosal Heal (Primary Estimand Approach)",
  "ENNRMP", "Endoscopic Normalization (Primary Estimand Approach)",
  "NANCYHI", "Nancy Histological Index",
  "RHI", "Robarts Histopathology Index",
  "GBTOT", "Geboes total score",
  "GBHI", "Geboes high activity subscore",
  "GBLO", "Geboes low activity subscore"
)

# ============================================================
# 3. READ SCRIPT 01 OUTPUT
# ============================================================

candidates <- read_csv(mapping_file, show_col_types = FALSE) %>%
  mutate(
    PARAMCD = as.character(PARAMCD),
    DATASET = as.character(DATASET),
    CODE = as.character(CODE),
    LABEL = as.character(LABEL)
  )

required_candidate_cols <- c(
  "PARAMCD", "DESCRIPTION", "SCORE",
  "DATASET", "CODE_VAR", "CODE", "LABEL_VAR", "LABEL"
)

missing_candidate_cols <- setdiff(required_candidate_cols, names(candidates))

if (length(missing_candidate_cols) > 0) {
  stop(
    "Candidate file is missing required columns: ",
    paste(missing_candidate_cols, collapse = ", ")
  )
}

# ============================================================
# 4. REVIEWED MAPPING LAYER
# ============================================================
#
# OBSERVED_CONFIRMED
#   Direct SDTM observation/assessment suitable for extraction.
#
# REVIEW_CANDIDATE
#   Plausible source exists, but semantic equivalence is not yet confirmed.
#
# DERIVABLE_COMPONENTS_AVAILABLE
#   Components exist but requested endpoint requires derivation.
#
# NOT_IDENTIFIED
#   No sufficiently supported direct representation confirmed.
# ============================================================

reviewed_map <- tribble(
  ~PARAMCD, ~EXPECTED_DATASET, ~EXPECTED_CODE, ~STATUS, ~REVIEW_NOTE,

  "MAYO", "QSMS", "MS0107", "OBSERVED_CONFIRMED",
  "Direct Total Mayo Score assessment.",

  "ENSCORE", NA, NA, "REVIEW_CANDIDATE",
  "Final endoscopy score requires confirmation of final/outcome versus central/local reader source.",

  "RBSCORE", "QSMS", "MS0105", "OBSERVED_CONFIRMED",
  "Direct Average Rectal Bleeding Score assessment.",

  "SFSCORE", "QSMS", "MS0103", "OBSERVED_CONFIRMED",
  "Direct Average Stool Frequency Score assessment.",

  "ENCSCORE", "QSMS", "MS0109", "OBSERVED_CONFIRMED",
  "Direct Central Read Endoscopy Score assessment.",

  "ENLSCORE", "QSMS", "MS0113", "OBSERVED_CONFIRMED",
  "Direct Site Entered Endoscopy Score assessment.",

  "UCEISP", NA, NA, "NOT_IDENTIFIED",
  "No direct Total UCEIS assessment confirmed.",

  "BLEEDP", NA, NA, "REVIEW_CANDIDATE",
  "Bleeding-related SDTM candidates need confirmation that they represent the requested UCEIS/ICE endpoint.",

  "EROSP", NA, NA, "REVIEW_CANDIDATE",
  "Erosion/ulcer candidates need confirmation that they represent the requested UCEIS/ICE endpoint.",

  "VASCP", NA, NA, "REVIEW_CANDIDATE",
  "Vascular Pattern candidate needs confirmation of requested UCEIS/ICE endpoint.",

  "CRESPP", NA, NA, "REVIEW_CANDIDATE",
  "Clinical response information exists in QSCR, but Primary Estimand mapping requires confirmation.",

  "HEHL", NA, NA, "DERIVABLE_COMPONENTS_AVAILABLE",
  "Histo-endoscopic mucosal healing is a composite/derived endpoint.",

  "HIHL", NA, NA, "DERIVABLE_COMPONENTS_AVAILABLE",
  "Histologic healing requires a study-specific derivation rule.",

  "ENHLP", NA, NA, "DERIVABLE_COMPONENTS_AVAILABLE",
  "Endoscopic healing requires a study-specific derivation rule.",

  "CREMP", NA, NA, "REVIEW_CANDIDATE",
  "QSCR remission status is plausible, but Primary Estimand mapping requires confirmation.",

  "PMRESPP", NA, NA, "DERIVABLE_COMPONENTS_AVAILABLE",
  "Partial Mayo response requires a derivation rule.",

  "ARCHCH", "MI", "GEB0L", "OBSERVED_CONFIRMED",
  "Direct Geboes architectural change assessment.",

  "CHRIINF", "MI", "GEB1L", "OBSERVED_CONFIRMED",
  "Direct Geboes chronic inflammatory infiltrate assessment.",

  "EOS", "LB", "EOS", "OBSERVED_CONFIRMED",
  "Direct laboratory eosinophils measurement; unit must be reviewed in traceability.",

  "NEUTLP", "MI", "GEB2BL", "OBSERVED_CONFIRMED",
  "Direct Geboes lamina propria neutrophils assessment.",

  "NEUTEP", "MI", "GEB3L", "OBSERVED_CONFIRMED",
  "Direct Geboes neutrophils in epithelium assessment.",

  "CRYPTDES", "MI", "GEB4L", "OBSERVED_CONFIRMED",
  "Direct Geboes crypt destruction assessment.",

  "ULCER", "MI", "GEB5L", "OBSERVED_CONFIRMED",
  "Direct Geboes erosion or ulceration assessment.",

  "CRPP", "LB", "CRP", "OBSERVED_CONFIRMED",
  "Direct C-reactive protein laboratory measurement; unit must be reviewed.",

  "CALPPP", "LB", "CALPRO", "OBSERVED_CONFIRMED",
  "Direct fecal calprotectin laboratory measurement; unit must be reviewed.",

  "CORTBL", NA, NA, "REVIEW_CANDIDATE",
  "Baseline glucocorticoid/corticosteroid information exists, but the requested induction baseline flag requires confirmation.",

  "IBDQTOT", NA, NA, "DERIVABLE_COMPONENTS_AVAILABLE",
  "IBDQ item-level data appear available; direct total score was not confirmed.",

  "PGSCORE", "QSPG", "PGA0101", "OBSERVED_CONFIRMED",
  "Direct Physician Global Assessment.",

  "MOTEST", "QSMS", "MS0106", "REVIEW_CANDIDATE",
  "MS0106 is Partial Mayo Score; requested Modified Mayo Score equivalence requires confirmation.",

  "IBREMP", NA, NA, "DERIVABLE_COMPONENTS_AVAILABLE",
  "IBDQ remission requires study-specific derivation or threshold.",

  "HEHLP", NA, NA, "DERIVABLE_COMPONENTS_AVAILABLE",
  "Primary-estimand histo-endoscopic mucosal healing is derived.",

  "ENNRMP", NA, NA, "DERIVABLE_COMPONENTS_AVAILABLE",
  "Endoscopic normalization requires a study-specific derivation rule.",

  "NANCYHI", NA, NA, "NOT_IDENTIFIED",
  "Nancy Histological Index not directly identified; RHI is not interchangeable with Nancy Index.",

  "RHI", "MI", "RHI", "OBSERVED_CONFIRMED",
  "Direct Robarts Histopathology Index.",

  "GBTOT", "MI", "TOTGEB", "OBSERVED_CONFIRMED",
  "Direct Total Geboes assessment.",

  "GBHI", NA, NA, "DERIVABLE_COMPONENTS_AVAILABLE",
  "Geboes high activity subscore requires derivation.",

  "GBLO", NA, NA, "DERIVABLE_COMPONENTS_AVAILABLE",
  "Geboes low activity subscore requires derivation."
)

# ============================================================
# 5. CONFIRM REVIEWED DIRECT MAPPINGS AGAINST SCRIPT 01 OUTPUT
# ============================================================

candidate_confirmation <- reviewed_map %>%
  filter(!is.na(EXPECTED_DATASET), !is.na(EXPECTED_CODE)) %>%
  left_join(
    candidates %>%
      transmute(
        PARAMCD,
        CANDIDATE_DATASET = DATASET,
        CANDIDATE_CODE = CODE,
        CANDIDATE_LABEL = LABEL,
        CANDIDATE_SCORE = SCORE
      ),
    by = "PARAMCD"
  ) %>%
  mutate(
    MATCHED = CANDIDATE_DATASET == EXPECTED_DATASET &
      CANDIDATE_CODE == EXPECTED_CODE
  ) %>%
  group_by(PARAMCD, EXPECTED_DATASET, EXPECTED_CODE) %>%
  summarise(
    FOUND_IN_SCRIPT01 = any(MATCHED, na.rm = TRUE),
    .groups = "drop"
  )

reviewed_map <- reviewed_map %>%
  left_join(
    candidate_confirmation,
    by = c("PARAMCD", "EXPECTED_DATASET", "EXPECTED_CODE")
  ) %>%
  mutate(
    FOUND_IN_SCRIPT01 = case_when(
      is.na(EXPECTED_DATASET) ~ NA,
      TRUE ~ coalesce(FOUND_IN_SCRIPT01, FALSE)
    ),
    STATUS = case_when(
      STATUS == "OBSERVED_CONFIRMED" & FOUND_IN_SCRIPT01 == FALSE ~
        "REVIEW_CANDIDATE",
      TRUE ~ STATUS
    ),
    REVIEW_NOTE = case_when(
      STATUS == "REVIEW_CANDIDATE" &
        !is.na(EXPECTED_DATASET) &
        FOUND_IN_SCRIPT01 == FALSE ~
        paste0(
          REVIEW_NOTE,
          " Expected reviewed mapping was not returned by Script 01."
        ),
      TRUE ~ REVIEW_NOTE
    )
  )

# ============================================================
# 6. READ REQUIRED SDTM DATASETS
# ============================================================

safe_read_xpt <- function(path) {
  tryCatch(
    read_xpt(path),
    error = function(e) {
      warning("Could not read ", basename(path), ": ", conditionMessage(e))
      NULL
    }
  )
}

xpt_files <- list.files(
  sdtm_dir,
  pattern = "\\.xpt$",
  full.names = TRUE,
  ignore.case = TRUE
)

dataset_names <- toupper(
  tools::file_path_sans_ext(basename(xpt_files))
)

xpt_lookup <- setNames(xpt_files, dataset_names)

needed_datasets <- reviewed_map %>%
  filter(
    STATUS == "OBSERVED_CONFIRMED",
    !is.na(EXPECTED_DATASET)
  ) %>%
  pull(EXPECTED_DATASET) %>%
  unique()

missing_xpt <- setdiff(needed_datasets, names(xpt_lookup))

if (length(missing_xpt) > 0) {
  warning(
    "Mapped datasets not found as XPT: ",
    paste(missing_xpt, collapse = ", ")
  )
}

datasets_to_read <- intersect(
  needed_datasets,
  names(xpt_lookup)
)

sdtm <- map(
  datasets_to_read,
  ~ safe_read_xpt(xpt_lookup[[.x]])
)

names(sdtm) <- datasets_to_read
sdtm <- compact(sdtm)

# ============================================================
# 7. HELPER FUNCTIONS
# ============================================================

first_existing <- function(nms, options) {
  hit <- options[options %in% nms]
  if (length(hit) == 0) {
    NA_character_
  } else {
    hit[1]
  }
}

collapse_unique <- function(x, sep = " | ") {
  x <- as.character(x)
  x <- x[!is.na(x) & x != ""]
  if (length(x) == 0) return(NA_character_)
  paste(unique(x), collapse = sep)
}

extract_direct_mapping <- function(
  paramcd,
  dataset,
  code,
  description,
  df
) {

  nms <- names(df)

  # Find TESTCD
  testcd_var <- first_existing(
    nms,
    c(
      paste0(dataset, "TESTCD"),
      "QSTESTCD",
      "MITESTCD",
      "LBTESTCD",
      "MOTESTCD",
      "FATESTCD"
    )
  )

  # Find TEST
  test_var <- first_existing(
    nms,
    c(
      paste0(dataset, "TEST"),
      "QSTEST",
      "MITEST",
      "LBTEST",
      "MOTEST",
      "FATEST"
    )
  )

  if (is.na(testcd_var)) {
    warning(
      paramcd,
      ": no TESTCD variable identified in ",
      dataset
    )
    return(tibble())
  }

  # Prefer numeric standardized result, then character standardized result,
  # then original result.
  value_var <- first_existing(
    nms,
    c(
      paste0(dataset, "STRESN"),
      "QSSTRESN",
      "MISTRESN",
      "LBSTRESN",
      "MOSTRESN",
      "FASTRESN",

      paste0(dataset, "STRESC"),
      "QSSTRESC",
      "MISTRESC",
      "LBSTRESC",
      "MOSTRESC",
      "FASTRESC",

      paste0(dataset, "ORRES"),
      "QSORRES",
      "MIORRES",
      "LBORRES",
      "MOORRES",
      "FAORRES"
    )
  )

  if (is.na(value_var)) {
    warning(
      paramcd,
      ": no result variable identified in ",
      dataset
    )
    return(tibble())
  }

  unit_var <- first_existing(
    nms,
    c(
      paste0(dataset, "STRESU"),
      "QSSTRESU",
      "MISTRESU",
      "LBSTRESU",
      "MOSTRESU",
      "FASTRESU",

      paste0(dataset, "ORRESU"),
      "QSORRESU",
      "MIORRESU",
      "LBORRESU",
      "MOORRESU",
      "FAORRESU"
    )
  )

  visit_var <- first_existing(
    nms,
    c("VISIT")
  )

  visitnum_var <- first_existing(
    nms,
    c("VISITNUM")
  )

  seq_var <- first_existing(
    nms,
    c(
      paste0(dataset, "SEQ"),
      "QSSEQ",
      "MISEQ",
      "LBSEQ",
      "MOSEQ",
      "FASEQ"
    )
  )

  date_var <- first_existing(
    nms,
    c(
      paste0(dataset, "DTC"),
      "QSDTC",
      "MIDTC",
      "LBDTC",
      "MODTC",
      "FADTC"
    )
  )

  if (!"USUBJID" %in% nms) {
    warning(
      paramcd,
      ": USUBJID not found in ",
      dataset
    )
    return(tibble())
  }

  out <- df %>%
    filter(
      as.character(.data[[testcd_var]]) == code
    ) %>%
    transmute(
      USUBJID = as.character(USUBJID),

      AVISIT = if (!is.na(visit_var)) {
        as.character(.data[[visit_var]])
      } else {
        NA_character_
      },

      AVISITN = if (!is.na(visitnum_var)) {
        suppressWarnings(as.numeric(.data[[visitnum_var]]))
      } else {
        NA_real_
      },

      PARAMCD = paramcd,
      DESCRIPTION = description,

      VALUE = as.character(.data[[value_var]]),

      UNIT = if (!is.na(unit_var)) {
        as.character(.data[[unit_var]])
      } else {
        NA_character_
      },

      SOURCE_DATASET = dataset,
      SOURCE_TESTCD_VAR = testcd_var,
      SOURCE_TESTCD = as.character(.data[[testcd_var]]),

      SOURCE_TEST_VAR = if (!is.na(test_var)) {
        test_var
      } else {
        NA_character_
      },

      SOURCE_TEST = if (!is.na(test_var)) {
        as.character(.data[[test_var]])
      } else {
        NA_character_
      },

      SOURCE_VALUE_VAR = value_var,

      SOURCE_SEQ = if (!is.na(seq_var)) {
        as.character(.data[[seq_var]])
      } else {
        NA_character_
      },

      SOURCE_DTC = if (!is.na(date_var)) {
        as.character(.data[[date_var]])
      } else {
        NA_character_
      }
    ) %>%
    filter(
      !is.na(VALUE),
      VALUE != ""
    )

  out
}

# ============================================================
# 8. EXTRACT CONFIRMED OBSERVED VARIABLES
# ============================================================

confirmed_map <- reviewed_map %>%
  inner_join(
    voi,
    by = "PARAMCD"
  ) %>%
  filter(
    STATUS == "OBSERVED_CONFIRMED",
    !is.na(EXPECTED_DATASET),
    !is.na(EXPECTED_CODE)
  )

trace_long <- pmap_dfr(
  confirmed_map %>%
    select(
      PARAMCD,
      EXPECTED_DATASET,
      EXPECTED_CODE,
      DESCRIPTION
    ),
  function(
    PARAMCD,
    EXPECTED_DATASET,
    EXPECTED_CODE,
    DESCRIPTION
  ) {

    if (!EXPECTED_DATASET %in% names(sdtm)) {
      warning(
        PARAMCD,
        ": dataset ",
        EXPECTED_DATASET,
        " not loaded."
      )
      return(tibble())
    }

    extract_direct_mapping(
      paramcd = PARAMCD,
      dataset = EXPECTED_DATASET,
      code = EXPECTED_CODE,
      description = DESCRIPTION,
      df = sdtm[[EXPECTED_DATASET]]
    )
  }
)

# ============================================================
# 9. TRACEABILITY SUMMARY
# ============================================================

if (nrow(trace_long) > 0) {

  trace_summary <- trace_long %>%
    group_by(
      PARAMCD,
      DESCRIPTION,
      SOURCE_DATASET,
      SOURCE_TESTCD_VAR,
      SOURCE_TESTCD,
      SOURCE_TEST_VAR,
      SOURCE_TEST,
      SOURCE_VALUE_VAR
    ) %>%
    summarise(
      N_RECORDS = n(),
      N_SUBJECTS = n_distinct(USUBJID),
      N_VISITS = n_distinct(
        AVISIT[
          !is.na(AVISIT) &
            AVISIT != ""
        ]
      ),
      UNITS = collapse_unique(UNIT),
      VISITS = collapse_unique(AVISIT),
      .groups = "drop"
    )

} else {

  trace_summary <- tibble()

}

write_csv(
  trace_summary,
  file.path(
    output_dir,
    "02_traceability_summary.csv"
  ),
  na = ""
)

write_csv(
  trace_long,
  file.path(
    output_dir,
    "03_traceability_long.csv"
  ),
  na = ""
)

# ============================================================
# 10. GAP ANALYSIS - ALL 37 VARIABLES
# ============================================================

if (nrow(trace_long) > 0) {

  observed_stats <- trace_long %>%
    group_by(PARAMCD) %>%
    summarise(
      N_RECORDS = n(),
      N_SUBJECTS = n_distinct(USUBJID),
      N_VISITS = n_distinct(
        AVISIT[
          !is.na(AVISIT) &
            AVISIT != ""
        ]
      ),
      OBSERVED_UNITS = collapse_unique(UNIT),
      OBSERVED_VISITS = collapse_unique(AVISIT),
      .groups = "drop"
    )

} else {

  observed_stats <- tibble(
    PARAMCD = character(),
    N_RECORDS = integer(),
    N_SUBJECTS = integer(),
    N_VISITS = integer(),
    OBSERVED_UNITS = character(),
    OBSERVED_VISITS = character()
  )

}

gap_analysis <- voi %>%
  left_join(
    reviewed_map,
    by = "PARAMCD"
  ) %>%
  left_join(
    observed_stats,
    by = "PARAMCD"
  ) %>%
  mutate(
    N_RECORDS = coalesce(
      N_RECORDS,
      0L
    ),

    N_SUBJECTS = coalesce(
      N_SUBJECTS,
      0L
    ),

    N_VISITS = coalesce(
      N_VISITS,
      0L
    ),

    FINAL_STATUS = case_when(
      STATUS == "OBSERVED_CONFIRMED" &
        N_RECORDS > 0 ~
        "FOUND_OBSERVED",

      STATUS == "OBSERVED_CONFIRMED" &
        N_RECORDS == 0 ~
        "MAPPED_BUT_NO_VALUES",

      STATUS == "DERIVABLE_COMPONENTS_AVAILABLE" ~
        "DERIVABLE_COMPONENTS_AVAILABLE",

      STATUS == "REVIEW_CANDIDATE" ~
        "REVIEW_CANDIDATE",

      STATUS == "NOT_IDENTIFIED" ~
        "NOT_IDENTIFIED",

      TRUE ~
        "REVIEW_CANDIDATE"
    )
  ) %>%
  select(
    PARAMCD,
    DESCRIPTION,
    FINAL_STATUS,
    EXPECTED_DATASET,
    EXPECTED_CODE,
    N_SUBJECTS,
    N_RECORDS,
    N_VISITS,
    OBSERVED_UNITS,
    OBSERVED_VISITS,
    REVIEW_NOTE,
    FOUND_IN_SCRIPT01
  )

write_csv(
  gap_analysis,
  file.path(
    output_dir,
    "01_gap_analysis.csv"
  ),
  na = ""
)

# ============================================================
# 11. DUPLICATE / MULTIPLE VALUE REVIEW
# ============================================================

if (nrow(trace_long) > 0) {

  duplicate_review <- trace_long %>%
    group_by(
      USUBJID,
      AVISIT,
      AVISITN,
      PARAMCD
    ) %>%
    summarise(
      N_RECORDS = n(),
      N_UNIQUE_VALUES = n_distinct(VALUE),
      VALUES = collapse_unique(VALUE),
      SOURCE_DATASETS = collapse_unique(SOURCE_DATASET),
      SOURCE_SEQS = collapse_unique(SOURCE_SEQ),
      .groups = "drop"
    ) %>%
    filter(
      N_RECORDS > 1 |
        N_UNIQUE_VALUES > 1
    ) %>%
    arrange(
      PARAMCD,
      USUBJID,
      AVISITN,
      AVISIT
    )

} else {

  duplicate_review <- tibble()

}

write_csv(
  duplicate_review,
  file.path(
    output_dir,
    "04_duplicate_review.csv"
  ),
  na = ""
)

# ============================================================
# 12. BUILD SDTM-BASED ARD
# ============================================================
#
# Grain:
#   One row per USUBJID + AVISIT + AVISITN
#
# Multiple distinct values for the same subject/visit/PARAMCD are preserved
# using " | " instead of arbitrarily selecting one value.
# ============================================================

if (nrow(trace_long) > 0) {

  ard_long <- trace_long %>%
    group_by(
      USUBJID,
      AVISIT,
      AVISITN,
      PARAMCD
    ) %>%
    summarise(
      VALUE = collapse_unique(VALUE),
      .groups = "drop"
    )

  ard <- ard_long %>%
    pivot_wider(
      id_cols = c(
        USUBJID,
        AVISIT,
        AVISITN
      ),
      names_from = PARAMCD,
      values_from = VALUE
    ) %>%
    arrange(
      USUBJID,
      AVISITN,
      AVISIT
    )

} else {

  ard <- tibble(
    USUBJID = character(),
    AVISIT = character(),
    AVISITN = numeric()
  )

}

# Add all 37 PARAMCD columns, even when not found.
for (p in voi$PARAMCD) {
  if (!p %in% names(ard)) {
    ard[[p]] <- NA_character_
  }
}

ard <- ard %>%
  select(
    USUBJID,
    AVISIT,
    AVISITN,
    all_of(voi$PARAMCD)
  )

write_csv(
  ard,
  file.path(
    output_dir,
    "05_FIGARO_UC301_SDTM_based_ARD.csv"
  ),
  na = ""
)

# ============================================================
# 13. MAPPING ACTUALLY USED FOR ARD
# ============================================================

mapping_used <- gap_analysis %>%
  mutate(
    INCLUDED_IN_ARD =
      FINAL_STATUS == "FOUND_OBSERVED"
  )

write_csv(
  mapping_used,
  file.path(
    output_dir,
    "06_mapping_used_for_ARD.csv"
  ),
  na = ""
)

# ============================================================
# 14. CONSOLE SUMMARY
# ============================================================

status_summary <- gap_analysis %>%
  count(
    FINAL_STATUS,
    name = "N_VARIABLES"
  ) %>%
  arrange(
    desc(N_VARIABLES)
  )

cat("\n============================================================\n")
cat("FIGARO UC301 - SDTM -> GAP ANALYSIS + TRACEABILITY + ARD\n")
cat("============================================================\n\n")

print(status_summary)

cat("\nARD dimensions:\n")
cat("Rows:    ", nrow(ard), "\n", sep = "")
cat("Columns: ", ncol(ard), "\n", sep = "")

cat("\nVariables included in the ARD:\n")

print(
  gap_analysis %>%
    filter(
      FINAL_STATUS == "FOUND_OBSERVED"
    ) %>%
    select(
      PARAMCD,
      EXPECTED_DATASET,
      EXPECTED_CODE,
      N_SUBJECTS,
      N_RECORDS,
      N_VISITS
    )
)

cat("\nFiles created in:\n")
cat(normalizePath(output_dir), "\n\n")

cat("  01_gap_analysis.csv\n")
cat("  02_traceability_summary.csv\n")
cat("  03_traceability_long.csv\n")
cat("  04_duplicate_review.csv\n")
cat("  05_FIGARO_UC301_SDTM_based_ARD.csv\n")
cat("  06_mapping_used_for_ARD.csv\n")
