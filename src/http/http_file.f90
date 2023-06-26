module http_file
    !! The http_file module defines the file_type type, which is used
    !! to store information about files to be sent in HTTP requests.
    implicit none
    private
    public :: file_type

    type :: file_type
        !! A derived type used to store information about files to be 
        !!sent in HTTP requests.
        character(:), allocatable :: name
        !! A character string that contains the name of the file.
        character(:), allocatable :: path
        !! A character string that contains the path of the file 
        !! on the local system.
    end type file_type
end module http_file