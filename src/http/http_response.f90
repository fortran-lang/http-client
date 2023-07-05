module http_response

    !! This module contains the definition of a response_type derived type, which 
    !! represents an HTTP response.

    use, intrinsic :: iso_fortran_env, only: int64
    use http_pair, only: pair_type, get_pair_value
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
        type(pair_type), allocatable :: header(:)
            !! An Array of response headers.
    contains
        procedure :: header_value
    end type response_type

contains
    pure function header_value(this, name) result(val)
        !! The header_value function takes a header name string as input and returns 
        !! the corresponding value as a string from a response_type object's 
        !! header array.
        class(response_type), intent(in) :: this
            !! An object representing the HTTP response.
        character(*), intent(in) :: name
            !! The name of the header value to be retrieved.
        character(:), allocatable :: val
            !! The value of the specified name in the HTTP response header.
        
        val = get_pair_value(this%header, name)
    end function header_value
    
end module http_response
