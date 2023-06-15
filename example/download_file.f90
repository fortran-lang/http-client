program download_file
    ! This program demonstrates using a GET request to download a file.
    use http, only: response_type, request
    use stdlib_io, only: open
    implicit none
    type(response_type) :: response
    integer :: file

    response = request('https://avatars.githubusercontent.com/u/53436240')

    if (response%ok) then
        file = open('fortran-lang.png', 'wb')
        write(file) response%content
        close(file)
    else
        error stop response%err_msg
    end if

end program download_file
