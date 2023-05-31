module http_response
    use, intrinsic :: iso_c_binding, only : c_size_t
    use fhash, only: fhash_tbl_t, key => fhash_key

    implicit none

    private
    public :: response_type

    ! Response Type
    type :: response_type
        character(len=:), public, allocatable :: url, content, method, err_msg, header_string
        integer, public :: status_code = 0
        integer(kind=c_long), public :: content_length = 0
        logical, public :: ok = .true.
        type(fhash_tbl_t) :: header
    end type response_type

end module http_response
