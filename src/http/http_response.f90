module http_response
    use, intrinsic :: iso_fortran_env, only: int64
    use fhash, only: fhash_tbl_t, key => fhash_key, fhash_iter_t, fhash_key_t
    use stdlib_string_type
    implicit none

    private
    public :: response_type

    ! Response Type
    type :: response_type
        character(len=:), allocatable :: url, content, method, err_msg
        integer :: status_code = 0
        integer(kind=int64) :: content_length = 0
        logical :: ok = .true.
        type(fhash_tbl_t), private :: header_fhash
        type(string_type), private, allocatable :: header_key(:)
        integer, private :: header_count = 0
        
    contains
        procedure :: set_header_key
        procedure :: header_keys
        procedure :: header_string_type_key
        procedure :: header_char_key
        generic :: header_value => header_string_type_key, header_char_key
        procedure :: update_header_fhash
    end type response_type
    
contains
    
    subroutine update_header_fhash(this, h_key, h_val)
        class(response_type), intent(inout) :: this
        character(:), intent(in), allocatable :: h_key, h_val
        call this%header_fhash%set(key(h_key), value=h_val)
        this%header_count = this%header_count + 1
    end subroutine update_header_fhash

    subroutine set_header_key(this)
        class(response_type), intent(inout) :: this
        type(fhash_iter_t) :: iter
        class(fhash_key_t), allocatable :: ikey
        class(*), allocatable :: idata
        character(:), allocatable :: val
        integer :: i = 1
        allocate(this%header_key(this%header_count))
        iter = fhash_iter_t(this%header_fhash)
        do while(iter%next(ikey,idata))
            this%header_key(i) = trim(ikey%to_string())
            i = i + 1
        end do
    end subroutine set_header_key

    function header_keys(this) 
        class(response_type), intent(in) :: this
        type(string_type), allocatable :: header_keys(:)
        header_keys = this%header_key
    end function header_keys

    function header_string_type_key(this, h_key) result(header_value)
        class(response_type) :: this
        type(string_type) :: h_key
        character(:), allocatable :: header_value
        if(len(h_key) /= 0) then
            call this%header_fhash%get(key(char(h_key)),header_value)
        else
            header_value = ''
        end if
    end function header_string_type_key

    function header_char_key(this, h_key) result(header_value)
        class(response_type) :: this
        character(*) :: h_key
        character(:), allocatable :: header_value
        if(len(h_key) /= 0) then
            call this%header_fhash%get(key(h_key),header_value)
        else
            header_value = ''
        end if
    end function header_char_key

end module http_response
