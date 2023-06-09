module http_response
    use, intrinsic :: iso_fortran_env, only: int64
    use http_header, only : header_type
    implicit none

    private
    public :: response_type

    ! Response Type
    type :: response_type
        character(len=:), allocatable :: url, content, method, err_msg
        integer :: status_code = 0
        integer(kind=int64) :: content_length = 0
        logical :: ok = .true.
        type(header_type), allocatable :: header(:)
    end type response_type

end module http_response
