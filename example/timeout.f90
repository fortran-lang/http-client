program timeout
    ! This program demonstrates the use of the timeout option. The request below is designed
    ! to take more than 10 seconds to complete, but we set the timeout value to 5 seconds.
    ! As a result, the request will fail with an error message that says "Timeout was reached".
    use http, only: response_type, request
    implicit none
    type(response_type) :: response

    ! Delay in response for 10 seconds
    response = request(url='https://httpbin.org/delay/10', timeout=5)
    if(.not. response%ok) then
        print *,'Error message : ', response%err_msg
    else
        print *, 'Response Code    : ', response%status_code
        print *, 'Response Content : ', response%content
    end if

end program timeout
