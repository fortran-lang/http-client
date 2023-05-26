module http_response
    use, intrinsic :: iso_c_binding, only : c_size_t
    implicit none
    
    ! Response Type
    type, public :: response_type
        character(len=:), public, allocatable :: content
        character(len=:), public, allocatable :: url
        character(len=:), public, allocatable :: method
        integer, public :: status_code
        integer(kind=c_size_t), public:: content_length = 0 
    end type response_type
    
end module http_response