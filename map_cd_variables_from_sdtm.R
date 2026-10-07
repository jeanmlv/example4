# ============================================================
# CROHN'S DISEASE - SDTM VARIABLE MAPPING / CANDIDATE SCANNER
# ============================================================
# Purpose:
#   1) Inventory all XPT datasets in one Crohn's disease SDTM folder.
#   2) Build searchable metadata from:
#        - actual SDTM variable names + labels,
#        - --TESTCD / --TEST values,
#        - SUPP-- QNAM / QLABEL values.
#   3) Compare that metadata with the 140 CD variables of interest.
#   4) Return ranked discovery candidates for clinical/programming review.
#
# IMPORTANT:
#   - Automated text matching is a discovery aid, not a replacement for review.
#   - ADaM-style analysis variables, flags, estimands and derived endpoints
#     must not be treated as observed SDTM variables solely because components
#     are present.
#   - This scanner intentionally includes SDTM COLUMN metadata because the
#     140-variable CD list contains identifiers/demographics such as USUBJID,
#     AGE, SEX, RACE, COUNTRY, VISIT and VISITNUM in addition to endpoints.
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

# REQUIRED:
# Set this to the SDTM XPT folder for the Crohn's disease study you want
# to scan. Re-run the script for each study.
sdtm_dir <- "/domino/datasets/local/CHANGE_ME/clinical/rawdata/CHANGE_ME"

# Optional study label used in every output.
study_id <- "CHANGE_ME"

# Output location.
output_root <- "/mnt"
if (!dir.exists(output_root) || file.access(output_root, 2) != 0) {
  output_root <- getwd()
}

safe_study_id <- str_replace_all(study_id, "[^A-Za-z0-9_-]+", "_")
output_dir <- file.path(output_root, paste0("cd_mapping_", safe_study_id))
dir.create(output_dir, showWarnings = FALSE, recursive = TRUE)

if (!dir.exists(sdtm_dir)) {
  stop(
    "SDTM folder does not exist:\n", sdtm_dir,
    "\n\nEdit 'sdtm_dir' in the CONFIGURATION section before running."
  )
}

xpt_files <- list.files(
  sdtm_dir,
  pattern = "\\.xpt$",
  full.names = TRUE,
  ignore.case = TRUE
)

if (length(xpt_files) == 0) {
  stop("No XPT files found in: ", sdtm_dir)
}

cat("\nStudy: ", study_id, "\n", sep = "")
cat("SDTM folder: ", sdtm_dir, "\n", sep = "")
cat("XPT files found: ", length(xpt_files), "\n\n", sep = "")

# ============================================================
# 2. 140 CROHN'S DISEASE VARIABLES OF INTEREST
#    Imported/adapted from cd_variables_interest.xlsx
# ============================================================

