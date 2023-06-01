module http_client
    use iso_c_binding
    use curl
    use fhash, only: key => fhash_key
    use http_request, only: request_type
    use http_response, only: response_type
    
    implicit none

    private
    public :: request

    ! http_client Type
    type :: client_type
        type(request_type) :: request
        type(c_ptr) :: curl_ptr
    contains
        procedure :: client_get_response
        procedure :: client_set_method
    end type client_type

    interface client_type
        module procedure new_client
    end interface client_type

    interface request
        module procedure new_request
    end interface request
    
contains
    ! Constructor for request_type type.
    function new_request(url, method) result(response)
        character(len=*), intent(in) :: url
        integer, intent(in), optional :: method
        type(request_type) :: request
        type(response_type) :: response
        type(client_type) :: client

        if(present(method)) then 
           request%method = method
        else
            request%method = 1
        end if
        request%url = url
        client = client_type(request=request)
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
        integer :: rc

        ! logic for populating response using fortran-curl
        response%url = this%request%url
      
        this%curl_ptr = curl_easy_init()
      
        if (.not. c_associated(this%curl_ptr)) then
            response%ok = .false.
            response%err_msg = "The initialization of a new easy handle using the 'curl_easy_init()'&
            & function failed. This can occur due to insufficient memory available in the system. &
            & Additionally, if libcurl is not installed or configured properly on the system"
            return
        end if
        ! setting request URL
        rc = curl_easy_setopt(this%curl_ptr, CURLOPT_URL, this%request%url // c_null_char)
        ! setting request method
        rc = this%client_set_method(response)
        ! setting callback for writing received data
        rc = curl_easy_setopt(this%curl_ptr, CURLOPT_WRITEFUNCTION, c_funloc(client_response_callback))
        ! setting response content pointer to write callback
        rc = curl_easy_setopt(this%curl_ptr, CURLOPT_WRITEDATA, c_loc(response))
        ! setting callback for writing received headers
        rc = curl_easy_setopt(this%curl_ptr, CURLOPT_HEADERFUNCTION, c_funloc(client_header_callback))
        ! setting response header pointer to write callback
        rc = curl_easy_setopt(this%curl_ptr, CURLOPT_HEADERDATA, c_loc(response))
        ! Send request.
        rc = curl_easy_perform(this%curl_ptr)
        
        if (rc /= CURLE_OK) then
            response%ok = .false.
            response%err_msg = curl_easy_strerror(rc)
        end if
        ! setting response status_code
        rc = curl_easy_getinfo(this%curl_ptr, CURLINFO_RESPONSE_CODE, response%status_code)  
        call curl_easy_cleanup(this%curl_ptr)
      
    end function client_get_response

    function client_set_method(this,  response) result(status)
        class(client_type), intent(inout) :: this
        type(response_type), intent(out) :: response
        integer :: status

        select case(this%request%method)
        case(1)
            status = curl_easy_setopt(this%curl_ptr, CURLOPT_CUSTOMREQUEST, 'GET' // c_null_char)
            response%method = 'GET'
        case(2)
            status = curl_easy_setopt(this%curl_ptr, CURLOPT_CUSTOMREQUEST, 'HEAD' // c_null_char)
            response%method = 'HEAD'
        case(3)
            status = curl_easy_setopt(this%curl_ptr, CURLOPT_CUSTOMREQUEST, 'POST' // c_null_char)
            response%method = 'POST'
        case(4)
            status = curl_easy_setopt(this%curl_ptr, CURLOPT_CUSTOMREQUEST, 'PUT' // c_null_char)
            response%method = 'PUT'
        case(5)
            status = curl_easy_setopt(this%curl_ptr, CURLOPT_CUSTOMREQUEST, 'DELETE' // c_null_char)
            response%method = 'DELETE'
        case(6)
            status = curl_easy_setopt(this%curl_ptr, CURLOPT_CUSTOMREQUEST, 'PATCH' // c_null_char)
            response%method = 'PATCH'
        case default
            error stop "Method argument can be either HTTP_GET, HTTP_HEAD, HTTP_POST, HTTP_PUT, HTTP_DELETE, HTTP_PATCH"
        end select
    end function client_set_method

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
        if (.not. allocated(response%header_string)) response%header_string = ''
      
        ! Convert C pointer to Fortran allocatable character.
        call c_f_str_ptr(ptr, buf, nmemb)
        if (.not. allocated(buf)) return
        ! Parsing Header, and storing in hashmap
        if(len(response%header_string) /= 0 .and. len(buf) > 2) then
            i = index(buf, ':')
            h_key = trim(buf(:i-1))
            h_value = buf(i+2 : )
            h_value = h_value( : len(h_value)-2)
            if(len(h_value) > 0 .and. len(h_key) > 0) then
                call response%header%set(key(h_key), value=h_value)
            end if
        end if
        response%header_string = response%header_string // buf
        deallocate (buf)
        ! Return number of received bytes.
        client_header_callback = nmemb

    end function client_header_callback
      
end module http_client
