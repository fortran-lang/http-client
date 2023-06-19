module http_client
    use iso_c_binding, only: c_associated, c_f_pointer, c_funloc, c_loc, &
        c_null_char, c_null_ptr, c_ptr, c_size_t
    use curl, only: c_f_str_ptr, curl_easy_cleanup, curl_easy_getinfo, &
        curl_easy_init, curl_easy_perform, curl_easy_setopt, &
        curl_easy_strerror, curl_slist_append, CURLE_OK, &
        CURLINFO_RESPONSE_CODE, CURLOPT_CUSTOMREQUEST, CURLOPT_HEADERDATA, &
        CURLOPT_HEADERFUNCTION, CURLOPT_HTTPHEADER, CURLOPT_URL, &
        CURLOPT_WRITEDATA, CURLOPT_WRITEFUNCTION, &
        CURLOPT_POSTFIELDS, CURLOPT_POSTFIELDSIZE_LARGE
    use stdlib_optval, only: optval
    use http_request, only: request_type
    use http_response, only: response_type
    use http_header, only : header_type
    
    implicit none

    private
    public :: request

    ! http_client Type
    type :: client_type
        type(request_type) :: request
    contains
        procedure :: client_get_response
    end type client_type

    interface client_type
        module procedure new_client
    end interface client_type

    interface request
        module procedure new_request
    end interface request
    
contains
    ! Constructor for request_type type.
    function new_request(url, method, header, json) result(response)
        integer, intent(in), optional :: method
        character(len=*), intent(in) :: url
        character(len=*), intent(in), optional :: json
        type(header_type), intent(in), optional :: header(:)
        type(request_type) :: request
        type(response_type) :: response
        type(client_type) :: client

        ! setting request url
        request%url = url

        ! Set default HTTP method.
        request%method = optval(method, 1)
        
        ! Set default request headers.
        request%header = [header_type('user-agent', 'fortran-http/1.0.0')]
        if(present(header)) then 
            request%header = [header, request%header]
        end if
        
        if(present(json)) then
            request%json = json
            request%header = [request%header, header_type('Content-Type', 'application/json')]
        end if
        
        client = client_type(request=request)
        
        ! Populates the response 
        response = client%client_get_response()
    end function new_request

    ! Constructor for client_type type.
    function new_client(request) result(client)
        type(request_type), intent(in) :: request
        type(client_type) :: client

        client%request = request
    end function new_client

    function client_get_response(this) result(response)
        class(client_type), intent(inout) :: this
        type(response_type), target :: response
        type(c_ptr) :: curl_ptr,  header_list_ptr
        integer :: rc, i
        
        curl_ptr = c_null_ptr
        header_list_ptr = c_null_ptr
        
        response%url = this%request%url

        ! prepare headers for curl
        call prepare_request_header_ptr(header_list_ptr, this%request%header)
        
        curl_ptr = curl_easy_init()
      
        if (.not. c_associated(curl_ptr)) then
            response%ok = .false.
            response%err_msg = "The initialization of a new easy handle using the 'curl_easy_init()'&
            & function failed. This can occur due to insufficient memory available in the system. &
            & Additionally, if libcurl is not installed or configured properly on the system"
            return
        end if

        ! setting request URL
        rc = curl_easy_setopt(curl_ptr, CURLOPT_URL, this%request%url // c_null_char)

        ! setting request method
        rc = set_method(curl_ptr, this%request%method, response)

        ! setting request body
        rc = set_body(curl_ptr, this%request%json)

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

    subroutine prepare_request_header_ptr(header_list_ptr, req_headers)
        type(c_ptr), intent(out) :: header_list_ptr
        type(header_type), allocatable, intent(in) :: req_headers(:)
        character(:), allocatable :: h_key, h_val, final_header_string
        integer :: i

        do i = 1, size(req_headers)
            h_key = req_headers(i)%key
            h_val = req_headers(i)%value
            final_header_string = h_key // ':' // h_val // c_null_char
            header_list_ptr = curl_slist_append(header_list_ptr, final_header_string)
        end do
    end subroutine prepare_request_header_ptr

    function set_method(curl_ptr, method, response) result(status)
        type(c_ptr), intent(out) :: curl_ptr
        integer, intent(in) :: method
        type(response_type), intent(out) :: response
        integer :: status

        select case(method)
        case(1)
            status = curl_easy_setopt(curl_ptr, CURLOPT_CUSTOMREQUEST, 'GET' // c_null_char)
            response%method = 'GET'
        case(2)
            status = curl_easy_setopt(curl_ptr, CURLOPT_CUSTOMREQUEST, 'HEAD' // c_null_char)
            response%method = 'HEAD'
        case(3)
            status = curl_easy_setopt(curl_ptr, CURLOPT_CUSTOMREQUEST, 'POST' // c_null_char)
            response%method = 'POST'
        case(4)
            status = curl_easy_setopt(curl_ptr, CURLOPT_CUSTOMREQUEST, 'PUT' // c_null_char)
            response%method = 'PUT'
        case(5)
            status = curl_easy_setopt(curl_ptr, CURLOPT_CUSTOMREQUEST, 'DELETE' // c_null_char)
            response%method = 'DELETE'
        case(6)
            status = curl_easy_setopt(curl_ptr, CURLOPT_CUSTOMREQUEST, 'PATCH' // c_null_char)
            response%method = 'PATCH'
        case default
            error stop 'Method argument can be either HTTP_GET, HTTP_HEAD, HTTP_POST, HTTP_PUT, HTTP_DELETE, HTTP_PATCH'
        end select
    end function set_method

    function set_body(curl_ptr, json) result(status)
        type(c_ptr), intent(out) :: curl_ptr
        character(*), intent(in) :: json
        integer :: status, json_length
        json_length = len(json)
        ! if(json_length > 0) then
            status = curl_easy_setopt(curl_ptr, CURLOPT_POSTFIELDS, json)
            status = curl_easy_setopt(curl_ptr, CURLOPT_POSTFIELDSIZE_LARGE, json_length)
        ! end if
    end function set_body

    function client_response_callback(ptr, size, nmemb, client_data) bind(c)
        type(c_ptr), intent(in), value :: ptr 
        integer(kind=c_size_t), intent(in), value :: size 
        integer(kind=c_size_t), intent(in), value :: nmemb
        type(c_ptr), intent(in), value :: client_data
        integer(kind=c_size_t) :: client_response_callback 
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
        type(c_ptr), intent(in), value :: ptr 
        integer(kind=c_size_t), intent(in), value :: size 
        integer(kind=c_size_t), intent(in), value :: nmemb
        type(c_ptr), intent(in), value :: client_data
        integer(kind=c_size_t) :: client_header_callback 
        type(response_type), pointer :: response 
        character(len=:), allocatable :: buf, h_key, h_value
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
        
        ! Parsing Header, and storing in hashmap
        i = index(buf, ':')
        if(i /= 0 .and. len(buf) > 2) then
            h_key = trim(buf(:i-1))
            h_value = buf(i+2 : )
            h_value = h_value( : len(h_value)-2)
            if(len(h_value) > 0 .and. len(h_key) > 0) then
                call response%append_header(h_key, h_value)
                ! response%header = [response%header, header_type(h_key, h_value)]
            end if
        end if
        deallocate(buf)
        
        ! Return number of received bytes.
        client_header_callback = nmemb

    end function client_header_callback

end module http_client
