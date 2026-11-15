---
title: openssl生成cert
date: 2017-07-13 16:14:43
tags:
- openssl
- cert
categories:
- Security

---
```
openssl genrsa -des3 -out server.key 2048
openssl rsa -in server.key -out server.key
openssl req -sha256 -new -key server.key -out server.csr -subj '/CN=localhost'
openssl x509 -req -sha256 -days 36500 -in server.csr -signkey server.key -out server.crt
```
> [https://stackoverflow.com/questions/10175812/how-to-create-a-self-signed-certificate-with-openssl](https://stackoverflow.com/questions/10175812/how-to-create-a-self-signed-certificate-with-openssl)
<!-- more -->


```
$ cat cert.pem
-----BEGIN CERTIFICATE-----
MIIDUzCCAjugAwIBAgIUc9s+2e+ABxNDunYGckzbCz+q4xMwDQYJKoZIhvcNAQEL
BQAwOTEUMBIGA1UEAwwLZXhhbXBsZS5jb20xFDASBgNVBAoMC0V4YW1wbGUgT3Jn
MQswCQYDVQQGEwJVUzAeFw0yNjExMTUwODA1MzNaFw0zNjExMTIwODA1MzNaMDkx
FDASBgNVBAMMC2V4YW1wbGUuY29tMRQwEgYDVQQKDAtFeGFtcGxlIE9yZzELMAkG
A1UEBhMCVVMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC0GV/qb354
zxZ8VFua2Tyb/Ox8lZNJSsG0XX2c3YELydHtEJyfHd72o/w/palCr2Rq2VxSX7dI
XlkuuWlfILgUVjfw/MIujmMIenlP4CUMQwDrMhnEE7U36r0xfXdHUdPTd47PR8cc
s+aXYHBlXPRc2EVVVBHY7SNAjZ0m2b8jZ9Vj9tYNBcAvHChi2iP5OsulPWQVxT4a
jgJURfMrYrw6K16ktYumASHKUs4t0XQzCfzadaHM0HW91GjdbzZ9axc9Ta2uizvv
RDc9iQ8bI29FRQN9Vtzmd0AV/HXioYdP78MwL6PPKFarAhpXNPpfxsB+sfUToyOR
QIJ6/IqDfOsDAgMBAAGjUzBRMB0GA1UdDgQWBBR1YsIR8Wcaz3RRugV7NW50b4zb
iDAfBgNVHSMEGDAWgBR1YsIR8Wcaz3RRugV7NW50b4zbiDAPBgNVHRMBAf8EBTAD
AQH/MA0GCSqGSIb3DQEBCwUAA4IBAQA4hzddmPOKy2dfrlFLgwdxYgGBmWGpWPkR
cSKvzx7flQt8ujMVStXw9GeBu0ajETR1kV791kUtgq043ixKDxcy9lvgm6pB9KmG
XzBwrlYl+XLUdvNe4reomVgej7455ozIyAsKf90Pfvhj1ZPyaP6EsU6Ce+tJm0ZQ
W4PJjJhsfVQzAUEhG89XdE1dovO2bT78FP21WHb9exwoZ2iAU1WbpxFIozx272Eh
cMa98IUND1sVjrbkqNC3FqdvkL7Fgy0ciV94/Jc103Rkc8YL1Z4VM5u92mIMm65r
+MjkPW0Ng+8b1iGUYdE/fxR3KjGk2bRwvKZL2KuZiaL+4LBJozOU
-----END CERTIFICATE-----
```
```
$ git config --local http.sslCAInfo /path/cert.pem
$ git config --local --unset http.sslCAInfo
```
```
$ git config --local http.sslVerify false #NO NEED TO USE THIS
$ git config --local --unset http.sslverify
```
- Copy CA cert to /usr/local/share/ca-certificates.
```
sudo update-ca-certificates
sudo service docker restart
```
