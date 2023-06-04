module http_header
    use iso_c_binding
    use curl
    implicit none
    private
    public :: header_type
    type :: header_type
        type(c_ptr) :: header_list_ptr = c_null_ptr
        integer :: header_count = 0
    contains
        procedure :: set_header
    end type header_type
contains
    subroutine set_header(this, h_key, h_val)
        class(header_type), intent(inout) :: this
        character(*), intent(in) :: h_key, h_val
        character(:), allocatable :: final_header_string

        final_header_string = h_key // ':' // h_val // c_null_char
        this%header_list_ptr = curl_slist_append(this%header_list_ptr, final_header_string)
        this%header_count = this%header_count + 1
    end subroutine set_header
end module http_header