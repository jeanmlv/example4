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
# COLUMNS TO KEEP
# ============================================================

keys = [
    "USUBJID",
    "AVISIT",
    "AVISITN"
]

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
"_ABLFL",
"_APOBLFL",
"_FASFL",
"_SAFFL",
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

columns_to_keep = keys + variables_of_interest


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
# CHECK COLUMNS
# ============================================================

available_columns = [
    col for col in columns_to_keep
    if col in df.columns
]

missing_columns = [
    col for col in columns_to_keep
    if col not in df.columns
]


print("\nAvailable requested columns:")
for col in available_columns:
    print(f"  ✔ {col}")


if missing_columns:
    print("\nRequested columns NOT FOUND:")
    
    for col in missing_columns:
        print(f"  ✘ {col}")


# ============================================================
# CREATE SLIM ARD
# ============================================================

df_slim = df[available_columns].copy()


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
print(f"Columns: {len(df_slim.columns)}")

print(f"\nOutput file:\n{output_file}")

if missing_columns:
    print(
        f"\nWarning: {len(missing_columns)} "
        "requested variable(s) were not found."
    )
