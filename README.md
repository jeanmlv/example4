# example4

Subject: Increase request body size for ARD Explorer Domino App

The ARD Explorer Streamlit App is configured with server.maxUploadSize = 500 MB and correctly displays a 500 MB upload limit. However, uploading a 183 MB XLSX file returns HTTP status 413 – Request Entity Too Large.

This suggests that the request is being rejected by the Domino App reverse proxy, ingress, or gateway before reaching Streamlit.

Could you please verify the maximum request body size configured for Domino Apps and increase it to at least 500 MB for this application, including a reasonable overhead above 500 MB?

Hi Eric,

I'm working on the ARD Explorer Streamlit app and I'm having an issue with uploading larger ARD files.

I updated the Streamlit configuration (server.maxUploadSize) to 500 MB, and the application now correctly displays "Limit 500 MB per file" on the upload component.

However, after testing different file sizes, I found that uploads larger than approximately 100 MB consistently fail with HTTP 413 (Request Entity Too Large). For example, a 183 MB XLSX file fails immediately with a 413 error, even though the Streamlit upload limit is configured to 500 MB.

This makes me think the request is being rejected by the Domino App infrastructure (reverse proxy / ingress / gateway) before it reaches the Streamlit application.

Could you please check whether there is a request body size limit configured for Domino Apps? If possible, would it be feasible to increase it to at least 500 MB for this application?

Thanks!
