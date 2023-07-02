program post_file

    ! This program demonstrates sending File using POST request.
    
    use http, only : request, response_type, HTTP_POST, pair_type
    implicit none
    type(response_type) :: response
    type(pair_type) :: file_data

    ! pair_type('<file_field_name>', '/path/to/file.txt')
    file_data = pair_type('info', './data/file.txt')

    response = request(url='https://httpbin.org/post', method=HTTP_POST, file=file_data)

    if(.not. response%ok) then
        print *,'Error message : ', response%err_msg
    else
        print *, 'Response Code    : ', response%status_code
        print *, 'Response Length  : ', response%content_length
        print *, 'Response Method  : ', response%method
        print *, 'Response Content : ', response%content
    end if
end program post_file