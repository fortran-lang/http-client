program simple_get
    use http_client, only : response_type, http_request, HTTP_GET
    implicit none
    type(response_type) :: response

    response = http_request(url='https://jsonplaceholder.typicode.com/todos/1', method=HTTP_GET)
    print *, "Response Content : ", response%content 

end program simple_get
