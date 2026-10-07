# ============================================================
# CROHN'S DISEASE - GENERIC SDTM -> GAP ANALYSIS + TRACEABILITY + ARD
# ============================================================
# Designed from the outputs of map_cd_variables_from_sdtm.R
#
# INPUTS:
#   03_mapping_candidates_automatic.csv
#   04_mapping_overview_best_candidate.csv
#   SDTM XPT folder for CARMEN CD 305
#
# OUTPUTS:
#   01_gap_analysis.csv
#   02_traceability_summary.csv
#   03_traceability_long.csv
#   04_duplicate_review.csv
#   05_CARMEN_CD305_SDTM_based_ARD.csv
#   06_mapping_used_for_ARD.csv
#   07_mapping_review_queue.csv
#
# SAFETY / INTERPRETATION:
#   - Highest text SCORE is NOT automatically a clinical mapping.
#   - Exact TESTCD matches are accepted as direct observed candidates.
#   - Exact SDTM COLUMN matches are accepted for direct subject-level fields,
#     but VISIT/VISITNUM are used as ARD keys rather than PARAM values.
#   - A small set of strong, semantically direct TEST mappings identified in
#     the current study scanner output is explicitly whitelisted.
#   - All other variables remain REVIEW_REQUIRED / NOT_IDENTIFIED and are not
#     populated in the ARD until reviewed.
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
# 1. CONFIGURATION - EDIT THESE PATHS IN DOMINO
# ============================================================

study_id <- "CHANGE_ME"

# CHANGE THIS to the SDTM XPT folder for the CD study.
sdtm_dir <- "/domino/datasets/local/CHANGE_ME/clinical/rawdata/CHANGE_ME"

candidate_mapping_files <- c(
  "03_mapping_candidates_automatic.csv",
  "03_mapping_candidates_automatic(1).csv",
  "/mnt/03_mapping_candidates_automatic.csv",
  "/mnt/03_mapping_candidates_automatic(1).csv"
)

overview_files <- c(
  "04_mapping_overview_best_candidate.csv",
  "/mnt/04_mapping_overview_best_candidate.csv"
)

output_root <- "/mnt"
if (!dir.exists(output_root) || file.access(output_root, 2) != 0) output_root <- getwd()
safe_study_id <- str_replace_all(study_id, "[^A-Za-z0-9_-]+", "_")
output_dir <- file.path(output_root, paste0(safe_study_id, "_cd_ard_output"))
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

if (!dir.exists(sdtm_dir)) {
  stop("SDTM folder does not exist: ", sdtm_dir,
       "\nEdit sdtm_dir in Section 1 before running.")
}

find_first <- function(x) {
  hit <- x[file.exists(x)]
  if (length(hit) == 0) NA_character_ else hit[1]
}

candidate_file <- find_first(candidate_mapping_files)
overview_file  <- find_first(overview_files)

if (is.na(candidate_file)) stop("03_mapping_candidates_automatic.csv not found.")
if (is.na(overview_file))  stop("04_mapping_overview_best_candidate.csv not found.")

# ============================================================
# 2. READ SCANNER OUTPUTS
# ============================================================

candidates <- read_csv(candidate_file, show_col_types = FALSE)
overview   <- read_csv(overview_file, show_col_types = FALSE)

stopifnot(nrow(overview) == 140)

voi <- overview %>%
  select(PARAMCD, DESCRIPTION) %>%
  distinct()

# ============================================================
# 3. CONSERVATIVE REVIEWED MAPPING
# ============================================================
# Base rule:
#   EXACT_CODE_CANDIDATE + TEST   -> OBSERVED_CONFIRMED
#   EXACT_CODE_CANDIDATE + COLUMN -> DIRECT_COLUMN
#   otherwise                     -> REVIEW_REQUIRED
#
# Explicit strong mappings below were present in the supplied CARMEN output
# and are semantically direct. They can be edited after clinical review.
# ============================================================

