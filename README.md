# example4

value_type_options = sorted(temp_map["value_type"].dropna().unique())

default_value_types = [
    value_type
    for value_type in ["AVAL", "AVALC"]
    if value_type in value_type_options
]

selected_value_type = st.sidebar.multiselect(
    "Value type",
    value_type_options,
    default=default_value_types
)
