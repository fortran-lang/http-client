program response_header
    use stdlib_string_type
    use http, only: response_type, request, header_type
    implicit none
    type(response_type) :: response
    type(string_type), allocatable :: headers(:)
    type(header_type) :: req_header
    character(:), allocatable :: val
    integer :: i = 0

    ! setting request header
    call req_header%set_header('h1', 'v1')
    call req_header%set_header('h2', 'v2')
    call req_header%set_header('h3', 'v3')

    response = request(url='https://jsonplaceholder.typicode.com/todos/1', header=req_header)
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