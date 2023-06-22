module http_form
    implicit none
    private
    public :: form_type

    type :: form_type
        character(:), allocatable :: name, value
    end type form_type
end module http_form