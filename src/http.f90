
!!> This file provides the **High-Level API** for the **`HTTP`** package. 
!!> When the `http` module is imported into the project, all these 
!!> high-level functionalities become available for use.

module http

    !!> This Module contains all **High-level API** for the **`HTTP`** package. 
    !!> When the `http` module is imported into the project, all these 
    !!> high-level functionalities become available for use.

    use http_request, only: &
        HTTP_DELETE, HTTP_GET, HTTP_HEAD, HTTP_PATCH, HTTP_POST, HTTP_PUT
    use http_response, only: response_type
    use http_client, only: request
    use http_pair, only : pair_type

end module http
