---
title: apache_conf
date: 2014-04-06 13:14:43
tags:
- httpd
- conf
- apache
categories:
- Web

---
1. 尽量安装新版本的Apache
<!-- more -->
2. 禁用不需要的模块，找到httpd.conf的loadModule行，对于不需要的用#注释掉
3. 设置Apache的bin、conf、logs目录属主为root，权限为755
4. 将Apache以专用的用户身份运行，配置httpd.conf
```
    User www-data
    Group www-data
```
5. 禁止目录索引，关闭服务端SSI包含
```
    <Directory/var/www/html>
        Options -Indexes -Includes
    </Directory>
```
6. 禁止对目录配置文件进行重载
```
    <Directory/>
        AllowOverride None
    </Directory>
```
7. 仅允许访问指定目录。对根目录设置禁止访问，然后对需要让用户访问的目录开放访问权限
```
    <Directory/>
        Order deny,allow
        Deny from all
    </Directory>
    <Directory"/var/www/www.example.com">
        Order allow,deny
        Allow from all
    </Directory>
```
8. 隐藏特征，不展示Web服务器类型和版本
```
    ServerSignatureOff
    ServerTokensProd
```
9. 目录访问限制，可以设置重要目录只允许特定的IP访问
```
    <Directory"/var/www/www.example.com/admin">
        order deny,allow
        denyfrom all
        allowfrom 10.1.0.0/16
    </Directory>
```
