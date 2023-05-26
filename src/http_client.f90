module http_client
    use, intrinsic :: iso_c_binding
    use, intrinsic :: iso_fortran_env, only: i4 => int32, i8 => int64, r4 => real32, r8 => real64
    use curl
    use request_type
    use response_type
    implicit none

    ! http_client Type
    type :: client_type
        type(request_type) :: request
    contains
        procedure :: client_get_response 
    end type client_type

    interface client_type
        module procedure new_client
    end interface client_type

contains
    ! Constructor for client_type type.
    function new_client(request) result(client)
        type(client_type) :: client
        type(request_type) :: request

        client%request = request
    end function new_client

    function client_get_response(this) result(response)
        class(client_type) :: this
        type(response_type), target :: response
        type(c_ptr) :: curl_ptr
        integer :: rc
        ! logic for populating response using fortran-curl
        response%url = this%request%url
        response%method = this%request%method
    
        curl_ptr = curl_easy_init()
    
        if (.not. c_associated(curl_ptr)) then
        stop 'Error: curl_easy_init() failed'
        end if
        ! setting request URL
        rc = curl_easy_setopt(curl_ptr, CURLOPT_URL, this%request%url // c_null_char)
        ! setting request method
        rc = curl_easy_setopt(curl_ptr, CURLOPT_CUSTOMREQUEST, this%request%method // c_null_char)
        ! setting callback for writing received data
        rc = curl_easy_setopt(curl_ptr, CURLOPT_WRITEFUNCTION, c_funloc(client_response_callback))
        ! setting response pointer to write callback
        rc = curl_easy_setopt(curl_ptr, CURLOPT_WRITEDATA, c_loc(response))
    
        ! Send request.
        rc = curl_easy_perform(curl_ptr)
        
        if (rc /= CURLE_OK) then
        print '(a)', 'Error: curl_easy_perform() failed'
        stop
        end if
        ! setting response status_code
        rc = curl_easy_getinfo(curl_ptr, CURLINFO_RESPONSE_CODE, response%status_code)  
        call curl_easy_cleanup(curl_ptr)
    
    end function client_get_response
    
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

end module http_client