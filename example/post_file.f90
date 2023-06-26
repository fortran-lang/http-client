! program post_file
!     ! This program demonstrates sending File using POST request.
!     use http, only: response_type, request, HTTP_POST, header_type, form_type, file_type
!     implicit none
!     type(response_type) :: response
!     type(header_type), allocatable :: req_header(:)
!     type(form_type), allocatable :: form_data(:)
!     type(file_type) :: file_data

!     form_data = [form_type('param1', 'value1'), form_type('param2', 'value2')]
!     
!     ! change file fileld name and file path as per requirement
!     file_data = file_type('<file_field_name>', '/path/to/file.txt')
    
!     response = request(url='https://example.com/post/file', method=HTTP_POST, form=form_data, file=file_data)
   
!     if(.not. response%ok) then
!         print *,'Error message : ', response%err_msg
!     else
!         print *, 'Response Code    : ', response%status_code
!         print *, 'Response Length  : ', response%content_length
!         print *, 'Response Method  : ', response%method
!         print *, 'Response Content : ', response%content
!     end if

! end program post_file
