---
title: ssh_tunnel
date: 2017-06-03 09:17:43
tags:
  - ssh
  - ssh_tunnel
  - autossh
categories:
- Network

---
1. [ssh转发](http://www.ruanyifeng.com/blog/2011/12/ssh_port_forwarding.html)
  - `ssh -N -f -L 5000:localhost:3306 root@23.226.78.113`
    > -N 不启动shell

    > -f 后台执行

    > -T不分配TTY

    > -D动态转发、 -L本地转发 、 -R 远程转发

    >>SSH 端口转发自然需要 SSH 连接，而 SSH 连接是有方向的，从 SSH Client 到 SSH Server 。而我们的应用也是有方向的，比如需要连接 Server 时 ，Server 自然就是 Server 端，我们应用连接的方向也是从应用的 Client 端连接到应用的 Server 端。如果这两个连接的方向一致，那我们就说它是本地转发。而如果两个方向不一致，我们就说它是远程转发。[本地转发与远程转发](https://www.ibm.com/developerworks/cn/linux/l-cn-sshforward/)

2. [autossh官方](http://www.harding.motd.ca/autossh/)
  - [README](../text/README)
```
autossh -M 0 -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -L 5000:localhost:3306 root@23.226.78.113
```
  >[参考文档](https://www.everythingcli.org/ssh-tunnelling-for-fun-and-profit-autossh/)
<!-- more -->
3. systemctl
```
workspace:~$ cat autossh-mysql-tunnel.service
[Unit]
Description=AutoSSH tunnel service everythingcli MySQL on local port 5000
After=network.target

[Service]
Environment="AUTOSSH_GATETIME=0"
ExecStart=/usr/bin/autossh -M 0 -o "ServerAliveInterval 30" -o "ServerAliveCountMax 3" -NL 5000:localhost:3306 root@23.226.78.113 -p 22

[Install]
WantedBy=multi-user.target
```
4. 测试ssh_tunnel稳定性
```
workspace:~$ cat ssh_tunnel.sh
#!/bin/bash
#kebyn
#kebyn@kebyn.cc

export PATH=$PATH:/bin:/sbin:/usr/bin:/usr/sbin

case $1 in
start | run)
    #autossh
    /usr/bin/autossh -i /home/user/.ssh/id_rsa -M 0 -o "ServerAliveInterval 60" -o "ServerAliveCountMax 10" -N -L 4096:localhost:80 root@23.226.78.113 &
    sleep 3

    test_connect(){
        while true; do
        #test_connect
        web_code=$(curl --connect-timeout 1 127.0.0.1:4096 -i 2>/dev/null |head -1 |perl -lane 'print $F[1]')
        if [ "$web_code" != "200" ] ;then
            echo "$(date +%Y/%m/%d_%H:%M:%S)" >> ssh_tunnel_erro.log
            sleep 1
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S)" > ssh_tunnel_success.log
            sleep 1
        fi
        done
    }
    test_connect &
    ;;
stop)
    if [ "$(/usr/bin/pgrep autossh)" ] ;then
        kill $(/usr/bin/pgrep autossh)
    fi
    if [ "$(/usr/bin/pgrep ssh_tunnel)" ] ;then
        kill $(/usr/bin/pgrep ssh_tunnel)
    fi
    ;;
*)
    echo 'Usage: ./ssh_tunnel.sh  [ OPTIONS ] { start | stop | run }'
    ;;
esac
```
