program test_header

    use iso_fortran_env, only: stderr => error_unit
    use http_header, only: get_header_value, header_has_key, header_type

    implicit none
    type(header_type), allocatable :: header(:)
    logical :: ok = .true.
    integer :: n

    header = [ &
        header_type('One', '1'), &
        header_type('Two', '2') &
    ]

    if (.not. size(header) == 2) then
        ok = .false.
        write(stderr, '(a)') 'Failed: Header size is incorrect.'
    end if

    if (.not. header(1)%value == '1') then
        ok = .false.
        write(stderr, '(a)') 'Failed: First header value is incorrect.'
    end if

    if (.not. header(2)%value == '2') then
        ok = .false.
        write(stderr, '(a)') 'Failed: Second header value is incorrect.'
    end if

    header = [header, header_type('Three', '3')]

    if (.not. size(header) == 3) then
        ok = .false.
        write(stderr, '(a)') 'Failed: Appending to header failed.'
    end if

    if (.not. header(3)%value == '3') then
        ok = .false.
        write(stderr, '(a)') 'Failed: Appended header value is incorrect.'
    end if

    do n = 1, size(header)
        if (.not. get_header_value(header, header(n)%key) == header(n)%value) then
            ok = .false.
            write(stderr, '(a)') 'Failed: Appended header value is incorrect.'
        end if
    end do

    do n = 1, size(header)
        if (.not. header_has_key(header, header(n)%key)) then
            ok = .false.
            write(stderr, '(a)') 'Failed: Incorrect output from header_has_key.'
        end if
    end do

    if (header_has_key(header, "Non-Existent")) then
        ok = .false.
        write(stderr, '(a)') 'Failed: Incorrect output from header_has_key for non-existent key.'
    end if
  
    if (.not. ok) then 
        write(stderr, '(a)'), 'test_header: One or more tests failed.'
        error stop 1
    else
        print '(a)', 'test_header: All tests passed.'
    end if

end program test_header