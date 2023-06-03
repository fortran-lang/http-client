program response_header
    use stdlib_string_type
    use http, only: response_type, request
    implicit none
    type(response_type) :: response
    type(string_type), allocatable :: headers(:)
    integer :: i = 0

    response = request(url='https://gorest.co.in/public/v2/todos')
    if(.not. response%ok) then
        print *,"Error message : ", response%err_msg
    else
        headers = response%header_keys()
        do i = 1, size(headers)
            print *,headers(i), ": ", response%header_value(headers(i))
        end do
    end if

end program response_header