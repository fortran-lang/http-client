program basic_auth
    ! Making request with HTTP Basic Auth
    use http, only: response_type, request, pair_type
    implicit none
    type(response_type) :: response
    type(pair_type) :: auth

    ! setting username and password
    auth = pair_type('user', 'passwd')

    response = request(url='https://httpbin.org/basic-auth/user/passwd', auth=auth)
    if(.not. response%ok) then
        print *,'Error message : ', response%err_msg
    else
        print *, 'Response Code    : ', response%status_code
        print *, 'Response Content : ', response%content
    end if

end program basic_auth
