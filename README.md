# example4

from pathlib import Path
import pandas as pd


# ============================================================
# CONFIGURATION
# ============================================================

input_folder = Path(
    r"C:\Users\JMende95\OneDrive - JNJ\Desktop\ard_data\csv"
)

input_file = (
    input_folder
    / "CNTO1275CRD3008_power_wk36_ard_20260621.csv"
)

output_folder = input_folder / "slim"
output_folder.mkdir(exist_ok=True)

output_file = (
    output_folder
    / "CNTO1275CRD3008_power_wk36_ard_slim_20260913.csv"
)


# ============================================================
# KEYS
# ============================================================

keys = [
    "USUBJID",
    "AVISIT",
    "AVISITN"
]


# ============================================================
# EXACT VARIABLES TO KEEP
# ============================================================

variables_of_interest = [
    "ADLBLOCF_PARAMCD_CALPRO_AVAL",
    "ADLBLOCF_PARAMCD_CRP_AVAL",
    "ADEF1_PARAMCD_REMIS_AVALC",
    "ADEF1_PARAMCD_RESP_AVALC",
    "ADSESCD_PARAMCD_MOREMISS_AVALC",
    "ADSESCD_PARAMCD_MOSESCDT_AVAL",
    "ADBDC_PARAMCD_ULOCBLGR_AVALC",
    "ADBDC_PARAMCD_PCFIST_AVALC",
    "ADCDAI_PARAMCD_CDA202B_AVAL",
    "ADCDAI_PARAMCD_CDA201B_AVAL",
    "ADCDAI_PARAMCD_CDA203B_AVAL",
    "ADCDAI_PARAMCD_CDA205B_AVAL",
    "ADCDAI_PARAMCD_CDA206B_AVAL",
    "ADCDAI_PARAMCD_CDA207B_AVAL",
    "ADCDAI_PARAMCD_CDA208B_AVAL",
    "ADBDC_PARAMCD_PCBOWEL_AVALC",
    "ADIBDQ_PARAMCD_IBDQTOT_AVAL",
    "ADIBDQ_PARAMCD_IBDQREM_AVALC",
    "ADSESCD_PARAMCD_MORESPON_AVALC",
    "ADSL_TRT01P",
    "ADSL_TRT01PN",
    "ADSL_TRT01A",
    "ADSL_TRT01AN",
    "ADSL_AGE",
    "ADSL_SEX",
    "ADSL_RACE",
    "ADSL_COUNTRY",
    "ADSL_ETHNIC",
    "ADCDAI_PARAMCD_CDAIM_AVAL",
    "ADCDAI_PARAMCD_WAPSTLTF_AVAL",
    "ADSESCD_PARAMCD_MO25IMPR_AVALC",
    "ADBDC_PARAMCD_SESCDBL_AVAL",
    "ADSESCD_PARAMCD_MOSECDIL_AVAL",
    "ADSESCD_PARAMCD_MOSECDLC_AVAL",
    "ADSESCD_PARAMCD_MOSECDRC_AVAL",
    "ADSESCD_PARAMCD_MOSECDRE_AVAL",
    "ADSESCD_PARAMCD_MOSECDTC_AVAL",
    "ADSESCD_PARAMCD_MOPRSIZT_AVAL"
]


# ============================================================
# COLUMN SUFFIXES TO KEEP
# ============================================================

suffixes_of_interest = [
    "_ABLFL",
    "_APOBLFL",
    "_FASFL",
    "_SAFFL"
]


# ============================================================
# VALIDATE INPUT FILE
# ============================================================

if not input_file.exists():
    raise FileNotFoundError(
        f"CSV file not found:\n{input_file}"
    )

print(f"Processing: {input_file.name}")


# ============================================================
# READ CSV
# ============================================================

df = pd.read_csv(
    input_file,
    low_memory=False
)

print(f"Original rows: {len(df):,}")
print(f"Original columns: {len(df.columns):,}")


# ============================================================
# FIND EXACT COLUMNS
# ============================================================

requested_exact_columns = keys + variables_of_interest

available_exact_columns = [
    col for col in requested_exact_columns
    if col in df.columns
]

missing_exact_columns = [
    col for col in requested_exact_columns
    if col not in df.columns
]


# ============================================================
# FIND COLUMNS BY SUFFIX
# ============================================================

suffix_columns = [
    col for col in df.columns
    if col.endswith(tuple(suffixes_of_interest))
]


# ============================================================
# COMBINE COLUMNS
# ============================================================

columns_to_keep = (
    available_exact_columns
    + suffix_columns
)

# Remove duplicates while preserving order
columns_to_keep = list(dict.fromkeys(columns_to_keep))


# ============================================================
# REPORT COLUMNS FOUND
# ============================================================

print("\n========================================")
print("EXACT VARIABLES FOUND")
print("========================================")

for col in available_exact_columns:
    print(f"  ✔ {col}")


if missing_exact_columns:
    print("\n========================================")
    print("EXACT VARIABLES NOT FOUND")
    print("========================================")

    for col in missing_exact_columns:
        print(f"  ✘ {col}")


print("\n========================================")
print("VARIABLES FOUND BY SUFFIX")
print("========================================")

if suffix_columns:
    for col in suffix_columns:
        print(f"  ✔ {col}")
else:
    print("  No columns found for the requested suffixes.")


# ============================================================
# SUFFIX SUMMARY
# ============================================================

print("\n========================================")
print("SUFFIX SUMMARY")
print("========================================")

for suffix in suffixes_of_interest:

    matched = [
        col for col in df.columns
        if col.endswith(suffix)
    ]

    print(
        f"{suffix}: {len(matched)} column(s) found"
    )


# ============================================================
# CREATE SLIM ARD
# ============================================================

df_slim = df[columns_to_keep].copy()


# ============================================================
# EXPORT
# ============================================================

df_slim.to_csv(
    output_file,
    index=False,
    encoding="utf-8-sig"
)


# ============================================================
# SUMMARY
# ============================================================

print("\n========================================")
print("SLIM ARD CREATED SUCCESSFULLY")
print("========================================")

print(f"Rows: {len(df_slim):,}")
print(f"Columns: {len(df_slim.columns):,}")

print(f"\nOutput file:\n{output_file}")

if missing_exact_columns:
    print(
        f"\nWarning: {len(missing_exact_columns)} "
        "exact requested variable(s) were not found."
    )

print(
    f"Columns added by suffix search: "
    f"{len(suffix_columns)}"
)
