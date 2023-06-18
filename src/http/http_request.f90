module http_request
    use http_header, only : header_type
    use stdlib_string_type, only: string_type, to_lower, operator(==), char

    implicit none

    private
    public :: HTTP_DELETE, HTTP_GET, HTTP_HEAD, HTTP_PATCH, HTTP_POST, HTTP_PUT
    public :: request_type

    ! HTTP methods:
    integer, parameter :: HTTP_GET = 1
    integer, parameter :: HTTP_HEAD = 2
    integer, parameter :: HTTP_POST = 3
    integer, parameter :: HTTP_PUT = 4
    integer, parameter :: HTTP_DELETE = 5
    integer, parameter :: HTTP_PATCH = 6

    ! Request Type
    type :: request_type
        character(len=:), allocatable :: url
        integer :: method
        type(header_type), allocatable :: header(:)
    contains
        procedure :: put_if_header_absent
        procedure :: append_header
    end type request_type

contains
    ! This procedure adds the header only if it does not already exist 
    ! in the current header array. It is typically used internally to 
    ! add default headers.
    subroutine put_if_header_absent(this, key, value)
        class(request_type), intent(inout) :: this
        character(*), intent(in) :: key, value
        integer :: i
        type(string_type) :: original_key, key_to_match 
        
        original_key = to_lower(string_type(key))

        do i=1, size(this%header)
            key_to_match = to_lower(string_type(this%header(i)%key))
            if(key_to_match == original_key) then
                return
            end if
        end do

        call this%append_header(key, value)  
    end subroutine put_if_header_absent

    subroutine append_header(this, key, value)
        class(request_type), intent(inout) :: this
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

end module http_request