voi <- tribble(
  ~PARAMCD, ~DESCRIPTION,
  "CALPRO", "Fecal Calprotectin (mg/kg)",
  "CRP", "C-Reactive Protein (mg/L)",
  "CREMISCO", "Clinical Remission Score",
  "CRESPSCO", "Clinical Response Score",
  "ENDREM", "Endoscopic Remission Main Approach",
  "TSESCD", "Total Simple Endoscopic Score for Crohn's Disease (SES-CD)",
  "COLON_ONLY", "Colon only",
  "FISTULA", "Anal Fissure (Presence of Fistula)",
  "ILEUM_COLON", "Ileum and Colon",
  "ILEUM_ONLY", "Ileum only",
  "CDAI_PAIN", "Abdominal Pain Score",
  "CDAI_STOOL", "Liquid/Soft Stools Score",
  "CDAI_WB", "General Well-Being Score",
  "CDAI_EXTRA_INTEST", "Extraintestinal Manifestation Score",
  "CDAI_ANTIDIAR", "Antidiarrheal Score",
  "CDAI_ABMASS", "Abdominal Mass Score",
  "CDAI_HCT", "Hematocrit Score",
  "CDAI_STWT", "Standard Weight (kg)",
  "STRICTURING", "Intestinal Stricture",
  "CREMIPR2", "Clinical Remission Patient Reported Outcome (PRO-2)",
  "FATIGUE", "Fatigue",
  "ENDHEL", "Endoscopic Healing",
  "bag_id", "-",
  "IBDQ_TOT", "Inflamatory Bowel Disease Questionnaire (IBDQ) Total Score",
  "IBDQREM", "IBDQ Remission (ICE 1-3,5,6 Non-Responder)",
  "IBDTC", "IBDQ Total Score (ICE 1-6 BL)",
  "IBDTP", "IBDQ Total Score (ICE 1-3,5,6 BL)",
  "ILEUMMAX", "Ileum Max Biopsy Score",
  "RECTMAX", "Rectum Max Biopsy Score",
  "TGHASMP", "Total GHAS Score - Complete Case (ICE 1-3 BL)",
  "TGHASNMP", "Total GHAS Score - Main Approach (ICE 1-3 BL)",
  "ENHRESBP", "Histo-Endoscopic Response Baseline Segment Match for both HR and ER (ICE 1-3 Non-Responder)",
  "ENHRMP", "Histo-Endoscopic Response Complete Case (ICE 1-3 Non-Responder)",
  "ENHRNMP", "Histo-Endoscopic Response Main Approach (ICE 1-3 Non-Responder)",
  "HISRESBP", "Histologic Response Baseline Segment Match (ICE 1-3 Non-Responder)",
  "HISTRMP", "Histologic Response Complete Case (ICE 1-3 Non-Responder)",
  "HISTRNMP", "Histologic Response Main Approach (ICE 1-3 Non-Responder)",
  "STUDYID", "Study Identifier",
  "USUBJID", "Unique Subject Identifier",
  "subject_id", "Unique Subject Identifier",
  "AVISIT", "Analysis Visit",
  "TRT01P", "Planned Treatment Arm 1",
  "TRT01PN", "Planned Treatment Arm Code (Numeric) 1",
  "TRT01A", "Actual Treatment Arm 1",
  "TRT01AN", "Actual Treatment Arm Code (Numeric) 1",
  "TRT02P", "Planned Treatment Arm 2",
  "TRT02PN", "Planned Treatment Arm Code (Numeric) 2",
  "TRT02A", "Actual Treatment Arm 2",
  "TRT02AN", "Actual Treatment Arm Code (Numeric) 2",
  "AGE", "Age",
  "SEX", "Sex",
  "RACE", "Race",
  "COUNTRY", "Country",
  "ETHNIC", "Ethnicity",
  "VISIT", "Study Visit",
  "VISITNUM", "Study Visit Number",
  "SITEID", "Study Site Identifier",
  "SUBJID", "Subject Identifier",
  "ABLFL", "Baseline Record Flag",
  "APOBLFL", "Post-Baseline Analysis Flag",
  "RANDFL", "Randomized Population Flag",
  "FASFL", "Full Analysis Set Flag",
  "SAFFL", "Safety Analysis Set Flag",
  "PASFL", "Per Protocol Analysis Set Flag",
  "USMFL", "Use of Study Medication Flag",
  "CDAI", "Modified Total CDAI Score",
  "CDAIC", "CDAI Score (ICE 1-4 BL)",
  "CDAIH", "CDAI Score (ICE 1-4 Missing)",
  "CDAIP", "CDAI Score (ICE 1-3,5,6 BL)",
  "CREMC", "Clinical Remission (ICE 1-4 Non-Responder)",
  "CREMP", "Clinical Remission (ICE 1-3 Non-Responder)",
  "CRESC", "Clinical Response (ICE 1-4 Non-Responder)",
  "CRESP", "Clinical Response (ICE 1-3 Non-Responder)",
  "AP", "Average Daily Abdominal Pain Score",
  "AP1C", "Average Daily AP Score <=1 (ICE 1-6 Non-Responder)",
  "PRO2C", "PRO-2 Score (ICE 1-6 BL)",
  "PRO2REMC", "PRO-2 Remission (ICE 1-6 Non-Responder)",
  "PRO2REMP", "PRO-2 Remission (ICE 1-3,5,6 Non-Responder)",
  "SF", "Average Daily Stool Frequency Score",
  "SF3C", "Daily Stool Frequency Score <=3 (ICE 1-4 Non-Responder)",
  "SF3P", "Daily Stool Frequency Score <=3 (ICE 1-3 Non-Responder)",
  "SFC", "Average Daily SF Score (ICE 1-4 BL)",
  "SFP", "Average Daily SF Score (ICE 1-3 BL)",
  "WTADP", "Weighted CDAI Antidiarrheal Score (ICE 1-3,5,6 BL)",
  "WTAMP", "Weighted CDAI Abdominal Mass Score (ICE 1-3,5,6 BL)",
  "WTAPP", "Weighted CDAI Abdominal Pain Score (ICE 1-3,5,6 BL)",
  "WTEIMP", "Weighted CDAI Extraintestinal Manifestation Score (ICE 1-3,5,6 BL)",
  "WTGWBP", "Weighted CDAI General Well-Being Score (ICE 1-3,5,6 BL)",
  "WTHCTP", "Weighted CDAI Hematocrit Score (ICE 1-3,5,6 BL)",
  "WTSFP", "Weighted CDAI Stool Frequency Score (ICE 1-3,5,6 BL)",
  "WTWTP", "Weighted CDAI Standardized Weight Score (ICE 1-3,5,6 BL)",
  "EHEALP", "Endoscopic Healing (ICE 1-3,5,6 Non-Responder)",
  "EREMP", "Endoscopic Remission (ICE 1-3,5,6 Non-Responder)",
  "EREMPM", "Endoscopic Remission (ICE 1-3 Non-Responder - Modified ICE 2)",
  "EREMSMP", "Endoscopic Remission Baseline Segment Match (ICE 1-3 Non-Responder)",
  "ERESPP", "Endoscopic Response (ICE 1-3,5,6 Non-Responder)",
  "ERESPPM", "Endoscopic Response (ICE 1-3 Non-Responder - Modified ICE 2)",
  "ERESPS48", "Endoscopic Response (Supplemental Week 48)",
  "ERESPSMP", "Endoscopic Response Baseline Segment Match (ICE 1-3,5,6 Non-Responder)",
  "ERMIRP", "Colonic/Ileonic disease with SES < 4 or Ileal disease with SES < 2 (ICE 1-3 Non-Responder)",
  "ERMIRSMP", "Colonic/Ileonic disease with SES < 4 or Ileal disease with SES < 2 Baseline Segment Match (ICE 1-3 Non-Responder)",
  "PAFSURI", "Percent Affected Surface Ileum",
  "PAFSURLC", "Percent Affected Surface Left Colon",
  "PAFSURRC", "Percent Affected Surface Right Colon",
  "PAFSURRE", "Percent Affected Surface Rectum",
  "PAFSURTC", "Percent Affected Surf Transverse Colon",
  "PNARRI", "Presence Narrowing Ileum",
  "PNARRLC", "Presence Narrowing Left Colon",
  "PNARRRC", "Presence Narrowing Right Colon",
  "PNARRRE", "Presence Narrowing Rectum",
  "PNARRTC", "Presence Narrowing Transverse Colon",
  "PULCERI", "Presence Size of Ulcers Ileum",
  "PULCERLC", "Presence Size of Ulcers Left Colon",
  "PULCERRC", "Presence Size of Ulcers Right Colon",
  "PULCERRE", "Presence Size of Ulcers Rectum",
  "PULCERTC", "Presence Size of Ulcers Transverse Colon",
  "PULSURI", "Percent Ulcerated Surface Ileum",
  "PULSURLC", "Percent Ulcerated Surface Left Colon",
  "PULSURRC", "Percent Ulcerated Surface Right Colon",
  "PULSURRE", "Percent Ulcerated Surface Rectum",
  "PULSURTC", "Percent Ulcerated Surface Transverse Colon",
  "SES25P", "At least 25 Percent Improvement in SES-CD Score (ICE 1-3 Non-Responder)",
  "SES25SMP", "At least 25 Percent Improvement in SES-CD Score Baseline Segment Match (ICE 1-3 Non-Responder)",
  "SESBLM", "SES-CD Total Score Baseline Segment Match",
  "SESBLMP", "SES-CD Total Score Baseline Segment Match (ICE 1-3,5,6 BL)",
  "SESILEUM", "SES-CD Ileum Segment Score",
  "SESLCOL", "SES-CD Left/Sigmoid Colon Segment Score",
  "SESRCOL", "SES-CD Right Colon Segment Score",
  "SESRECT", "SES-CD Rectum Segment Score",
  "SESTCOL", "SES-CD Transverse Colon Segment Score",
  "SESTOT", "SES-CD Total Score",
  "SESTOTP", "SES-CD Total Score (ICE 1-3,5,6 BL)",
  "PAFSURTOT", "Percent Affected Surface Total",
  "PNARRTOT", "Presence Narrowing Total",
  "PULCERTOT", "Presence Size of Ulcers Total",
  "PULSURTOT", "Percent Ulcerated Surface Total",
  "RHI", "Robarts Histopathology Index",
  "GBTOT", "Geboes total score",
  "GBHI", "Geboes high activity subscore",
  "GBLO", "Geboes low activity subscore"
)

