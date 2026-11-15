---
title: ngrok server 简单部署
date: 2017-12-10 13:43:52
tags:
- ngrok
- tunnel
categories:
- Network

---

ngrok 服务端部署与证书配置备忘。

<!-- more -->

- [ngrok下载](https://github.com/inconshreveable/ngrok/releases)
- 生成网站证书
```
openssl genrsa -out rootCA.key 4096
openssl req -x509 -new -nodes -key rootCA.key -subj "/CN=kebyn.cc" -days 36500 -out rootCA.pem
openssl genrsa -out device.key 4096
openssl req -new -key device.key -subj "/CN=kebyn.cc" -out device.csr
openssl x509 -req -in device.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out device.crt -days 36500
```
- 替换 ngrok 默认证书
```
cp rootCA.pem ../assets/client/tls/ngrokroot.crt
cp device.crt ../assets/server/tls/snakeoil.crt
cp device.key ../assets/server/tls/snakeoil.key
```
- 非 root 用户
```
sudo GOOS=darwin GOARCH=386 make release-all && sudo GOOS=darwin GOARCH=amd64 make release-all &&sudo GOOS=linux GOARCH=386 make release-all && sudo GOOS=linux GOARCH=amd64 make release-all &&sudo GOOS=linux GOARCH=arm make release-all && sudo GOOS=linux GOARCH=arm64 make release-all &&sudo GOOS=windows GOARCH=386 make release-all && sudo GOOS=windows GOARCH=amd64 make release-all
```
- root 用户
```
GOOS=darwin GOARCH=386 make release-all && GOOS=darwin GOARCH=amd64 make release-all && GOOS=linux GOARCH=386 make release-all && GOOS=linux GOARCH=amd64 make release-all && GOOS=linux GOARCH=arm make release-all && GOOS=linux GOARCH=arm64 make release-all && GOOS=windows GOARCH=386 make release-all && GOOS=windows GOARCH=amd64 make release-all
```
