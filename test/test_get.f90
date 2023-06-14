program test_get
    use iso_fortran_env, only: stderr => error_unit
    use http, only : response_type, request, header_type
 
    implicit none
    type(response_type) :: res
    character(:), allocatable :: msg, original_content
    character(2), allocatable :: number
    logical :: ok = .true.
    type(header_type), allocatable :: request_header(:)
    integer :: i, passed_test_case, fail_test_case

    passed_test_case = 0
    fail_test_case = 0

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
        write(stderr, '(a)') msg
        error stop 1
    end if
    
    ! Status Code Validation
    if (res%status_code /= 200) then
        ok = .false.
        print '(a)', 'Failed : Status Code Validation'
        fail_test_case = fail_test_case + 1
    else
        print '(a)', 'Passed : Status Code Validation'
        passed_test_case = passed_test_case + 1
    end if
   
    ! Content Length Validation
    if (res%content_length /= len(original_content) .or. &
        len(res%content) /= len(original_content)) then
        ok = .false.
        print '(a)', 'Failed : Content Length Validation'
        fail_test_case = fail_test_case + 1
    else 
        print '(a)', 'Passed : Content Length Validation'
        passed_test_case = passed_test_case + 1
    end if

    ! Content Validation
    if (res%content /= original_content) then
        ok = .false.
        print '(a)', 'Failed : Content Validation'
        fail_test_case = fail_test_case + 1
    else 
        print '(a)', 'Passed : Content Validation'
        passed_test_case = passed_test_case + 1
    end if

    ! Header Size Validation
    if (size(res%header) /= 14 .and. size(res%header) /= 15) then
        ok = .false.
        print '(a)', 'Failed : Header Size Validation'
        fail_test_case = fail_test_case + 1
    else 
        print '(a)', 'Passed : Header Size Validation'
        passed_test_case = passed_test_case + 1
    end if

    ! Header Value Validation
    if (res%header_value('content-type') /= 'application/json; charset=utf-8') then
        ok = .false.
        print '(a)', 'Failed : Header Value Validation'
        fail_test_case = fail_test_case + 1
    else 
        print '(a)', 'Passed : Header Value Validation'
        passed_test_case = passed_test_case + 1
    end if

    if (.not. ok) then 
        write(stderr, '(a i2 a i2 a)'), msg, fail_test_case,'/',fail_test_case+passed_test_case,&
        & ' Test Case Failed'
        error stop 1
    else
        msg = msg // 'All tests passed.'
        print '(a)', msg 
    end if
end program test_get
