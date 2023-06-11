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
    contains
        procedure :: append_header
    end type response_type

contains
    subroutine append_header(this, key, value)
        class(response_type), intent(inout) :: this
        character(*), intent(in) :: key, value
        type(header_type), allocatable :: temp(:)
        integer :: n
    
        if (allocated(this%header)) then
            n = size(this%header)
            allocate(temp(n+1))
            temp(1:n) = this%header
            temp(n+1) = header_type(key, value)
            call move_alloc(temp, this%header)
        else
            allocate(this%header(1))
            this%header(1) = header_type(key, value)
        end if
    
    end subroutine append_header
  

end module http_response
