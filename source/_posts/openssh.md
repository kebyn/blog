---
title: openssh
date: 2015-07-17 13:22:17
tags:
- openssh
- conf
categories:
- Network

---

### /etc/ssh/ssh_config 文件
```
# Site-wide defaults for various options
Host *
"Host"只对匹配后面字串的计算机有效，“*”表示所有的计算机。从该项格式前置一些可以看出，这是一个类似于全局的选项，表示下面缩进的选项都适用于该设置，可以指定某计算机替换*号使下面选项只针对该算机器生效。
ForwardAgent no
"ForwardAgent"设置连接是否经过验证代理（如果存在）转发给远程计算机。
ForwardX11 no
"ForwardX11"设置X11连接是否被自动重定向到安全的通道和显示集（DISPLAY set）。
RhostsAuthentication no
"RhostsAuthentication"设置是否使用基于rhosts的安全验证。
RhostsRSAAuthentication no
"RhostsRSAAuthentication"设置是否使用用RSA算法的基于rhosts的安全验证。
RSAAuthentication yes
"RSAAuthentication"设置是否使用RSA算法进行安全验证。
PasswordAuthentication yes
"PasswordAuthentication"设置是否使用口令验证。
FallBackToRsh no
"FallBackToRsh"设置如果用ssh连接出现错误是否自动使用rsh，由于rsh并不安全，所以此选项应当设置为"no"。
UseRsh no
"UseRsh"设置是否在这台计算机上使用"rlogin/rsh"，原因同上，设为"no"。
BatchMode no
"BatchMode"：批处理模式，一般设为"no"；如果设为"yes"，交互式输入口令的提示将被禁止，这个选项对脚本文件和批处理任务十分有用。
CheckHostIP yes
"CheckHostIP"设置ssh是否查看连接到服务器的主机的IP地址以防止DNS欺骗。建议设置为"yes"。
StrictHostKeyChecking no
"StrictHostKeyChecking"如果设为"yes"，ssh将不会自动把计算机的密匙加入"$HOME/.ssh/known_hosts"文件，且一旦计算机的密匙发生了变化，就拒绝连接。
IdentityFile ~/.ssh/identity
"IdentityFile"设置读取用户的RSA安全验证标识。
Port 22
"Port"设置连接到远程主机的端口，ssh默认端口为22。
Cipher blowfish
“Cipher”设置加密用的密钥，blowfish可以自己随意设置。
EscapeChar ~
“EscapeChar”设置escape字符。
```
<!-- more -->

---

