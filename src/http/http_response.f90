module http_response
    use, intrinsic :: iso_fortran_env, only: int64
    use fhash, only: fhash_tbl_t, key => fhash_key

    implicit none

    private
    public :: response_type

    ! Response Type
    type :: response_type
        character(len=:), allocatable :: url, content, method, err_msg, header_string
        integer :: status_code = 0
        integer(kind=int64) :: content_length = 0
        logical :: ok = .true.
        type(fhash_tbl_t) :: header
    end type response_type

end module http_response
