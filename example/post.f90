program post_request
    ! This program demonstrates sending JSON data using POST request and printing the
    ! status, length of the body, method, and the body of the response.
    use http, only: response_type, request, HTTP_POST, pair_type
    implicit none
    type(response_type) :: response
    character(:), allocatable :: json_data
    type(pair_type), allocatable :: req_header(:)

    ! Storing request header in array of pair_type object
    req_header = [pair_type('Content-Type', 'application/json')]

    ! JSON data we want to send
    json_data = '{"name":"Jhon","role":"developer"}'

    response = request(url='https://httpbin.org/post', method=HTTP_POST, data=json_data, header=req_header)
   
    if(.not. response%ok) then
        print *,'Error message : ', response%err_msg
    else
        print *, 'Response Code    : ', response%status_code
        print *, 'Response Length  : ', response%content_length
        print *, 'Response Method  : ', response%method
        print *, 'Response Content : ', response%content
    end if

end program post_request
