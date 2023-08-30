
!!> This file defines the **`request_type`** derived type, which 
!!> represents an **HTTP request**.

module http_request

    !!> This module defines the **`request_type`** derived type, which 
    !!> represents an **HTTP request**.

    use iso_fortran_env, only: int64
    use http_pair, only: pair_type
    use stdlib_string_type, only: string_type, to_lower, operator(==), char

    implicit none

    private
    public :: HTTP_DELETE, HTTP_GET, HTTP_HEAD, HTTP_PATCH, HTTP_POST, HTTP_PUT
    public :: request_type

    ! HTTP methods:
    integer, parameter :: HTTP_GET = 1
    integer, parameter :: HTTP_HEAD = 2
    integer, parameter :: HTTP_POST = 3
    integer, parameter :: HTTP_PUT = 4
    integer, parameter :: HTTP_DELETE = 5
    integer, parameter :: HTTP_PATCH = 6

    ! Request Type
    type :: request_type
        !! Representing an **HTTP `request`**.
        character(len=:), allocatable :: url
            !! The URL of the request
        character(len=:), allocatable :: data
            !! The data to be send with request
        character(len=:), allocatable :: form_encoded_str
            !! The URL-encoded form data.
        integer :: method
            !! The HTTP method of the request.
        type(pair_type), allocatable :: header(:)
            !! An Array of request headers.
        type(pair_type), allocatable :: form(:)
            !! An array of fields in an HTTP form.
        type(pair_type), allocatable :: file
            !! Used to store information about files to be sent in HTTP requests.
        integer(kind=int64) :: timeout
            !! **`Timeout`** value for the request in **seconds**.
        type(pair_type), allocatable :: auth
            !! Stores the username and password for Authentication
    end type request_type
end module http_request
