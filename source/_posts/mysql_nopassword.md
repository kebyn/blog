---
title: MySQL无密码登陆（MySQL_config_editor用法）
date: 2017-03-16 19:22:42
tags:
- database
- mysql
- conf
- password
- script
categories:
- Database

---
#### mysql_config_editor是MySQL5.6.6以后版本的工具。这个工具可以认证信息加密存储在`.mylogin.cnf`中，通常这个文件在Linux用户的`家目录`和Windows的`%APPDATA%\MySQL`目录中。

##### `.mylogin.cnf`文件未加密的示例如下：
```
[client]
user = mydefaultname
password = mydefaultpass
host = 127.0.0.1
[mypath]
user = myothername
password = myotherpass
host = localhost
```
> 实际使用时密码会被加密。
>> 大坑！！！ 含有特殊字符的密码不能加密成功，没有报错，但是登陆会提示密码错误，让人迷惑。    ----于2017/04/01更新
<!-- more -->
##### mysql_config_editor的用法
`
shell> mysql_config_editor [program_options] command [command_options]
`
#### 添加认证信息
```
#添加认证时查看帮助信息
shell> mysql_config_editor --help set
shell> mysql_config_editor set --help

#添加认证信息
shell> mysql_config_editor set --login-path=client
         --host=localhost --user=localuser --password
Enter password: enter password "localpass" here
shell> mysql_config_editor set --login-path=remote
         --host=remote.example.com --user=remoteuser --password
Enter password: enter password "remotepass" here

#查看已经添加的认证信息
shell> mysql_config_editor print --all
[client]
user = localuser
password = *****
host = localhost
[remote]
user = remoteuser
password = *****
host = remote.example.com
```

#### 无密码登陆
```
shell> mysql --login-path=remote

shell> mysql --login-path=client
#因为mysql默认读取login-path=client的认证信息，所以上条命令可以简化如下
shell> mysql

shell> mysql --login-path=remote --host=remote2.example.com
```
#### 移除认证信息
```
shell> mysql_config_editor remove --login-path=mypath --user
shell> mysql_config_editor remove --login-path=mypath
```

#### 查看帮助
`
shell> mysql_config_editor command --help
`
#### 参考链接
[https://dev.mysql.com/doc/refman/5.6/en/mysql-config-editor.html](https://dev.mysql.com/doc/refman/5.6/en/mysql-config-editor.html)
[https://dev.mysql.com/doc/refman/5.7/en/mysql-config-editor.html](https://dev.mysql.com/doc/refman/5.7/en/mysql-config-editor.html)
