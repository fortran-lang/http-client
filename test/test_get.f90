program test_get
    use iso_fortran_env, only: stderr => error_unit
    use http, only : response_type, request, header_type
 
    implicit none
    type(response_type) :: res
    character(:), allocatable :: msg, original_content
    logical :: ok = .true.
    type(header_type), allocatable :: request_header(:)
    integer :: i

    original_content = '{"id":1,"title":"iPhone 9","description":"An apple mobile which is nothing like &
    apple","price":549,"discountPercentage":12.96,"rating":4.69,"stock":94,"brand":"Apple","category":&
    "smartphones","thumbnail":"https://i.dummyjson.com/data/products/1/thumbnail.jpg","images":&
    ["https://i.dummyjson.com/data/products/1/1.jpg","https://i.dummyjson.com/data/products/1/2.jpg",&
    "https://i.dummyjson.com/data/products/1/3.jpg","https://i.dummyjson.com/data/products/1/4.jpg",&
    "https://i.dummyjson.com/data/products/1/thumbnail.jpg"]}'

    ! setting request header
    request_header = [ &
      header_type('Another-One', 'Hello'), &
      header_type('Set-Cookie', 'Theme-Light'), &
      header_type('Set-Cookie', 'Auth-Token: 12345'), &
      header_type('User-Agent', 'my user agent') &
      ]

    ! res = request(url='https://reqres.in/api/users/1', header=request_header)
    res = request(url='https://dummyjson.com/products/1', header=request_header)
    
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
    end if
   
    ! Content Length Validation
    if (res%content_length /= len(original_content) .or. &
        len(res%content) /= len(original_content)) then
        ok = .false.
        print '(a)', 'Failed : Content Length Validation'
    end if

    ! Content Validation
    if (res%content /= original_content) then
        ok = .false.
        print '(a)', 'Failed : Content Validation'
    end if

    ! Header Size Validation
    if (size(res%header) /= 16) then
        ok = .false.
        print '(a)', 'Failed : Header Size Validation'
    end if

    ! Header Value Validation
    if (res%header_value('content-type') /= 'application/json; charset=utf-8') then
        ok = .false.
        print '(a)', 'Failed : Header Value Validation'
    end if

    if (.not. ok) then 
        msg = msg // 'Test Case Failed'
        write(stderr, '(a)'), msg
        error stop 1
    else
        msg = msg // 'All tests passed.'
        print '(a)', msg 
    end if
end program test_get
