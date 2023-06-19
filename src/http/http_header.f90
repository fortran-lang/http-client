module http_header

    !! This module provides a simple key value type to use for HTTP headers.
    !! It also provides procedures to inquire about the presence of a key and
    !! its value in a header array, as well as a procedure to append new
    !! headers to an existing array of headers.

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

    subroutine append_header(header, key, value)
        !! Append a new header_type instance with key and value members to the
        !! header array.
        type(header_type), allocatable, intent(inout) :: header(:)
            !! Header array to append to
        character(*), intent(in) :: key
            !! Key member of header_type to append
        character(*), intent(in) :: value
            !! Value member of header_type to append
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

    pure function get_header_value(header, key) result(val)
        !! Return the value of a requested key in a header array. If the key is
        !! not found, the function returns an empty string (unallocated). If
        !! there are duplicates of the key in the header array, return the value
        !! of the first occurence of the key.
        type(header_type), intent(in) :: header(:)
            !! Header to search for key
        character(*), intent(in) :: key
            !! Key to search in header
        character(:), allocatable :: val
            !! Value of the key to return
        integer :: n

        do n = 1, size(header)
            if (to_lower(key) == to_lower(header(n)%key)) then
                val = header(n)%value
                return
            end if
        end do

    end function get_header_value

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