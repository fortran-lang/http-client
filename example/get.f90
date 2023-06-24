program get_request
    ! This program demonstrates sending a simple GET request and printing the
    ! status, length of the body, method, and the body of the response.
    use http, only: response_type, request
    implicit none
    type(response_type) :: response

    response = request(url='https://httpbin.org/get')
    if(.not. response%ok) then
        print *,'Error message : ', response%err_msg
    else
        print *, 'Response Code    : ', response%status_code
        print *, 'Response Length  : ', response%content_length
        print *, 'Response Method  : ', response%method
        print *, 'Response Content : ', response%content
    end if

end program get_request
