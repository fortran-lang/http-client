
!!> This file defines the **`client_type`** derived type, which handles the 
!!> process of making **HTTP requests**. The actual HTTP requests are executed 
!!> using the [Fortran-curl](https://github.com/interkosmos/fortran-curl) 
!!> package as the underlying mechanism.

module http_client

    !!> This module defines the **`client_type`** derived type, which handles the 
    !!> process of making **HTTP requests**. The actual HTTP requests are executed 
    !!> using the [Fortran-curl](https://github.com/interkosmos/fortran-curl) 
    !!> package as the underlying mechanism.

    use iso_fortran_env, only: int64
    use iso_c_binding, only: c_associated, c_f_pointer, c_funloc, c_loc, &
        c_null_ptr, c_ptr, c_size_t, c_null_char
    use curl, only: c_f_str_ptr, curl_easy_cleanup, curl_easy_getinfo, &
        curl_easy_init, curl_easy_perform, curl_easy_setopt, &
        curl_easy_strerror, curl_slist_append, CURLE_OK, &
        CURLINFO_RESPONSE_CODE, CURLOPT_CUSTOMREQUEST, CURLOPT_HEADERDATA, &
        CURLOPT_HEADERFUNCTION, CURLOPT_HTTPHEADER, CURLOPT_URL, &
        CURLOPT_WRITEDATA, CURLOPT_WRITEFUNCTION, &
        CURLOPT_POSTFIELDS, CURLOPT_POSTFIELDSIZE_LARGE, curl_easy_escape, &
        curl_mime_init, curl_mime_addpart, curl_mime_filedata,curl_mime_name, &
        CURLOPT_MIMEPOST,curl_mime_data, CURL_ZERO_TERMINATED, &
        CURLOPT_TIMEOUT, CURLOPT_CONNECTTIMEOUT, &
        CURLOPT_HTTPAUTH, CURLAUTH_BASIC, CURLOPT_USERNAME, CURLOPT_PASSWORD
    use stdlib_optval, only: optval
    use http_request, only: request_type
    use http_response, only: response_type
    use http_pair, only: append_pair, pair_has_name, pair_type
    use http_version, only: VERSION_STRING
    
    implicit none

    private
    public :: request

    ! http_client Type
    type :: client_type
        !!> A derived type, responsible for making **actual HTTP `request`** using
        !!> fortran-curl at backend.
        type(request_type) :: request
    contains
        procedure :: client_get_response
    end type client_type

    interface client_type
        !!> Interface for `new_client` function.
        module procedure new_client
    end interface client_type

    interface request
        !!> Interface for `new_request` function.
        module procedure new_request
    end interface request
    
contains

    function new_request(url, method, header, data, form, file, timeout, auth) result(response)
    
        !!> This function create a `request_type` object and populates it.
        !!> The function returns the `response_type` object containing the
        !!> **server's response**.
        !!____
        !!> #### Note :
        !!> If the `header` argument is not provided, **default `user-agent`
        !!> header is set to `http-client/0.1`**.
    
        integer, intent(in), optional :: method
            !! Specifies the HTTP `method` to use for the request. 
            !! The **default value is 1**, which corresponds to the **`HTTP_GET`** method.
        character(len=*), intent(in) :: url
            !! Specifies the **`URL`** of the server.
        character(len=*), intent(in), optional :: data
            !! Specifies the **`data`** that needs to be sent to the server.
        type(pair_type), intent(in), optional :: header(:)
            !! Specifies the **request `headers`** that need to be sent to the server.
        type(pair_type), intent(in), optional :: form(:)
            !! Specifies the **`form data`** that needs to be sent to the server.
        type(pair_type), intent(in), optional :: file
            !! Specifies the **`file`** that needs to be sent to the server.
        integer, intent(in), optional :: timeout
            !! **`Timeout`** value for the request in **seconds**.
        type(pair_type), intent(in), optional :: auth
            !! stores the `username` and `password` for **`authentication`** purposes.
        type(response_type) :: response
            !! Stores the server's **`response`**.

        type(request_type) :: request
        type(client_type) :: client
        integer :: i

        ! setting request url
        request%url = url

        ! Set default HTTP method.
        request%method = optval(method, 1)
        
        ! Set request header
        if (present(header)) then
            request%header = header
            ! Set default request headers.
            if (.not. pair_has_name(header, 'user-agent')) then
              call append_pair(request%header, 'user-agent', 'http-client/'//VERSION_STRING)
            end if
        else
            ! Set default request headers.
            request%header = [pair_type('user-agent', 'http-client/'//VERSION_STRING)]
        end if

        ! setting the request data to be send
        if(present(data)) then
            request%data = data
        end if
        
        ! setting request form
        if(present(form)) then
            request%form = form
        end if

        ! setting request file
        if(present(file)) then
            request%file = file
        end if

        ! Set request timeout.
        request%timeout = optval(timeout, -1)
                
        ! setting username and password for Authentication
        if(present(auth)) then
            request%auth = auth
        end if

        ! Populates the response 
        client = client_type(request=request)
        response = client%client_get_response()
    end function new_request

    function new_client(request) result(client)

        !!> This is the constructor for the `client_type` derived type.
        
        type(request_type), intent(in) :: request
            !! Specifies the **HTTP `request`** to send.
        type(client_type) :: client
            !! A `client_type` object containing the `request` field set to the input `request` object.

        client%request = request
    end function new_client

    function client_get_response(this) result(response)
        
        !!> This function sends an HTTP `request` to a server using the 
        !!> [fortran-curl](https://github.com/interkosmos/fortran-curl) package 
        !!> and stores the server's response in a `response_type` 
        !!> object.

        class(client_type), intent(inout) :: this
            !! Contains the HTTP `request` to send.
        type(response_type), target :: response
            !! Contains the **server's response**.

        type(c_ptr) :: curl_ptr, header_list_ptr
        integer :: rc, i
        
        curl_ptr = c_null_ptr
        header_list_ptr = c_null_ptr
        
        response%url = this%request%url
        
        curl_ptr = curl_easy_init()
      
        if (.not. c_associated(curl_ptr)) then
            response%ok = .false.
            response%err_msg = "The initialization of a new easy handle using the 'curl_easy_init()'&
            & function failed. This can occur due to insufficient memory available in the system. &
            & Additionally, if libcurl is not installed or configured properly on the system"
            return
        end if

        ! setting request URL
        rc = curl_easy_setopt(curl_ptr, CURLOPT_URL, this%request%url)

        ! setting request method
        rc = set_method(curl_ptr, this%request%method, response)

        ! setting request timeout
        rc = set_timeout(curl_ptr, this%request%timeout)

        ! setting request body
        rc = set_body(curl_ptr, this%request)

        ! setting request authentication
        rc = set_auth(curl_ptr, this%request)

        ! prepare headers for curl
        call prepare_request_header_ptr(header_list_ptr, this%request%header)

        ! setting request header
        rc = curl_easy_setopt(curl_ptr, CURLOPT_HTTPHEADER, header_list_ptr);

        ! setting callback for writing received data
        rc = curl_easy_setopt(curl_ptr, CURLOPT_WRITEFUNCTION, c_funloc(client_response_callback))

        ! setting response content pointer to write callback
        rc = curl_easy_setopt(curl_ptr, CURLOPT_WRITEDATA, c_loc(response))

        ! setting callback for writing received headers
        rc = curl_easy_setopt(curl_ptr, CURLOPT_HEADERFUNCTION, c_funloc(client_header_callback))

        ! setting response header pointer to write callback
        rc = curl_easy_setopt(curl_ptr, CURLOPT_HEADERDATA, c_loc(response))

        ! Send request.
        rc = curl_easy_perform(curl_ptr)
        
        if (rc /= CURLE_OK) then
            response%ok = .false.
            response%err_msg = curl_easy_strerror(rc)
        end if
        
        ! setting response status_code
        rc = curl_easy_getinfo(curl_ptr, CURLINFO_RESPONSE_CODE, response%status_code)  
        
        call curl_easy_cleanup(curl_ptr)
      
    end function client_get_response
    
    function prepare_form_encoded_str(curl_ptr, request) result(form_encoded_str)
        
        !!> This subroutine converts the `request%form` into a **URL-encoded name-value 
        !!> string** and returns it.

        ! This subroutine takes a request object containing a list of name-value pairs 
        ! representing the form data. It iterates over the list and URL-encodes each 
        ! name and value using the curl_easy_escape function, which replaces special 
        ! characters with their corresponding escape sequences.
        ! The encoded name-value pairs are concatenated into a single string, separated 
        ! by '&' characters. The resulting string is returned

        type(c_ptr), intent(out) :: curl_ptr
            !! Pointer to the `curl` handler.
        type(request_type), intent(inout) :: request
            !! The HTTP `request` to send, which includes the `form` data to be encoded.
        character(:), allocatable :: form_encoded_str
            !! Stores the **URL Encoded string**.
        
        integer :: i
        if(allocated(request%form)) then
            do i=1, size(request%form)
                if(.not. allocated(form_encoded_str)) then
                    form_encoded_str = curl_easy_escape(curl_ptr, request%form(i)%name, &
                    len(request%form(i)%name)) // '=' // curl_easy_escape(curl_ptr, &
                    request%form(i)%value, len(request%form(i)%value))
                else
                    form_encoded_str = form_encoded_str // '&' // &
                    curl_easy_escape(curl_ptr, request%form(i)%name, len(request%form(i)%name))&
                    // '=' // curl_easy_escape(curl_ptr, request%form(i)%value, len(request%form(i)%value))
                end if
            end do
        end if
    end function prepare_form_encoded_str

    subroutine prepare_request_header_ptr(header_list_ptr, req_headers)
        
        !!> This subroutine prepares `headers` in required format(Linked list) for an HTTP request.
        !!____
        !!> This subroutine prepares a **linked list** of `headers` for an HTTP request using the 
        !!> [fortran-curl](https://github.com/interkosmos/fortran-curl) package. 
        !!> The function takes an array of `pair_type` objects(i.e. `req_headers`) that contain the  
        !!> **key-value** pairs of the headers to include in the request.
        !!> It iterates over the array and constructs a string for each header in the format **`key:value`**.
        !!> The subroutine then appends each string to the linked list using the `curl_slist_append` function.
        !!> The resulting linked list is returned via the `header_list_ptr` argument.
        
        type(c_ptr), intent(out) :: header_list_ptr
            !! A `Pointer` that is allocated and points to a linked list of headers.
        type(pair_type), allocatable, intent(in) :: req_headers(:)
            !! The `headers` to be included in the request.
        character(:), allocatable :: h_name, h_val, final_header_string
        integer :: i

        do i = 1, size(req_headers)
            h_name = req_headers(i)%name
            h_val = req_headers(i)%value
            final_header_string = h_name // ':' // h_val 
            header_list_ptr = curl_slist_append(header_list_ptr, final_header_string)
        end do
    end subroutine prepare_request_header_ptr

    function set_method(curl_ptr, method, response) result(status)
        !!> This function sets the **HTTP `method`** for the request.
        !!____
        !!#### **The `method` argument can take one of the following values:**
        !!> `HTTP_GET`, `HTTP_HEAD`, `HTTP_POST`, `HTTP_PUT`, `HTTP_DELETE`, 
        !!> `HTTP_PATCH`. If any other value is provided, an **error will be thrown**.

        type(c_ptr), intent(out) :: curl_ptr
            !! Pointer to the `curl` handler.
        integer, intent(in) :: method
            !! Specifies the HTTP `method` to use.
        type(response_type), intent(out) :: response
            !! The HTTP `response` from the server.
        integer :: status
            !! The `status` of setting HTTP method.

        select case(method)
        case(1)
            status = curl_easy_setopt(curl_ptr, CURLOPT_CUSTOMREQUEST, 'GET' )
            response%method = 'GET'
        case(2)
            status = curl_easy_setopt(curl_ptr, CURLOPT_CUSTOMREQUEST, 'HEAD' )
            response%method = 'HEAD'
        case(3)
            status = curl_easy_setopt(curl_ptr, CURLOPT_CUSTOMREQUEST, 'POST' )
            response%method = 'POST'
        case(4)
            status = curl_easy_setopt(curl_ptr, CURLOPT_CUSTOMREQUEST, 'PUT' )
            response%method = 'PUT'
        case(5)
            status = curl_easy_setopt(curl_ptr, CURLOPT_CUSTOMREQUEST, 'DELETE' )
            response%method = 'DELETE'
        case(6)
            status = curl_easy_setopt(curl_ptr, CURLOPT_CUSTOMREQUEST, 'PATCH' )
            response%method = 'PATCH'
        case default
            error stop 'Method argument can be either HTTP_GET, HTTP_HEAD, HTTP_POST, HTTP_PUT, HTTP_DELETE, HTTP_PATCH'
        end select
    end function set_method

    function set_timeout(curl_ptr, timeout) result(status)
        !!> This function sets the `timeout` value **(in seconds)**. 
        !!>
        !!> If the `timeout` value is **less than zero**, it is ignored and a success status is returned. 
        type(c_ptr), intent(out) :: curl_ptr
            !! Pointer to the `curl` handle.
        integer(kind=int64), intent(in) :: timeout
            !! `Timeout` seconds for request.
        integer :: status
            !! `Status code` indicating whether the operation was successful.
        if(timeout < 0) then
            status = 0
        else
            ! setting the maximum time allowed for the connection to established.(in seconds)
            status = curl_easy_setopt(curl_ptr, CURLOPT_CONNECTTIMEOUT, timeout)
            ! setting maximum time allowed for transfer operation.(in seconds)
            status = curl_easy_setopt(curl_ptr, CURLOPT_TIMEOUT, timeout)
        end if
    end function set_timeout

    ! This function determines the type of data to include in the `request body` 
    ! based on the inputs provided. 
    
    ! If `data` member is provided, it is sent as the body of the 
    ! request. If along with `data` member `file` or `form` or both `file` and `form` members 
    ! are provided then both `form` and `file` member will be ignored and only `data` member will be
    ! sent in request body. `data` argument takes the highest priority.

    ! If only `file` member is provided then `file` is sent as the body of the request. and 
    ! a default `Content-type` header with value `multipart/form-data` will be set, if no `Content-type`
    ! header is provided. If both `form` and `file` members are provided, then `file` 
    ! and the `form` is sent as part of the body. having default `Content-type` header with value `multipart/form-data`
    ! if no `Content-type` header is provided.
    ! If data, form, and file are all provided, only data is sent and the form and file 
    ! inputs are ignored.
    !
    ! If only `form` member is provided then `form` data is URL encoded and sent 
    ! as the body of the request. and a default `Content-type` header with value 
    ! `application/x-www-form-urlencoded` will be set, if no `Content-type` header is
    ! provided 
    ! 
    ! 
    ! data -> data
    ! form -> form
    ! file -> file
    ! data + form + file -> data
    ! form + file -> form + file (in multipart/form-data)
    ! 
    ! Note : At a time only one file can be send
    function set_body(curl_ptr, request) result(status)
        !!> The function sets the request `body`.
        !!____

        !!> This function determines and set the type of data to include in the `request body` 
        !!> based on the inputs provided to the `request()` procedure.

        !!> The function handles different combinations of `data`, `file`, and `form` members 
        !!> to decide the content and the default header for the request body.

        !!> - If `data` member is provided, it takes the highest priority and is sent as the 
        !!> body of the request. Any other provided `file` or `form` members will be ignored, 
        !!> and only the `data` member will be included in the request body.

        !!> - If only the `file` member is provided, the `file` is sent as the body of the request. 
        !!> If no `Content-type` header is provided, a default `Content-type` header with value 
        !!> `multipart/form-data` will be set.

        !!> - If only the `form` member is provided, the `form` data is URL encoded and sent as 
        !!> the body of the request. If no `Content-type` header is provided, a default `Content-type` 
        !!> header with value `application/x-www-form-urlencoded` will be set.

        !!> - If both `form` and `file` members are provided, both `form` and `file` data are included 
        !!> as part of the request body. A default `Content-type` header with value `multipart/form-data` 
        !!> will be set if no `Content-type` header is provided.

        !!> - If `data`, `form`, and `file` are all provided, only `data` is sent, and the `form` and `file`
        !!> inputs are ignored.

        !!> ### **Combination Behavior Table**


        !!> | Passed Arguments   | Request Body                    | Default Header                | Behavior                                                |
        !! |--------------------|---------------------------------|-------------------------------|---------------------------------------------------------|
        !! | data               | data                            | None                          | The `data` is sent as the body of the request.         |
        !! | file               | file                            | multipart/form-data           | The `file` is sent as the body of the request with the default header.  |
        !! | form               | Form data URL encoded           | application/x-www-form-urlencoded | The `form` data is sent as the body of the request with the default header. |
        !! | data + file        | data (file ignored)             | None                          | The `file` member is ignored, and the `data` is sent as the body of the request. |
        !! | data + form        | data (form ignored)             | None                          | The `form` member is ignored, and the `data` is sent as the body of the request. |
        !! | file + form        | both file and form              | multipart/form-data           | Both `form` and `file` are sent as part of the request. |
        !! | data + file + form | data (form and file ignored)    | None                          | Both `form` and `file` members are ignored, and only the `data` is sent as the body of the request. |
        
        !!> Note: If custom headers are provided in the `headers` parameter, they will be used. Otherwise, default headers will be applied as mentioned in the table.

        type(c_ptr), intent(out) :: curl_ptr
            !! Pointer to the `curl` handle.
        type(request_type), intent(inout) :: request
            !! The HTTP request
        integer :: status
            !! An integer value representing the status of the function call.
        
        integer :: i
        type(c_ptr) :: mime_ptr, part_ptr

        ! if only data is passed
        if (allocated(request%data)) then
            status = set_postfields(curl_ptr, request%data)
        
        ! if file is passsed
        else if (allocated(request%file)) then
            mime_ptr = curl_mime_init(curl_ptr)
            part_ptr = curl_mime_addpart(mime_ptr)
            status = curl_mime_filedata(part_ptr, request%file%value)
            status = curl_mime_name(part_ptr, request%file%name)
            
            ! if both file and form are passed
            if(allocated(request%form)) then 
                do i=1, size(request%form)
                    part_ptr = curl_mime_addpart(mime_ptr)
                    status = curl_mime_data(part_ptr, request%form(i)%value, CURL_ZERO_TERMINATED)
                    status = curl_mime_name(part_ptr, request%form(i)%name)
                end do
            end if
            status = curl_easy_setopt(curl_ptr, CURLOPT_MIMEPOST, mime_ptr)
            
            ! setting the Content-Type header to multipart/form-data, used for sending  binary data
            if (.not. pair_has_name(request%header, 'Content-Type')) then
                call append_pair(request%header, 'Content-Type', 'multipart/form-data')
            end if
        
        ! if only form is passed
        else if (allocated(request%form)) then
            request%form_encoded_str = prepare_form_encoded_str(curl_ptr, request)
            status = set_postfields(curl_ptr, request%form_encoded_str)
           
            ! setting the Content-Type header to application/x-www-form-urlencoded, used for sending form data
            if (.not. pair_has_name(request%header, 'Content-Type')) then
                call append_pair(request%header, 'Content-Type', 'application/x-www-form-urlencoded')
            end if
        else
            ! No curl function was called so set status to zero.
            status = 0
        end if
        
    end function set_body

    function set_postfields(curl_ptr, data) result(status)
        !!> Set the data to be sent in the HTTP POST request body.
        !!____
        !!> Use as helper function by `set_body` procedure to set request body
        type(c_ptr), intent(inout) :: curl_ptr
            !! Pointer to the CURL handle.
        character(*), intent(in), target :: data
            !! The data to be sent in the request body.
        integer :: status
            !! An integer indicating whether the operation was successful (0) or not (non-zero).

        status = curl_easy_setopt(curl_ptr, CURLOPT_POSTFIELDS, c_loc(data))
        status = curl_easy_setopt(curl_ptr, CURLOPT_POSTFIELDSIZE_LARGE, len(data, kind=int64))

    end function set_postfields

    function set_auth(curl_ptr, request) result(status)
        !!> Set the user name and password for Authentication. 
        !!_____
        !!> It sends the user name and password over the network in plain text, easily captured by others.
        type(c_ptr), intent(out) :: curl_ptr
            !! Pointer to the CURL handle.
        type(request_type), intent(inout) :: request
            !! The HTTP request
        integer :: status
            !! An integer indicating whether the operation was successful (0) or not (non-zero).

        if(allocated(request%auth)) then
            status = curl_easy_setopt(curl_ptr, CURLOPT_HTTPAUTH, CURLAUTH_BASIC)
            status = curl_easy_setopt(curl_ptr, CURLOPT_USERNAME, request%auth%name)
            status = curl_easy_setopt(curl_ptr, CURLOPT_PASSWORD, request%auth%value)
        else 
            ! No curl function was called so set status to zero.
            status = 0
        end if
    end function set_auth

    function client_response_callback(ptr, size, nmemb, client_data) bind(c)
        !!> This function is a `callback` function used by the fortran-curl package to handle HTTP responses. 
        !!> It is called for each `chunk` of data received from the server and appends the data to a 
        !!> `response_type` object.
        !!>_____
        !!> It is called for each `chunk` of data received from the server and appends the data to a `response_type` 
        !!> object passed(i.e `client_data`). The function takes four input arguments: `ptr`, `size`, `nmemb`,  
        !!> and `client_data`. `ptr` is a pointer to the received data buffer, `size` specifies the size of each 
        !!> data element, `nmemb` specifies the number of data elements received, and `client_data` is a pointer to  
        !!> a `response_type` object. The function uses `c_f_pointer` to convert the C pointer to a Fortran pointer and 
        !!> appends the received data to the `content` field of the `response_type` object. The function returns an integer
        !!> value representing the **number of bytes received.**
        
        type(c_ptr), intent(in), value :: ptr 
            !! Pointer to the CURL handle.
        integer(kind=c_size_t), intent(in), value :: size 
            !! Specifies the size of each data element.
        integer(kind=c_size_t), intent(in), value :: nmemb
            !! Specifies the number of data elements received.
        type(c_ptr), intent(in), value :: client_data
            !!  Points to a response_type object.
        integer(kind=c_size_t) :: client_response_callback 
            !! The number of bytes received.
        type(response_type), pointer :: response 
        character(len=:), allocatable :: buf
      
        client_response_callback = int(0, kind=c_size_t)
      
        ! Are the passed C pointers associated?
        if (.not. c_associated(ptr)) return
        if (.not. c_associated(client_data)) return
      
        ! Convert C pointer to Fortran pointer.
        call c_f_pointer(client_data, response)
        if (.not. allocated(response%content)) response%content = ''
      
        ! Convert C pointer to Fortran allocatable character.
        call c_f_str_ptr(ptr, buf, nmemb)
        if (.not. allocated(buf)) return
        response%content = response%content // buf
        deallocate (buf)
        response%content_length = response%content_length + nmemb
        
        ! Return number of received bytes.
        client_response_callback = nmemb

    end function client_response_callback

    function client_header_callback(ptr, size, nmemb, client_data) bind(c)
        !!> This function is a `callback` function used by the `fortran-curl` package to handle HTTP headers. 
        !!>_____
        !!> It is called for each header received from the server and stores the header in an `header` member 
        !!> of `response_type` object.
        type(c_ptr), intent(in), value :: ptr 
            !! Pointer to the CURL handle. that points to the received header buffer.
        integer(kind=c_size_t), intent(in), value :: size 
            !!  Specifies the size of each header element.
        integer(kind=c_size_t), intent(in), value :: nmemb
            !! Specifies the number of header elements received.
        type(c_ptr), intent(in), value :: client_data
            !! Pointer to a `response_type` object.
        integer(kind=c_size_t) :: client_header_callback 
            !! The number of bytes received.
        type(response_type), pointer :: response 
        character(len=:), allocatable :: buf, h_name, h_value
        integer :: i
      
        client_header_callback = int(0, kind=c_size_t)
      
        ! Are the passed C pointers associated?
        if (.not. c_associated(ptr)) return
        if (.not. c_associated(client_data)) return
      
        ! Convert C pointer to Fortran pointer.
        call c_f_pointer(client_data, response)
      
        ! Convert C pointer to Fortran allocatable character.
        call c_f_str_ptr(ptr, buf, nmemb)
        if (.not. allocated(buf)) return
        
        ! Parsing Header, and storing in array of pair_type object
        i = index(buf, ':')
        if(i /= 0 .and. len(buf) > 2) then
            h_name = trim(buf(:i-1))
            h_value = buf(i+2 : )
            h_value = h_value( : len(h_value)-2)
            if(len(h_value) > 0 .and. len(h_name) > 0) then
                call append_pair(response%header, h_name, h_value)
                ! response%header = [response%header, pair_type(h_name, h_value)]
            end if
        end if
        deallocate(buf)
        
        ! Return number of received bytes.
        client_header_callback = nmemb

    end function client_header_callback

end module http_client