reviewed <- overview %>%
  transmute(
    PARAMCD,
    DESCRIPTION,
    AUTO_TRIAGE,
    METADATA_TYPE = AUTO_METADATA_TYPE,
    DATASET = AUTO_DATASET,
    CODE_VAR = AUTO_CODE_VAR,
    CODE = AUTO_CODE,
    LABEL_VAR = AUTO_LABEL_VAR,
    LABEL = AUTO_LABEL,
    SCORE = AUTO_SCORE,
    STATUS = case_when(
      AUTO_TRIAGE == "EXACT_CODE_CANDIDATE" &
        AUTO_METADATA_TYPE == "TEST" ~ "OBSERVED_CONFIRMED",
      AUTO_TRIAGE == "EXACT_CODE_CANDIDATE" &
        AUTO_METADATA_TYPE == "COLUMN" ~ "DIRECT_COLUMN",
      AUTO_TRIAGE == "NO_AUTOMATIC_CANDIDATE" ~ "NOT_IDENTIFIED",
      TRUE ~ "REVIEW_REQUIRED"
    ),
    REVIEW_NOTE = case_when(
      STATUS == "OBSERVED_CONFIRMED" ~
        "Exact TESTCD/code match from current study scanner output.",
      STATUS == "DIRECT_COLUMN" ~
        "Exact SDTM column match; subject-level fields are propagated across ARD rows.",
      STATUS == "NOT_IDENTIFIED" ~
        "No automatic candidate returned by scanner.",
      TRUE ~
        "Candidate exists but requires clinical/programming review before ARD inclusion."
    )
  )

# OPTIONAL STUDY-SPECIFIC REVIEWED OVERRIDES
# Leave empty on the first pass. Add mappings here only after reviewing
# 03_mapping_candidates_automatic.csv / 07_mapping_review_queue.csv.
reviewed_overrides <- tibble(
  PARAMCD=character(), METADATA_TYPE=character(), DATASET=character(),
  CODE=character(), LABEL=character(), STATUS=character(), REVIEW_NOTE=character()
)

if (nrow(reviewed_overrides) > 0) {
  for (i in seq_len(nrow(reviewed_overrides))) {
    p <- reviewed_overrides$PARAMCD[i]
    reviewed <- reviewed %>% mutate(
      METADATA_TYPE=if_else(PARAMCD==p,reviewed_overrides$METADATA_TYPE[i],METADATA_TYPE),
      DATASET=if_else(PARAMCD==p,reviewed_overrides$DATASET[i],DATASET),
      CODE=if_else(PARAMCD==p,reviewed_overrides$CODE[i],CODE),
      LABEL=if_else(PARAMCD==p,reviewed_overrides$LABEL[i],LABEL),
      STATUS=if_else(PARAMCD==p,reviewed_overrides$STATUS[i],STATUS),
      REVIEW_NOTE=if_else(PARAMCD==p,reviewed_overrides$REVIEW_NOTE[i],REVIEW_NOTE)
    )
  }
}

# subject_id is an alias of USUBJID in the scanner result; do not duplicate it
# as an independent clinical observation.
reviewed <- reviewed %>%
  mutate(
    STATUS = if_else(PARAMCD == "subject_id", "ALIAS_OF_USUBJID", STATUS),
    REVIEW_NOTE = if_else(
      PARAMCD == "subject_id",
      "Scanner maps subject_id to USUBJID; retained as alias, not independent observation.",
      REVIEW_NOTE
    )
  )

# VISIT and VISITNUM are structural ARD keys.
reviewed <- reviewed %>%
  mutate(
    STATUS = if_else(PARAMCD %in% c("VISIT", "VISITNUM"), "ARD_KEY", STATUS),
    REVIEW_NOTE = if_else(
      PARAMCD %in% c("VISIT", "VISITNUM"),
      "Used to construct AVISIT/AVISITN keys; not extracted as a separate value column.",
      REVIEW_NOTE
    )
  )

# ============================================================
# 4. READ XPT DATASETS
# ============================================================

xpt_files <- list.files(sdtm_dir, pattern = "\\.xpt$", full.names = TRUE,
                        ignore.case = TRUE)
