module http_request
    use http_header, only: header_type
    use stdlib_string_type, only: string_type, to_lower, operator(==), char

    implicit none

    private
    public :: HTTP_DELETE, HTTP_GET, HTTP_HEAD, HTTP_PATCH, HTTP_POST, HTTP_PUT
    public :: request_type

    ! HTTP methods:
    integer, parameter :: HTTP_GET = 1
    integer, parameter :: HTTP_HEAD = 2
    integer, parameter :: HTTP_POST = 3
    integer, parameter :: HTTP_PUT = 4
    integer, parameter :: HTTP_DELETE = 5
    integer, parameter :: HTTP_PATCH = 6

    ! Request Type
    type :: request_type
        character(len=:), allocatable :: url
        integer :: method
        type(header_type), allocatable :: header(:)
    end type request_type
end module http_request
