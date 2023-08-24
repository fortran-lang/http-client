# http-client

http-client is Fortran library to make HTTP requests.
It simplifies interacting with web services by providing a high-level and
user-friendly interface.

## Features

* HTTP request methods:
  - `GET`: Retrieve data from the server.
  - `POST`: Create new data the server.
  - `PUT`: Replace an existing resource on the server.
  - `DELETE`: Delete a resource from the server.
  - `PATCH`: Partially update a resource on the server.
  - `HEAD`: Get response headers without the response content.
* Supported data types:
  - URL encoded fields
  - HTTP form data
  - File uploads
* Response handling:
  - Retrieve response body (content).
  - Get the HTTP status code returned by the server.
  - Access response headers.
* Setting custom request headers
* Error handling with informative error messages
* Setting request timeouts
* Basic HTTP authentication

## Installation

Before building the http-client library, ensure that you have the necessary
dependencies installed. On Ubuntu, you need to install the curl development
headers. Use the following command:

```
sudo apt install -y libcurl4-openssl-dev
```

To use http-client as a dependency in your fpm project, add the following to
your the fpm.toml file of your package:

```toml
[dependencies]
http = { git = "https://github.com/fortran-lang/http-client.git" }
stdlib = "*"
```

## Example use

The following example demonstrates how to use http-client to make a simple `GET`
request and process the response:

```fortran
program simple_get
    use http, only : response_type, request
    implicit none
    type(response_type) :: response

    ! Send a GET request to retrieve JSON data
    response = request(url='https://jsonplaceholder.typicode.com/todos/1')

    ! Check if the request was successful
    if (.not. response%ok) then
        print *, 'Error message:', response%err_msg
    else
        ! Print the response details
        print *, 'Response Code    :', response%status_code
        print *, 'Response Length  :', response%content_length
        print *, 'Response Method  :', response%method
        print *, 'Response Content :', response%content
    end if

end program simple_get

```

Ouptut: 

```
 Response Code    :          200
 Response Length  :                    83
 Response Method  : GET
 Response Content : {
  "userId": 1,
  "id": 1,
  "title": "delectus aut autem",
  "completed": false
}
```

In this example, we make a `GET` request to the URL
https://jsonplaceholder.typicode.com/todos/1 to retrieve JSON data.
If the request is successful, we print the response code, content length,
method, and content. If the request fails, we print the error message.

## Getting Started Guides

To begin your journey with our package, dive into the comprehensive tutorial
available here: [tutorial.md](./tutorial/tutorial.md)**.

## Projects using http-client

* [github-org-analyzer](https://github.com/rajkumardongre/github-org-analyzer):
An example mini-project to demonstrate the use of http-client by downloading
and parsing data from the GitHub API.
* [fortran-xkcd](https://github.com/rajkumardongre/fortran-xkcd/tree/http_client_version):
An fpm example project that displays the latest xkcd comic inside an X window.
As a limitation, only images in PNG format are supported.
The alt text will be printed to console.
* [foropenai](https://github.com/gha3mi/foropenai): A Fortran library to access
* the OpenAI API.

If you're using http-client in your Fortran project and would like to be
included on this list, we welcome you to contribute by creating a pull request
(PR) and adding your project details. 

## Contributing to project

Thank you for your interest in http-client! Contributions from the community
are esential for improving the package. This section provides a guide on how to
get the code, build the library, and run examples and tests.

### Get the code

To get started, follow these steps:

Clone the repository using Git:

```
git clone https://github.com/fortran-lang/http-client
cd http-client
```

### Prerequisites

Before building the library, ensure that you have the necessary dependencies
installed. On Ubuntu, you need to install the curl development headers.
Use the following command:

```
sudo apt install -y libcurl4-openssl-dev
```

### Build the library

http-client uses **fpm** as the build system. Make sure you have fpm-0.8.x or
later installed. To build the library, run the following command within the
project directory:


```
fpm build
```

### Run examples

http-client provides example programs that demonstrate its use. To run the
examples, use the following command:

```
fpm run --example <example name>
```

Executing this command will execute the example programs, allowing you to see
the package in action and understand how to utilize its features.

### Run tests

http-client includes a test suite to ensure its functionality is working as
expected. To run the tests, type:

```
fpm test
```

Running the tests will validate the behavior of the package and help identify
any issues or regressions.

### Generating API Documentation

Before generating API documentation, ensure that you have FORD
[installed on your system](https://github.com/Fortran-FOSS-Programmers/ford#installation).

Once FORD is set up, execute the following command to build the API documentation:

```bash
ford ford.md
```

### Supported compilers

http-client is known to work with the following compilers:

* GFortran 11 & 12 (tested in CI)
* Intel OneAPI ifx v2023.1.0 and ifort classic v2021.9.0

### Contributing guidelines

When contributing to the http Fortran package, please keep the following guidelines in mind:

* Before making any substantial changes, it is recommended to open an issue to discuss the proposed changes and ensure they align with the project's goals.
* Fork the repository and create a new branch for your contribution.
* Ensure that your code adheres to the existing coding style and follows good software engineering practices.
* Write clear and concise commit messages.
* Make sure to test your changes and ensure they do not introduce regressions or break existing functionality.
* Submit a pull request with your changes, providing a clear explanation of the problem you are solving and the approach you have taken.

We appreciate your contributions and look forward to your valuable input in improving http-client.

Happy coding!👋