module http_response

    !! This module contains the definition of a response_type derived type, which 
    !! represents an HTTP response.

    use, intrinsic :: iso_fortran_env, only: int64
    use http_header, only: header_type, get_header_value
    use stdlib_string_type, only: string_type, to_lower, operator(==), char

    implicit none

    private
    public :: response_type

    ! Response Type
    type :: response_type
        character(len=:), allocatable :: url, content, method, err_msg
            !! url: a character allocatable component representing the URL of the request that generated the response.
            !! method: a character allocatable component representing the HTTP method used in the request.
            !! content: a character allocatable component representing the content of the response.
            !! err_msg: a character allocatable component representing an error message if the response was not successful.
        integer :: status_code = 0
            !! An integer component representing the HTTP status code of the response
        integer(kind=int64) :: content_length = 0
            !! An integer component representing the length of the response content.
        logical :: ok = .true.
            !! A logical component that is true if the response was successful else false.
        type(header_type), allocatable :: header(:)
            !! An allocatable array of header_type derived types representing the response headers.
    contains
        procedure :: header_value
    end type response_type

contains
    ! The header_value function takes a key string as input and returns the corresponding 
    ! value as a string from a response_type object's header array.
    pure function header_value(this, key) result(val)
        class(response_type), intent(in) :: this
        character(*), intent(in) :: key
        character(:), allocatable :: val
        
        val = get_header_value(this%header, key)
    end function header_value
    
end module http_response
