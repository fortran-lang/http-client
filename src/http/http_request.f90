module http_request

    !! This module contains the definition of a request_type derived type, which 
    !! represents an HTTP request.

    use http_form , only: form_type
    use http_header, only: header_type
    use stdlib_string_type, only: string_type, to_lower, operator(==), char

    implicit none

    private
    public :: HTTP_DELETE, HTTP_GET, HTTP_HEAD, HTTP_PATCH, HTTP_POST, HTTP_PUT
    public :: request_type

    ! HTTP methods:
    ! An integer parameter representing the HTTP GET method.
    integer, parameter :: HTTP_GET = 1
    ! An integer parameter representing the HTTP HEAD method.
    integer, parameter :: HTTP_HEAD = 2
    ! An integer parameter representing the HTTP POST method.
    integer, parameter :: HTTP_POST = 3
    ! An integer parameter representing the HTTP PUT method.
    integer, parameter :: HTTP_PUT = 4
    ! An integer parameter representing the HTTP DELETE method.
    integer, parameter :: HTTP_DELETE = 5
    ! An integer parameter representing the HTTP PATCH method.
    integer, parameter :: HTTP_PATCH = 6

    ! Request Type
    type :: request_type
    !! A derived type representing an HTTP request.
        character(len=:), allocatable :: url, data, form_encoded_str
            !!  url: a character allocatable component representing the URL of the request.
            !! data: a character allocatable component representing the request data.
            !! form_encoded_str: a character allocatable component representing the URL-encoded form data.
        integer :: method
            !! an integer component representing the HTTP method of the request.
        type(header_type), allocatable :: header(:)
            !! an allocatable array of header_type derived types representing the request headers.
        type(form_type), allocatable :: form(:)
            !! an allocatable array of form_type derived types representing the fields of an HTTP form.
    end type request_type
end module http_request
