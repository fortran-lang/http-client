program test_get
    use iso_fortran_env, only: stderr => error_unit
    use stdlib_string_type
    use http, only : response_type, request, header_type
    implicit none
    type(response_type) :: res
    character(:), allocatable :: msg, original_content
    logical :: ok = .true.
    type(string_type), allocatable :: header_array(:)
    type(header_type) :: request_header

    integer :: header_counter = 0, original_header_count = 19

    original_content = '{"id":15726,"user_id":2382773,&
    &"title":"Somnus ventosus theatrum delinquo spargo.",&
    &"due_on":"2023-06-09T00:00:00.000+05:30",&
    &"status":"completed"}'

    ! setting request header
    call request_header%set_header('header-1', 'value-1')
    call request_header%set_header('header-2', 'value-2')
    call request_header%set_header('header-3', 'value-3')


    res = request(url='https://gorest.co.in/public/v2/todos/15726', header=request_header)
    
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

    if (res%content_length /= len(original_content) .or. len(res%content) /= len(original_content)) then
        ok = .false.
        msg = msg // 'test case 2, '
        print *, res%content_length, " ", len(original_content), " ", len(res%content)
    end if

    if (res%content /= original_content) then
        ok = .false.
        msg = msg // 'test case 3, '
    end if

    header_array = res%header_keys()
    header_counter = size(header_array)
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