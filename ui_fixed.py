from __future__ import annotations

import html
from typing import Iterable

import pandas as pd
import plotly.express as px
import streamlit as st

from .config import COLORS


STATUS_COLORS = {
    "Available": COLORS["green"],
    "Complete": COLORS["green"],
    "Completed": COLORS["green"],
    "Approved": COLORS["green"],
    "Pending": COLORS["amber"],
    "In Progress": COLORS["amber"],
    "Missing": COLORS["red"],
    "Failed": COLORS["red"],
    "Not Started": COLORS["gray_500"],
    "Unknown": COLORS["gray_300"],
    "N/A": COLORS["gray_300"],
}


def inject_css() -> None:
    """Inject the global VSquad dashboard styling."""
    st.markdown(
        f"""
        <style>
            .block-container,
            [data-testid="stMainBlockContainer"] {{
                max-width: 1500px;
                padding-top: 4.25rem !important;
                padding-bottom: 2rem !important;
            }}

            [data-testid="stSidebar"] {{
                background: {COLORS['gray_100']};
                border-right: 1px solid {COLORS['gray_300']};
            }}

            .app-title {{
                display: block;
                font-size: clamp(1.85rem, 3vw, 2.55rem);
                font-weight: 750;
                line-height: 1.25 !important;
                color: {COLORS['navy']};
                margin: 0 0 .20rem 0 !important;
                padding: .10rem 0 .05rem 0 !important;
                overflow: visible !important;
            }}

            .app-subtitle {{
                display: block;
                font-size: 1rem;
                line-height: 1.45;
                color: {COLORS['gray_700']};
                margin-top: .15rem;
                margin-bottom: 1rem;
            }}

            .section-title {{
                font-size: 1.18rem;
                font-weight: 700;
                line-height: 1.35;
                color: {COLORS['navy']};
                margin-top: 1.25rem;
                margin-bottom: .35rem;
            }}

            .section-note {{
                color: {COLORS['gray_700']};
                font-size: .92rem;
                margin-bottom: .75rem;
            }}

            div[data-testid="stMetric"] {{
                background: {COLORS['white']};
                border: 1px solid {COLORS['gray_300']};
                padding: .8rem 1rem;
                border-radius: 12px;
            }}

            div[data-testid="stMetricLabel"] {{
                color: {COLORS['gray_700']};
            }}

            div[data-testid="stMetricValue"] {{
                color: {COLORS['navy']};
                font-weight: 750;
            }}

            .status-pill {{
                display: inline-block;
                border-radius: 999px;
                padding: .12rem .52rem;
                font-size: .8rem;
                font-weight: 650;
            }}

            .small-muted {{
                color: {COLORS['gray_500']};
                font-size: .85rem;
            }}

            @media (max-width: 700px) {{
                .block-container,
                [data-testid="stMainBlockContainer"] {{
                    padding-top: 4rem !important;
                    padding-left: .8rem !important;
                    padding-right: .8rem !important;
                }}

                .app-title {{
                    font-size: 1.8rem;
                }}
            }}
        </style>
        """,
        unsafe_allow_html=True,
    )


def title_block(title: str, subtitle: str) -> None:
    st.markdown(
        f'<div class="app-title">{html.escape(title)}</div>',
        unsafe_allow_html=True,
    )
    st.markdown(
        f'<div class="app-subtitle">{html.escape(subtitle)}</div>',
        unsafe_allow_html=True,
    )


def section(title: str, note: str | None = None) -> None:
    st.markdown(
        f'<div class="section-title">{html.escape(title)}</div>',
        unsafe_allow_html=True,
    )
    if note:
        st.markdown(
            f'<div class="section-note">{html.escape(note)}</div>',
            unsafe_allow_html=True,
        )


def safe_sorted(values: Iterable) -> list:
    return sorted({str(v) for v in values if pd.notna(v) and str(v).strip()})


def kpi_row(metrics: list[tuple[str, str | int | float, str | None]]) -> None:
    cols = st.columns(len(metrics))
    for col, (label, value, help_text) in zip(cols, metrics):
        with col:
            if value is None:
                value = "—"
            else:
                try:
                    if pd.isna(value):
                        value = "—"
                except (TypeError, ValueError):
                    pass
            st.metric(label, value, help=help_text)


def status_distribution_chart(df: pd.DataFrame, status_col: str, title: str):
    if df.empty or status_col not in df.columns:
        st.info("No data available for this view.")
        return

    counts = (
        df[status_col]
        .fillna("Unknown")
        .astype(str)
        .value_counts()
        .rename_axis(status_col)
        .reset_index(name="Count")
    )

    fig = px.bar(
        counts,
        x=status_col,
        y="Count",
        color=status_col,
        color_discrete_map=STATUS_COLORS,
        title=title,
        text_auto=True,
    )
    fig.update_layout(
        showlegend=False,
        margin=dict(l=10, r=10, t=50, b=10),
        height=330,
    )
    st.plotly_chart(fig, width="stretch")


def donut_chart(data: pd.DataFrame, names: str, values: str, title: str):
    if data.empty:
        st.info("No data available for this view.")
        return

    fig = px.pie(
        data,
        names=names,
        values=values,
        hole=.55,
        title=title,
        color_discrete_sequence=[
            COLORS["blue"],
            COLORS["teal"],
            COLORS["green"],
            COLORS["amber"],
            COLORS["gray_500"],
        ],
    )
    fig.update_layout(
        margin=dict(l=10, r=10, t=50, b=10),
        height=330,
        legend_title_text="",
    )
    st.plotly_chart(fig, width="stretch")


def download_csv(df: pd.DataFrame, filename: str, label: str = "Download filtered data") -> None:
    st.download_button(
        label,
        df.to_csv(index=False).encode("utf-8"),
        file_name=filename,
        mime="text/csv",
        width="content",
    )


def show_table(df: pd.DataFrame, *, height: int = 420, link_columns: list[str] | None = None) -> None:
    if df.empty:
        st.info("No records match the selected filters.")
        return

    column_config = {}
    for col in link_columns or []:
        if col in df.columns:
            column_config[col] = st.column_config.LinkColumn(col, display_text="Open")

    st.dataframe(
        df,
        width="stretch",
        hide_index=True,
        height=height,
        column_config=column_config,
    )
