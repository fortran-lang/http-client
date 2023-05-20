module http_client
  implicit none
  private

  public :: say_hello
contains
  subroutine say_hello
    print *, "Hello, http-client!"
  end subroutine say_hello
end module http_client
