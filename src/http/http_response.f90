module http_response
    use, intrinsic :: iso_c_binding, only : c_size_t
    implicit none
      ! Response Type
    type, public :: response_type
        character(len=:), public, allocatable :: url,content,method,err_msg
        integer, public :: status_code = 0
        integer(kind=8), public :: content_length = 0
        logical, public :: ok = .true.
    end type response_type    
end module http_response