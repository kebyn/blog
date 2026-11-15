---
title: openvpn  设置备忘
date: 2017-07-09 13:23:57
tags:
- openvpn
---
1. opevpn 服务器开启
```
port 1194
proto udp
dev tun
ca ca.crt
cert xxx.crt
dh dh2048.pem
server 10.8.0.0 255.255.255.0  //openvpnIP段
ifconfig-pool-persist ipp.txt  //分配的地址记录在ipp.txt
client-config-dir ccd  //个人单独配置文件

client-to-client  //客户端可以互相连接
keepalive 10 120
comp-lzo

user nobody
group nogroup
persist-key
persist-tun
status /tmp/openvpn-status.log
log         /tmp/openvpn.log
verb 4

mode server  //运行模式
tls-server  //tls加密
topology subnet  //使用服务端子网
push "topology subnet"  //通知客户端使用子网

auth-user-pass-verify /etc/openvpn/checkpsw.js via-env  //密码认证
client-cert-not-required  //不认证证书
username-as-common-name  //使用用户名区别不同用户
script-security 3

route 192.168.2.0 255.255.255.0 10.8.0.2  //使用这个子网
push "route 192.168.2.0 255.255.255.0 10.8.0.2"  //通知客户端使用子网
route 10.8.0.0 255.255.255.0 10.8.0.1  //使用这个子网
push "route 10.8.0.0 255.255.255.0"  //通知客户端使用子网
route 192.168.3.0 255.255.255.0 10.8.0.2  //使用这个子网
push "route 192.168.3.0 255.255.255.0 10.8.0.2"  //通知客户端使用子网
```
2. 连接到openvpn服务器
  - 开启路由转发
```
    echo 1 > /proc/sys/net/ipv4/ip_forward
    sudo iptables -A FORWARD -i eth0 -j ACCEPT
    sudo iptables -A FORWARD -i eth1 -j ACCEPT
```
3. 配置路由
   + 可以在路由器上配置全局路由
   + 下面是需要连接 openvpn 的单独配置
      - Windows 需要cmd 管理员窗口执行:
          `route add  10.8.0.0 mask 255.255.255.0 10.0.0.1`
      - Linux 需要sudo 权限执行:
          `ip route add 10.8.0.0/24 via 10.0.0.1`

> 可以在各个网络出入口使用 tcpdump 抓包判断网络情况
