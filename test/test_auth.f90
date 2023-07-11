program test_auth
    use iso_fortran_env, only: stderr => error_unit
    use http, only : response_type, request, pair_type
 
    implicit none
    type(response_type) :: res
    character(:), allocatable :: msg
    logical :: ok = .true.
    type(pair_type) :: auth

    ! setting username and password
    auth = pair_type('user', 'passwd')   
    res = request(url='https://httpbin.org/basic-auth/user/passwd', auth=auth)
    
    msg = 'test_auth: '
   
    if (.not. res%ok) then
        ok = .false.
        msg = msg // res%err_msg
        write(stderr, '(a)') msg
        error stop 1
    end if
    
    ! Status Code Validation
    if (res%status_code /= 200) then
        ok = .false.
        print '(a)', 'Failed : Status Code Validation'
    end if
   
    ! Content Length Validation
    if (res%content_length /= 47 .or. &
        len(res%content) /= 47) then
        ok = .false.
        print '(a)', 'Failed : Content Length Validation'
    end if

    if (.not. ok) then 
        msg = msg // 'Test Case Failed'
        write(stderr, '(a)'), msg
        error stop 1
    else
        msg = msg // 'All tests passed.'
        print '(a)', msg 
    end if
end program test_auth