stopifnot(nrow(voi) == 140)

# ============================================================
# 3. TEXT NORMALIZATION / SEARCH HELPERS
# ============================================================

normalize_text <- function(x) {
  x %>%
    as.character() %>%
    str_to_lower() %>%
    str_replace_all("[^a-z0-9]+", " ") %>%
    str_squish()
}

# Generic expansions help match abbreviations commonly found in clinical data.
expand_search_text <- function(paramcd, description) {
  x <- paste(paramcd, description)

  replacements <- c(
    "crp" = "c reactive protein",
    "calpro" = "fecal calprotectin",
    "cdai" = "crohn disease activity index",
    "ibdq" = "inflammatory bowel disease questionnaire",
    "ses cd" = "simple endoscopic score crohn disease",
    "pro 2" = "patient reported outcome 2",
    "rhi" = "robarts histopathology index",
    "geboes" = "geboes",
    "gbtot" = "geboes total score",
    "gbhi" = "geboes high activity",
    "gblo" = "geboes low activity"
  )

  out <- normalize_text(x)
  for (nm in names(replacements)) {
    if (str_detect(out, fixed(normalize_text(nm)))) {
      out <- paste(out, replacements[[nm]])
    }
  }
  normalize_text(out)
}

token_score <- function(term, candidate) {
  a <- unique(str_split(term, " ", simplify = FALSE)[[1]])
  b <- unique(str_split(candidate, " ", simplify = FALSE)[[1]])

  # Ignore very short tokens; they generate excessive false positives.
  a <- a[nchar(a) >= 3]
  b <- b[nchar(b) >= 3]

  if (length(a) == 0 || length(b) == 0) return(0)

  # Fraction of target tokens represented in candidate metadata.
  length(intersect(a, b)) / length(a)
}

