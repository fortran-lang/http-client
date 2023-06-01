program response_header
    use fhash, only: fhash_tbl_t, key => fhash_key, fhash_iter_t, fhash_key_t
    use http, only: response_type, request
    implicit none
    
    type(fhash_iter_t) :: iter
    class(fhash_key_t), allocatable :: ikey
    class(*), allocatable :: idata
    type(response_type) :: response
    character(:), allocatable :: val

    response = request(url='https://gorest.co.in/public/v2/todos')
    if(.not. response%ok) then
        print *,"Error message : ", response%err_msg
    else
        print '(a)', '=================Response Header in string=================='
        print '(a)',  response%header_string
        print '(a)', '=================Response Header in hash table=============='
        iter = fhash_iter_t(response%header)
        do while(iter%next(ikey,idata))
            call response%header%get(key(ikey%to_string()),val)
            print '(a,": ",a)', ikey%to_string(), val
        end do
    end if

end program response_header
