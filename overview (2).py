from __future__ import annotations

import pandas as pd
import plotly.express as px
import streamlit as st

from src.ard_loader import (
    discover_ard_files,
    extract_study_id_from_filename,
    get_available_variables,
    load_ard_csv,
    load_uploaded_ard,
    numeric_values,
    ordered_visits,
    prepare_variable_data,
    variable_option_label,
)


def _status_yes(series: pd.Series) -> int:
    values = series.astype(str).str.strip().str.lower()
    return int(values.isin({"yes", "y", "true", "1", "available"}).sum())


def _portfolio_charts(studies: pd.DataFrame) -> None:
    left, right = st.columns(2)

    with left:
        st.subheader("Portfolio by disease")
        if "Disease" in studies.columns and not studies.empty:
            disease = (
                studies["Disease"]
                .fillna("Unknown")
                .astype(str)
                .value_counts()
                .rename_axis("Disease")
                .reset_index(name="Studies")
            )
            fig = px.bar(
                disease,
                x="Studies",
                y="Disease",
                orientation="h",
                text="Studies",
            )
            fig.update_traces(textposition="inside")
            fig.update_layout(
                height=330,
                margin=dict(l=10, r=10, t=10, b=10),
                showlegend=False,
                yaxis_title=None,
            )
            st.plotly_chart(fig, width="stretch")
        else:
            st.info("Disease information is not available.")

    with right:
        st.subheader("Trial status")
        if "Trial Status" in studies.columns and not studies.empty:
            status = (
                studies["Trial Status"]
                .fillna("Unknown")
                .astype(str)
                .value_counts()
                .rename_axis("Trial Status")
                .reset_index(name="Studies")
            )
            fig = px.pie(
                status,
                names="Trial Status",
                values="Studies",
                hole=0.52,
            )
            fig.update_traces(textposition="inside", textinfo="percent")
            fig.update_layout(
                height=330,
                margin=dict(l=10, r=10, t=10, b=10),
                legend_title_text="",
            )
            st.plotly_chart(fig, width="stretch")
        else:
            st.info("Trial status information is not available.")


def _render_numeric_explorer(variable_df: pd.DataFrame, variable: str) -> None:
    values = numeric_values(variable_df["VALUE"])

    if values.empty:
        st.warning("The selected AVAL column does not contain usable numeric values.")
        return

    subjects = (
        variable_df.loc[variable_df["VALUE"].notna(), "USUBJID"].nunique()
        if "USUBJID" in variable_df.columns
        else 0
    )
    visits = (
        variable_df.loc[variable_df["VALUE"].notna(), "AVISIT"].nunique()
        if "AVISIT" in variable_df.columns
        else 0
    )

    k1, k2, k3, k4 = st.columns(4)
    k1.metric("Observations", f"{len(values):,}")
    k2.metric("Subjects", f"{subjects:,}")
    k3.metric("Visits", f"{visits:,}")
    k4.metric("Median", f"{values.median():,.2f}")

    overall, by_visit = st.columns(2)

    with overall:
        st.subheader("Overall distribution")
        plot_df = pd.DataFrame({"Value": values})
        fig = px.histogram(plot_df, x="Value", nbins=30)
        fig.update_layout(
            height=380,
            margin=dict(l=10, r=10, t=20, b=10),
            showlegend=False,
            xaxis_title=variable,
            yaxis_title="Observations",
        )
        st.plotly_chart(fig, width="stretch")

    with by_visit:
        st.subheader("Distribution by visit")
        plot_df = variable_df.copy()
        plot_df["Value"] = pd.to_numeric(plot_df["VALUE"], errors="coerce")
        plot_df = plot_df.loc[plot_df["Value"].notna() & plot_df["AVISIT"].notna()].copy()

        if plot_df.empty:
            st.info("Visit-level information is not available for this variable.")
        else:
            plot_df["AVISIT"] = plot_df["AVISIT"].astype(str)
            visit_order = ordered_visits(plot_df)
            fig = px.box(
                plot_df,
                x="AVISIT",
                y="Value",
                category_orders={"AVISIT": visit_order},
                points=False,
            )
            fig.update_layout(
                height=380,
                margin=dict(l=10, r=10, t=20, b=10),
                xaxis_title="Visit",
                yaxis_title=variable,
            )
            st.plotly_chart(fig, width="stretch")


