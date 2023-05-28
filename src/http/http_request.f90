module http_request
    implicit none
    private
    ! HTTP methods:
    integer, parameter, public :: HTTP_GET = 1
    integer, parameter, public :: HTTP_HEAD = 2
    integer, parameter, public :: HTTP_POST = 3
    integer, parameter, public :: HTTP_PUT = 4
    integer, parameter, public :: HTTP_DELETE = 5
    integer, parameter, public :: HTTP_PATCH = 6
    ! Request Type
    type, public :: request_type
        character(len=:), allocatable :: url
        integer :: method
    end type request_type

end module http_request