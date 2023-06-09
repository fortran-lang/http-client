module http_header
    use iso_c_binding
    implicit none
    private
    public :: header_type
    type :: header_type
        character(:), allocatable :: key, value
    end type header_type
end module http_header