---
title: rsapberry ssh 连接不上问题 (raspberry ssh connection failed)
date: 2017-04-16 22:36:17
tags:
- raspberry
- ssh
- release
categories:
- Network

---

##### 2016-11-25：
  ___*默认情况下禁用SSH; 可以通过在引导分区中创建名为“ssh”的文件来启用___
  ___*启用默认密码时启用SSH时提示密码更改___
> [官方文档](http://downloads.raspberrypi.org/raspbian/release_notes.txt)

```
2017-04-10：
  * Wolfram Mathematica更新到11.0.1版本
  * Adobe Flash Player已更新至版本25.0.0.127
  *使用PARTUUID来支持USB启动
2017-03-02：
  *更新内核和固件（最终的Pi Zero W支持）
  * Wolfram Mathematica更新到版本11
  * NOOBS安装现在检查在NOOBS分区上是否存在'ssh'文件。
2017-02-16：
  * Chromium浏览器更新到版本56
  * Adobe Flash Player已更新至24.0.0.221版
  * RealVNC Server和Viewer更新到6.0.2版（RealVNC Connect）
  * Sonic Pi更新到2.11版本
  * Node-RED更新到版本0.15.3
  * Scratch更新到120117版本
  *使用默认密码检测启用的SSH已移至PAM
  *更新桌面GL驱动程序，以支持使用假KMS选项
  * Raspberry Pi配置和raspi-config允许设置固定的HDMI分辨率
  * raspi-config允许串行硬件独立于串行终端
  *更新内核和固件
  *各种小错误修复和可用性和外观调整
2017-01-11：
  *使用FAT32格式的引导分区重新发布2016-11-25图像
2016-11-25：
  *默认情况下禁用SSH; 可以通过在引导分区中创建名为“ssh”的文件来启用
  *启用默认密码时启用SSH时提示密码更改
  *包括Adobe Flash Player
  *更新Chromium浏览器中的硬件视频加速
  * Greeter现在使用外观设置中最后一个设置的背景图像，而不是pi用户
  *更新版本的Scratch
  *从raspi-config和Raspberry Pi Configuration中删除Rastrack选项
  *能够禁用图形启动启动屏幕添加到raspi-config和Raspberry Pi配置
  *外观设置对话框标签为在小屏幕上更好地工作
  * Raspberry Pi配置现在需要当前密码才能更改密码
  *各种小错误修复
  *更新固件和内核
```
<!-- more -->
```
2016-09-23：
  *新的PIXEL桌面环境 - 新的图标集，窗口设计，桌面图像，启动屏幕和恭喜
  *包含Chromium网络浏览器
  *包含Infinality字体渲染补丁
  *包括RealVNC服务器和查看器
  *包含SenseHAT仿真器
  * RFkill条目添加到Wifi和蓝牙面板插件
  *更新各种标准应用程序，包括Scratch和NodeRED
  *各种错误修复，调整和翻译更新
  *更新固件和内核（https://github.com/raspberrypi/firmware/commit/ad8608c08b122b2c228dba0ff5070d6e9519faf5）
至于27：
  *当D-bus不可访问时，修复了lxpanel的崩溃
  *固定D-bus蓝牙访问权限
  *从关闭选项中删除sudo
  *主题更新的工具提示的外观
  *固定弹出插件抓取焦点
  * raspi-config命令行和GUI应用程序整理; 删除不必要的重启
  *在piclone中更多错误检测; 复制添加的卷名称和ID
  *更新翻译文件
2016-05 -10：
  *新版Scratch，不再需要sudo
  *新版BlueJ
  *新版本的NodeRED
  *新版Pypy
  *包括pigpio
  *包括geany编辑器
  * SD卡复印机添加（可用于复制或备份Pi）
  *蓝牙插件添加到任务栏
  *任务栏上的音量控制现在与蓝牙设备兼容
  *新的关机助手应用程序
  *鼠标双击速度设置添加到鼠标和键盘首选项应用程序
  *选项启用/禁用1线接口和远程访问添加到Raspberry Pi配置应用程序的pigpio
  *文件系统在首次启动时自动扩展
  *添加空的废纸篓选项到右键菜单
  * Ctrl-Alt-T可用于打开终端窗口
  *各种小错误修复和外观调整
  *更新固件和内核（https://github.com/raspberrypi/firmware/commit/cc6d7bf8b4c03a2a660ff9fdf4083fc165620866）
2016-03-18：
  *更新固件和内核（https://github.com/raspberrypi/firmware/commit/951799bbcd795ddf27769d14acf4813fdcbe53dc）
  *在cmdline.txt中使用serial0
  * wpa_supplicant.conf国家默认为GB（允许使用通道12和13）
2016-02-26：
  *支持添加Pi 3，包括Wifi和蓝牙
  *将WiFi国家代码设置为raspi-config的选项
2016-02-09：
  * dtb使用mmc sdcard驱动程序（修复某些SD卡遇到的问题）
2016-02-03：
  *新版本的Sonic Pi（2.9）
  *新版Scratch（15/1/16）
  *新版本的Node-Red（2.5）
  *新版Wolfram（10.3）
  *可选实验GL桌面驱动程序（可以使用命令行raspi-config中的高级选项启用）
  *新版本的Java（1.8.0_65）
  *新版本的WiringPi
  *包含raspi-gpio
  * ping不再需要sudo（NOOBS安装除外）
  *支持lxpanel中的更多USB音频设备
  *在Alacarte中创建新菜单的错误修复
  *对raspi-config和GUI进行各种更改，以整理板支持和修复错误以及更新的翻译
  *小调整主题以支持GL驱动
2015-11-21：
  *包括IBM Node-RED IoT应用程序
  *包括图形包管理器
  *包含加速的pixman库
  *更新了Epiphany浏览器，以提高视频兼容性
  *更新Scratch与性能改进和错误修复
  *更新了Raspberry Pi配置，以允许启动暂停
    网络建立
  *各种小错误修复
2015-09-25：
  *基于Debian Jessie
  *升级应用程序 - 主显节浏览器，Scratch和Sonic Pi
  *包含的应用程序 -  LibreOffice，Claws Mail，Greenfoot，BlueJ
  *包含的实用程序 -  Alacarte菜单编辑器，Lxkeymap，scrot，tree，pip
  *新的基于GUI的Raspberry Pi配置应用程序
  * GPIO控制现在可以不需要sudo
  *包含Magpi杂志的网页链接
  *新的任务栏插件来弹出安装的USB驱动器
  *默认启动现在是GUI不是桌面
  *现在看起来基于GTK + 3默认主题
  *打印屏幕键启动scrot以产生截图
  *由GUI和驱动程序自动检测的通用键盘相应地加载
  *许多小的调整和错误修复
2015-05-05：
  *更新UI更改
  *更新固件
  *安装raspberrypi-net-mods
  *安装avahi-daemon
  *将用户pi添加到新的i2c和spi组
  * i2c和spi设备修改的udev规则
2015-02-16：
  *较新的固件与各种修复
  *新的Sonic Pi发行
  * Pi2兼容RPi.GPIO
  Wolfram数学更新
2015-01-31：
  *支持Pi2
  *较新的固件
  *新的Sonic Pi发行
  *更新划痕
  *新的Wolfram数学发行
  *更新主显节
2014-12-24：
  *通过省略python-pygame来修复回归
2014-12-22：
  *新固件与variosu修复和改进
  * lxde的新UI配置
  *各种包更新
  * python3-pygame预装
  *'nuscratch'，在Cog StackVM上运行
  *其他更改
2014-09-09：
  *具有各种修复和改进的新固件
  * Minecraft Pi预装
  * Sonic Pi升级到2.0
  *包括Collabora中的主显式浏览器工作
  *从Java 7切换到Java 8
  *更新数学
  *其他次要配置更改
2014-06-20：
  *具有各种修复的新固件和内核错误修复
2014-06-02：
  *许多固件更新与主要的USB改进
  * pyserial默认安装
  * picamera默认安装
2014-01-07：
  *固件更新
  *保存在根文件系统上的一些空间
2013-12-20：
  *固件更新，包括V4L2修复
  *更新omxplayer
2013-12-18：
  *固件更新，现在使用内核3.10。许多改进
  * fbturbo XOrg驱动程序默认包含并启用。谢谢
    ssvb https://github.com/ssvb/xf86-video-fbturbo
  *更新Scratch图像与进一步的错误修复
  *包括Wolfram Mathematica
  *更新到PyPy 2.2
  *更新omxplayer
  *包含v4l-utils用于实验V4L2 Raspberry Pi相机驱动程序
  *更新squeak-vm以解决加载JPEG的问题
2013-09-25：
  *更新Scratch图像以进一步提高性能
  *包括Oracle JDK
  *至少需要4GiB SD卡（见上文）
  *包含PyPy 2.1
  *包含基本的piface包
  *更新raspi-config以包含用于继承语言设置的错误修复
    来自NOOBS
2013-09-10：
  *更新到当前顶部的树固件
  *更新squeak-vm，包括针对Raspbery Pi优化的fastblit
  *包括Sonic Pi和固定的jackd2包
  *支持启动到Scratch
  *从NOOBS继承键盘和语言设置
```
