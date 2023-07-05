program test_patch
    use iso_fortran_env, only: stderr => error_unit
    use http, only: request, pair_type, HTTP_PATCH, response_type
    implicit none
    type(response_type) :: res
    character(:), allocatable :: json_data, original_content, msg
    type(pair_type), allocatable :: req_header(:)
    logical :: ok = .true.

    original_content = '{"id":1,"title":"iPhone Galaxy +1","price":549,"stock":94,"rating":4.69,&
    "images":["https://i.dummyjson.com/data/products/1/1.jpg","https://i.dummyjson.com/data/products/1/2.jpg"&
    ,"https://i.dummyjson.com/data/products/1/3.jpg","https://i.dummyjson.com/data/products/1/4.jpg",&
    "https://i.dummyjson.com/data/products/1/thumbnail.jpg"],"thumbnail":"https://i.dummyjson.com/data/products/1/thumbnail.jpg",&
    "description":"An apple mobile which is nothing like apple","brand":"Apple","category":"smartphones"}'

    req_header = [pair_type('Content-Type', 'application/json')]

    json_data = '{"title":"iPhone Galaxy +1"}'

    res = request(url='https://dummyjson.com/products/1', method=HTTP_PATCH, data=json_data, header=req_header)
    
    msg = 'test_patch: '

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

    if (.not. ok) then 
        msg = msg // 'Test Case Failed'
        write(stderr, '(a)'), msg
        error stop 1
    else
        msg = msg // 'All tests passed.'
        print '(a)', msg 
    end if

end program test_patch