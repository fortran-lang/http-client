program simple_get
    use http, only : response_type, request
    implicit none
    type(response_type) :: response

    response = request(url='https://jsonplaceholder.typicode.com/todos/1')
    print *, "Response Code    : ", response%status_code
    print *, "Response Length  : ", response%content_length
    print *, "Response Method  : ", response%method
    print *, "Response Content : ", response%content

end program simple_get
