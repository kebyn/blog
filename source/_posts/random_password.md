---
title: random_password
date: 2016-07-17 12:23:33
tags:
- password
- random
- command
categories:
- Security

---

1. `</dev/urandom  tr -dc ' 0-9a-zA-Z-~!@#$%,./\|'  | head -c32; echo ""`
<!-- more -->

2. `< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-32};echo;`
   - 上述命令使用内嵌的/dev/urandom，只输出字符，结果取头32个。

3. `openssl rand -base64 32`
   - 上述命令使用系统自带的openssl的随机特点来产生随机密码

4. `tr -cd ' [:alnum:]'  < /dev/urandom | fold -w30 | head -n1`

5. `strings /dev/urandom | grep -o '[[:alnum:]]' | head -n 32 | tr -d '\n'; echo`
   - 通过过滤字符命令，输出随机密码

6. `< /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c6
`
7. `dd if=/dev/urandom bs=1 count=32 2>/dev/null | base64 -w 0 | rev | cut -b 2- | rev`

8. `date +%s | sha256sum | base64 | head -c 32 ; echo`
   - 上述命令使用SHA来哈希日期，输出头32个字节。

9. `randpw(){ < /dev/urandom tr -dc _A-Z-a-z-0-9 | head -c${1:-16};echo;}`

10. `date | md5sum`
