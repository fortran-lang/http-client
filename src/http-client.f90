module http_client
  use, intrinsic :: iso_c_binding
  use, intrinsic :: iso_fortran_env, only: i4 => int32, i8 => int64, r4 => real32, r8 => real64
  use curl
  implicit none
  private
  ! HTTP methods:
  integer, parameter, public :: HTTP_GET = 1
  integer, parameter, public :: HTTP_HEAD = 2
  integer, parameter, public :: HTTP_POST = 3
  integer, parameter, public :: HTTP_PUT = 4
  integer, parameter, public :: HTTP_DELETE = 5
  integer, parameter, public :: HTTP_PATCH = 6

  ! Request Type
  type :: request_type
    character(len=:), allocatable :: url
    character(len=:), allocatable :: method
  end type request_type

  ! Response Type
  type, public :: response_type
    character(len=:), allocatable :: content
    character(len=:), allocatable :: url
    character(len=:), allocatable :: method
    integer :: status_code
    integer(kind=c_size_t) :: content_length = 0
  end type response_type
  
  ! http_client Type
  type :: client_type
    type(request_type) :: request
  contains
    procedure :: client_get_response 
  end type client_type

  interface client_type
    module procedure new_client
  end interface client_type

  interface http_request
    module procedure new_request
  end interface http_request

  ! Procedure defination
  public :: http_request
  
contains


! Constructor for request_type type.
function new_request(url, method) result(response)
  character(len=*) :: url
  integer, optional :: method
  type(request_type) :: request
  type(response_type) :: response
  type(client_type) :: client

  if(present(method)) then 
    if(method == 1) then
      request%method = 'GET'  
    else if (method == 2) then
      request%method = 'HEAD'  
    else if (method == 3) then
      request%method = 'POST'  
    else if (method == 4) then
      request%method = 'PUT'  
    else if(method == 5) then
      request%method = 'DELETE' 
    else if( method == 6) then
      request%method = 'PATCH'  
    end if      
  else
    request%method = 'GET'
  end if
  request%url = url
  client = client_type(request=request)
  response = client%client_get_response()
  
end function new_request

function client_get_response(this) result(response)
  class(client_type) :: this
  type(response_type), target :: response
  type(c_ptr) :: curl_ptr
  integer :: rc
  ! logic for populating response using fortran-curl
  response%url = this%request%url
  response%method = this%request%method

  curl_ptr = curl_easy_init()

  if (.not. c_associated(curl_ptr)) then
    stop 'Error: curl_easy_init() failed'
  end if
  ! setting request URL
  rc = curl_easy_setopt(curl_ptr, CURLOPT_URL, this%request%url // c_null_char)
  ! setting request method
  rc = curl_easy_setopt(curl_ptr, CURLOPT_CUSTOMREQUEST, this%request%method // c_null_char)
  ! setting callback for writing received data
  rc = curl_easy_setopt(curl_ptr, CURLOPT_WRITEFUNCTION, c_funloc(client_response_callback))
  ! setting response pointer to write callback
  rc = curl_easy_setopt(curl_ptr, CURLOPT_WRITEDATA, c_loc(response))

  ! Send request.
  rc = curl_easy_perform(curl_ptr)
  
  if (rc /= CURLE_OK) then
    print '(a)', 'Error: curl_easy_perform() failed'
    stop
  end if
  ! setting response status_code
  rc = curl_easy_getinfo(curl_ptr, CURLINFO_RESPONSE_CODE, response%status_code)  
  call curl_easy_cleanup(curl_ptr)

end function client_get_response

function client_response_callback(ptr, size, nmemb, client_data) bind(c)
  type(c_ptr), intent(in), value :: ptr !! C pointer to a chunk of the response.
  integer(kind=c_size_t), intent(in), value :: size !! Always 1.
  integer(kind=c_size_t), intent(in), value :: nmemb !! Size of the response chunk.
  type(c_ptr), intent(in), value :: client_data !! C pointer to argument passed by caller.
  integer(kind=c_size_t) :: client_response_callback !! Function return value.
  type(response_type), pointer :: response !! Stores response.
  character(len=:), allocatable :: buf

  client_response_callback = int(0, kind=c_size_t)

  ! Are the passed C pointers associated?
  if (.not. c_associated(ptr)) return
  if (.not. c_associated(client_data)) return

  ! Convert C pointer to Fortran pointer.
  call c_f_pointer(client_data, response)
  if (.not. allocated(response%content)) response%content = ''

  ! Convert C pointer to Fortran allocatable character.
  call c_f_str_ptr(ptr, buf, nmemb)
  if (.not. allocated(buf)) return
  response%content = response%content // buf
  deallocate (buf)
  response%content_length = response%content_length + nmemb
  ! Return number of received bytes.
  client_response_callback = nmemb
end function client_response_callback

! Constructor for client_type type.
function new_client(request) result(client)
  type(client_type) :: client
  type(request_type) :: request

  client%request = request
end function new_client

end module http_client
