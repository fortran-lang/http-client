program response_header
    use stdlib_string_type
    use http, only: response_type, request
    implicit none
    type(response_type) :: response
    type(string_type), allocatable :: headers(:)
    character(:), allocatable :: val
    integer :: i = 0

    response = request(url='https://jsonplaceholder.typicode.com/todos/1')
    if(.not. response%ok) then
        print *,'Error message : ', response%err_msg
    else
        print *, '===========Response header value by passing string_type============'
        headers = response%header_keys()
        do i = 1, size(headers)
            print *, headers(i), ': ', response%header_value(headers(i))
        end do
        print *, '===========Response header value by passing characters============'
        val = response%header_value('date')
        print *, 'date', ' : ',val
    end if

end program response_header