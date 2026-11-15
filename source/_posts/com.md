---
title: 串口调试
date: 2017-08-09 13:23:57
tags:
- com
- minicom
- common
categories:
- Linux

---
### Linux下调试串口服务器的命令
<!-- more -->

```
minicom -D /dev/ttyUSB0 -H -w -o

  - -D 指定串口设备

  - -H 使用16进制输出

  - -w 滚屏输出

  - -o 不对设备进行初始化

  - -c on/off 输出开启颜色
```
### Windows 下调试串口服务器的软件
+ [common](https://github.com/movsb/common)
