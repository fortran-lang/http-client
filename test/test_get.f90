program test_get
    use fhash, only: fhash_tbl_t, key => fhash_key, fhash_iter_t, fhash_key_t
    use http, only : response_type, request
    implicit none
    type(response_type) :: res
    character(:), allocatable :: msg, original_content
    logical :: ok = .true.

    type(fhash_iter_t) :: iter
    class(fhash_key_t), allocatable :: ikey
    class(*), allocatable :: idata
    character(:), allocatable :: val
    integer :: header_counter = 0, original_header_count = 25

    original_content = '[{"id":15726,"user_id":2382773,"title":"Somnus ventosus theatrum delinquo spargo.",&
    &"due_on":"2023-06-09T00:00:00.000+05:30","status":"completed"},{"id":15721,"user_id":2382762,"title":&
    &"Correptius atrox aut auctus avarus synagoga error supplanto aedificium.","due_on":"2023-06-08T00:00:00.000+05:30"&
    &,"status":"completed"},{"id":15720,"user_id":2382757,"title":"Volup bis crepusculum tamisium thalassinus&
    & solum territo cetera.","due_on":"2023-06-06T00:00:00.000+05:30","status":"completed"},{"id":15719,&
    &"user_id":2382756,"title":"Amicitia cornu et comprehendo conculco auctus amplitudo amita crastinus."&
    &,"due_on":"2023-06-25T00:00:00.000+05:30","status":"completed"},{"id":15718,"user_id":2382754,"title"&
    &:"Vomito alter tantillus videlicet cubo inflammatio infit absconditus super.","due_on":&
    &"2023-06-20T00:00:00.000+05:30","status":"completed"},{"id":15717,"user_id":2382751,"title":&
    &"Omnis quaerat recusandae adstringo confido qui.","due_on":"2023-06-08T00:00:00.000+05:30","status":&
    &"completed"},{"id":15716,"user_id":2382750,"title":"Texo audentia strenuus aureus canto trucido odio &
    &carcer.","due_on":"2023-06-06T00:00:00.000+05:30","status":"completed"},{"id":15715,"user_id":2382749,&
    &"title":"Defessus ipsa articulus tenuis coruscus suscipio ut succedo.","due_on":"2023-06-06T00:00:00.000+05:30"&
    &,"status":"completed"},{"id":15714,"user_id":2382748,"title":"Omnis autem tumultus ciminatio decipio &
    &bestia peccatus vomica.","due_on":"2023-06-08T00:00:00.000+05:30","status":"pending"},{"id":15713,&
    &"user_id":2382746,"title":"Defluo perspiciatis somniculosus occaecati attonbitus cuppedia.","due_on"&
    &:"2023-06-12T00:00:00.000+05:30","status":"pending"}]'

    res = request(url='https://gorest.co.in/public/v2/todos')
    
    msg = 'test_get: '
    if (.not. res%ok) then
        ok = .false.
        msg = msg // res%err_msg
        print *,msg
        stop
    end if

    if (res%status_code /= 200) then
        ok = .false.
        msg = msg // 'test case 1, '
    end if

    if (res%content_length /= len(original_content) .or. len(res%content) /= len(original_content)) then
        ok = .false.
        msg = msg // 'test case 2, '
    end if

    if (res%content /= original_content) then
        ok = .false.
        msg = msg // 'test case 3, '
    end if

    iter = fhash_iter_t(res%header)
    do while(iter%next(ikey,idata))
        header_counter = header_counter + 1
    end do

    if (header_counter /= original_header_count) then
        ok = .false.
        msg = msg // 'test case 4, '
    end if

    if (.not. ok) then
        msg = msg // 'Failed.'
    else
        msg = msg // 'All Test case Passed.'
    end if
    print '(a)', msg 
end program test_get