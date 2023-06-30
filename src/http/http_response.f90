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
    !! Representing an HTTP response.
        character(len=:), allocatable :: url
            !! The URL of the request
        character(len=:), allocatable :: content
            !! The content of the response.
        character(len=:), allocatable :: method
            !! The HTTP method of the request.
        character(len=:), allocatable :: err_msg
            !! The Error message if the response was not successful.
        integer :: status_code = 0
            !! The HTTP status code of the response
        integer(kind=int64) :: content_length = 0
            !! length of the response content.
        logical :: ok = .true.
            !! true if the response was successful else false.
        type(header_type), allocatable :: header(:)
            !! An Array of response headers.
    contains
        procedure :: header_value
    end type response_type

contains
    pure function header_value(this, key) result(val)
        !! The header_value function takes a key string as input and returns 
        !! the corresponding value as a string from a response_type object's 
        !! header array.
        class(response_type), intent(in) :: this
            !! An object representing the HTTP response.
        character(*), intent(in) :: key
            !! The key of the header value to be retrieved.
        character(:), allocatable :: val
            !! The value of the specified key in the HTTP response header.
        
        val = get_header_value(this%header, key)
    end function header_value
    
end module http_response