if (length(xpt_files) == 0) stop("No XPT files found in ", sdtm_dir)

xpt_names <- toupper(tools::file_path_sans_ext(basename(xpt_files)))
xpt_lookup <- setNames(xpt_files, xpt_names)

safe_read_xpt <- function(path) {
  tryCatch(read_xpt(path), error = function(e) {
    warning("Could not read ", basename(path), ": ", conditionMessage(e))
    NULL
  })
}

needed <- reviewed %>%
  filter(STATUS %in% c("OBSERVED_CONFIRMED", "DIRECT_COLUMN")) %>%
  pull(DATASET) %>% na.omit() %>% unique() %>% toupper()

# DM is required for subject-level direct columns.
needed <- unique(c(needed, "DM"))

available <- intersect(needed, names(xpt_lookup))
sdtm <- map(available, ~safe_read_xpt(xpt_lookup[[.x]]))
names(sdtm) <- available
sdtm <- compact(sdtm)

# ============================================================
# 5. HELPERS
# ============================================================

first_existing <- function(nms, opts) {
  z <- opts[opts %in% nms]
  if (length(z) == 0) NA_character_ else z[1]
}

collapse_unique <- function(x, sep = " | ") {
  x <- as.character(x)
  x <- x[!is.na(x) & x != ""]
  if (length(x) == 0) return(NA_character_)
  paste(unique(x), collapse = sep)
}

extract_test <- function(paramcd, description, dataset, code, df) {
  nms <- names(df)

  testcd <- first_existing(nms, c(
    paste0(dataset, "TESTCD"), "QSTESTCD", "LBTESTCD", "MITESTCD",
    "MOTESTCD", "FATESTCD"
  ))
  test <- first_existing(nms, c(
    paste0(dataset, "TEST"), "QSTEST", "LBTEST", "MITEST",
    "MOTEST", "FATEST"
  ))
  value <- first_existing(nms, c(
    paste0(dataset, "STRESN"), "QSSTRESN", "LBSTRESN", "MISTRESN", "MOSTRESN", "FASTRESN",
    paste0(dataset, "STRESC"), "QSSTRESC", "LBSTRESC", "MISTRESC", "MOSTRESC", "FASTRESC",
    paste0(dataset, "ORRES"),  "QSORRES",  "LBORRES",  "MIORRES",  "MOORRES",  "FAORRES"
  ))
  unit <- first_existing(nms, c(
    paste0(dataset, "STRESU"), "QSSTRESU", "LBSTRESU", "MISTRESU", "MOSTRESU", "FASTRESU",
    paste0(dataset, "ORRESU"), "QSORRESU", "LBORRESU", "MIORRESU", "MOORRESU", "FAORRESU"
  ))
  seqv <- first_existing(nms, c(
    paste0(dataset, "SEQ"), "QSSEQ", "LBSEQ", "MISEQ", "MOSEQ", "FASEQ"
  ))
  dtc <- first_existing(nms, c(
    paste0(dataset, "DTC"), "QSDTC", "LBDTC", "MIDTC", "MODTC", "FADTC"
  ))

  if (!"USUBJID" %in% nms || is.na(testcd) || is.na(value)) return(tibble())

  df %>%
    filter(as.character(.data[[testcd]]) == code) %>%
    transmute(
      USUBJID = as.character(USUBJID),
      AVISIT = if ("VISIT" %in% nms) as.character(VISIT) else NA_character_,
      AVISITN = if ("VISITNUM" %in% nms) suppressWarnings(as.numeric(VISITNUM)) else NA_real_,
      PARAMCD = paramcd,
      DESCRIPTION = description,
      VALUE = as.character(.data[[value]]),
      UNIT = if (!is.na(unit)) as.character(.data[[unit]]) else NA_character_,
      SOURCE_DATASET = dataset,
      SOURCE_CODE_VAR = testcd,
      SOURCE_CODE = as.character(.data[[testcd]]),
      SOURCE_TEST = if (!is.na(test)) as.character(.data[[test]]) else NA_character_,
      SOURCE_VALUE_VAR = value,
      SOURCE_SEQ = if (!is.na(seqv)) as.character(.data[[seqv]]) else NA_character_,
      SOURCE_DTC = if (!is.na(dtc)) as.character(.data[[dtc]]) else NA_character_
    ) %>%
    filter(!is.na(VALUE), VALUE != "")
}

