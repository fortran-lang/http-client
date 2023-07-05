module http_pair

    !! This module provides a simple name-value type to use for HTTP Header,
    !! Form, and File. It also provides procedures to inquire about the presence
    !! of a name and its value in a pair array, as well as a procedure to append
    !! new pairs to an existing array of pairs.

    use stdlib_ascii, only: to_lower

    implicit none
    private
    
    public :: pair_type
    public :: append_pair
    public :: get_pair_value
    public :: pair_has_name
    
    type :: pair_type
        !! A derived type use to store a name-value pair, it is used in many
        !! instances like:
        !! 1. Storing request and response headers:
        !!  * `name` to represent the header name.
        !!  * `value` to represent the header value.
        !! 2. Representing fields in a url-encoded HTTP form:
        !!  * `name` to represent the form field name.
        !!  * `value` to represent the form field value.
        !! 3. Storing information about the file to upload:
        !!  * `name` to represent the name of the file.
        !!  * `value` to represent the path of the file on the local system.
        character(:), allocatable :: name
            !! Name (key)
        character(:), allocatable :: value
            !! Value
    end type pair_type

contains

    subroutine append_pair(pair, name, value)
        !! Append a new `pair_type` instance with name and value members to
        !! the pair array.
        type(pair_type), allocatable, intent(inout) :: pair(:)
            !! `pair_type` array to append to
        character(*), intent(in) :: name
            !! Name member of `pair_type` to append
        character(*), intent(in) :: value
            !! Value member of `pair_type` to append
        type(pair_type), allocatable :: temp(:)
        integer :: n

        if (allocated(pair)) then
            n = size(pair)
            allocate(temp(n+1))
            temp(1:n) = pair
            temp(n+1) = pair_type(name, value)
            call move_alloc(temp, pair)
        else
            allocate(pair(1))
            pair(1) = pair_type(name, value)
        end if
    end subroutine append_pair

    pure function get_pair_value(pair, name) result(val)
        !! Return the value of a requested name in a pair array.
        !! The search for the pair by its name is case-insensitive.
        !! If the name is not found, the function returns an unallocated string.
        !! If there are duplicates of the name in the pair array, return the
        !! value of the first occurence of the name.
        type(pair_type), intent(in) :: pair(:)
            !! Pair to search for name
        character(*), intent(in) :: name
            !! Name to search in pair
        character(:), allocatable :: val
            !! Value of the name to return
        integer :: n

        do n = 1, size(pair)
            if (to_lower(name) == to_lower(pair(n)%name)) then
                val = pair(n)%value
                return
            end if
        end do

    end function get_pair_value

    pure logical function pair_has_name(pair, name)
        !! Return .true. if name is present in pair, .false. otherwise.
        !! HTTP pairs are case insensitive, so values are converted to
        !! lowercase before comparison.
        type(pair_type), intent(in) :: pair(:)
            !! Pair to search for name
        character(*), intent(in) :: name
            !! Name to search in pair
        integer :: n

        pair_has_name = .false.
        do n = 1, size(pair)
            if (to_lower(name) == to_lower(pair(n)%name)) then
                pair_has_name = .true.
                return
            end if
        end do

    end function pair_has_name

end module http_pair