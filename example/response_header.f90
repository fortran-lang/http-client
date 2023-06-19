program response_header
    ! This program demonstrates sending user-provided headers in a GET request
    ! and iterating over the headers of the response sent back by the server.
    use stdlib_string_type, only: string_type, write(formatted)
    use http, only: response_type, request, header_type
    
    implicit none
    type(response_type) :: response
    type(header_type), allocatable :: header(:), req_header(:)
    character(:), allocatable :: val
    integer :: i = 0

    req_header = [ &
      header_type('Another-One', 'Hello'), &
      header_type('Set-Cookie', 'Theme-Light'), &
      header_type('Set-Cookie', 'Auth-Token: 12345'), &
      header_type('User-Agent', 'my user agent') &
      ]

    response = request(url='https://httpbin.org/get', header=req_header)

    if (.not. response%ok) then
        print *,'Error message : ', response%err_msg
    else
        print*, '::::::::::::::::: Request send by us :::::::::::::::::'
        print *, response%content
        print*, '::::::::::::::::: Fetching all response header :::::::::::::::::'
        header = response%header
        ! Iterate over response headers.
        do i = 1, size(header)
            print *, header(i)%key, ': ', header(i)%value
        end do

        ! getting header value by header name
        print*, '::::::::::::::::: Fetching individual response header by name :::::::::::::::::'
        print *, 'Content-Type: ', response%header_value('Content-Type')
    end if
end program response_header