# ============================================================
# 6. EXTRACT DIRECT OBSERVED TESTS
# ============================================================

test_map <- reviewed %>%
  filter(STATUS == "OBSERVED_CONFIRMED", METADATA_TYPE == "TEST",
         !is.na(DATASET), !is.na(CODE))

trace_long <- pmap_dfr(
  test_map %>% select(PARAMCD, DESCRIPTION, DATASET, CODE),
  function(PARAMCD, DESCRIPTION, DATASET, CODE) {
    ds <- toupper(DATASET)
    if (!ds %in% names(sdtm)) return(tibble())
    extract_test(PARAMCD, DESCRIPTION, ds, CODE, sdtm[[ds]])
  }
)

# ============================================================
# 7. BUILD VISIT GRID FROM OBSERVED TEST DATA
# ============================================================

visit_grid <- trace_long %>%
  distinct(USUBJID, AVISIT, AVISITN)

# Fallback: if no accepted TEST observations were extracted, use SV.
if (nrow(visit_grid) == 0 && "SV" %in% names(xpt_lookup)) {
  sv <- safe_read_xpt(xpt_lookup[["SV"]])
  if (!is.null(sv)) {
    visit_grid <- sv %>%
      transmute(
        USUBJID = as.character(USUBJID),
        AVISIT = if ("VISIT" %in% names(sv)) as.character(VISIT) else NA_character_,
        AVISITN = if ("VISITNUM" %in% names(sv)) suppressWarnings(as.numeric(VISITNUM)) else NA_real_
      ) %>% distinct()
  }
}

# ============================================================
# 8. DIRECT SUBJECT-LEVEL COLUMN VALUES
# ============================================================
# Exact columns such as AGE, SEX, RACE, COUNTRY, ETHNIC, SITEID, SUBJID,
# STUDYID and USUBJID are sourced preferentially from DM when present.
# They are propagated across the subject's ARD visit rows.
# ============================================================

column_params <- reviewed %>%
  filter(STATUS == "DIRECT_COLUMN") %>%
  pull(PARAMCD)

subject_cols <- tibble(USUBJID = unique(visit_grid$USUBJID))

if ("DM" %in% names(sdtm)) {
  dm <- sdtm[["DM"]]
  keep <- intersect(c("USUBJID", column_params), names(dm))
  if ("USUBJID" %in% keep) {
    subject_cols <- dm %>%
      select(all_of(keep)) %>%
      mutate(across(everything(), as.character)) %>%
      distinct(USUBJID, .keep_all = TRUE)
  }
}

# STUDYID can be taken from DM even if scanner's best candidate was AE.
if ("DM" %in% names(sdtm) && "STUDYID" %in% names(sdtm[["DM"]]) &&
    "STUDYID" %in% column_params) {
  dm_study <- sdtm[["DM"]] %>%
    transmute(USUBJID = as.character(USUBJID), STUDYID = as.character(STUDYID)) %>%
    distinct()
  subject_cols <- subject_cols %>%
    select(-any_of("STUDYID")) %>%
    left_join(dm_study, by = "USUBJID")
}

# ============================================================
# 9. TRACEABILITY SUMMARY
# ============================================================

trace_summary <- if (nrow(trace_long) > 0) {
  trace_long %>%
    group_by(PARAMCD, DESCRIPTION, SOURCE_DATASET, SOURCE_CODE_VAR,
             SOURCE_CODE, SOURCE_TEST, SOURCE_VALUE_VAR) %>%
    summarise(
      N_RECORDS = n(),
      N_SUBJECTS = n_distinct(USUBJID),
      N_VISITS = n_distinct(AVISIT[!is.na(AVISIT) & AVISIT != ""]),
      UNITS = collapse_unique(UNIT),
      VISITS = collapse_unique(AVISIT),
      .groups = "drop"
    )
} else tibble()

