program main
  ! This Fortran project, named "GitHub Organization Analyzer," demonstrates the usage of the 
  ! http-client module to make HTTP requests and interact with the GitHub API. The project 
  ! provides a set of subroutines that allow users to fetch and display information about GitHub 
  ! repositories and contributors within a specified GitHub organization.

  use github_org_analyzer, only:  analyze_github_organization, get_top_active_repositories, &
  get_top_starred_repositories, get_most_used_repositories, get_contributor_from_repositories
  
  implicit none

  ! Fetching and displaying information about all repositories within the GitHub organization 
  ! 'fortran-lang' using the analyze_github_organization subroutine.
  print *, '::::::: All Repositories :::::::'//new_line('a')
  call analyze_github_organization(org_name='fortran-lang')

  ! Fetching and displaying detailed information about the top active repositories within the 
  ! organization using the get_top_active_repositories subroutine.
  print *, '::::::: Top Active Repositories :::::::'//new_line('a')
  call get_top_active_repositories(org_name='fortran-lang')

  ! Fetching and displaying detailed information about the top starred repositories within the 
  ! organization using the get_top_starred_repositories subroutine.
  print *, '::::::: Top Starred Repositories :::::::'//new_line('a')
  call get_top_starred_repositories(org_name='fortran-lang')

  ! Fetching and displaying detailed information about the most used repositories within the 
  ! organization (based on the number of forks) using the get_most_used_repositories subroutine.
  print *, '::::::: Top Used Repositories :::::::'//new_line('a')
  call get_most_used_repositories(org_name='fortran-lang')

  ! Fetching and displaying detailed information about contributors from the repository 'stdlib' 
  ! within the organization using the get_contributor_from_repositories subroutine.
  print *, '::::::: Contributors from a Repositories :::::::'//new_line('a')
  call get_contributor_from_repositories(org_name='fortran-lang', repo_name='stdlib')

end program main
