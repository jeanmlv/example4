# example4

import pandas as pd
import streamlit as st
from src.ui import show_table


def render(filtered, data):
    st.header("Studies & Assets")

    st.markdown(
        '<div class="section-note">'
        'Study portfolio and the source assets registered for each study.'
        '</div>',
        unsafe_allow_html=True
    )

    # Retrieve filtered datasets
    s = filtered["01_STUDIES"].copy()
    a = filtered.get("03_ASSETS", pd.DataFrame()).copy()

    # Remove completely empty rows
    s = s.dropna(how="all")
    a = a.dropna(how="all")

    # Reset indexes
    s = s.reset_index(drop=True)
    a = a.reset_index(drop=True)

    # KPI metrics
    c1, c2, c3, c4 = st.columns(4)

    c1.metric(
        "Studies",
        s["Study ID"].nunique() if "Study ID" in s.columns else 0
    )

    c2.metric("Assets", len(a))

    c3.metric(
        "Asset types",
        a["Asset Type"].nunique() if "Asset Type" in a.columns else 0
    )

    c4.metric(
        "Sources",
        a["Source"].nunique() if "Source" in a.columns else 0
    )

    # Tabs
    t1, t2 = st.tabs(["Studies", "Assets"])

    with t1:
        show_table(
            s,
            key="studies_table",
            link_cols=["ClinicalTrials Link"]
        )

    with t2:
        show_table(
            a,
            key="assets_table"
        )















        