write_csv(trace_summary, file.path(output_dir, "02_traceability_summary.csv"), na = "")
write_csv(trace_long, file.path(output_dir, "03_traceability_long.csv"), na = "")

# ============================================================
# 10. DUPLICATE REVIEW
# ============================================================

duplicate_review <- if (nrow(trace_long) > 0) {
  trace_long %>%
    group_by(USUBJID, AVISIT, AVISITN, PARAMCD) %>%
    summarise(
      N_RECORDS = n(),
      N_UNIQUE_VALUES = n_distinct(VALUE),
      VALUES = collapse_unique(VALUE),
      SOURCE_DATASETS = collapse_unique(SOURCE_DATASET),
      SOURCE_SEQS = collapse_unique(SOURCE_SEQ),
      SOURCE_DTCS = collapse_unique(SOURCE_DTC),
      .groups = "drop"
    ) %>%
    filter(N_RECORDS > 1 | N_UNIQUE_VALUES > 1) %>%
    arrange(PARAMCD, USUBJID, AVISITN, AVISIT)
} else tibble()

write_csv(duplicate_review, file.path(output_dir, "04_duplicate_review.csv"), na = "")

# ============================================================
# 11. BUILD ARD
# ============================================================

ard_test <- if (nrow(trace_long) > 0) {
  trace_long %>%
    group_by(USUBJID, AVISIT, AVISITN, PARAMCD) %>%
    summarise(VALUE = collapse_unique(VALUE), .groups = "drop") %>%
    pivot_wider(
      id_cols = c(USUBJID, AVISIT, AVISITN),
      names_from = PARAMCD,
      values_from = VALUE
    )
} else visit_grid

ard <- visit_grid %>%
  left_join(ard_test, by = c("USUBJID", "AVISIT", "AVISITN")) %>%
  left_join(subject_cols, by = "USUBJID")

# subject_id alias
if ("subject_id" %in% voi$PARAMCD) ard$subject_id <- ard$USUBJID

# Add all 140 variables so the output directly visualizes coverage.
for (p in voi$PARAMCD) {
  if (!p %in% names(ard)) ard[[p]] <- NA_character_
}

# VISIT/VISITNUM are represented by AVISIT/AVISITN, but populate the requested
# columns too for convenience.
if ("VISIT" %in% voi$PARAMCD) ard$VISIT <- ard$AVISIT
if ("VISITNUM" %in% voi$PARAMCD) ard$VISITNUM <- as.character(ard$AVISITN)

ard <- ard %>%
  select(USUBJID, AVISIT, AVISITN, all_of(setdiff(voi$PARAMCD, "USUBJID"))) %>%
  arrange(USUBJID, AVISITN, AVISIT)

write_csv(
  ard,
  file.path(output_dir, paste0("05_", safe_study_id, "_SDTM_based_ARD.csv")),
  na = ""
)

# ============================================================
# 12. GAP ANALYSIS
# ============================================================

obs_stats <- if (nrow(trace_long) > 0) {
  trace_long %>%
    group_by(PARAMCD) %>%
    summarise(
      N_RECORDS = n(),
      N_SUBJECTS = n_distinct(USUBJID),
      N_VISITS = n_distinct(AVISIT[!is.na(AVISIT) & AVISIT != ""]),
      OBSERVED_UNITS = collapse_unique(UNIT),
      OBSERVED_VISITS = collapse_unique(AVISIT),
      .groups = "drop"
    )
} else tibble(
  PARAMCD=character(), N_RECORDS=integer(), N_SUBJECTS=integer(),
  N_VISITS=integer(), OBSERVED_UNITS=character(), OBSERVED_VISITS=character()
)

