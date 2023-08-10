# **http**
## **Overview** 🤗

The `http` Fortran package provides a **simple and convenient** way to make HTTP requests and retrieve responses. It aims to **simplify** the process of interacting with web services by providing a high-level API.

___
## **Features** 🔥

 The package includes the following features:

 1. #### **Sending HTTP Requests:**
    - **`GET`**: Retrieve data from the server.
    - **`POST`**: Submit data to be processed by the server.
    - **`PUT`**: Replace or create resources on the server.
    - **`DELETE`**: Remove resources from the server.
    - **`PATCH`**: Partial updates to resources.
    - **`HEAD`**: Retrieve response headers without the response content.

 2. #### **Data Support:**
    - Send any type of data with requests, including support for `file` uploads and `form data`.
    
 3. #### **Response Handling:**
    - Retrieve response `content`.
    - Get the HTTP `status code` returned by the server.
    - Fetch the `length` of the response content.
    - Access response `headers`.
  
 4. #### **Custom Headers:**
    - Include `custom headers` in requests to the server.

 5. #### **Error Handling:**
    - Detect and handle unsuccessful requests gracefully, with informative `error messages`.

 6. #### **Request Timeout:**
    - Set a maximum time allowed for a request to complete, improving responsiveness.

 7. #### **Authentication:**
    - Authenticate requests to protected resources using standard authentication methods.

## **Installation** ⚙️

 Before building the `http-client` library, ensure that you have the necessary dependencies installed. On Ubuntu, you need to install the curl development headers. Use the following command:

```
sudo apt install -y libcurl4-openssl-dev
```

 To use `http-client` within your fpm project, add the following to your package `fpm.toml` file:

```toml
[dependencies]
http = { git = "https://github.com/fortran-lang/http-client.git" }
stdlib = "*"
```
## **Usage Example** 🔧
The following example demonstrates how to use the http package to make a **Simple GET request** and process the response

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
### Ouptut : 
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
In this example, we make a GET request to the URL https://jsonplaceholder.typicode.com/todos/1 to retrieve JSON data. If the request is successful, we print the ***response code, content length, method, and content***. If the request fails, we print the ***error message***.

## **Getting Started Guides** 👋


### **Table of contents:** 

1. ### [**Installation** 🌈](tutorial/tuotrial.md#installation)

