module http_header

    use stdlib_ascii, only: to_lower

    implicit none
    private
    
    public :: header_type
    public :: append_header
    public :: get_header_value
    public :: header_has_key
    
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
        type(header_type), intent(in) :: header(:)
        character(*), intent(in) :: key
        character(:), allocatable :: val
        integer :: n

        do n = 1, size(header)
            if (to_lower(key) == to_lower(header(n)%key)) then
                val = header(n)%value
                return
            end if
        end do

    end function get_header_value

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

    pure logical function header_has_key(header, key)
        !! Return .true. if key is present in header, .false. otherwise.
        !! HTTP headers are case insensitive, so values are converted to
        !! lowercase before comparison.
        type(header_type), intent(in) :: header(:)
          !! Header to search for key
        character(*), intent(in) :: key
          !! Key to search in header
        integer :: n

        header_has_key = .false.
        do n = 1, size(header)
            if (to_lower(key) == to_lower(header(n)%key)) then
                header_has_key = .true.
                return
            end if
        end do

    end function header_has_key

end module http_header