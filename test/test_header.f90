program test_header

    use iso_fortran_env, only: stderr => error_unit
    use http_pair, only: get_pair_value, pair_has_name, pair_type

    implicit none
    type(pair_type), allocatable :: header(:)
    logical :: ok = .true.
    integer :: n

    header = [ &
        pair_type('One', '1'), &
        pair_type('Two', '2') &
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

    header = [header, pair_type('Three', '3')]

    if (.not. size(header) == 3) then
        ok = .false.
        write(stderr, '(a)') 'Failed: Appending to header failed.'
    end if

    if (.not. header(3)%value == '3') then
        ok = .false.
        write(stderr, '(a)') 'Failed: Appended header value is incorrect.'
    end if

    do n = 1, size(header)
        if (.not. get_pair_value(header, header(n)%name) == header(n)%value) then
            ok = .false.
            write(stderr, '(a)') 'Failed: Appended header value is incorrect.'
        end if
    end do

    do n = 1, size(header)
        if (.not. pair_has_name(header, header(n)%name)) then
            ok = .false.
            write(stderr, '(a)') 'Failed: Incorrect output from pair_has_name.'
        end if
    end do

    if (pair_has_name(header, "Non-Existent")) then
        ok = .false.
        write(stderr, '(a)') 'Failed: Incorrect output from pair_has_name for non-existent key.'
    end if
  
    if (.not. ok) then 
        write(stderr, '(a)'), 'test_header: One or more tests failed.'
        error stop 1
    else
        print '(a)', 'test_header: All tests passed.'
    end if

end program test_header