# ============================================================
# 4. READ ALL SDTM XPT FILES
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

sdtm <- set_names(
  map(xpt_files, safe_read_xpt),
  toupper(tools::file_path_sans_ext(basename(xpt_files)))
)

sdtm <- compact(sdtm)

if (length(sdtm) == 0) {
  stop("XPT files were found, but none could be read successfully.")
}

# ============================================================
# 5. SDTM INVENTORY
# ============================================================

inventory <- imap_dfr(sdtm, function(df, nm) {
  tibble(
    STUDY = study_id,
    DATASET = nm,
    N_ROWS = nrow(df),
    N_COLS = ncol(df),
    VARIABLES = paste(names(df), collapse = " | ")
  )
})

write_csv(
  inventory,
  file.path(output_dir, "01_sdtm_inventory.csv"),
  na = ""
)

# ============================================================
# 6. BUILD SEARCHABLE SDTM METADATA
# ============================================================
#
# Three metadata types are searched:
#
#   A) COLUMN:
#      actual SDTM variable names/labels, useful for USUBJID, AGE, SEX,
#      RACE, COUNTRY, VISIT, VISITNUM, etc.
#
#   B) TEST:
#      values of --TESTCD / --TEST, useful for QS, LB, MI, etc.
#
#   C) SUPP:
#      values of QNAM / QLABEL in SUPP-- domains.
# ============================================================

