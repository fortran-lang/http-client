# **Welcome**
### *Welcome to the Getting Started Guides.* 👋

### **Table of contents:** 📜 

1. ### [**Installation** 🌟](#installation)

2. ### [**Making HTTP Requests** 🚀](#making-http-requests-f09f9a80-1)
    - [**Sending `GET` Requests**](#sending-get-requests)
        - [*Accessing Response `Content`*](#accessing-response-content)
        - [*Extracting `Content Length`*](#extracting-content-length)
        - [*Retrieving `Status Codes`*](#retrieving-status-codes)
        - [*Handling `Errors`*](#handling-errors)
        - [*Getting Response `Headers`*](#getting-response-headers)
        - [*Understanding `pair_type` derived type*](#understanding-pair_type-derived-type)
        - [*Sending Custom `Headers`*](#sending-custom-headers)
        - [*Setting Request `Timeout`*](#setting-request-timeout)
        - [*Setting `Authentication`*](#setting-authentication)
    - [**Sending `POST` Requests**](#sending-post-request)
        - [*Sending Data using `data`*](#sending-data-using-data)
        - [*Sending Data using `form`*](#sending-data-using-form)
        - [*Sending Data using `file`*](#sending-data-using-file)
    - [**Sending `PUT` Requests**](#sending-put-requests)
    - [**Sending `PATCH` Requests**](#sending-patch-requests)
    - [**Sending `DELETE` Requests**](#sending-delete-requests)
    - [**Sending `HEAD` Requests**](#sending-head-requests)

3. ### [**Real Projects** 🤖](#real-projects-f09fa496-1)
    

1. # **Installation** 🌟

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

2. # **Making HTTP Requests** 🚀
## **Sending `GET` Requests**
Let's First Import `http` package into our program
```fortran
program send_get_request
    use http, only : request, response_type
    ...
end program send_get_request
```
For making a `GET` request we required to import `request` function which is use to configure our HTTP request(like setting request `URL`, `method`, `headers` and etc.).

The `request()` function returns a `response_type` object, containing server response. so we also have to import `response_type` derived type to store server response, like below.

```fortran
type(response_type) :: response
```
Now Let's make the HTTP `GET` request.
```fortran
response = request(url='https://httpbin.org/get')
```
The above code will make a HTTP `GET` request to https://httpbin.org/get url and store the server response in `response` variable.

Now let's study the `response` object in detail. 🧐

The `response` object contain rich information about server response. It contains following attribute.

* `url` : The URL of the request.
* `method` : The HTTP method of the request.
* `content` : The content of the server response.   
* `err_msg` : The Error message if the response was not successful.
* `status_code` : The HTTP status code of the response.
* `content_length` : length of the response content.
* `ok` : Boolean flag, which indicates weather the request was sucessfull or not.
* `header` :  An array of **name-value** pairs representing response headers.

### **Accessing Response `Content`**
To access the content of the server's response, use the `content` attribute:

```fortran
print *, 'Response Content: ', response%content
```
### **Extracting `Content Length`**

You can retrieve the response content length using the `content_length` attribute:

```fortran
print *, 'Response Length: ', response%content_length
```

### **Retrieving `Status Codes`**

HTTP response [`status codes`](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status) indicate whether a request was successful or not. The status code is stored in the `status_code` attribute:

```fortran
print *, 'Response Code: ', response%status_code
```
### **Handling `Errors`**

Ensuring robust error handling is crucial when working with HTTP requests. You can verify the success of your request by inspecting the `ok` attribute in the response. If the attribute is `.false.`, it indicates a request failure. Conversely, if it's `.true.`, the HTTP request was successful.

```fortran
print *, 'Request is Successful: ', response%ok
```

In cases where the request encounters an issue, the `err_msg` attribute in the response will contain information about the reason for the failure. It's essential to handle errors gracefully:

```fortran
if (.not. response%ok) then
    print *, response%err_msg
    ! Code for handling the failed request
else
    ! Code for processing a successful request
end if
```

> **Note:** 
>
> Always prioritize checking the `ok` attribute of the response to identify any request failures. Incorporate the provided code snippet whenever you are processing the response to ensure comprehensive error management. This practice will help you build more robust and reliable HTTP interactions.

### **Getting Response `Headers`**

The response headers are stored as array of [`pair_type`](#pair_type-derived-type) object in `header` attribute.

```fortran
print *, 'Response Header Size : ', size(response%header)
```
We can iterate over all the `headers` in this way.
```fortran
implicit none
character(:), allocatable :: header_name, header_value
integer :: i
!...
!...
do i=1, size(response%header)
    header_name = response%header(i)%name
    header_value = response%header(i)%value
    print *,header_name, ': ', header_value
end do
```

Complete program for sending `GET` request : 
```fortran
program get
    use http, only : request, response_type 
    implicit none
    type(response_type) :: response
    character(:), allocatable :: header_name, header_value
    integer :: i
    
    ! Making a GET request
    response = request(url='https://httpbin.org/get')
    
    ! Checking any errors
    if(.not. response%ok) then
        print *, 'Request Fail: ', response%err_msg
    else
        print *, 'Status Code : ', response%status_code
        print *, 'Content : ',  response%content
        print *, 'Content Length : ', response%content_length
        print *, 'Response Header Size : ', size(response%header)

        print *, 'All response headers :'
        ! Traversing over all response headers
        do i=1, size(response%header)
            ! Extracting header name 
            header_name = response%header(i)%name
            ! Extracting corresponding header value 
            header_value = response%header(i)%value
            print *, header_name, ': ', header_value
        end do
    end if
end program get
```


Before we proceed, it's crucial to grasp the `pair_type` derived type, as we will be utilizing it in various scenarios.

### **Understanding `pair_type` derived type**

It is use to store a **name-value pair**.

```fortran
! pair_type defination
type :: pair_type
    character(:), allocatable :: name, value
end type pair_type
```
It serves various purposes within the `http` package.
 
1. Storing request and response `headers` as array of `pair_type` objects, where :
    - `name` represent the header name.
    - `value` represent the header value.
 
2. Representing fields in a url-encoded **HTTP `form`**:
    - `name` to represent the form field name.
    - `value` to represent the form field value.
 
3. Storing information about the `file` to upload:
    - `name` to represent the name of the file.
    - `value` to represent the path of the file on the local system.
 
4. Storing authentication detail, require to authenticate the request.
    - `name` to represent the **username**
    - `value` to represent the **password**


### **Sending Custom `Headers`**

Much like [response headers](#getting-response-headers), request headers are also stored as an array of [`pair_type`](#pair_type-derived-type) objects. These headers are provided through the `header` attribute of the `request()` function.

```fortran
program send_headers
    use http, only : request, response_type, pair_type
    implicit none
    type(response_type) :: response
    type(pair_type), allocatable :: req_headers(:) ! will store request headers
    
    ! Storing request header in array of pair_type object, where each pair_type
    ! object represents a single header. (in header-name,header-value format)
    req_headers = [ &
      pair_type('my-header-1', 'Hello World'), &
      pair_type('my-header-2', 'Hello Universe'), &
      pair_type('Set-Cookie', 'Theme-Light'), &
      pair_type('Set-Cookie', 'Auth-Token: 12345'), &
      pair_type('User-Agent', 'my user agent') &
    ]
    
    ! Congiguring request with API URL and request headers
    response = request( &
        url='https://httpbin.org/headers', &
        header=req_headers &
    )
    
    ! Checking for any error
    if(.not. response%ok) then
        print *, 'Request Fail: ', response%err_msg
    else
        print *, 'Content : ',  response%content
    end if
end program send_headers
```
### **Setting Request `Timeout`**

The overall `timeout` for the request, which is the time the entire request must complete. The value of this timeout(**in seconds**) can be set by passing the `timeout` parameter to the `request()` function.

```fortran
program timeout
    ! The request below is designed to take more than 10 seconds to complete, 
    ! but we set the timeout value to 5 seconds.
    ! As a result, the request will fail with an error message that says 
    ! "Timeout was reached".
    use http, only: response_type, request
    implicit none
    type(response_type) :: response

    ! Delay in response for 10 seconds
    response = request( &
        url='https://httpbin.org/delay/10', &
        timeout=5 &
    )
    
    ! Checking for any error
    if(.not. response%ok) then
        print *,'Error message : ', response%err_msg
    else
        print *, 'Response Content : ', response%content
    end if
end program timeout
```

### **Setting `Authentication`**

We can set a Basic Authentication to the request by setting `auth` parameter to the `request()` function.  

The `auth` parameter takes `pair_type` object as value, in which <u>`name` represent the **username** and `value` represent the **password**.</u>

```fortran
program authentication
    ! Making request with HTTP Basic Auth
    use http, only: response_type, request, pair_type
    implicit none
    type(response_type) :: response
    type(pair_type) :: req_auth

    ! setting username and password required for authentication
    req_auth = pair_type('user', 'passwd')

    ! Configuring request
    response = request( &
        url='https://httpbin.org/basic-auth/user/passwd', &
        auth=req_auth &
    )
    
    ! Checking for any error
    if(.not. response%ok) then
        print *,'Error message : ', response%err_msg
    else
        print *, 'Response Code    : ', response%status_code
        print *, 'Response Content : ', response%content
    end if
end program authentication
```
Output  : 
```bash
 Response Code    :          200
 Response Content : {
  "authenticated": true, 
  "user": "user"
}
```
> **Note :**
>
>It sends the **username** and **password** over the network **in plain text, easily captured by others**.

## **Sending `POST` Request**

An HTTP `POST` request is used to send data to a server, where data are shared via the body of a request. You can send a `POST` request by setting `method` parameter of `request()` function to `HTTP_POST`.

```fortran
program post
    use http, only: response_type, request, HTTP_POST
    implicit none
    type(response_type) :: response

    ! Setting HTTP Method for request
    response = request( &
        url='https://example.com/post', &
        method=HTTP_POST &
    )

end program post
```

Within the `http` package, there are several options for sending data, accomplished through three mainly parameters: `data`, `form`, and `file` within the `request()` function.

Now let's see each of them 🧐 

### **Sending Data using `data`**

The `data` parameter allows us to transmit a variety of data. When utilizing this parameter, it's essential to include the `Content-Type` header, indicating the type of data being transmitted.

**Sending plain text :** 
```fortran
program post
    ! This program demonstrates sending plain text data using POST request 
    use http, only: response_type, request, HTTP_POST, pair_type
    implicit none
    type(response_type) :: response
    character(:), allocatable :: req_data
    type(pair_type), allocatable :: req_header(:)

    ! Setting Content-type header for sending plain text
    req_header = [pair_type('Content-Type', 'text/plain')]

    ! plain-text data we want to send
    req_data = 'Hello, this data needs to be sent to the server.'

    ! Setting HTTP POST method and Data to be send on server
    response = request( &
        url='https://httpbin.org/post', &
        method=HTTP_POST, &
        data=req_data, &
        header=req_header &
    )

    ! Checking for any error
    if(.not. response%ok) then
        print *, 'Request Fail: ', response%err_msg
    else
        print *, 'Response Content : ', response%content
    end if
end program post
```
**Sending JSON data :**
```fortran
program post
    ! This program demonstrates sending JSON data using POST request.
    use http, only: response_type, request, HTTP_POST, pair_type
    implicit none
    type(response_type) :: response
    character(:), allocatable :: json_data
    type(pair_type), allocatable :: req_header(:)

     ! Setting Content-type header for sending JSON
    req_header = [pair_type('Content-Type', 'application/json')]

    ! JSON data we want to send
    json_data = '{"name":"Jhon","role":"developer"}'

    ! Configuring request with HTTP Method, JSON data and request headers
    response = request( &
        url='https://httpbin.org/post',& 
        method=HTTP_POST, &
        data=json_data, &
        header=req_header &
    )

    ! Checking for any errors
    if(.not. response%ok) then
        print *, 'Request Fail: ', response%err_msg
    else
        print *, 'Response Content : ', response%content
    end if
end program post
``` 
### **Sending Data using `form`**

When you need to transmit HTML form data to the server, you can utilize the `form` parameter to pass the data. The `form` parameter accepts an array of `pair_type` objects, where each `pair_type` object represents a **single form field**.

The `form` data is initially URL encoded and then sent as the request's body. If no `Content-type` header is specified, a default `Content-type` header with the value `application/x-www-form-urlencoded` will be automatically set.

```fortran
program post_form_data
    ! This program demonstrates sending Form data using a POST request.
    use http, only: response_type, request, HTTP_POST, pair_type
    implicit none
    type(response_type) :: response
    type(pair_type), allocatable :: form_data(:)

    ! Store form data in an array of pair_type objects, where each  
    ! pair_type object represents a single form field
    form_data = [ &
        pair_type('name', 'John'), &
        pair_type('job', 'Developer') &
    ]

    ! Make the HTTP POST request with the form data
    response = request( &
        url='https://httpbin.org/post', &
        method=HTTP_POST, &
        form=form_data &
    )
    
    ! Checking for any errors
    if (.not. response%ok) then
        print *, 'Error message: ', response%err_msg
    else
        print *, 'Response Content: ', response%content
    end if
end program post_form_data
```

### **Sending Data using `file`**

When you need to send a file (such as .png, .jpg, .txt, etc.) to a server, you can utilize the `file` parameter within the `request()` function. This parameter takes a `pair_type` object as its value. In this `pair_type` object, the `name` member specifies the field name under which the file will be sent to the server, and the `value` member represents the path to the file you want to send.

If you don't explicitly provide a `Content-type` header, a default `Content-type` header with the value `multipart/form-data` will be automatically set.

```fortran
program post_file

    ! This program demonstrates sending a File using a POST request.
    
    use http, only : request, response_type, HTTP_POST, pair_type
    implicit none
    type(response_type) :: response
    type(pair_type) :: file_data

    ! Specify the pair_type object as ('<file_field_name>', '/path/to/file.txt')
    file_data = pair_type('my_file', '/path/to/file.txt')

    ! Make the HTTP POST request with the file data
    response = request( &
        url='https://httpbin.org/post', &
        method=HTTP_POST, &
        file=file_data &
    )

    ! Checking for any errors
    if (.not. response%ok) then
        print *, 'Error message: ', response%err_msg
    else
        print *, 'Response Content: ', response%content
    end if
end program post_file
```

#### **Note** : 
- If `data` member is provided, it takes the **highest priority** and is sent as the  body of the request. Any other provided `file` or `form` members will be ignored, and only the `data` member will be included in the request body.

- If both `form` and `file` members are provided, both `form` and `file` data are included as part of the request body. A default `Content-type` header with value `multipart/form-data` will be set if no `Content-type` header is provided.

- If `data`, `form`, and `file` are all provided, only `data` is sent, and the `form` and `file` inputs are ignored.

## **Sending `PUT` Requests**

Sending a `PUT` request is quite similar to sending a [`POST`](#sending-post-request) request. In this case, the `method` parameter should be set to `HTTP_PUT`.

```fortran
program put
    ! This program demonstrates sending JSON data with PUT request.
    use http, only: response_type, request, HTTP_PUT, pair_type
    implicit none
    type(response_type) :: response
    character(:), allocatable :: json_data
    type(pair_type), allocatable :: req_header(:)

    req_header = [pair_type('Content-Type', 'application/json')]

    ! JSON data we want to send
    json_data = '{"name":"Jhon","role":"developer"}'

    response = request( &
        url='https://httpbin.org/put',& 
        method=HTTP_PUT, &
        data=json_data, &
        header=req_header &
    )

    if(.not. response%ok) then
        print *, 'Request Fail: ', response%err_msg
    else
        print *, 'Response Content : ', response%content
    end if
end program put
``` 

## **Sending `PATCH` Requests**

Sending a `PATCH` request is quite similar to sending a [`POST`](#sending-post-request) request. In this case, the `method` parameter should be set to `HTTP_PATCH`.

```fortran
program patch
    ! This program demonstrates sending JSON data with PATCH request.
    use http, only: response_type, request, HTTP_PATCH, pair_type
    implicit none
    type(response_type) :: response
    character(:), allocatable :: json_data
    type(pair_type), allocatable :: req_header(:)

    req_header = [pair_type('Content-Type', 'application/json')]

    ! JSON data we want to send
    json_data = '{"name":"Jhon","role":"developer"}'

    response = request( &
        url='https://httpbin.org/patch',& 
        method=HTTP_PATCH, &
        data=json_data, &
        header=req_header &
    )

    if(.not. response%ok) then
        print *, 'Request Fail: ', response%err_msg
    else
        print *, 'Response Content : ', response%content
    end if
end program patch
``` 

## **Sending `DELETE` Requests**

To send a `DELETE` request, simply set the `method` parameter to `HTTP_DELETE`.

```fortran
program delete
    ! This program demonstrates sending DELETE request.
    use http, only: response_type, request, HTTP_DELETE
    implicit none
    type(response_type) :: response

    response = request( &
        url='https://httpbin.org/delete',& 
        method=HTTP_DELETE &
    )

    if(.not. response%ok) then
        print *, 'Request Fail: ', response%err_msg
    else
        print *, 'Response Content : ', response%content
    end if
end program delete
``` 

## **Sending `HEAD` Requests**

To send a `HEAD` request, simply set the `method` parameter to `HTTP_HEAD`.

```fortran
program head
    ! This program demonstrates sending HEAD request.
    use http, only: response_type, request, HTTP_HEAD
    implicit none
    type(response_type) :: response

    response = request( &
        url='https://www.w3schools.com/python/demopage.php',& 
        method=HTTP_HEAD &
    )

    if(.not. response%ok) then
        print *, 'Request Fail: ', response%err_msg
    else
        print *, 'Request is Successfull!!!'
    end if
end program head
```

3. # **Real Projects** 🤖

-  [**GitHub organization analyzer**](example-project/github-org-analyzer.md) : 

    This Fortran project **provides procedures to analyze GitHub organizations and retrieve valuable information about their repositories**. By leveraging the power of the `http-client` package, this analyzer fetches data from the GitHub API to generate insightful reports.

- There are many more to come... 