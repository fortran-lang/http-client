module http_header
    use iso_c_binding
    use stdlib_string_type, only: string_type, to_lower, operator(==), char

    implicit none
    private
    
    public :: header_type
    public :: get_header_value
    public :: put_if_header_absent
    public :: append_header
    
    type :: header_type
        character(:), allocatable :: key, value
    end type header_type

contains
    ! The get_header_value function takes a key string as input and returns the corresponding 
    ! value as a string from a response_type object's header array, which contains key-value 
    ! pairs representing HTTP headers. If the key is not found, the function returns an empty
    !  string. If there are duplicates of the key in the header array, the function returns 
    ! the value associated with the first occurrence of the key.
    pure function get_header_value(header, key) result(val)
        type(header_type), allocatable, intent(in) :: header(:)
        character(*), intent(in) :: key
        character(:), allocatable :: val
        type(string_type) :: string_to_match
        integer :: i

        string_to_match = to_lower(string_type(key))
        do i=1, size(header)
            if(to_lower(string_type(header(i)%key)) == string_to_match) then
                val = header(i)%value
                return
            end if
        end do
    end function get_header_value

    ! This procedure adds the header only if it does not already exist 
    ! in the current header array. It is typically used internally to 
    ! add default headers.
    subroutine put_if_header_absent(header, key, value)
        type(header_type), allocatable, intent(inout) :: header(:)
        character(*), intent(in) :: key, value
        integer :: i
        type(string_type) :: original_key, key_to_match 
        
        original_key = to_lower(string_type(key))
        do i=1, size(header)
            key_to_match = to_lower(string_type(header(i)%key))
            if(key_to_match == original_key) then
                return
            end if
        end do
        call append_header(header, key, value)  
    end subroutine put_if_header_absent

    ! This subroutine appends a new header_type object to the header array.
    subroutine append_header(header, key, value)
        type(header_type), allocatable, intent(inout) :: header(:)
        character(*), intent(in) :: key, value
        type(header_type), allocatable :: temp(:)
        integer :: n

        if (allocated(header)) then
            n = size(header)
            allocate(temp(n+1))
            temp(1:n) = header
            temp(n+1) = header_type(key, value)
            call move_alloc(temp, header)
        else
            allocate(header(1))
            header(1) = header_type(key, value)
        end if
    end subroutine append_header

end module http_header