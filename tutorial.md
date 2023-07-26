## Building a [GitHub Organization Analyzer](https://github.com/rajkumardongre/github-org-analyzer) in Fortran, using `http-client` 🚀

In this tutorial, we'll create a simple Fortran program that uses the [GitHub API](https://docs.github.com/en/rest?apiVersion=2022-11-28) to retrieve and display all the repositories of the [`fortran-lang`](https://github.com/fortran-lang) organization. We'll use the [`http-client`](https://github.com/fortran-lang/http-client) and [`json-fortran`](https://github.com/jacobwilliams/json-fortran) libraries to make API requests and handle JSON responses.

# Prerequisite 🚩

Before building the GitHub Organization Analyzer library and running the program, you need to ensure that you have [`fpm`](https://fpm.fortran-lang.org/) (Fortran Package Manager) installed. Additionally, there is one dependency required for the [`http-client`](https://github.com/fortran-lang/http-client) library used in the project. Follow the steps below to set up your environment:

### Step 1: Install fpm

[`fpm`](https://fpm.fortran-lang.org/) is the Fortran Package Manager used for building and managing Fortran projects. If you don't have `fpm` installed, you can follow the installation instructions provided on the official `fpm` repository: [Installation guide](https://fpm.fortran-lang.org/install/index.html)


### Step 2: Install libcurl Development Headers

The `http-client` library, requires the libcurl development headers to be installed. On Ubuntu-based systems, you can install the required dependencies using the following command:

```
sudo apt install -y libcurl4-openssl-dev
```

This command will install the necessary development headers for libcurl, enabling the `http-client` library to make API requests to fetch data from the GitHub API.

Once you have `fpm` installed and the required dependencies set up, you are ready to proceed with building and running the GitHub Organization Analyzer project.🙌

# Let's Start Building 👨‍💻

### Step 1: Set up the Project

1. Open your terminal or command prompt and create a new directory for the project:

```
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
http.git = "https://github.com/fortran-lang/http-client.git"
stdlib = "*"
json-fortran = { git = "https://github.com/jacobwilliams/json-fortran.git" }
```

### Step 3: Build the Project

Run the following command to build the project:

```
fpm build
```

### Step 4: Create `utils.f90`

In order to encapsulate helper functions for the program, we'll create a new file named `utils.f90` in the `src` folder. This module will contain the `int_to_str` function, which takes an integer as input and returns a string equivalent of that integer.

**utils.f90:**

```fortran
! utils.f90 - Helper functions module

module utils
    implicit none

    ! Declare the function as public to make it accessible to other modules
    public :: int_to_str

contains

    ! Function: int_to_str
    ! Converts an integer to a string
    ! Inputs:
    !   int - The integer to convert
    ! Returns:
    !   str - The string representation of the input integer
    function int_to_str(int) result(str)
        integer, intent(in) :: int
        character(:), allocatable :: str
        integer :: j, temp, rem
        integer, allocatable :: nums(:)

        ! Initialize variables
        temp = int
        str = ''

        ! Convert the integer to its string representation
        do while (temp > 9)
            rem = mod(temp, 10)
            temp = temp / 10
            if (allocated(nums)) then
                nums = [rem, nums]
            else
                nums = [rem]
            end if
        end do

        ! Add the last digit to the string
        if (allocated(nums)) then
            nums = [temp, nums]
        else
            nums = [temp]
        end if

        ! Convert the individual digits to characters and concatenate them
        do j = 1, size(nums)
            str = str // achar(nums(j) + 48)
        end do

        ! Deallocate the temporary array
        deallocate(nums)
    end function int_to_str

end module utils
```

### Step 5: Import the Libraries

Open the `github-org-analyzer.f90` file in the `src` folder and import the required libraries and the `utils` module:

```fortran
module github_org_analyzer
    use json_module, only : json_file
    use http, only : request, response_type
    use utils, only : int_to_str

    ! ... (subroutine to be added later)
end module github_org_analyzer
```
* `json_module` : This module provides functionalities for parsing JSON content, and we use it here to work with JSON data obtained from the GitHub API.

* The `http` module enables us to make API calls and send HTTP requests to fetch data from the GitHub API.

* `int_to_str` : We use this function to convert integers to their string representations

### Step 6: Create the `print_org_repositories` Subroutine

Now let's write the `print_org_repositories` subroutine, which fetches and prints all the repositories of the "fortran-lang" organization using the GitHub API. This subroutine utilizes the `http-client` and `json-fortran` libraries to make API requests and handle JSON responses.

1. Open the `github_org_analyzer.f90` file in the `src` folder.

2. Create the `print_org_repositories` subroutine within the `github_org_analyzer` module:

```fortran
subroutine print_org_repositories()
    !! subroutine to print all repositories of fortran-lang organization
    character(:), allocatable :: api_url
        !! stores the github api url 
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

    ! Initialize the `api_url` variable with the GitHub API URL for fetching repositories
    api_url = 'https://api.github.com/orgs/fortran-lang/repos'

    ! Make an HTTP GET request to the API URL and store the response in the `response` variable
    response = request(url=api_url)

    ! Initialize the `json` object to parse the JSON content
    call json%initialize()

    ! Deserialize the JSON response(parsing the json)
    call json%deserialize(response%content)

    ! Traverse Repositories and Print Names
    
    ! Counter to traverse all repos one by one
    i = 1

    ! Storing the string equivalent of i in the count variable
    count = int_to_str(i)

    ! Fetching the name of the 1st GitHub repository, if it exists (found is set to true)
    call json%get('['//count//'].name', value, found)


    ! Enter the loop to traverse all repositories while they exist
    do while(found)

        ! Fetch the name of the current repository (based on the `i` counter) and check if it exists
        call json%get('['//count//'].name', value, found)

        ! If the repository name exists (`found` is true), print the repository number and name
        if (found) then
            print *, count//'. ', value
        end if

        ! Increment the counter for the next repository
        i = i + 1

        ! Convert the updated counter to its string representation and store it in count variable
        count = int_to_str(i)

        ! Fetch the name of the next repository (based on the updated `i` counter) and update `found` accordingly
        call json%get('['//count//'].name', value, found)
    
    end do
end subroutine print_org_repositories

```

### Step 7: Call the Subroutine in `main.f90`

Open the `main.f90` file in the `app` folder and call the `print_org_repositories` subroutine:

```fortran
program main
    use github_org_analyzer, only: print_org_repositories
    implicit none

    print *, 'Fortran lang All repositories:'
    call print_org_repositories()
end program main
```

### Step 8: Run the Program

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