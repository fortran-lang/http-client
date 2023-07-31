---
project: HTTP
src_dir: ./src
output_dir: ./doc
project_github: https://github.com/fortran-lang/http-client
summary: The http Fortran package provides a simple and convenient way to make HTTP requests and retrieve responses. It aims to simplify the process of interacting with web services by providing a high-level API.
author: Rajkumar Dongre
github: https://github.com/rajkumardongre
email: rajkumardongre17@gmail.com
twitter: https://twitter.com/ATOM12060827
author_description: Just Love to build Things 🛠️
graph: true
search: true
display: public
         protected
         private
source: true
print_creation_date: true
creation_date: %Y-%m-%d %H:%M %z

---



## **Overview**

> The `http-client` Fortran package provides a user-friendly interface for making HTTP requests and handling responses. It allows users to interact with web services, send various types of data, and retrieve response content, status code, headers, and other relevant information. Additionally, the package supports error handling, request timeout settings, and authentication options.
___
## **Features**

> The package includes the following features:

> 1. #### **Sending HTTP Requests:**
    - **`GET`**: Retrieve data from the server.
    - **`POST`**: Submit data to be processed by the server.
    - **`PUT`**: Replace or create resources on the server.
    - **`DELETE`**: Remove resources from the server.
    - **`PATCH`**: Partial updates to resources.
    - **`HEAD`**: Retrieve response headers without the response content.

> 2. #### **Data Support:**
    - Send any type of data with requests, including support for `file` uploads and `form data`.
    
> 3. #### **Response Handling:**
    - Retrieve response `content`.
    - Get the HTTP `status code` returned by the server.
    - Fetch the `length` of the response content.
    - Access response `headers`.
  
> 4. #### **Custom Headers:**
    - Include `custom headers` in requests to the server.

> 5. #### **Error Handling:**
    - Detect and handle unsuccessful requests gracefully, with informative `error messages`.

> 6. #### **Request Timeout:**
    - Set a maximum time allowed for a request to complete, improving responsiveness.

> 7. #### **Authentication:**
    - Authenticate requests to protected resources using standard authentication methods.
___
> ## **Installation**

> Before building the `http-client` library, ensure that you have the necessary dependencies installed. On Ubuntu, you need to install the curl development headers. Use the following command:

```
sudo apt install -y libcurl4-openssl-dev
```

> To use `http-client` within your fpm project, add the following to your package manifest file (`fpm.toml`):

```toml
[dependencies]
http = { git = "https://github.com/fortran-lang/http-client.git" }
stdlib = "*"
```
___
>## **Tutorial:**

>### <u>***Content Table***</u>

>1. #### **Getting Started** 👋
    - Installing Dependencies (Ubuntu)
    - Setting up the Package in your Project

>2. #### **Making HTTP Requests** 🚀
    - **Sending `GET` Requests**
        - *Accessing Response `Content`*
        - *Retrieving `Status Codes`*
        - *Getting Response `Headers`*
        - *Extracting `Content Length`*
    - **Sending `POST` Requests**
        - *Sending `Data` with Requests*
        - *Sending `Form Data`*
        - *Uploading `File`*
    - **Sending `PUT` Requests**
    - **Sending `PATCH` Requests**
    - **Sending `DELETE` Requests**
    - **Sending `HEAD` Requests**

>3. #### **Customizing Requests** ✏️
    - Sending Custom Headers
    - Setting Request Timeout
    - Authentication Options

>4. #### **Error Handling** 🤨
    - Handling Unsuccessful Requests
    - Displaying Error Messages

>5. #### **Real Projects** 🤖
    -  GitHub organization analyzer : Retrieve valuable information about the organization repositories

>6. #### **Conclusion** 🤝
    - Recap of Package Features
    - Summary of Tutorial



