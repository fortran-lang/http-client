module http_request
    use http_response, only : response_type
    use http_client, only : client_type
    implicit none

    ! Request Type
    type, public :: request_type
        character(len=:), public, allocatable :: url
        character(len=:), public, allocatable :: method
    end type request_type
    
end module http_request