extract_column_metadata <- function(df, dataset) {
  labs <- map_chr(df, function(x) {
    lab <- attr(x, "label")
    if (is.null(lab) || length(lab) == 0 || is.na(lab)) "" else as.character(lab)
  })

  tibble(
    STUDY = study_id,
    METADATA_TYPE = "COLUMN",
    DATASET = dataset,
    CODE_VAR = "VARIABLE",
    CODE = names(df),
    LABEL_VAR = "VARIABLE_LABEL",
    LABEL = labs
  )
}

extract_test_supp_metadata <- function(df, dataset) {
  nms <- names(df)
  out <- list()

  testcd_vars <- nms[str_detect(nms, "TESTCD$")]

  for (tc in testcd_vars) {
    prefix <- str_remove(tc, "TESTCD$")
    test_var <- paste0(prefix, "TEST")

    if (test_var %in% nms) {
      tmp <- df %>%
        transmute(
          STUDY = study_id,
          METADATA_TYPE = "TEST",
          DATASET = dataset,
          CODE_VAR = tc,
          CODE = as.character(.data[[tc]]),
          LABEL_VAR = test_var,
          LABEL = as.character(.data[[test_var]])
        ) %>%
        filter(
          (!is.na(CODE) & CODE != "") |
          (!is.na(LABEL) & LABEL != "")
        ) %>%
        distinct()

      out[[length(out) + 1]] <- tmp
    }
  }

  if (all(c("QNAM", "QLABEL") %in% nms)) {
    tmp <- df %>%
      transmute(
        STUDY = study_id,
        METADATA_TYPE = "SUPP",
        DATASET = dataset,
        CODE_VAR = "QNAM",
        CODE = as.character(QNAM),
        LABEL_VAR = "QLABEL",
        LABEL = as.character(QLABEL)
      ) %>%
      filter(
        (!is.na(CODE) & CODE != "") |
        (!is.na(LABEL) & LABEL != "")
      ) %>%
      distinct()

    out[[length(out) + 1]] <- tmp
  }

  if (length(out) == 0) {
    return(tibble(
      STUDY = character(),
      METADATA_TYPE = character(),
      DATASET = character(),
      CODE_VAR = character(),
      CODE = character(),
      LABEL_VAR = character(),
      LABEL = character()
    ))
  }

  bind_rows(out)
}

column_metadata <- imap_dfr(sdtm, extract_column_metadata)
clinical_metadata <- imap_dfr(sdtm, extract_test_supp_metadata)

metadata <- bind_rows(column_metadata, clinical_metadata) %>%
  mutate(
    SEARCH_TEXT = normalize_text(
      paste(DATASET, CODE, LABEL)
    )
  ) %>%
  distinct()

write_csv(
  metadata,
  file.path(output_dir, "02_sdtm_searchable_metadata.csv"),
  na = ""
)

# ============================================================
# 7. AUTOMATIC CANDIDATE SEARCH FOR ALL 140 VARIABLES
# ============================================================

search_terms <- voi %>%
  mutate(
    SEARCH_TERM = map2_chr(
      PARAMCD,
      DESCRIPTION,
      expand_search_text
    )
  )

candidate_list <- map(seq_len(nrow(search_terms)), function(i) {

  paramcd <- search_terms$PARAMCD[i]
  description <- search_terms$DESCRIPTION[i]
  search_term <- search_terms$SEARCH_TERM[i]

  # Exact code/name match gets highest priority.
  exact_code <- normalize_text(metadata$CODE) == normalize_text(paramcd)

  scores <- map_dbl(
    metadata$SEARCH_TEXT,
    ~ token_score(search_term, .x)
  )

  # Bonus for exact code/name match. Kept separate in output as well.
  rank_score <- scores + ifelse(exact_code, 2, 0)

  tibble(
    STUDY = study_id,
    PARAMCD = paramcd,
    DESCRIPTION = description,
    SEARCH_TERM = search_term,
    EXACT_CODE_MATCH = exact_code,
    SCORE = scores,
    RANK_SCORE = rank_score,
    METADATA_TYPE = metadata$METADATA_TYPE,
    DATASET = metadata$DATASET,
    CODE_VAR = metadata$CODE_VAR,
    CODE = metadata$CODE,
    LABEL_VAR = metadata$LABEL_VAR,
    LABEL = metadata$LABEL
  ) %>%
    filter(EXACT_CODE_MATCH | SCORE > 0) %>%
    arrange(desc(RANK_SCORE), desc(SCORE), DATASET, CODE) %>%
    slice_head(n = 15)
})

