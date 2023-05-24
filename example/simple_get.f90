program simple_get
    use http_client, only : response_type, http_request, HTTP_GET
    implicit none
    type(response_type) :: response

    response = http_request(url='https://jsonplaceholder.typicode.com/todos/1', method=HTTP_GET)
    print *, "Response Code    : ", response%status_code
    print *, "Response Length  : ", response%content_length
    print *, "Response Content : ", response%content
    ! print *, "Response Content : ", response%content 

end program simple_get
