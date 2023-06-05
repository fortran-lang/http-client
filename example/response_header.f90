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
    call req_header%set('h1', 'v1')
    call req_header%set('h2', 'v2')
    call req_header%set('h3', 'v3')
    call req_header%set('h4', 'v4')

    ! response = request(url='https://gorest.co.in/public/v2/todos/15726', header=req_header)
    response = request(url='http://localhost:3002/', header=req_header)
    if(.not. response%ok) then
        print *,'Error message : ', response%err_msg
    else
        print *, '=========== Response header value by passing string_type ============'
        ! headers is array of header key
        headers = response%header%keys()
        do i = 1, size(headers)
            val = response%header%value(headers(i))
            print *, headers(i), ': ', val
        end do
        print *, '=========== Response header value by passing characters ============'
        val = response%header%value('date')
        print *, 'date', ' : ',val
    end if
end program response_header