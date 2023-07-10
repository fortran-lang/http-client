program test_timeout
    use iso_fortran_env, only: stderr => error_unit
    use http, only : response_type, request
 
    implicit none
    type(response_type) :: res
    character(:), allocatable :: msg
    logical :: ok = .true.


    res = request(url='https://httpbin.org/delay/10', timeout=5)
    
    msg = 'test_timeout: '

    if(res%err_msg /= 'Timeout was reached') then
        ok = .false.
        print '(a)', 'Failed : Timeout not reached'
    end if

    ! Status Code Validation
    if (res%status_code /= 0) then
        ok = .false.
        print '(a)', 'Failed : Status Code Validation'
    end if

    if (.not. ok) then 
        msg = msg // 'Test Case Failed'
        write(stderr, '(a)'), msg
        error stop 1
    else
        msg = msg // 'All tests passed.'
        print '(a)', msg 
    end if
end program test_timeout
