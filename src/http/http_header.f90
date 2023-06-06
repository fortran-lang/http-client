module http_header
    use iso_c_binding
    use fhash, only: fhash_tbl_t, key => fhash_key, fhash_iter_t, fhash_key_t
    use stdlib_string_type
    ! use curl
    implicit none
    private
    public :: header_type
    type :: header_type
        type(fhash_tbl_t), private :: header
        type(string_type), private, allocatable :: header_key(:)
        integer :: header_count = 0
    contains
        procedure :: set_header_key
        procedure :: keys => get_header_keys
        procedure :: header_string_type_key
        procedure :: header_char_key
        generic :: value => header_string_type_key, header_char_key
        procedure :: set => update_header
    end type header_type
contains
    subroutine update_header(this, h_key, h_val)
        class(header_type), intent(inout) :: this
        character(*), intent(in) :: h_key, h_val
        if(len_trim(h_key) > 0 .and.  len_trim(h_val) > 0) then
            call this%header%set(key(h_key), value=h_val)
            this%header_count = this%header_count + 1
        end if
    end subroutine update_header

    subroutine set_header_key(this)
        class(header_type), intent(inout) :: this
        type(fhash_iter_t) :: iter
        class(fhash_key_t), allocatable :: ikey
        class(*), allocatable :: idata
        character(:), allocatable :: val
        integer :: i
        i = 1
        allocate(this%header_key(this%header_count))
        iter = fhash_iter_t(this%header)
        do while(iter%next(ikey,idata) .and. i <= this%header_count)
            this%header_key(i) = string_type(trim(ikey%to_string()))
            i = i + 1
        end do
    end subroutine set_header_key

    function get_header_keys(this) 
        class(header_type), intent(in) :: this
        type(string_type), allocatable :: get_header_keys(:)
        get_header_keys = this%header_key
    end function get_header_keys

    function header_string_type_key(this, h_key) result(header_value)
        class(header_type) :: this
        type(string_type) :: h_key
        character(:), allocatable :: header_value
        if(len(h_key) > 0) then
            call this%header%get(key(char(h_key)),header_value)
        else
            header_value = ''
        end if
    end function header_string_type_key

    function header_char_key(this, h_key) result(header_value)
        class(header_type) :: this
        character(*) :: h_key
        character(:), allocatable :: header_value
        if(len(h_key) > 0) then
            call this%header%get(key(h_key),header_value)
        else
            header_value = ''
        end if
    end function header_char_key


end module http_header