# example4

st.markdown(
    f"""
    <div style="padding:10px 0 20px 0;">
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
            font-size:12px;
            color:{MUTED};
            margin-top:6px;
        ">
            ARGES Commons • Clinical Data Inventory
        </div>
    </div>
    """,
    unsafe_allow_html=True,
)
