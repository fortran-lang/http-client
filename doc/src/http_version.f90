
!!>  This file provides details about the **`version number`** of the package.

module http_version

    !!> This module store information regarding **`version`**
    !!> number of package

    integer, parameter, public :: VERSION_MAJOR = 0
        !! major version number
    integer, parameter, public :: VERSION_MINOR = 1
        !! minor version number
    character(len=*), parameter, public :: VERSION_STRING = achar(VERSION_MAJOR + 48) // '.' // achar(VERSION_MINOR + 48)
        !! string representation of version number
    
end module http_version