def _render_categorical_explorer(variable_df: pd.DataFrame, variable: str) -> None:
    work = variable_df.loc[variable_df["VALUE"].notna()].copy()
    if work.empty:
        st.warning("The selected AVALC column does not contain non-missing values.")
        return

    work["Value"] = work["VALUE"].astype(str)
    subjects = work["USUBJID"].nunique() if "USUBJID" in work.columns else 0
    visits = work["AVISIT"].nunique() if "AVISIT" in work.columns else 0
    categories = work["Value"].nunique()

    k1, k2, k3, k4 = st.columns(4)
    k1.metric("Observations", f"{len(work):,}")
    k2.metric("Subjects", f"{subjects:,}")
    k3.metric("Visits", f"{visits:,}")
    k4.metric("Categories", f"{categories:,}")

    overall, by_visit = st.columns(2)

    with overall:
        st.subheader("Overall distribution")
        counts = (
            work["Value"]
            .value_counts()
            .rename_axis("Value")
            .reset_index(name="Observations")
        )
        fig = px.bar(counts, x="Observations", y="Value", orientation="h", text="Observations")
        fig.update_layout(
            height=max(380, min(650, 34 * len(counts) + 100)),
            margin=dict(l=10, r=10, t=20, b=10),
            showlegend=False,
            yaxis_title=None,
        )
        st.plotly_chart(fig, width="stretch")

    with by_visit:
        st.subheader("Distribution by visit")
        visit_work = work.loc[work["AVISIT"].notna()].copy()
        if visit_work.empty:
            st.info("Visit-level information is not available for this variable.")
        else:
            visit_work["AVISIT"] = visit_work["AVISIT"].astype(str)
            visit_order = ordered_visits(visit_work)
            counts = (
                visit_work.groupby(["AVISIT", "Value"], dropna=False)
                .size()
                .reset_index(name="Observations")
            )
            fig = px.bar(
                counts,
                x="AVISIT",
                y="Observations",
                color="Value",
                barmode="stack",
                category_orders={"AVISIT": visit_order},
            )
            fig.update_layout(
                height=380,
                margin=dict(l=10, r=10, t=20, b=10),
                xaxis_title="Visit",
                legend_title_text=variable,
            )
            st.plotly_chart(fig, width="stretch")


