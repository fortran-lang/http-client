program post_form_data
    ! This program demonstrates sending Form data using POST request and printing 
    ! the status, length of the body, method, and the body of the response.
    use http, only: response_type, request, HTTP_POST, pair_type
    implicit none
    type(response_type) :: response
    type(pair_type), allocatable :: req_header(:)
    type(pair_type), allocatable :: form_data(:)

    ! Storing form data in a array of pair_type object, each pair_type object 
    ! represent a single form field
    form_data = [pair_type('param1', 'value1'), pair_type('param2', 'value2')]

    response = request(url='https://httpbin.org/post', method=HTTP_POST, form=form_data)
   
    if(.not. response%ok) then
        print *,'Error message : ', response%err_msg
    else
        print *, 'Response Code    : ', response%status_code
        print *, 'Response Length  : ', response%content_length
        print *, 'Response Method  : ', response%method
        print *, 'Response Content : ', response%content
    end if

end program post_form_data