candidates <- bind_rows(candidate_list)

write_csv(
  candidates,
  file.path(output_dir, "03_mapping_candidates_automatic.csv"),
  na = ""
)

# ============================================================
# 8. BEST-CANDIDATE OVERVIEW
# ============================================================
#
# This is only a triage table. BEST != clinically confirmed.
# ============================================================

best_candidate <- candidates %>%
  group_by(PARAMCD) %>%
  arrange(desc(RANK_SCORE), desc(SCORE), .by_group = TRUE) %>%
  slice_head(n = 1) %>%
  ungroup() %>%
  transmute(
    PARAMCD,
    AUTO_EXACT_CODE_MATCH = EXACT_CODE_MATCH,
    AUTO_SCORE = SCORE,
    AUTO_METADATA_TYPE = METADATA_TYPE,
    AUTO_DATASET = DATASET,
    AUTO_CODE_VAR = CODE_VAR,
    AUTO_CODE = CODE,
    AUTO_LABEL_VAR = LABEL_VAR,
    AUTO_LABEL = LABEL
  )

overview <- voi %>%
  left_join(best_candidate, by = "PARAMCD") %>%
  mutate(
    AUTO_TRIAGE = case_when(
      AUTO_EXACT_CODE_MATCH == TRUE ~ "EXACT_CODE_CANDIDATE",
      is.na(AUTO_SCORE) ~ "NO_AUTOMATIC_CANDIDATE",
      AUTO_SCORE >= 0.75 ~ "STRONG_TEXT_CANDIDATE",
      AUTO_SCORE >= 0.40 ~ "MODERATE_TEXT_CANDIDATE",
      TRUE ~ "WEAK_TEXT_CANDIDATE"
    ),
    REVIEW_STATUS = "REVIEW_REQUIRED",
    REVIEW_NOTE = ""
  )

write_csv(
  overview,
  file.path(output_dir, "04_mapping_overview_best_candidate.csv"),
  na = ""
)

# ============================================================
# 9. COVERAGE / TRIAGE SUMMARY
# ============================================================

coverage <- overview %>%
  count(AUTO_TRIAGE, name = "N_VARIABLES") %>%
  mutate(
    TOTAL_VARIABLES = nrow(voi),
    PERCENT = round(100 * N_VARIABLES / TOTAL_VARIABLES, 1)
  ) %>%
  arrange(desc(N_VARIABLES))

write_csv(
  coverage,
  file.path(output_dir, "05_mapping_triage_summary.csv"),
  na = ""
)

# ============================================================
# 10. CONSOLE SUMMARY
# ============================================================

cat("\n============================================================\n")
cat("CROHN'S DISEASE SDTM VARIABLE MAPPING SCANNER\n")
cat("============================================================\n")
cat("Study: ", study_id, "\n", sep = "")
cat("Variables of interest: ", nrow(voi), "\n", sep = "")
cat("SDTM datasets read: ", length(sdtm), "\n", sep = "")
cat("Searchable metadata rows: ", nrow(metadata), "\n", sep = "")
cat("Candidate rows generated: ", nrow(candidates), "\n\n", sep = "")

print(coverage)

cat("\nOutputs created in:\n", normalizePath(output_dir), "\n\n", sep = "")
cat("  01_sdtm_inventory.csv\n")
cat("  02_sdtm_searchable_metadata.csv\n")
cat("  03_mapping_candidates_automatic.csv\n")
cat("  04_mapping_overview_best_candidate.csv\n")
cat("  05_mapping_triage_summary.csv\n\n")

cat("IMPORTANT: Review 03 and 04 before using any candidate to build an ARD.\n")
