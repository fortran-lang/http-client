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
        type(header_type) :: header
        ! type(fhash_tbl_t), private :: header_fhash
        ! type(string_type), private, allocatable :: header_key(:)
        ! integer, private :: header_count = 0
        
    ! contains
    !     procedure :: set_header_key
    !     procedure :: header_keys
    !     procedure :: header_string_type_key
    !     procedure :: header_char_key
    !     generic :: header_value => header_string_type_key, header_char_key
    !     procedure :: update_header_fhash
    end type response_type

end module http_response
