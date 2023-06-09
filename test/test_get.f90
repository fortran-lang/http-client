program test_get
    use iso_fortran_env, only: stderr => error_unit
    use stdlib_string_type
    use http, only : response_type, request, header_type
 
    implicit none
    type(response_type) :: res
    character(:), allocatable :: msg, original_content
    logical :: ok = .true.
    type(header_type), allocatable :: request_header(:), response_header(:)
    integer :: header_counter = 0, original_header_count = 15, i

    original_content = '{"data":{"id":1,"email":"george.bluth@reqres.in",&
    &"first_name":"George","last_name":"Bluth",&
    &"avatar":"https://reqres.in/img/faces/1-image.jpg"},&
    &"support":{"url":"https://reqres.in/#support-heading",&
    &"text":"To keep ReqRes free, contributions towards server costs are appreciated!"}}'


    ! setting request header
    request_header = [ &
      header_type('Another-One', 'Hello'), &
      header_type('Set-Cookie', 'Theme-Light'), &
      header_type('Set-Cookie', 'Auth-Token: 12345'), &
      header_type('User-Agent', 'my user agent') &
      ]

    res = request(url='https://reqres.in/api/users/1', header=request_header)
    
    msg = 'test_get: '
   
    if (.not. res%ok) then
        ok = .false.
        msg = msg // res%err_msg
        write(stderr, *) msg
        error stop 1
    end if

    if (res%status_code /= 200) then
        ok = .false.
        msg = msg // 'test case 1, '
    end if
   
    if (res%content_length /= len(original_content) .or. &
        len(res%content) /= len(original_content)) then
        ok = .false.
        msg = msg // 'test case 2, '
    end if

    if (res%content /= original_content) then
        ok = .false.
        msg = msg // 'test case 3, '
    end if

    response_header = res%header
    do i=1, size(response_header)
        header_counter = header_counter + 1
    end do

    if (header_counter /= original_header_count) then
        ok = .false.
        msg = msg // 'test case 4, '
    end if


    if (.not. ok) then
        msg = msg // 'Failed.'
        write(stderr, *) msg
        error stop 1
    else
        msg = msg // 'All Test case Passed.'
        print '(a)', msg 
    end if
end program test_get