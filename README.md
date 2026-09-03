# example4

PS C:\Users\JMende95\OneDrive - JNJ\Desktop\vsquad_streamlit_dash> py -m streamlit run app.py
2026-09-03 12:32:09.717 Uvicorn server started on 0.0.0.0:8501

  You can now view your Streamlit app in your browser.

  Local URL: http://localhost:8501
  Network URL: http://10.51.32.195:8501
  External URL: http://199.65.29.20:8501

2026-09-03 12:41:53.769 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:41:54.095 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:41:54.257 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:41:54.363 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:41:54.404 Uncaught app execution
Traceback (most recent call last):
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\runtime\scriptrunner\exec_code.py", line 129, in exec_func_with_error_handling
    result = func()
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\runtime\scriptrunner\script_runner.py", line 789, in code_to_exec
    exec(code, module.__dict__)  # noqa: S102
    ~~~~^^^^^^^^^^^^^^^^^^^^^^^
  File "C:\Users\JMende95\OneDrive - JNJ\Desktop\vsquad_streamlit_dash\app.py", line 270, in <module>
    main()
    ~~~~^^
  File "C:\Users\JMende95\OneDrive - JNJ\Desktop\vsquad_streamlit_dash\app.py", line 254, in main
    study_detail_panel(data, study_ids)
    ~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^
  File "C:\Users\JMende95\OneDrive - JNJ\Desktop\vsquad_streamlit_dash\app.py", line 222, in study_detail_panel
    c3.metric("Patients", row.get("Patients", "—"))
    ~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\runtime\metrics_util.py", line 698, in wrapped_func
    result = non_optional_func(*args, **kwargs)
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\elements\metric.py", line 372, in metric
    metric_proto.body = _parse_value(value)
                        ~~~~~~~~~~~~^^^^^^^
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\elements\metric.py", line 461, in _parse_value
    return from_number(value)
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\string_util.py", line 302, in from_number
    raise TypeError(
    ...<2 lines>...
    )
TypeError: '<NA>' is of type <class 'pandas.api.typing.NAType'>, which is not an accepted type. Please convert the value to an accepted number type.
2026-09-03 12:42:12.500 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:12.524 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:12.562 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:12.597 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:12.612 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:12.618 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:12.623 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:12.629 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:12.634 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:19.960 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:32.714 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:32.742 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:32.788 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:32.821 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:32.838 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:32.845 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:32.850 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:32.857 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:32.863 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:53.719 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:53.741 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:53.771 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:53.805 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:53.819 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:53.823 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:53.828 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:53.834 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:53.840 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:55.834 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:55.859 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:55.903 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:55.940 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:42:55.949 Uncaught app execution
Traceback (most recent call last):
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\runtime\scriptrunner\exec_code.py", line 129, in exec_func_with_error_handling
    result = func()
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\runtime\scriptrunner\script_runner.py", line 789, in code_to_exec
    exec(code, module.__dict__)  # noqa: S102
    ~~~~^^^^^^^^^^^^^^^^^^^^^^^
  File "C:\Users\JMende95\OneDrive - JNJ\Desktop\vsquad_streamlit_dash\app.py", line 270, in <module>
    main()
    ~~~~^^
  File "C:\Users\JMende95\OneDrive - JNJ\Desktop\vsquad_streamlit_dash\app.py", line 254, in main
    study_detail_panel(data, study_ids)
    ~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^
  File "C:\Users\JMende95\OneDrive - JNJ\Desktop\vsquad_streamlit_dash\app.py", line 222, in study_detail_panel
    c3.metric("Patients", row.get("Patients", "—"))
    ~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\runtime\metrics_util.py", line 698, in wrapped_func
    result = non_optional_func(*args, **kwargs)
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\elements\metric.py", line 372, in metric
    metric_proto.body = _parse_value(value)
                        ~~~~~~~~~~~~^^^^^^^
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\elements\metric.py", line 461, in _parse_value
    return from_number(value)
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\string_util.py", line 302, in from_number
    raise TypeError(
    ...<2 lines>...
    )
