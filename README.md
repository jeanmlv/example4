# example4

def apply_theme():
    st.markdown(
        f"""
        <style>
        /* =========================================================
           ARGES Commons — theme-aware styling
           Works with both Streamlit Light and Dark modes
           ========================================================= */

        /* Main application */
        .stApp {{
            background-color: var(--background-color);
            color: var(--text-color);
        }}

        .block-container {{
            padding-top: 1.3rem;
            padding-bottom: 3rem;
            max-width: 1500px;
        }}

        /* Sidebar */
        [data-testid="stSidebar"] {{
            background-color: var(--secondary-background-color);
            border-right: 1px solid rgba(128, 128, 128, 0.25);
        }}

        /* Typography */
        h1, h2, h3 {{
            letter-spacing: -0.02em;
            color: var(--text-color);
        }}

        h1 {{
            font-size: 2rem !important;
        }}

        /* =========================================================
           KPI cards
           ========================================================= */

        div[data-testid="stMetric"] {{
            background-color: var(--secondary-background-color);
            border: 1px solid rgba(128, 128, 128, 0.25);
            border-radius: 14px;
            padding: 14px 16px;
            box-shadow: 0 2px 10px rgba(16, 24, 40, 0.06);
        }}

        div[data-testid="stMetricLabel"] {{
            color: var(--text-color) !important;
        }}

        div[data-testid="stMetricLabel"] p {{
            color: var(--text-color) !important;
            opacity: 0.78;
        }}

        div[data-testid="stMetricValue"] {{
            color: var(--text-color) !important;
        }}

        div[data-testid="stMetricValue"] > div {{
            color: var(--text-color) !important;
        }}

        /* =========================================================
           ARGES branding / hero
           ========================================================= */

        .eyebrow {{
            font-size: 12px;
            letter-spacing: .12em;
            text-transform: uppercase;
            color: {JNJ_RED};
            font-weight: 800;
        }}

        .hero {{
            padding: 22px 24px;
            border: 1px solid rgba(128, 128, 128, 0.25);
            border-radius: 18px;
            background-color: var(--secondary-background-color);
            margin-bottom: 18px;
        }}

        .hero-title {{
            font-size: 28px;
            font-weight: 800;
            line-height: 1.15;
            margin: 5px 0 6px 0;
            color: var(--text-color);
        }}

        .hero-copy,
        .section-note {{
            color: var(--text-color);
            opacity: 0.70;
            font-size: 13px;
        }}

        /* =========================================================
           Tables / controls
           ========================================================= */

        [data-testid="stDataFrame"] {{
            border: 1px solid rgba(128, 128, 128, 0.25);
            border-radius: 12px;
            overflow: hidden;
        }}

        hr {{
            border-color: rgba(128, 128, 128, 0.25);
        }}

        </style>
        """,
        unsafe_allow_html=True,
    )