2. ### [**Making HTTP Requests** 🚀](tutorial/tuotrial.md#making-http-requests-f09f9a80-1)
    - [**Sending `GET` Requests**](tutorial/tuotrial.md#sending-get-requests)
        - [*Accessing Response `Content`*](tutorial/tuotrial.md#accessing-response-content)
        - [*Extracting `Content Length`*](tutorial/tuotrial.md#extracting-content-length)
        - [*Retrieving `Status Codes`*](tutorial/tuotrial.md#retrieving-status-codes)
        - [*Handling `Errors`*](tutorial/tuotrial.md#handling-errors)
        - [*Getting Response `Headers`*](tutorial/tuotrial.md#getting-response-headers)
        - [*Understanding `pair_type` derived type*](tutorial/tuotrial.md#understanding-pair_type-derived-type)
        - [*Sending Custom `Headers`*](tutorial/tuotrial.md#sending-custom-headers)
        - [*Setting Request `Timeout`*](tutorial/tuotrial.md#setting-request-timeout)
        - [*Setting `Authentication`*](tutorial/tuotrial.md#setting-authentication)
    - [**Sending `POST` Requests**](tutorial/tuotrial.md#sending-post-request)
        - [*Sending Data using `data`*](tutorial/tuotrial.md#sending-data-using-data)
        - [*Sending Data using `form`*](tutorial/tuotrial.md#sending-data-using-form)
        - [*Sending Data using `file`*](tutorial/tuotrial.md#sending-data-using-file)
    - [**Sending `PUT` Requests**](tutorial/tuotrial.md#sending-put-requests)
    - [**Sending `PATCH` Requests**](tutorial/tuotrial.md#sending-patch-requests)
    - [**Sending `DELETE` Requests**](tutorial/tuotrial.md#sending-delete-requests)
    - [**Sending `HEAD` Requests**](tutorial/tuotrial.md#sending-head-requests)

3. ### [**Real Projects** 🤖](tutorial/tuotrial.md#real-projects-f09fa496-1)

## **Projects Currently using `http` package** 🥳

* **[github-org-analyzer](https://github.com/rajkumardongre/github-org-analyzer):** This Fortran project **provides procedures to analyze GitHub organizations and retrieve valuable information about their repositories**. By leveraging the power of the `http-client` package, this analyzer fetches data from the GitHub API to generate insightful reports.

    *~By [Rajkumar Dongre (rajkumardongre)](https://github.com/rajkumardongre)*
* **[fortran-xkcd](https://github.com/rajkumardongre/fortran-xkcd/tree/http_client_version):** An fpm example project written in Fortran 2018 that displays the latest xkcd comic inside an X window. As a limitation, only images in PNG format are supported (no JPEG). The alt text will be printed to console.

    *~By [Philipp (interkosmos)](https://github.com/interkosmos)*

* **[foropenai](https://github.com/gha3mi/foropenai):** A Fortran library for OpenAI API.

    *~By [AliG (gha3mi)](https://github.com/gha3mi)*

If you're utilizing the `http` package in your Fortran project and would like to be included on this list, we welcome you to contribute by creating a pull request (PR) and adding your project details. 

Let's build it together! 🤝

## **Contributing to project** 🌱
Thank you for your interest in contributing to the `http` Fortran package! Contributions from the community are valuable in improving and enhancing the functionality of the package. This section provides a guide on how to get the code, build the library, and run examples and tests.

### **Get the code**
To get started, follow these steps:

Clone the repository using Git:
```
git clone https://github.com/fortran-lang/http-client
cd http-client
```
### **Prerequisites**
Before building the library, ensure that you have the necessary dependencies installed. On `Ubuntu`, you need to install the curl development headers. Use the following command:
```
sudo apt install -y libcurl4-openssl-dev
```
### **Build the library**

The `http` package uses **fpm** as the build system. Make sure you have fpm `version 0.8.x` or later installed. To build the library, execute the following command within the project directory:

```
fpm build
```
### **Run examples**
The http package provides example programs that demonstrate its usage. To run the examples, use the following command:

```
fpm run --example <example name>
```
Executing this command will execute the example programs, allowing you to see the package in action and understand how to utilize its features.

### **Run tests**
 The http package includes a test suite to ensure its functionality is working as expected. To run the tests, execute the following command:
```
fpm test
```
Running the tests will validate the behavior of the package and help identify any issues or regressions.

### **Generating API Documentation**

Before generating API documentation, ensure that you have FORD installed on your system.

**Installation link**: [https://github.com/Fortran-FOSS-Programmers/ford#installation](https://github.com/Fortran-FOSS-Programmers/ford#installation)

Once FORD is set up, execute the following command to build the API documentation:

```bash
ford ford.md
```

### **Supported compilers**

http-client is known to work with the following compilers:

* GFortran 11 & 12 (tested in CI)
* Intel OneAPI ifx v2023.1.0 and ifort classic v2021.9.0

### **Contributing guidelines**

When contributing to the http Fortran package, please keep the following guidelines in mind:

* Before making any substantial changes, it is recommended to open an issue to discuss the proposed changes and ensure they align with the project's goals.
* Fork the repository and create a new branch for your contribution.
* Ensure that your code adheres to the existing coding style and follows good software engineering practices.
* Write clear and concise commit messages.
* Make sure to test your changes and ensure they do not introduce regressions or break existing functionality.
* Submit a pull request with your changes, providing a clear explanation of the problem you are solving and the approach you have taken.

We appreciate your contributions and look forward to your valuable input in improving the http Fortran package.

Happy coding!👋
