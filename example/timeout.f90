program timeout

    use http, only: response_type, request
    implicit none
    type(response_type) :: response

    ! Delay in response for 10 seconds
    response = request(url='https://httpbin.org/delay/10', timeout=5)
    if(.not. response%ok) then
        print *,'Error message : ', response%err_msg
    else
        print *, 'Response Code    : ', response%status_code
        print *, 'Response Length  : ', response%content_length
        print *, 'Response Method  : ', response%method
        print *, 'Response Content : ', response%content
    end if

end program timeout
