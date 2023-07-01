module http_pair

    !! This module provides a simple name-value type to use for HTTP Header, Form, File.
    !! It also provides procedures to inquire about the presence of a name and
    !! its value in a pair array, as well as a procedure to append new
    !! pairs to an existing array of pairs.

    use stdlib_ascii, only: to_lower

    implicit none
    private
    
    public :: pair_type
    public :: append_pair
    public :: get_pair_value
    public :: pair_has_name
    
    type :: pair_type
        !! A derived type use to store a name-value pair, it is 
        !! use in many instances like : 
        !! 1. To store request and response headers. 
        !!  * `name` represent the header name.
        !!  * `value` represent the header value. 
        !! 2. While sending Form data, it represent a single a single field 
        !!    of an HTTP form.
        !!  * `name` represents the name of the single form field.
        !!  * `value` represents the value of that single form field.
        !! 3. While sending File, it is used to store information about 
        !!    files to be sent.
        !!  * `name` represent the name of the file.
        !!  * `value` represent the path of the file on the local system. 
        character(:), allocatable :: name
            !! represent the name of the pair.
        character(:), allocatable :: value
            !! represent the value of the pair.
    end type pair_type

contains

    subroutine append_pair(pair, name, value)
        !! Append a new pair_type instance with name and value members to
        !! the pair array.
        type(pair_type), allocatable, intent(inout) :: pair(:)
            !! pair array to append to
        character(*), intent(in) :: name
            !! name member of pair_type to append
        character(*), intent(in) :: value
            !! Value member of pair_type to append
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
        !! Return the value of a requested name in a pair array. If the name is
        !! not found, the function returns an empty string (unallocated). If
        !! there are duplicates of the name in the pair array, return the value
        !! of the first occurence of the name.
        type(pair_type), intent(in) :: pair(:)
            !! pair to search for name
        character(*), intent(in) :: name
            !! name to search in pair
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
            !! pair to search for name
        character(*), intent(in) :: name
            !! name to search in pair
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