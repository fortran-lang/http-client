program test_head
    use iso_fortran_env, only: stderr => error_unit
    use http, only : response_type, request, HTTP_HEAD
 
    implicit none
    type(response_type) :: res
    character(:), allocatable :: msg
    logical :: ok = .true.


    res = request(url='https://www.w3schools.com/python/demopage.php', method=HTTP_HEAD)
    
    msg = 'test_head: '
   
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

    ! Header Size Validation
    if (size(res%header) /= 13) then
        ok = .false.
        print '(a)', 'Failed : Header Size Validation'
    end if

    if (.not. ok) then 
        msg = msg // 'Test Case Failed'
        write(stderr, '(a)'), msg
        error stop 1
    else
        msg = msg // 'All tests passed.'
        print '(a)', msg 
    end if
end program test_head
