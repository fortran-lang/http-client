module github_org_analyzer
  ! This module contains subroutines to analyze and retrieve 
  ! information about GitHub repositories of a given organization. 
  ! The module utilizes the json-fortran library to parse JSON 
  ! content and the http-client library to make API calls to fetch 
  ! data from the GitHub API
  use json_module, only : json_file
    ! This module provides functionalities for parsing JSON content, and we use it here to work with JSON data obtained from the GitHub API.
  use http, only : request, response_type
    ! The http module enables us to make API calls and send HTTP requests to fetch data from the GitHub API.
  use utils, only : int_to_str
    ! int_to_str : We use this function to convert integers to their string representations

  implicit none
  private

  public :: analyze_github_organization
  public :: get_top_active_repositories
  public :: get_top_starred_repositories
  public :: get_most_used_repositories
  public :: get_contributor_from_repositories
  
  contains

  subroutine analyze_github_organization(org_name)
    ! This subroutine analyzes a GitHub organization specified by its name (org_name). 
    ! It fetches data for all the repositories within the organization using the GitHub 
    ! API and prints detailed information about each repository.
    character(*), intent(in) :: org_name
    ! The name of the GitHub organization to analyze.
    character(:), allocatable :: api_url
    ! stores the GitHub API URL to fetch organization repositories' data.

    ! Construct the GitHub API URL (api_url) to fetch all the repositories within the specified organization
    api_url = 'https://api.github.com/orgs/'//org_name//'/repos'

    ! print detailed information about each repository within the organization.
    call print_org_repositories(api_url)
  end subroutine

  subroutine get_top_active_repositories(org_name, count)
    ! This subroutine fetches data for the top active repositories within a specified 
    ! GitHub organization (org_name) using the GitHub API. The number of repositories 
    ! to fetch (count) is optional, and if not provided, the default value is 5
    character(*), intent(in) :: org_name
    !  The name of the GitHub organization to fetch top active repositories.
    integer, optional, intent(in) :: count
    ! The number of top active repositories to fetch. If not provided, the default value is 5.
    character(:), allocatable :: api_url
    ! stores the GitHub API URL to fetch top active repositories within the organization.
    character(:), allocatable :: count_str
    ! A string representation of the count variable, used in constructing the API URL.

    if(present(count)) then
      count_str = int_to_str(count)
    else
      count_str = '5'
    end if

    api_url = 'https://api.github.com/orgs/'//org_name//'/repos?sort=updated&direction=desc&per_page='//count_str
    call print_org_repositories(api_url)
  end subroutine get_top_active_repositories

  subroutine get_top_starred_repositories(org_name, count)
    ! This subroutine fetches data for the top starred repositories within a 
    ! specified GitHub organization (org_name) using the GitHub API. The number 
    ! of repositories to fetch (count) is optional, and if not provided, the 
    ! default value is 5.
    character(*), intent(in) :: org_name
    ! The name of the GitHub organization to fetch top starred repositories.
    integer, optional, intent(in) :: count
    ! The number of top starred repositories to fetch. If not provided, the default value is 5.
    character(:), allocatable :: api_url
    ! stores the GitHub API URL to fetch top starred repositories within the organization.
    character(:), allocatable :: count_str
    ! A string representation of the count variable, used in constructing the API URL.

    if(present(count)) then
      count_str = int_to_str(count)
    else
      count_str = '5'
    end if

    api_url = 'https://api.github.com/orgs/'//org_name//'/repos?sort=stars&direction=desc&per_page='//count_str
    call print_org_repositories(api_url)
  end subroutine get_top_starred_repositories

  subroutine get_most_used_repositories(org_name, count)
    ! This subroutine fetches data for the most used repositories within a 
    ! specified GitHub organization (org_name) using the GitHub API. The 
    ! "most used" criteria is based on the number of forks the repositories 
    ! have. The number of repositories to fetch (count) is optional, and if 
    ! not provided, the default value is 5.
    
    character(*), intent(in) :: org_name
    ! The name of the GitHub organization to fetch the most used repositories.
    integer, optional, intent(in) :: count
    ! The number of most used repositories to fetch. If not provided, the default value is 5.
    character(:), allocatable :: api_url
    ! stores the GitHub API URL to fetch the most used repositories within the organization.
    character(:), allocatable :: count_str
    ! A string representation of the count variable, used in constructing the API URL.

    if(present(count)) then
      count_str = int_to_str(count)
    else
      count_str = '5'
    end if

    api_url = 'https://api.github.com/orgs/'//org_name//'/repos?sort=forks&direction=desc&per_page='//count_str
    call print_org_repositories(api_url)
  end subroutine get_most_used_repositories

  subroutine get_contributor_from_repositories(org_name, repo_name, count)
    ! This subroutine fetches contributor data from the GitHub API for a specified 
    ! repository (repo_name) within a specified GitHub organization (org_name). It 
    ! can fetch a specified number of top contributors (count) or a default of 5 
    ! contributors if the count is not provided.
    character(*), intent(in) :: org_name
    ! The name of the GitHub organization to which the repository belongs.
    character(*), intent(in) :: repo_name
    ! The name of the GitHub repository for which to fetch contributors.
    integer, optional, intent(in) :: count
    ! The number of top contributors to fetch. If not provided, the default value is 5.
    character(:), allocatable :: api_url
    ! stores the GitHub API URL to fetch contributor data.
    character(:), allocatable :: count_str
    ! A string representation of the count variable, used in constructing the API URL.
    
    ! setting count default value
    if(present(count)) then
      count_str = int_to_str(count)
    else
      count_str = '5'
    end if

    ! Construct the GitHub API URL (api_url) to fetch the contributors from 
    ! the specified repository within the organization
    api_url = 'https://api.github.com/repos/'//org_name//'/'//repo_name//'/contributors?per_page='//count_str
    
    ! print detailed information about the contributors.
    call print_contributors(api_url)
  end subroutine get_contributor_from_repositories

  subroutine print_org_repositories(api_url)
    ! This subroutine fetches repository data from the GitHub API for a 
    ! given API URL (api_url) and prints detailed information about each repository.
    character(*), intent(in) :: api_url
      ! The URL of the GitHub API to fetch repositories.
    character(:), allocatable :: count 
      ! stores the index of the current repository during traversal.
    character(:), allocatable :: value
      ! store the fetched values for each repository attribute.
    type(json_file) :: json
      ! responsible for parsing JSON content.
    type(response_type) :: response
      ! Store the response from the GitHub API
    integer :: i
      ! A counter variable used to traverse the repositories one by one.
    logical :: found
      ! A flag used to check if the current repository exists 
      ! (i.e., found in the JSON content).

    ! Make an HTTP GET request to the specified api_url using the request function from 
    ! the http module, and store the response in the response variable:
    response = request(url=api_url)
    
    ! Initialize the json object using the initialize method from the json_file 
    ! type, and deserialize the JSON content from the API response:
    call json%initialize()
    call json%deserialize(response%content)
    
    ! Set the counter i to 1, and convert it to its string representation using the 
    ! int_to_str function from the utils module, storing the result in the count variable
    i = 1
    count = int_to_str(i)

    ! Fetch the name of the 1st GitHub repository and check if it exists (found is true)
    call json%get('['//count//'].name', value, found)

    ! Enter a loop to traverse all the repositories while they exist
    do while(found)

      ! Fetch the attributes of the current repository and print their values if they exist
      call json%get('['//count//'].name', value, found); if(found) print*, 'Repository Name: ',value
      call json%get('['//count//'].description', value, found); if(found) print*, 'Description    : ',value
      call json%get('['//count//'].language', value, found); if(found) print*, 'Language       : ',value
      call json%get('['//count//'].stargazers_count', value, found); if(found) print*, 'Stars          : ',value
      call json%get('['//count//'].forks_count', value, found); if(found) print*, 'Forks          : ',value
      call json%get('['//count//'].open_issues_count', value, found); if(found) print*, 'Open Issues    : ',value
      call json%get('['//count//'].html_url', value, found); if(found) print*, 'URL            : ',value
      print *, ''

      ! Increment the counter i for the next repository and update the 
      ! count variable accordingly
      i = i+1
      count = int_to_str(i)

      ! Fetch the name of the next repository (based on the updated i counter) 
      ! and update the found flag accordingly
      call json%get('['//count//'].name', value, found)
    end do
  end subroutine print_org_repositories

  subroutine print_contributors(api_url)
    ! This subroutine fetches contributor data from the GitHub API for a given API URL 
    ! (api_url) and prints detailed information about each contributor.
    character(*), intent(in) :: api_url
    ! The URL of the GitHub API to fetch contributor data.
    character(:), allocatable :: count
    ! stores the index of the current contributor during traversal in string format.
    character(:), allocatable :: value
    ! store the fetched values for each contributor attribute.
    type(json_file) :: json
    ! responsible for parsing JSON content.
    type(response_type) :: response
    ! stores the response from the GitHub API.
    integer :: i
    ! A counter variable used to traverse the contributors one by one.
    logical :: found
    ! A flag used to check if the current contributor exists (i.e., found in the JSON content).

    ! Make an HTTP GET request to the specified api_url using the request function from 
    ! the http module, and store the response in the response variable
    response = request(url=api_url)
    
    ! Initialize the json object using the initialize method from the json_file type, 
    ! and deserialize the JSON content from the API response
    call json%initialize()
    call json%deserialize(response%content)
    
    ! Set the counter i to 1, and convert it to its string representation using the int_to_str 
    ! function from the utils module, storing the result in the count variable
    i = 1
    count = int_to_str(i)

    ! Fetch the login (username) of the 1st GitHub contributor and check if it exists (found is true):
    call json%get('['//count//'].login', value, found)

    ! Enter a loop to traverse all the contributors while they exist
    do while(found)
      ! Fetch the attributes of the current contributor and print their values if they exist
      call json%get('['//count//'].login', value, found); if(found) print*, 'User Name        : ',value
      call json%get('['//count//'].contributions', value, found); if(found) print*, 'Contributions    : ',value
      call json%get('['//count//'].html_url', value, found); if(found) print*, 'URL              : ',value
      print *, ''

      ! Increment the counter i for the next contributor and update the count variable accordingly
      i = i+1
      count = int_to_str(i)

      ! Fetch the login (username) of the next contributor (based on the updated i counter) 
      ! and update the found flag accordingly
      call json%get('['//count//'].login', value, found)
    end do

  end subroutine print_contributors


end module github_org_analyzer
