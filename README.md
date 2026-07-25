# example4

Hello Team,

I am experiencing an issue with a Domino Streamlit application (ARD Explorer - Clinical Dashboard).

Issue

The application is configured with:

server.maxUploadSize = 500
server.maxMessageSize = 500

The upload component correctly displays "Limit 500 MB per file".

However, uploads larger than approximately 100 MB consistently fail with HTTP 413 (Request Entity Too Large).

For example:

✅ Files smaller than ~100 MB upload successfully.
❌ A 183 MB XLSX file immediately returns HTTP 413.
Troubleshooting already performed
Tested the same application locally using Streamlit.
The 183 MB file uploads successfully without any issues.
The problem only occurs after deploying the application as a Domino App.
The Streamlit configuration has already been updated to allow 500 MB uploads.

Based on these tests, it appears the request is being rejected before reaching the Streamlit application, possibly by the Domino App infrastructure (reverse proxy / ingress / gateway).

Could you please verify whether there is a request body size limit configured for Domino Apps and, if possible, increase it to support uploads up to 500 MB?