### /etc/ssh/sshd_config 文件
```
# 关于 SSH Server 的整体设定，包含使用的 port 啦，以及使用的密码演算方式
Port 22　　　　　　　　　# SSH 预设使用 22 这个 port，您也可以使用多的 port ！
  　　　　　　  　　　　　 # 亦即重复使用 port 这个设定项目即可！
Protocol 2,1　 　　　　 # 选择的 SSH 协议版本，可以是 1 也可以是 2 ，
　　　　　　　　　　　　　 # 如果要同时支持两者，就必须要使用 2,1 这个分隔了！
#ListenAddress 0.0.0.0　　 # 监听的主机适配卡！举个例子来说，如果您有两个 IP，
 　　　　　　　　　　　　　 # 分别是 192.168.0.100 及 192.168.2.20 ，那么只想要
 　　　　　　　　　　　　　 # 开放 192.168.0.100 时，就可以写如同下面的样式：
ListenAddress 192.168.0.100          # 只监听来自 192.168.0.100 这个 IP 的SSH联机。
 　　　　　　　　　　　　　　　　　　 # 如果不使用设定的话，则预设所有接口均接受 SSH
PidFile /var/run/sshd.pid　　　　　　# 可以放置 SSHD 这个 PID 的档案！左列为默认值
LoginGraceTime 600　　　　 # 当使用者连上 SSH server 之后，会出现输入密码的画面，
　　　　　　　　　　　　 # 在该画面中，在多久时间内没有成功连上 SSH server ，
 　　　　　　　　　　　　　 # 就断线！时间为秒！
Compression yes　　　　　　# 是否可以使用压缩指令？当然可以啰！

# 主机的 Private Key 放置的档案，预设使用下面的档案即可！
HostKey /etc/ssh/ssh_host_key　　　　# SSH version 1 使用的私钥
HostKey /etc/ssh/ssh_host_rsa_key　　# SSH version 2 使用的 RSA 私钥
HostKey /etc/ssh/ssh_host_dsa_key　　# SSH version 2 使用的 DSA 私钥
#  关于 version 1 的一些设定！
KeyRegenerationInterval 3600　 　　# 由前面联机的说明可以知道， version 1 会使用
 　　　　　　　　　　　　　　　　　　 # server 的 Public Key ，那么如果这个 Public
 　　　　　　　　　　　　　　　　　　 # Key 被偷的话，岂不完蛋？所以需要每隔一段时间
 　　　　　　　　　　　　　　　　　　 # 来重新建立一次！这里的时间为秒！
ServerKeyBits 768 　　　　　　　　　 # 没错！这个就是 Server key 的长度！
#  关于登录文件的讯息数据放置与 daemon 的名称！
SyslogFacility AUTH　　　　　　　　　# 当有人使用 SSH 登入系统的时候，SSH会记录资
 　　　　　　　　　　　　　　　　　　 # 讯，这个信息要记录在什么 daemon name 底下？
 　　　　　　　　　　　　　　　　　　 # 预设是以 AUTH 来设定的，即是 /var/log/secure
 　　　　　　　　　　　　　　　　　　 # 里面！什么？忘记了！回到 Linux 基础去翻一下
 　　　　　　　　　　　　　　　　　　 # 其它可用的 daemon name 为：DAEMON,USER,AUTH,
 　　　　　　　　　　　　　　　　　　 # LOCAL0,LOCAL1,LOCAL2,LOCAL3,LOCAL4,LOCAL5,
LogLevel INFO　　　　　　　　　　　　# 登录记录的等级！嘿嘿！任何讯息！
 　　　　　　　　　　　　　　　　　　 # 同样的，忘记了就回去参考！
#  安全设定项目！极重要！
#  登入设定部分
PermitRootLogin no　　 　　# 是否允许 root 登入！预设是允许的，但是建议设定成 no！
UserLogin no　　　　　　　 # 在 SSH 底下本来就不接受 login 这个程序的登入！
StrictModes yes　　　　　　# 当使用者的 host key 改变之后，Server 就不接受联机，
 　　　　　　　　　　　　　 # 可以抵挡部分的木马程序！
#RSAAuthentication yes　　 # 是否使用纯的 RSA 认证！？仅针对 version 1 ！
PubkeyAuthentication yes　 # 是否允许 Public Key ？当然允许啦！只有 version 2
AuthorizedKeysFile      .ssh/authorized_keys
 　　　　　　　　　　　　　 # 上面这个在设定若要使用不需要密码登入的账号时，那么那个
 　　　　　　　　　　　　　 # 账号的存放档案所在档名！
#  认证部分
RhostsAuthentication no　　# 本机系统不止使用 .rhosts ，因为仅使用 .rhosts 太
　　　　　　　　　　　　　 # 不安全了，所以这里一定要设定为 no ！
IgnoreRhosts yes　　　　　 # 是否取消使用 ~/.ssh/.rhosts 来做为认证！当然是！
RhostsRSAAuthentication no # 这个选项是专门给 version 1 用的，使用 rhosts 档案在
　　　　　　　　　　　　　 # /etc/hosts.equiv配合 RSA 演算方式来进行认证！不要使用
HostbasedAuthentication no # 这个项目与上面的项目类似，不过是给 version 2 使用的！
IgnoreUserKnownHosts no　　# 是否忽略家目录内的 ~/.ssh/known_hosts 这个档案所记录
　　　　　　　　　　　　　 # 的主机内容？当然不要忽略，所以这里就是 no 啦！
PasswordAuthentication yes # 密码验证当然是需要的！所以这里写 yes 啰！
PermitEmptyPasswords no　　# 若上面那一项如果设定为 yes 的话，这一项就最好设定
　　　　　　　　　　　　　 # 为 no ，这个项目在是否允许以空的密码登入！当然不许！
ChallengeResponseAuthentication yes  # 挑战任何的密码认证！所以，任何 login.conf
　　　　　　　　　　　　　　　　　　 # 规定的认证方式，均可适用！
#PAMAuthenticationViaKbdInt yes      # 是否启用其它的 PAM 模块！启用这个模块将会
　　　　　　　　　　　　　　　　　　 # 导致 PasswordAuthentication 设定失效！

#  与 Kerberos 有关的参数设定！因为我们没有 Kerberos 主机，所以底下不用设定！
#KerberosAuthentication no
#KerberosOrLocalPasswd yes
#KerberosTicketCleanup yes
#KerberosTgtPassing no

#  底下是有关在 X-Window 底下使用的相关设定！
X11Forwarding yes
#X11DisplayOffset 10
#X11UseLocalhost yes
#  登入后的项目：
PrintMotd no              # 登入后是否显示出一些信息呢？例如上次登入的时间、地点等
　　　　　　　　　　　　　# 等，预设是 yes ，但是，如果为了安全，可以考虑改为 no ！
PrintLastLog yes　　　　　# 显示上次登入的信息！可以啊！预设也是 yes ！
KeepAlive yes　　　　　　 # 一般而言，如果设定这项目的话，那么 SSH Server 会传送
　　　　　　　　　　　　　# KeepAlive 的讯息给 Client 端，以确保两者的联机正常！
　　　　　　　　　　　　　# 在这个情况下，任何一端死掉后， SSH 可以立刻知道！而不会
　　　　　　　　　　　　　# 有僵尸程序的发生！
UsePrivilegeSeparation yes # 使用者的权限设定项目！就设定为 yes 吧！
MaxStartups 10　　　　　　# 同时允许几个尚未登入的联机画面？当我们连上 SSH ，
　　　　　　　　　　　　　# 但是尚未输入密码时，这个时候就是我们所谓的联机画面啦！
　　　　　　　　　　　　　# 在这个联机画面中，为了保护主机，所以需要设定最大值，
　　　　　　　　　　　　　# 预设最多十个联机画面，而已经建立联机的不计算在这十个当中
#  关于使用者抵挡的设定项目：
DenyUsers *　　　　　　　 # 设定受抵挡的使用者名称，如果是全部的使用者，那就是全部
 　　　　　　　　　　　　　# 挡吧！若是部分使用者，可以将该账号填入！例如下列！
DenyUsers test
DenyGroups test　　　　　 # 与 DenyUsers 相同！仅抵挡几个群组而已！
# 5. 关于 SFTP 服务的设定项目！
Subsystem       sftp    /usr/lib/ssh/sftp-server
```
