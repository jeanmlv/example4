# example4

Subject: Increase request body size for ARD Explorer Domino App

The ARD Explorer Streamlit App is configured with server.maxUploadSize = 500 MB and correctly displays a 500 MB upload limit. However, uploading a 183 MB XLSX file returns HTTP status 413 – Request Entity Too Large.

This suggests that the request is being rejected by the Domino App reverse proxy, ingress, or gateway before reaching Streamlit.

Could you please verify the maximum request body size configured for Domino Apps and increase it to at least 500 MB for this application, including a reasonable overhead above 500 MB?
