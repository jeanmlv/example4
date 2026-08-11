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
    / "77242113UC02001_anthem_wk78_ard_merged_20260810_ARD.csv"
)

output_folder = input_folder / "slim"
output_folder.mkdir(exist_ok=True)

output_file = (
    output_folder
    / "77242113UC02001_anthem_wk78_ard_merged_20260810_ARD_SLIM.csv"
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
    "ADHIST_T",
    "ADHIST_TF",
    "TRT02PN",
    "CRESP",
    "CRESPP",
    "CORTBL",
    "ENFSCOR"
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
