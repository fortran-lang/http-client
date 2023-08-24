# Building a [GitHub Organization Analyzer](https://github.com/rajkumardongre/github-org-analyzer) in Fortran, using `http-client` 🚀

In this tutorial, we'll create a simple Fortran program that uses the [GitHub API](https://docs.github.com/en/rest?apiVersion=2022-11-28) to retrieve and display all the repositories of the [`fortran-lang`](https://github.com/fortran-lang) organization. We'll use the [`http-client`](https://github.com/fortran-lang/http-client) and [`json-fortran`](https://github.com/jacobwilliams/json-fortran) libraries to make API requests and handle JSON responses.

# Prerequisite 🚩

Before proceeding with building the GitHub Organization Analyzer library and running the program, it's crucial to ensure that you have at least [`fpm`](https://fpm.fortran-lang.org/) v0.9.0 (Fortran Package Manager) installed. Additionally, there is a single dependency required for the [`http-client`](https://github.com/fortran-lang/http-client) library utilized in this project. Please follow the steps provided below to set up your environment:

### Step 1: Install fpm

[`fpm`](https://fpm.fortran-lang.org/) is the Fortran Package Manager used for building and managing Fortran projects. If you do not currently have `fpm` installed, you can follow the installation instructions available on the official `fpm` repository to install version v0.9.0 or a more recent version. The installation guide can be found here: [Installation Guide](https://fpm.fortran-lang.org/install/index.html).


### Step 2: Install libcurl Development Headers

The `http-client` library requires the [`libcurl`](https://curl.se/libcurl/) development headers to be installed. On Ubuntu-based systems, you can install the required dependencies using the following command:

```bash
sudo apt install -y libcurl4-openssl-dev
```

This command will install the necessary development headers for libcurl, enabling the `http-client` library to make API requests to fetch data from the GitHub API.

Once you have `fpm` installed and the required dependencies set up, you are ready to proceed with building and running the GitHub Organization Analyzer project.🙌

# Let's Start Building 👨‍💻

### Step 1: Set up the Project

>**Note : This requires at least fpm v0.9.0.**

1. Open your terminal or command prompt and create a new directory for the project:

```bash
fpm new github-org-analyzer
cd github-org-analyzer
```

2. The project structure will look like this:

```
.
├── README.md
├── app
│   └── main.f90
├── fpm.toml
├── src
│   └── github-org-analyzer.f90
└── test
    └── check.f90
```

### Step 2: Add Dependencies to `fpm.toml`

Open the `fpm.toml` file and add the following dependencies:

```toml
[dependencies]
http = { git = "https://github.com/fortran-lang/http-client.git" }
stdlib = "*"
json-fortran = { git = "https://github.com/jacobwilliams/json-fortran.git" }
```

### Step 3: Import the Libraries

Open the `github-org-analyzer.f90` file in the `src` folder and import the required libraries:

```fortran
module github_org_analyzer
    use json_module, only : json_file
    use http, only : request, response_type
    use stdlib_strings, only : to_string

    ! ... (subroutine to be added later)
end module github_org_analyzer
```
* `json_module` : This module provides functionalities for parsing JSON content, and we use it here to work with JSON data obtained from the GitHub API.

* The `http` module enables us to make API calls and send HTTP requests to fetch data from the GitHub API.

* `to_string` : We use this function to convert integers to their string representations

### Step 4: Create the `print_org_repositories` Subroutine

Now let's write the `print_org_repositories` subroutine, which fetches and prints all the repositories of the "fortran-lang" organization using the GitHub API. This subroutine utilizes the `http-client` and `json-fortran` libraries to make API requests and handle JSON responses.

1. Open the `github_org_analyzer.f90` file in the `src` folder.

2. Create the `print_org_repositories` subroutine within the `github_org_analyzer` module:

```fortran
module github_org_analyzer
   use json_module, only : json_file
   use http, only : request, response_type
   use stdlib_strings, only : to_string

   implicit none
   private

   ! Declare the function as public to make it accessible to other modules
   public :: print_org_repositories
contains
   subroutine print_org_repositories()
      !! subroutine to print all repositories of fortran-lang organization
      character(*), parameter :: api_url = 'https://api.github.com/orgs/fortran-lang/repos'
      !! Stores GitHub API URL for fetching repositories
      integer :: i
      !! counter to traverse all the repos return by api
      character(:), allocatable :: count
      !! stores the string equivalent of counter, i.e variable i
      character(:), allocatable :: value
      !! stores the individual github repo name for each traversal
      type(json_file) :: json
      !! give the ability to parse the json content
      type(response_type) :: response
      !! stores the response from the github api
      logical :: found
      !!  flag for weather the current repo found or not

      ! Make an HTTP GET request to the API URL and store the response in the `response` variable
      response = request(url=api_url)

      ! Checking for any errors. If an error occurs during the HTTP call, the `ok`
      ! attribute will be set to .false., and the `err_msg` attribute will contain
      ! the reason for the error.
      if(.not. response%ok) then
         print *, 'Request Fail: ', response%err_msg
      else
         print *, 'Fortran lang All repositories:'

         ! Initialize the `json` object to parse the JSON content
         call json%initialize()

         ! Deserialize the JSON response(parsing the json)
         call json%deserialize(response%content)

         ! Traverse Repositories and Print Names
         
         ! Counter to traverse all repos one by one
         i = 0
         ! Enter the loop to traverse all repositories while they exist
         do
            ! Increment the counter for the next repository
            i = i + 1
            
            ! Convert the updated counter to its string representation and store it in count variable
            count = to_string(i)
            
            ! Fetch the name of the current repository (based on the `i` counter) and check if it exists
            call json%get('['//count//'].name', value, found)
            if(.not.found) exit
            
            ! If the repository name exists (`found` is true), print the repository number and name
            print *, count//'. ', value            
            
         end do
      end if
   end subroutine print_org_repositories
end module github_org_analyzer
```

### Step 5: Call the Subroutine in `main.f90`

Open the `main.f90` file in the `app` folder and call the `print_org_repositories` subroutine:

```fortran
program main
  ! importing `print_org_repositories` subroutine
  use github_org_analyzer, only: print_org_repositories
  implicit none

  ! Print all repositories inside Fortran lang organization'
  call print_org_repositories()
end program main
```

### Step 6: Run the Program

Now that you've completed all the steps, it's time to run the program:

```
fpm run
```

You should see the following output🧐:

```
Fortran lang All repositories:
1. fftpack
2. vscode-fortran-support
3. stdlib
4. stdlib-docs
5. fpm
6. fortran-lang.org
7. talks
8. benchmarks
9. fpm-registry
10. setup-fpm
11. stdlib-cmake-example
12. .github
13. fortran-forum-article-template
14. test-drive
15. fpm-haskell
16. fpm-metadata
17. minpack
18. fortls
19. fpm-docs
20. homebrew-fortran
21. playground
22. contributor-graph
23. webpage
24. assets
25. registry
26. fpm-on-wheels
27. http-client
```

🎉Congratulations! You've successfully built a simple Fortran program that fetches and displays the repositories of the "fortran-lang" organization using the GitHub API. 

👨‍💻 Feel free to explore the full capabilities of the [`http-client`](https://github.com/fortran-lang/http-client) library to create more advanced projects!

Moreover, we highly encourage you to actively contribute to the [github-org-analyzer](https://github.com/rajkumardongre/github-org-analyzer) project. You have the opportunity to propose and implement new features, address any bugs, and enhance the existing code.

Happy Coding! 👋 