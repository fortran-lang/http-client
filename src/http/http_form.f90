module http_form
    !! This module contains the definition of a form_type derived type, which represents a 
    !!single field of an HTTP form.
    implicit none
    private
    public :: form_type

    type :: form_type
    !! A derived type representing a single field of an HTTP form.
        character(:), allocatable :: name, value
        !! The form_type derived type contains two character allocatable components: name and value. 
        !! The name component represents the name of the field, while the value component represents 
        !! the value of the field.
    end type form_type
end module http_form