# Direct-column coverage
column_stats <- map_dfr(column_params, function(p) {
  if (!p %in% names(ard)) return(tibble())
  x <- ard[[p]]
  tibble(
    PARAMCD = p,
    COLUMN_NONMISSING_ROWS = sum(!is.na(x) & as.character(x) != ""),
    COLUMN_SUBJECTS = n_distinct(ard$USUBJID[!is.na(x) & as.character(x) != ""])
  )
})

gap <- reviewed %>%
  left_join(obs_stats, by = "PARAMCD") %>%
  left_join(column_stats, by = "PARAMCD") %>%
  mutate(
    N_RECORDS = coalesce(N_RECORDS, COLUMN_NONMISSING_ROWS, 0L),
    N_SUBJECTS = coalesce(N_SUBJECTS, COLUMN_SUBJECTS, 0L),
    N_VISITS = coalesce(N_VISITS, 0L),
    FINAL_STATUS = case_when(
      STATUS == "OBSERVED_CONFIRMED" & N_RECORDS > 0 ~ "FOUND_OBSERVED",
      STATUS == "OBSERVED_CONFIRMED" & N_RECORDS == 0 ~ "MAPPED_BUT_NO_VALUES",
      STATUS == "DIRECT_COLUMN" & N_RECORDS > 0 ~ "FOUND_DIRECT_COLUMN",
      STATUS == "DIRECT_COLUMN" & N_RECORDS == 0 ~ "DIRECT_COLUMN_NO_VALUES",
      STATUS == "ARD_KEY" ~ "ARD_KEY",
      STATUS == "ALIAS_OF_USUBJID" ~ "ALIAS_OF_USUBJID",
      STATUS == "NOT_IDENTIFIED" ~ "NOT_IDENTIFIED",
      TRUE ~ "REVIEW_REQUIRED"
    )
  ) %>%
  select(
    PARAMCD, DESCRIPTION, FINAL_STATUS, AUTO_TRIAGE,
    METADATA_TYPE, DATASET, CODE, LABEL, SCORE,
    N_SUBJECTS, N_RECORDS, N_VISITS,
    OBSERVED_UNITS, OBSERVED_VISITS, REVIEW_NOTE
  )

write_csv(gap, file.path(output_dir, "01_gap_analysis.csv"), na = "")

mapping_used <- gap %>%
  mutate(
    INCLUDED_IN_ARD = FINAL_STATUS %in%
      c("FOUND_OBSERVED", "FOUND_DIRECT_COLUMN", "ARD_KEY", "ALIAS_OF_USUBJID")
  )

write_csv(mapping_used, file.path(output_dir, "06_mapping_used_for_ARD.csv"), na = "")

review_queue <- gap %>%
  filter(FINAL_STATUS %in% c("REVIEW_REQUIRED", "MAPPED_BUT_NO_VALUES",
                             "DIRECT_COLUMN_NO_VALUES")) %>%
  arrange(desc(SCORE), PARAMCD)

write_csv(review_queue, file.path(output_dir, "07_mapping_review_queue.csv"), na = "")

# ============================================================
# 13. CONSOLE SUMMARY
# ============================================================

cat("\n============================================================\n")
cat("CROHN DISEASE - GAP ANALYSIS + TRACEABILITY + ARD\n")
cat("Study: ", study_id, "\n", sep="")
cat("============================================================\n\n")

print(gap %>% count(FINAL_STATUS, name = "N_VARIABLES") %>% arrange(desc(N_VARIABLES)))

cat("\nARD dimensions:\n")
cat("Rows: ", nrow(ard), "\n", sep = "")
cat("Columns: ", ncol(ard), "\n", sep = "")

cat("\nFiles created in:\n", normalizePath(output_dir), "\n\n", sep = "")
cat("  01_gap_analysis.csv\n")
cat("  02_traceability_summary.csv\n")
cat("  03_traceability_long.csv\n")
cat("  04_duplicate_review.csv\n")
cat("  05_", safe_study_id, "_SDTM_based_ARD.csv\n", sep="")
cat("  06_mapping_used_for_ARD.csv\n")
cat("  07_mapping_review_queue.csv\n\n")
cat("Review 01, 04 and 07 before treating the ARD as final.\n")
