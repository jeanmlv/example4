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
        brand_html = (
            f'<div style="padding:10px 0 20px 0;">'
            f'<div style="'
            f"font-family:'Times New Roman', Times, serif;"
            f'font-size:28px;'
            f'font-weight:400;'
            f'line-height:1;'
            f'letter-spacing:-1.2px;'
            f'color:{JNJ_RED};'
            f'white-space:nowrap;'
            f'text-shadow:none;'
            f'-webkit-font-smoothing:antialiased;'
            f'text-rendering:geometricPrecision;'
            f'">'
            f'Johnson&amp;Johnson'
            f'</div>'
            f'<div style="'
            f'font-size:12px;'
            f'color:{MUTED};'
            f'margin-top:6px;'
            f'">'
            f'ARGES Commons • Clinical Data Inventory'
            f'</div>'
            f'</div>'
        )

        st.markdown(
            brand_html,
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
