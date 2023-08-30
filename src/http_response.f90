
!!> This file defines the **`response_type`** derived type, which 
!!> represents an **HTTP response** from a web server.

module http_response

    !!> This module defines the **`response_type`** derived type, which 
    !!> represents an **HTTP response** from a web server.

    use, intrinsic :: iso_fortran_env, only: int64
    use http_pair, only: pair_type, get_pair_value
    use stdlib_string_type, only: string_type, to_lower, operator(==), char

    implicit none

    private
    public :: response_type

    ! Response Type
    type :: response_type
        !!> Representing an **HTTP `response`**.
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
        
        !!> This function is used to retrieve the `value` of a response header. 
        !!> It takes the response header `name` as input and returns the corresponding 
        !!> **header value**.
        
        class(response_type), intent(in) :: this
            !! An object representing the HTTP response.
        character(*), intent(in) :: name
            !! This refers to the name of the header for which we want to retrieve the value.
        character(:), allocatable :: val
            !! This denotes the value of the specified header name.
        
        val = get_pair_value(this%header, name)
    end function header_value
    
end module http_response
