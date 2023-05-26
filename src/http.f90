module http
    use http_request
    use http_response, only : response_type
    use http_client
    implicit none

    ! HTTP methods:
    integer, parameter, public :: HTTP_GET    = 1
    integer, parameter, public :: HTTP_HEAD   = 2
    integer, parameter, public :: HTTP_POST   = 3
    integer, parameter, public :: HTTP_PUT    = 4
    integer, parameter, public :: HTTP_DELETE = 5
    integer, parameter, public :: HTTP_PATCH  = 6

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

    
end module http