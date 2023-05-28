module http_response
    use, intrinsic :: iso_c_binding, only : c_size_t
    implicit none
      ! Response Type
    type, public :: response_type
        character(len=:), allocatable :: url,content,method,err_msg
        integer :: status_code = 0
        integer(kind=c_size_t) :: content_length = 0
        logical :: ok = .true.
    end type response_type
contains
    
end module http_response