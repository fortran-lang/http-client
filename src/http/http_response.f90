module http_response
    use, intrinsic :: iso_fortran_env, only: int64
    use http_header, only : header_type, get_header_value
    use stdlib_string_type, only: string_type, to_lower, operator(==), char

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
    contains
        procedure :: header_value
    end type response_type

contains
    ! The header_value function takes a key string as input and returns the corresponding 
    ! value as a string from a response_type object's header array.
    pure function header_value(this, key) result(val)
        class(response_type), intent(in) :: this
        character(*), intent(in) :: key
        character(:), allocatable :: val
        
        val = get_header_value(this%header, key)
    end function header_value
    
end module http_response
