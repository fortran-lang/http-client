program response_header
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

    response = request(url='https://reqres.in/api/users/1', header=req_header)

    if(.not. response%ok) then
        print *,'Error message : ', response%err_msg
    else
       header = response%header
       do i = 1, size(header)
        print *, header(i)%key, ': ', header(i)%value
       end do
    end if
end program response_header