from __future__ import annotations

from pathlib import Path
from typing import Dict

import pandas as pd
import streamlit as st

from .config import DEFAULT_DATA_FILE, SHEETS


NA_TOKENS = {"", "...", "-", "--", "—", "none", "nan", "null"}


def _clean_scalar(value):
    if pd.isna(value):
        return pd.NA
    if isinstance(value, str):
        value = value.strip()
        if value.lower() in NA_TOKENS:
            return pd.NA
    return value


def clean_frame(df: pd.DataFrame) -> pd.DataFrame:
    """Normalize headers, empty placeholder values and fully-empty rows/columns."""
    df = df.copy()
    df.columns = [str(c).strip().replace("\n", " ") if not pd.isna(c) else "" for c in df.columns]
    df = df.loc[:, [c for c in df.columns if c and not c.startswith("Unnamed:")]]
    for col in df.columns:
        df[col] = df[col].map(_clean_scalar)
    df = df.dropna(how="all").reset_index(drop=True)
    return df


@st.cache_data(show_spinner=False)
def load_workbook(path: str | Path = DEFAULT_DATA_FILE, mtime_ns: int | None = None) -> Dict[str, pd.DataFrame]:
    """Load and clean all expected workbook tabs.

    Cached for performance while still refreshing periodically if the backing file changes.
    """
    path = Path(path)
    if not path.exists():
        raise FileNotFoundError(f"Workbook not found: {path}")

    # mtime_ns is intentionally part of the cache key. When the workbook changes,
    # Streamlit reloads it on the next rerun without waiting for a TTL.
    _ = mtime_ns
    book = pd.ExcelFile(path, engine="openpyxl")
    result: Dict[str, pd.DataFrame] = {}
    for key, sheet_name in SHEETS.items():
        if sheet_name in book.sheet_names:
            result[key] = clean_frame(pd.read_excel(book, sheet_name=sheet_name))
        else:
            result[key] = pd.DataFrame()
    # Backfill missing Study IDs from the master study table when Study Name is available.
    studies = result.get("studies", pd.DataFrame())
    if not studies.empty and {"Study ID", "Study Name"}.issubset(studies.columns):
        name_to_id = (
            studies.dropna(subset=["Study ID", "Study Name"])
            .drop_duplicates("Study Name")
            .set_index("Study Name")["Study ID"]
            .to_dict()
        )
        for key, frame in result.items():
            if key == "studies" or frame.empty or "Study Name" not in frame.columns:
                continue
            if "Study ID" not in frame.columns:
                frame["Study ID"] = frame["Study Name"].map(name_to_id)
            else:
                missing = frame["Study ID"].isna()
                frame.loc[missing, "Study ID"] = frame.loc[missing, "Study Name"].map(name_to_id)
            result[key] = frame

    return result


def normalize_availability(value) -> str:
    if pd.isna(value):
        return "Unknown"
    text = str(value).strip().lower()
    if text in {"yes", "y", "available", "approved", "true", "complete", "completed"}:
        return "Available"
    if text in {"no", "n", "missing", "not available", "false"}:
        return "Missing"
    if "pending" in text or "request" in text:
        return "Pending"
    if text in {"n/a", "na", "not applicable"}:
        return "N/A"
    return str(value).strip() if str(value).strip() else "Unknown"


def normalize_processing(value) -> str:
    if pd.isna(value):
        return "Unknown"
    text = str(value).strip().lower()
    mapping = {
        "complete": "Complete",
        "completed": "Complete",
        "in progress": "In Progress",
        "pending": "Pending",
        "not started": "Not Started",
        "failed": "Failed",
        "n/a": "N/A",
        "na": "N/A",
    }
    return mapping.get(text, str(value).strip())


def study_lookup(studies: pd.DataFrame) -> pd.DataFrame:
    cols = [c for c in ["Study ID", "Study Name", "Disease", "Phase", "Compound"] if c in studies.columns]
    return studies[cols].drop_duplicates("Study ID") if "Study ID" in studies.columns else studies[cols]


def attach_study_metadata(df: pd.DataFrame, studies: pd.DataFrame) -> pd.DataFrame:
    if df.empty or studies.empty or "Study ID" not in df.columns or "Study ID" not in studies.columns:
        return df.copy()
    lookup = study_lookup(studies)
    # Avoid duplicate Study Name after merge; keep the table-specific value first.
    extras = [c for c in lookup.columns if c not in df.columns or c == "Study ID"]
    return df.merge(lookup[extras], on="Study ID", how="left")


def filtered_study_ids(
    studies: pd.DataFrame,
    diseases: list[str],
    phases: list[str],
    compounds: list[str],
    study_names: list[str],
) -> set:
    if studies.empty or "Study ID" not in studies.columns:
        return set()
    frame = studies.copy()
    if diseases and "Disease" in frame.columns:
        frame = frame[frame["Disease"].isin(diseases)]
    if phases and "Phase" in frame.columns:
        frame = frame[frame["Phase"].isin(phases)]
    if compounds and "Compound" in frame.columns:
        frame = frame[frame["Compound"].isin(compounds)]
    if study_names and "Study Name" in frame.columns:
        frame = frame[frame["Study Name"].isin(study_names)]
    return set(frame["Study ID"].dropna().astype(str))


def filter_by_studies(df: pd.DataFrame, study_ids: set) -> pd.DataFrame:
    if df.empty or "Study ID" not in df.columns:
        return df.copy()
    if not study_ids:
        return df.iloc[0:0].copy()
    return df[df["Study ID"].astype(str).isin(study_ids)].copy()
