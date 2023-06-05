# http-client

HTTP client library for Fortran

## Getting started

Get the code:

```
git clone https://github.com/fortran-lang/http-client
cd http-client
```
Install curl development headers on Ubuntu
```
sudo apt install -y libcurl4-openssl-dev
```

Build the library using [fpm](https://fpm.fortran-lang.org).
http-client requires fpm version 0.8.x or later to build.
Type:

```
fpm build
```

To run the examples, type:

```
fpm run --example
```

To run the tests, type:

```
fpm test
```
