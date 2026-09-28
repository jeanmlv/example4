# example4

import pandas as pd
import streamlit as st

from .config import JNJ_RED, MUTED


def clean_text_values(series: pd.Series) -> list[str]:
    return sorted(
        series.dropna()
        .astype(str)
        .str.strip()
        .loc[lambda s: s.ne("")]
        .unique()
        .tolist()
    )


def render_sidebar_filters(
    studies: pd.DataFrame,
) -> tuple[pd.DataFrame, set[str]]:

    with st.sidebar:

        # ==========================================================
        # ARGES Commons branding
        # ==========================================================
        st.markdown(
            f"""
            <div style="padding: 10px 0 20px 0;">

                <div style="
                    font-family: 'Times New Roman', Times, serif;
                    font-size: 28px;
                    font-weight: 400;
                    line-height: 1;
                    letter-spacing: -1.2px;
                    color: {JNJ_RED};
                    white-space: nowrap;
                    text-shadow: none;
                    -webkit-font-smoothing: antialiased;
                    text-rendering: geometricPrecision;
                ">
                    Johnson&amp;Johnson
                </div>

                <div style="
                    font-size: 12px;
                    color: {MUTED};
                    margin-top: 6px;
                ">
                    ARGES Commons • Clinical Data Inventory
                </div>

            </div>
            """,
            unsafe_allow_html=True,
        )

        # ==========================================================
        # Filters
        # ==========================================================
        st.markdown("### Filters")

        eligible = studies.copy()

        # Study
        selected = st.multiselect(
            "Study",
            clean_text_values(
                eligible.get(
                    "Study Name",
                    pd.Series(dtype=str),
                )
            ),
        )

        if selected and "Study Name" in eligible:
            eligible = eligible[
                eligible["Study Name"].astype(str).isin(selected)
            ]

        # Phase
        phases = st.multiselect(
            "Phase",
            clean_text_values(
                eligible.get(
                    "Phase",
                    pd.Series(dtype=str),
                )
            ),
        )

        if phases and "Phase" in eligible:
            eligible = eligible[
                eligible["Phase"].astype(str).isin(phases)
            ]

        # Trial Status
        statuses = st.multiselect(
            "Trial status",
            clean_text_values(
                eligible.get(
                    "Trial Status",
                    pd.Series(dtype=str),
                )
            ),
        )

        if statuses and "Trial Status" in eligible:
            eligible = eligible[
                eligible["Trial Status"].astype(str).isin(statuses)
            ]

        # Compound
        compounds = st.multiselect(
            "Compound",
            clean_text_values(
                eligible.get(
                    "Compound",
                    pd.Series(dtype=str),
                )
            ),
        )

        if compounds and "Compound" in eligible:
            eligible = eligible[
                eligible["Compound"].astype(str).isin(compounds)
            ]

        # ==========================================================
        # Selected studies counter
        # ==========================================================
        ids = set(
            eligible["Study ID"]
            .dropna()
            .astype(str)
        )

        st.markdown("---")

        st.caption(
            f"{len(ids)} of "
            f"{studies['Study ID'].nunique()} "
            f"studies selected"
        )

    return eligible, ids
