from __future__ import annotations

import os
from pathlib import Path

import pandas as pd
import plotly.express as px
import streamlit as st

from src.config import APP_SUBTITLE, APP_TITLE, COLORS, DEFAULT_DATA_FILE
from src.data_loader import (
    attach_study_metadata,
    filter_by_studies,
    filtered_study_ids,
    load_workbook,
    normalize_availability,
    normalize_processing,
)
from src.ui import download_csv, donut_chart, inject_css, kpi_row, safe_sorted, section, show_table, status_distribution_chart, title_block


st.set_page_config(page_title=APP_TITLE, page_icon="📊", layout="wide", initial_sidebar_state="expanded")
inject_css()


def resolve_data_file() -> Path:
    env_path = os.getenv("IBD_INVENTORY_FILE")
    if env_path:
        return Path(env_path)
    return DEFAULT_DATA_FILE


def load_data_or_stop() -> dict[str, pd.DataFrame]:
    path = resolve_data_file()
    try:
        data = load_workbook(path, path.stat().st_mtime_ns)
    except Exception as exc:
        st.error(f"Unable to load the inventory workbook: {exc}")
        st.caption("Set IBD_INVENTORY_FILE to a valid .xlsx path or place the workbook in the project's data folder.")
        st.stop()
    return data


def global_filters(studies: pd.DataFrame) -> set:
    st.sidebar.markdown("### Filters")
    diseases = st.sidebar.multiselect("Disease", safe_sorted(studies.get("Disease", [])))
    phases = st.sidebar.multiselect("Phase", safe_sorted(studies.get("Phase", [])))
    compounds = st.sidebar.multiselect("Compound", safe_sorted(studies.get("Compound", [])))
    study_names = st.sidebar.multiselect("Study", safe_sorted(studies.get("Study Name", [])))
    ids = filtered_study_ids(studies, diseases, phases, compounds, study_names)
    st.sidebar.caption(f"{len(ids):,} studies in current selection")
    return ids


def page_overview(data: dict[str, pd.DataFrame], study_ids: set):
    studies = filter_by_studies(data["studies"], study_ids)
    availability = filter_by_studies(data["availability"], study_ids)
    processing = filter_by_studies(data["processing"], study_ids)
    analysis = filter_by_studies(data["analysis"], study_ids)

    avail = availability.copy()
    for col in ["Videos", "SDTM/ADaM (Med.ai)", "SDTM/ADaM (Domino)", "Analysis-Ready-Dataset (ARD)"]:
        if col in avail.columns:
            avail[col] = avail[col].map(normalize_availability)

    proc = processing.copy()
    for col in ["Preprocessing", "Feature Extraction", "CMES Inference", "Modeling"]:
        if col in proc.columns:
            proc[col] = proc[col].map(normalize_processing)

    def available_count(col: str) -> int:
        return int((avail[col] == "Available").sum()) if col in avail.columns else 0

    ready_modeling = int((proc.get("Modeling", pd.Series(dtype=str)) == "Complete").sum())
    complete_analyses = int((analysis.get("Status", pd.Series(dtype=str)).astype(str).str.lower() == "complete").sum()) if not analysis.empty else 0

    kpi_row([
        ("Studies", len(studies), "Studies matching the active filters"),
        ("Video available", available_count("Videos"), "Studies with video data marked available"),
        ("ARD available", available_count("Analysis-Ready-Dataset (ARD)"), "Studies with an ARD available"),
        ("Modeling complete", ready_modeling, "Studies with modeling marked complete"),
        ("Analyses complete", complete_analyses, "Completed registered analyses"),
    ])

    c1, c2 = st.columns([1.25, 1])
    with c1:
        section("Availability matrix", "A compact view of what is available, pending, missing or unknown by study.")
        matrix_cols = [c for c in ["Study Name", "Videos", "SDTM/ADaM (Med.ai)", "SDTM/ADaM (Domino)", "Analysis-Ready-Dataset (ARD)", "Symptom Data", "QS", "ADQS", "Feature Vectors"] if c in avail.columns]
        show_table(avail[matrix_cols], height=390)
    with c2:
        section("Studies by disease")
        if not studies.empty and "Disease" in studies.columns:
            disease = studies["Disease"].fillna("Unknown").value_counts().rename_axis("Disease").reset_index(name="Studies")
            donut_chart(disease, "Disease", "Studies", "Portfolio mix")

    section("Portfolio status")
    c1, c2 = st.columns(2)
    with c1:
        if "Analysis-Ready-Dataset (ARD)" in avail.columns:
            status_distribution_chart(avail, "Analysis-Ready-Dataset (ARD)", "ARD availability")
    with c2:
        if "Modeling" in proc.columns:
            status_distribution_chart(proc, "Modeling", "Modeling status")


