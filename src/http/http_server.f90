module http_server
    use iso_c_binding
    use curl
    use http_request, only : request_type
    use http_response, only : response_type
    
    implicit none

    ! http_server Type
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

    public :: request

    
contains
    ! Constructor for request_type type.
    function new_request(url, method) result(response)
        character(len=*) :: url
        integer, optional :: method
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
        type(client_type) :: client
        type(request_type) :: request

        client%request = request
    end function new_client

    function client_get_response(this) result(response)
        class(client_type) :: this
        type(response_type), target :: response
        integer :: rc
        ! logic for populating response using fortran-curl
        response%url = this%request%url
        ! response%method = this%request%method
      
        this%curl_ptr = curl_easy_init()
      
        if (.not. c_associated(this%curl_ptr)) then
          stop 'Error: curl_easy_init() failed'
        end if
        ! setting request URL
        rc = curl_easy_setopt(this%curl_ptr, CURLOPT_URL, this%request%url // c_null_char)
        ! setting request method
        rc = this%client_set_method(response)
        ! setting callback for writing received data
        rc = curl_easy_setopt(this%curl_ptr, CURLOPT_WRITEFUNCTION, c_funloc(client_response_callback))
        ! setting response pointer to write callback
        rc = curl_easy_setopt(this%curl_ptr, CURLOPT_WRITEDATA, c_loc(response))
      
        ! Send request.
        rc = curl_easy_perform(this%curl_ptr)
        
        if (rc /= CURLE_OK) then
          print '(a)', 'Error: curl_easy_perform() failed'
          stop
        end if
        ! setting response status_code
        rc = curl_easy_getinfo(this%curl_ptr, CURLINFO_RESPONSE_CODE, response%status_code)  
        call curl_easy_cleanup(this%curl_ptr)
      
    end function client_get_response

    function client_set_method(this,  response) result(status)
        class(client_type) :: this
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
      

end module http_server