def _render_variable_explorer(studies: pd.DataFrame) -> None:
    st.divider()
    st.header("Variable Explorer")
    st.caption(
        "Upload an ARD CSV or use an ARD available in the project to explore "
        "PARAMCD variables overall and across visits."
    )

    uploaded = st.file_uploader(
        "Upload ARD (.csv)",
        type=["csv"],
        key="overview_ard_upload",
        help="The file is read for the current Streamlit session and is not written to the project by this dashboard.",
    )

    ard_df = None
    ard_name = None
    detected_study = None

    if uploaded is not None:
        try:
            ard_df = load_uploaded_ard(uploaded.getvalue())
            ard_name = uploaded.name
            known_ids = studies["Study ID"].dropna().astype(str).tolist() if "Study ID" in studies.columns else []
            detected_study = extract_study_id_from_filename(ard_name, known_ids)
        except Exception as exc:
            st.error(f"Unable to load the uploaded ARD: {exc}")
            return
    else:
        local_files = discover_ard_files()
        if local_files:
            selected_path = st.selectbox(
                "ARD available in project",
                options=local_files,
                format_func=lambda p: p.name,
                key="overview_local_ard",
            )
            try:
                ard_df = load_ard_csv(str(selected_path))
                ard_name = selected_path.name
                known_ids = studies["Study ID"].dropna().astype(str).tolist() if "Study ID" in studies.columns else []
                detected_study = extract_study_id_from_filename(ard_name, known_ids)
            except Exception as exc:
                st.error(f"Unable to load the ARD: {exc}")
                return

    if ard_df is None:
        st.info("Upload an ARD CSV above to start exploring variables.")
        return

    variables = get_available_variables(ard_df)

    if variables.empty:
        st.warning(
            "ARD loaded, but no columns matching PARAMCD_<variable>_AVAL or "
            "PARAMCD_<variable>_AVALC were detected."
        )
        return

    unique_params = variables["Variable"].nunique()

    label = f"ARD loaded: {ard_name} · {len(ard_df):,} rows × {len(ard_df.columns):,} columns · {unique_params:,} PARAMCD variables"
    if detected_study:
        label += f" · Study ID: {detected_study}"
    st.success(label)

    search = st.text_input(
        "Search variable",
        placeholder="e.g. MAYO, UCEIS, SESTOT",
        key="overview_variable_search",
    ).strip()

    available = variables.copy()
    if search:
        mask = (
            available["Variable"].str.contains(search, case=False, na=False, regex=False)
            | available["Source"].str.contains(search, case=False, na=False, regex=False)
        )
        available = available.loc[mask].copy()

    if available.empty:
        st.warning("No PARAMCD variable matches the current search.")
        return

    duplicate_names = set(
        available.loc[available["Variable"].duplicated(keep=False), "Variable"].tolist()
    )

    options = available.index.tolist()
    selected_index = st.selectbox(
        "Variable",
        options=options,
        format_func=lambda idx: variable_option_label(available.loc[idx], duplicate_names),
        key="overview_variable",
    )

    selected = available.loc[selected_index]
    variable = str(selected["Variable"])
    value_type = str(selected["Value Type"])
    source = str(selected["Source"])
    column = str(selected["Column"])

    st.caption(f"Source: {source}  •  Value type: {value_type}  •  Column: {column}")

    variable_df = prepare_variable_data(ard_df, column)

    if value_type == "AVAL":
        _render_numeric_explorer(variable_df, variable)
    else:
        _render_categorical_explorer(variable_df, variable)

    export_df = variable_df.loc[variable_df["VALUE"].notna()].copy()
    export_df.insert(0, "PARAMCD", variable)
    export_df.insert(1, "VALUE_TYPE", value_type)
    export_df.insert(2, "SOURCE_COLUMN", column)

    st.download_button(
        "Download selected variable CSV",
        data=export_df.to_csv(index=False).encode("utf-8"),
        file_name=f"{variable}_{value_type}_variable_export.csv",
        mime="text/csv",
        key="overview_variable_download",
    )


def render(filtered: dict[str, pd.DataFrame], data: dict[str, pd.DataFrame]) -> None:
    studies = filtered.get("01_STUDIES", pd.DataFrame()).copy()
    availability = filtered.get("02_DATA_AVAILABILITY", pd.DataFrame()).copy()

    patients = (
        pd.to_numeric(studies["Patients"], errors="coerce").fillna(0).sum()
        if "Patients" in studies.columns
        else 0
    )
    videos = (
        pd.to_numeric(studies["Videos"], errors="coerce").fillna(0).sum()
        if "Videos" in studies.columns
        else 0
    )

    ard_available = 0
    if "Analysis-Ready-Dataset (ARD)" in availability.columns:
        ard_available = _status_yes(availability["Analysis-Ready-Dataset (ARD)"])

    coverage_col = None
    for candidate in ("ARD Coverage", "ARD coverage", "Coverage"):
        if candidate in availability.columns:
            coverage_col = candidate
            break

    mean_coverage = None
    if coverage_col:
        coverage = (
            availability[coverage_col]
            .astype(str)
            .str.replace("%", "", regex=False)
        )
        coverage = pd.to_numeric(coverage, errors="coerce")
        if coverage.notna().any():
            mean_coverage = coverage.mean()

    k1, k2, k3, k4, k5 = st.columns(5)
    k1.metric("Studies", f"{len(studies):,}")
    k2.metric("Patients", f"{int(patients):,}")
    k3.metric("Videos", f"{int(videos):,}")
    k4.metric("ARD available", f"{ard_available:,}")
    k5.metric("Mean ARD coverage", f"{mean_coverage:.0f}%" if mean_coverage is not None else "—")

    _portfolio_charts(studies)
    _render_variable_explorer(studies)
