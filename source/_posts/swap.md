---
title: swap设置
date: 2015-03-16 13:17:43
tags:
- command
- cnf
- swap
categories:
- Linux

---

### Swap 设置

1.  检查 Swap 空间  
    在设置 Swap 文件之前，有必要先检查一下系统里有没有既存的 Swap 文件。  
    运行以下命令：
    
    ```
    swapon -s
    ```
    

如果返回的信息概要是空的，则表示 Swap 文件不存在。

2.检查文件系统  
在设置 Swap 文件之前，同样有必要检查一下文件系统，看看是否有足够的硬盘空间来设置 Swap 。运行以下命令：  

```
df -hal
```

检查返回的信息，还剩余足够的硬盘空间即可。

1.  创建并允许 Swap 文件  
    下面使用 dd 命令来创建 Swap 文件。
    
    ```
    dd if=/dev/zero of=/tmp/swapfile bs=1024 count=1024k
    ```
    

参数解读：

if=文件名：输入文件名，缺省为标准输入。即指定源文件。< if=input file >

of=文件名：输出文件名，缺省为标准输出。即指定目的文件。< of=output file >

bs=bytes：同时设置读入/输出的块大小为bytes个字节

count=blocks：仅拷贝blocks个块，块大小等于bs指定的字节数。

<!-- more -->

最后，赋予 Swap 文件适当的权限：  

```
chown root:root /tmp/swapfile 
chmod 600 /tmp/swapfile
```

1.  格式化并激活 Swap 文件

上面已经创建好 Swap 文件，还需要格式化后才能使用。  

```
mkswap /tmp/swapfile
swapon /tmp/swapfile
```

以上步骤做完，再次运行命令：  

```
swapon -s

Filename                    Type        Size    Used    Priority

/tmp/swapfile               file        524284    0     -1
```

如果要机器重启的时候自动挂载 Swap ，那么还需要修改 fstab 配置。

```
/tmp/swapfile           swap                    swap    defaults        0 0
```

同时，我们还可以修改 Linux Swap 空间的 swappiness ，降低对硬盘的缓存。

Linux 会使用硬盘的一部分做为 Swap 分区，用来进行进程调度–进程是正在运行的程序–把当前不用的进程调成‘等待（standby）’，甚至‘睡眠（sleep）’，一旦要用，再调成‘活动（active）’，睡眠的进程就会在 Swap 分区，把内存空出来让给‘活动’的进程。

如果内存够大，应当告诉 Linux 不必太多的使用 Swap 分区，可以通过修改 swappiness 的参数来设置。swappiness=0 的时候表示最大限度使用物理内存，然后才是 Swap 空间，swappiness＝100 的时候表示积极的使用 Swap 分区，并且把内存上的数据及时的搬运到 Swap 空间里面。

在 CentOS 中，swappiness 的默认值是60。  
通过以下命令可以看到：

```
cat /proc/sys/vm/swappiness
```

返回值60

我们可以调整 swappiness 的值到一个合适的参数，从而达到最优化使用 Swap 的目的。这里我们将其设为10。  
使用 sysctl 命令：

```
sysctl vm.swappiness=10
```

但是这只是临时性的修改，在你重启系统后会恢复默认的60，要永久设置，还需要在 vim 中修改sysctl.conf：  

```
vi /etc/sysctl.conf

# Search for the vm.swappiness setting.  Uncomment and change it as necessary.
vm.swappiness=10
```

这样一来，Swap 分区重启后都会生效了。
