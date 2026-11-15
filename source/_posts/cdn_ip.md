---
title: CDN中记录真实IP
date: 2016-12-25 17:34:52
tags:
- X-FORWARDED-FOR

categories:
- Network

---
#### 使用CDN后在网页服务器日志中显示真实的用户IP地址
##### 真实IP：为解决这个问题，可以通过在云加速转发的HTTP头信息中增加 X-Forwarded-For 信息，用于记录客户端的真实IP，这时web服务器的日志就可以使用 $http_x_forwarded_for变量记录远程客户端的真实IP。格式如下：
<!-- more -->

1. Nginx
`
'$http_x_forwarded_for - $remote_user [$time_local] "$request" '
'$status $body_bytes_sent "$http_referer" '
'"$http_user_agent" ';
`
2. Apache
`
LogFormat "%{X-Forwarded-For}i %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\""
`
