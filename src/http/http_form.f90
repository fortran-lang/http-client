module http_form
    !! This module contains the definition of a form_type derived type, which represents a 
    !!single field of an HTTP form.
    implicit none
    private
    public :: form_type

    type :: form_type
    !! A derived type representing a single field of an HTTP form.
        character(:), allocatable :: name
        !! The name of the form field 
        character(:), allocatable :: value
        !! The value of the form filed
    end type form_type
end module http_form