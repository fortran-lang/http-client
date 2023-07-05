program test_delete
    use iso_fortran_env, only: stderr => error_unit
    use http, only: request, pair_type, HTTP_DELETE, response_type
    implicit none
    type(response_type) :: res
    character(:), allocatable :: original_content, msg
    logical :: ok = .true.

    original_content = '{"id":1,"title":"iPhone 9","description":"An apple mobile which is nothing like &
    apple","price":549,"discountPercentage":12.96,"rating":4.69,"stock":94,"brand":"Apple","category":&
    "smartphones","thumbnail":"https://i.dummyjson.com/data/products/1/thumbnail.jpg","images":&
    ["https://i.dummyjson.com/data/products/1/1.jpg","https://i.dummyjson.com/data/products/1/2.jpg",&
    "https://i.dummyjson.com/data/products/1/3.jpg","https://i.dummyjson.com/data/products/1/4.jpg",&
    "https://i.dummyjson.com/data/products/1/thumbnail.jpg"],"isDeleted":true'

    res = request(url='https://dummyjson.com/products/1', method=HTTP_DELETE)
    
    msg = 'test_delete: '

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
    if (res%content_length /= (len(original_content)+40) .or. &
        len(res%content) /= (len(original_content)+40)) then
        ok = .false.
        print '(a)', 'Failed : Content Length Validation'
    end if

    ! Content Validation
    if (res%content(1:535) /= original_content) then
        ok = .false.
        print '(a)', 'Failed : Content Validation'
    end if

    if (.not. ok) then 
        msg = msg // 'Test Case Failed'
        write(stderr, '(a)'), msg
        error stop 1
    else
        msg = msg // 'All tests passed.'
        print '(a)', msg 
    end if

end program test_delete