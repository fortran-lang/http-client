
!!> This file contains the **`pair_type`** derived type, designed to 
!!> store various details like `headers`, `file` information, `form-data`, 
!!> and `authentication` details.

module http_pair

    !!> This module contains the **`pair_type`** derived type, designed to 
    !!> store various details like `headers`, `file` information, `form-data`, 
    !!> and `authentication` details.

    use stdlib_ascii, only: to_lower

    implicit none
    private
    
    public :: pair_type
    public :: append_pair
    public :: get_pair_value
    public :: pair_has_name
    
    type :: pair_type
        !!> A derived type use to store a **name-value pair**.
        !!>____
        !!>It is used in many instances like:
        !!> 
        !!>1. Storing request and response `headers`:
        !!>     - `name` to represent the header name.
        !!>     - `value` to represent the header value.
        !!> 
        !!>2. Representing fields in a url-encoded **HTTP `form`**:
        !!>     - `name` to represent the form field name.
        !!>     - `value` to represent the form field value.
        !!> 
        !!>3. Storing information about the `file` to upload:
        !!>     - `name` to represent the name of the file.
        !!>     - `value` to represent the path of the file on the local system.
        !!> 
        !!>4. Storing authentication detail, require to authenticate the request.
        !!>     - `name` to represent the **username**
        !!>     - `value` to represent the **password**

        character(:), allocatable :: name
            !! Name (key)
        character(:), allocatable :: value
            !! Value
    end type pair_type

contains

    subroutine append_pair(pair, name, value)
        
        !!> Appends a new `pair_type` instance with the provided `name` 
        !!> and `value` into the given `pair_type array`(i.e pair).

        type(pair_type), allocatable, intent(inout) :: pair(:)
            !! An array of `pair_type` objects, to which a new instance of `pair_type` needs to be added.
        character(*), intent(in) :: name
            !! The `name` attribute of the `pair_type` to be added.
        character(*), intent(in) :: value
            !! The `value` attribute of the `pair_type` to be added.
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

    pure function get_pair_value(pair_arr, name) result(val)
    
        !!> The function retrieves the `value` associated with a specified 
        !!> `name` from the passed array of `pair_type` objects (i.e., pair_arr). 
        !!> The search for the `name` is **case-insensitive**. If the `name` is 
        !!> not found, the function returns an **unallocated string**. In the case 
        !!> of duplicate `name` entries in the `pair_arr`, the function returns the 
        !!> `value` of the **first occurrence** of the `name`.

        type(pair_type), intent(in) :: pair_arr(:)
            !! The array in which we want to find a `pair_type` instance with its 
            !! `name` attribute equal to the given `name`.
        character(*), intent(in) :: name
            !! The `name` to be searched in the `pair_arr`.
        character(:), allocatable :: val
            !! Stores the `value` of the corresponding `pair_type` object whose `name`  
            !! attribute is equal to the given `name`.
        integer :: n

        do n = 1, size(pair_arr)
            if (to_lower(name) == to_lower(pair_arr(n)%name)) then
                val = pair_arr(n)%value
                return
            end if
        end do

    end function get_pair_value

    pure logical function pair_has_name(pair_arr, name)
        !!> Return `.true.` if there exists a `pair_type` object inside `pair_arr` with 
        !!> a `name` attribute equal to the provided `name`; otherwise, return `.false.`. 
        !!> HTTP pairs are **case-insensitive**, implying that values are **converted to 
        !!> lowercase** before the comparison is performed.

        type(pair_type), intent(in) :: pair_arr(:)
            !! The array in which we want to find a `pair_type` instance with its 
            !! `name` attribute equal to the given `name`.
        character(*), intent(in) :: name
            !! The `name` to be searched in the `pair_arr`.
        integer :: n

        pair_has_name = .false.
        do n = 1, size(pair_arr)
            if (to_lower(name) == to_lower(pair_arr(n)%name)) then
                pair_has_name = .true.
                return
            end if
        end do

    end function pair_has_name

end module http_pair