def page_availability(data: dict[str, pd.DataFrame], study_ids: set):
    df = filter_by_studies(data["availability"], study_ids)
    for col in [c for c in df.columns if c not in {"Study ID", "Study Name", "Annotations Location", "Annotations Notes", "Clinical GT Location", "Clinical GT Notes"}]:
        df[col] = df[col].map(normalize_availability)

    section("Data availability", "Explore high-level availability across videos, SDTM/ADaM, ARDs, symptoms, annotations and feature vectors.")
    status_filter = st.multiselect("Availability status", ["Available", "Pending", "Missing", "Unknown", "N/A"], default=[])
    if status_filter:
        status_cols = [c for c in df.columns if c not in {"Study ID", "Study Name", "Annotations Notes", "Clinical GT Notes"}]
        mask = df[status_cols].isin(status_filter).any(axis=1)
        df = df[mask]
    show_table(df, link_columns=["Annotations Location", "Clinical GT Location"])
    download_csv(df, "data_availability_filtered.csv")


def page_assets(data: dict[str, pd.DataFrame], study_ids: set):
    df = filter_by_studies(data["assets"], study_ids)
    section("Assets", "Individual Med.ai/data assets and their technical locations.")
    c1, c2, c3 = st.columns(3)
    with c1:
        asset_types = st.multiselect("Asset type", safe_sorted(df.get("Asset Type", [])))
    with c2:
        sources = st.multiselect("Source", safe_sorted(df.get("Source", [])))
    with c3:
        statuses = st.multiselect("Status", safe_sorted(df.get("Status", [])))
    if asset_types and "Asset Type" in df: df = df[df["Asset Type"].isin(asset_types)]
    if sources and "Source" in df: df = df[df["Source"].isin(sources)]
    if statuses and "Status" in df: df = df[df["Status"].isin(statuses)]
    show_table(df, link_columns=["S3 Location"])
    download_csv(df, "assets_filtered.csv")


def page_processing(data: dict[str, pd.DataFrame], study_ids: set):
    df = filter_by_studies(data["processing"], study_ids)
    for col in ["Preprocessing", "Feature Extraction", "CMES Inference", "Modeling"]:
        if col in df.columns:
            df[col] = df[col].map(normalize_processing)

    section("Processing pipeline", "Trace each study from raw data through preprocessing, feature extraction, CMES inference and modeling.")
    stage = st.selectbox("Pipeline stage", ["Preprocessing", "Feature Extraction", "CMES Inference", "Modeling"])
    if stage in df.columns:
        status_distribution_chart(df, stage, f"{stage} status")
    show_table(df, link_columns=["Raw Data Location", "Results Location"])
    download_csv(df, "processing_filtered.csv")


def page_splits(data: dict[str, pd.DataFrame], study_ids: set):
    df = filter_by_studies(data["splits"], study_ids)
    section("Training / validation / test splits", "Where available, this tab documents split proportions, counts, files, locations and versions.")
    split_types = st.multiselect("Split type", safe_sorted(df.get("Split Type", [])))
    if split_types and "Split Type" in df.columns:
        df = df[df["Split Type"].isin(split_types)]

    if not df.empty and "Split %" in df.columns and "Study Name" in df.columns and "Split Type" in df.columns:
        chart_df = df.dropna(subset=["Split %"]).copy()
        if not chart_df.empty:
            fig = px.bar(chart_df, x="Study Name", y="Split %", color="Split Type", barmode="stack", title="Split composition by study")
            fig.update_yaxes(tickformat=".0%")
            fig.update_layout(height=360, margin=dict(l=10, r=10, t=50, b=10), legend_title_text="")
            st.plotly_chart(fig, use_container_width=True)
    show_table(df, link_columns=["Location"])
    download_csv(df, "data_splits_filtered.csv")


