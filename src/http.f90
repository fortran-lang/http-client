module http
    use http_request, only: &
        HTTP_DELETE, HTTP_GET, HTTP_HEAD, HTTP_PATCH, HTTP_POST, HTTP_POST
    use http_response, only: response_type
    use http_client, only: request
    use http_header, only : header_type
    use http_form, only : form_type
    use http_file, only : file_type
end module http