TypeError: '<NA>' is of type <class 'pandas.api.typing.NAType'>, which is not an accepted type. Please convert the value to an accepted number type.
2026-09-03 12:43:29.310 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:43:29.337 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:43:29.376 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:43:29.413 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:43:29.423 Uncaught app execution
Traceback (most recent call last):
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\runtime\scriptrunner\exec_code.py", line 129, in exec_func_with_error_handling
    result = func()
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\runtime\scriptrunner\script_runner.py", line 789, in code_to_exec
    exec(code, module.__dict__)  # noqa: S102
    ~~~~^^^^^^^^^^^^^^^^^^^^^^^
  File "C:\Users\JMende95\OneDrive - JNJ\Desktop\vsquad_streamlit_dash\app.py", line 270, in <module>
    main()
    ~~~~^^
  File "C:\Users\JMende95\OneDrive - JNJ\Desktop\vsquad_streamlit_dash\app.py", line 254, in main
    study_detail_panel(data, study_ids)
    ~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^
  File "C:\Users\JMende95\OneDrive - JNJ\Desktop\vsquad_streamlit_dash\app.py", line 222, in study_detail_panel
    c3.metric("Patients", row.get("Patients", "—"))
    ~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\runtime\metrics_util.py", line 698, in wrapped_func
    result = non_optional_func(*args, **kwargs)
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\elements\metric.py", line 372, in metric
    metric_proto.body = _parse_value(value)
                        ~~~~~~~~~~~~^^^^^^^
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\elements\metric.py", line 461, in _parse_value
    return from_number(value)
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\string_util.py", line 302, in from_number
    raise TypeError(
    ...<2 lines>...
    )
TypeError: '<NA>' is of type <class 'pandas.api.typing.NAType'>, which is not an accepted type. Please convert the value to an accepted number type.
2026-09-03 12:43:38.253 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:43:38.278 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:43:38.318 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:43:38.352 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:43:38.360 Uncaught app execution
Traceback (most recent call last):
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\runtime\scriptrunner\exec_code.py", line 129, in exec_func_with_error_handling
    result = func()
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\runtime\scriptrunner\script_runner.py", line 789, in code_to_exec
    exec(code, module.__dict__)  # noqa: S102
    ~~~~^^^^^^^^^^^^^^^^^^^^^^^
  File "C:\Users\JMende95\OneDrive - JNJ\Desktop\vsquad_streamlit_dash\app.py", line 270, in <module>
    main()
    ~~~~^^
  File "C:\Users\JMende95\OneDrive - JNJ\Desktop\vsquad_streamlit_dash\app.py", line 254, in main
    study_detail_panel(data, study_ids)
    ~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^
  File "C:\Users\JMende95\OneDrive - JNJ\Desktop\vsquad_streamlit_dash\app.py", line 222, in study_detail_panel
    c3.metric("Patients", row.get("Patients", "—"))
    ~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\runtime\metrics_util.py", line 698, in wrapped_func
    result = non_optional_func(*args, **kwargs)
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\elements\metric.py", line 372, in metric
    metric_proto.body = _parse_value(value)
                        ~~~~~~~~~~~~^^^^^^^
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\elements\metric.py", line 461, in _parse_value
    return from_number(value)
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\string_util.py", line 302, in from_number
    raise TypeError(
    ...<2 lines>...
    )
TypeError: '<NA>' is of type <class 'pandas.api.typing.NAType'>, which is not an accepted type. Please convert the value to an accepted number type.
2026-09-03 12:43:40.600 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:43:40.630 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:43:40.670 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:43:40.707 Please replace `use_container_width` with `width`.

`use_container_width` will be removed after 2025-12-31.

For `use_container_width=True`, use `width='stretch'`. For `use_container_width=False`, use `width='content'`.
2026-09-03 12:43:40.720 Uncaught app execution
Traceback (most recent call last):
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\runtime\scriptrunner\exec_code.py", line 129, in exec_func_with_error_handling
    result = func()
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\runtime\scriptrunner\script_runner.py", line 789, in code_to_exec
    exec(code, module.__dict__)  # noqa: S102
    ~~~~^^^^^^^^^^^^^^^^^^^^^^^
  File "C:\Users\JMende95\OneDrive - JNJ\Desktop\vsquad_streamlit_dash\app.py", line 270, in <module>
    main()
    ~~~~^^
  File "C:\Users\JMende95\OneDrive - JNJ\Desktop\vsquad_streamlit_dash\app.py", line 254, in main
    study_detail_panel(data, study_ids)
    ~~~~~~~~~~~~~~~~~~^^^^^^^^^^^^^^^^^
  File "C:\Users\JMende95\OneDrive - JNJ\Desktop\vsquad_streamlit_dash\app.py", line 222, in study_detail_panel
    c3.metric("Patients", row.get("Patients", "—"))
    ~~~~~~~~~^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\runtime\metrics_util.py", line 698, in wrapped_func
    result = non_optional_func(*args, **kwargs)
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\elements\metric.py", line 372, in metric
    metric_proto.body = _parse_value(value)
                        ~~~~~~~~~~~~^^^^^^^
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\elements\metric.py", line 461, in _parse_value
    return from_number(value)
  File "C:\Users\JMende95\AppData\Local\Programs\Python\Python314\Lib\site-packages\streamlit\string_util.py", line 302, in from_number
    raise TypeError(
    ...<2 lines>...
    )
TypeError: '<NA>' is of type <class 'pandas.api.typing.NAType'>, which is not an accepted type. Please convert the value to an accepted number type.