def page_ard(data: dict[str, pd.DataFrame], study_ids: set):
    ard = filter_by_studies(data["ard"], study_ids)
    variables = filter_by_studies(data["ard_variables"], study_ids)
    section("ARD coverage", "ARD-level inventory and variable gap mapping coverage.")
    if not ard.empty and "Coverage %" in ard.columns:
        plot_df = ard.dropna(subset=["Coverage %"]).copy()
        if not plot_df.empty:
            fig = px.bar(plot_df, x="Study Name", y="Coverage %", color="Coverage Level", text_auto=".0%", title="Variable mapping coverage")
            fig.update_yaxes(tickformat=".0%", range=[0, 1])
            fig.update_layout(height=360, margin=dict(l=10, r=10, t=50, b=10), legend_title_text="Coverage")
            st.plotly_chart(fig, use_container_width=True)
    show_table(ard, link_columns=["Location"])

    section("Variable-level mapping")
    statuses = st.multiselect("Variable mapping status", safe_sorted(variables.get("Status", [])))
    if statuses and "Status" in variables.columns:
        variables = variables[variables["Status"].isin(statuses)]
    show_table(variables, height=520)
    download_csv(variables, "ard_variables_filtered.csv")


def page_analysis(data: dict[str, pd.DataFrame], study_ids: set):
    df = filter_by_studies(data["analysis"], study_ids)
    section("Analysis & traceability", "Trace each analysis from the input dataset through SAP and code to the resulting output.")
    c1, c2 = st.columns(2)
    with c1:
        owners = st.multiselect("Analysis owner", safe_sorted(df.get("Analysis Owner", [])))
    with c2:
        statuses = st.multiselect("Analysis status", safe_sorted(df.get("Status", [])))
    if owners and "Analysis Owner" in df: df = df[df["Analysis Owner"].isin(owners)]
    if statuses and "Status" in df: df = df[df["Status"].isin(statuses)]

    kpi_row([
        ("Registered analyses", len(df), None),
        ("Complete", int((df.get("Status", pd.Series(dtype=str)).astype(str).str.lower() == "complete").sum()), None),
        ("Studies represented", int(df.get("Study ID", pd.Series(dtype=str)).nunique()), None),
    ])
    show_table(df, link_columns=["Dataset Location", "SAP Location", "Code Repository", "Results Location"])
    download_csv(df, "data_analysis_filtered.csv")


def study_detail_panel(data: dict[str, pd.DataFrame], study_ids: set):
    studies = filter_by_studies(data["studies"], study_ids)
    if studies.empty:
        return
    section("Study detail")
    selected = st.selectbox("Select a study for a consolidated view", safe_sorted(studies["Study Name"]))
    row = studies[studies["Study Name"] == selected].iloc[0]
    sid = str(row["Study ID"])
    c1, c2, c3, c4 = st.columns(4)
    c1.metric("Study ID", sid)
    c2.metric("Disease", row.get("Disease", "—"))
    c3.metric("Patients", row.get("Patients", "—"))
    c4.metric("Videos", row.get("Videos", "—"))
    tabs = st.tabs(["Availability", "Assets", "Processing", "Splits", "ARD", "Analysis"])
    keys = ["availability", "assets", "processing", "splits", "ard", "analysis"]
    for tab, key in zip(tabs, keys):
        with tab:
            frame = data[key]
            if "Study ID" in frame.columns:
                frame = frame[frame["Study ID"].astype(str) == sid]
            show_table(frame, height=280)


def main():
    data = load_data_or_stop()
    studies = data["studies"]
    title_block(APP_TITLE, APP_SUBTITLE)

    study_ids = global_filters(studies)
    if st.sidebar.button("Refresh data", use_container_width=True):
        st.cache_data.clear()
        st.rerun()

    st.sidebar.markdown("---")
    page = st.sidebar.radio(
        "Navigation",
        ["Overview", "Data Availability", "Assets", "Processing", "Data Splits", "ARD & Variables", "Analysis & Traceability"],
    )
    st.sidebar.markdown("---")
    st.sidebar.caption("The workbook loads automatically at startup. File changes invalidate the cache on the next rerun; use Refresh data for an immediate manual reload.")

    if page == "Overview":
        page_overview(data, study_ids)
        study_detail_panel(data, study_ids)
    elif page == "Data Availability":
        page_availability(data, study_ids)
    elif page == "Assets":
        page_assets(data, study_ids)
    elif page == "Processing":
        page_processing(data, study_ids)
    elif page == "Data Splits":
        page_splits(data, study_ids)
    elif page == "ARD & Variables":
        page_ard(data, study_ids)
    elif page == "Analysis & Traceability":
        page_analysis(data, study_ids)


if __name__ == "__main__":
    main()
