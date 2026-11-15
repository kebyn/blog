---
title: Unbound 与 BIND9：递归解析、DoT/DoH 与 RHEL 打包差异
date: 2026-11-15 10:10:00
description: 对比 Unbound 与 BIND9 的递归解析配置，整理 IPv6、DoT、DoH、http-notls-downstream、RHEL 打包差异与 acme.sh 证书自动化。
categories:
- Network
tags:
- unbound
- bind9
- dns
- dot
- doh
- rhel
- acme-sh
---

Unbound 和 BIND9 都能做递归解析，也都支持 DNSSEC 验证。真正影响部署的是默认行为、配置方式、加密 DNS 能力和发行版打包差异。本文把递归配置、IPv6/DoT/DoH、`http-notls-downstream`、RHEL 8/9/10 的 DoH 支持，以及 acme.sh 证书自动化放在一起，方便按场景选型。

<!-- more -->

## 结论与能力速览

- **Unbound** 是专用递归解析器，安装后默认开启递归，但默认只允许本机使用。
- **BIND9** 的 `named` 同时承担权威和递归两种角色，需要显式开启 `recursion`、指定 `allow-recursion`，并提供根提示或转发上游。
- 让递归真正可用，需要同时满足三件事：开启递归、提供根提示或转发器、用 ACL 限定允许使用递归的客户端。
- DoT 两个方向都支持：Unbound 可以作为 DoT 服务端，也可以作为 DoT 上游客户端。
- DoH 只支持服务端。Unbound 没有 DoH 上游客户端功能。
- RHEL 9/10 的官方 `unbound` 包带 DoH；RHEL 8 的包没有带 nghttp2，需要重编 SRPM、容器或前置代理。

## 递归解析的工作过程

1. 客户端发送 RD=1（Recursion Desired）的查询。
2. 解析器先查缓存，命中则直接返回。
3. 未命中时，从根提示（`.` 的 NS 记录）开始，逐级向根、顶级域、权威服务器发送迭代查询，跟随 referral 和 glue 记录。
4. 得到答案后按 TTL 缓存并返回，响应中 `RA=1` 表示服务器支持递归。
5. 配置了转发器时，查询交给上游递归服务器完成迭代；`forward-first` 允许上游失败后回退到本地迭代，`forward-only` 则只走转发。

DNSSEC 验证也在这条链上完成（RRSIG/DS 信任链），所以递归解析器通常同时是验证器。

## Unbound 递归配置

Unbound 的权威服务能力限于 `local-zone` / `local-data` 提供的本地记录，主要角色是递归解析器。

`/etc/unbound/unbound.conf`：

```conf
server:
    interface: 0.0.0.0
    interface: ::0
    port: 53
    do-ip4: yes
    do-ip6: yes
    do-udp: yes
    do-tcp: yes

    # 谁可以使用递归；默认仅 localhost
    access-control: 127.0.0.0/8 allow
    access-control: ::1 allow
    access-control: 192.168.0.0/16 allow
    access-control: 10.0.0.0/8 allow

    # 完整迭代所需的根提示，也可使用内置根提示
    root-hints: "/var/lib/unbound/root.hints"

    # DNSSEC 信任锚，支持 RFC 5011 自动滚动
    auto-trust-anchor-file: "/var/lib/unbound/root.key"

    qname-minimisation: yes
    harden-dnssec-stripped: yes
    harden-referral-path: yes
    prefetch: yes

    num-threads: 4
    msg-cache-size: 64m
    rrset-cache-size: 128m
    cache-min-ttl: 60
    cache-max-ttl: 86400

    hide-identity: yes
    hide-version: yes
    deny-any: yes
```

改为转发模式，由上游负责迭代：

```conf
forward-zone:
    name: "."
    forward-addr: 8.8.8.8
    forward-addr: 1.1.1.1
    # forward-first: yes   # 上游不可用时回退到本地迭代
```

验证：

```bash
unbound-checkconf
unbound-control status
dig @127.0.0.1 example.com A
dig @127.0.0.1 example.com A +norecurse
```

要点：

- `access-control` 默认允许 `127.0.0.0/8` 和 `::1`，其他来源被拒绝；服务局域网必须显式添加 `allow`。
- RD=0 的非递归查询默认会被拒绝；需要 cache snooping 时使用 `access-control: <网段> allow_snoop`。
- 把 53 端口暴露到公网会成为开放解析器和放大攻击跳板，需要防火墙限制并考虑启用 `ratelimit`。
- `root.key` 由 `unbound-anchor` 初始化，需要保证 unbound 用户对该文件有写权限以完成自动滚动。
- 与 systemd-resolved 的 `127.0.0.53` stub 冲突时，修改监听地址或关闭 stub listener。

## BIND9 递归配置

BIND9 用一份配置即可同时提供权威 zone 和递归解析：

```c
acl trusted {
    127.0.0.0/8;
    ::1;
    192.168.0.0/16;
    10.0.0.0/8;
};

options {
    directory "/var/cache/bind";

    recursion yes;
    allow-recursion { trusted; };      # 递归 ACL，建议显式设置
    allow-query { trusted; };          # 谁可以查询本机
    allow-query-cache { trusted; };    # 谁可以使用缓存

    listen-on { any; };
    listen-on-v6 { any; };

    # 本地迭代模式：保留根提示 zone，不配置 forwarders
    # 转发模式：启用 forwarders，并按需加 forward only
    // forwarders { 8.8.8.8; 1.1.1.1; };
    // forward only;

    dnssec-validation auto;
    minimal-responses yes;
    qname-minimization strict;
    max-cache-size 256m;
};
```

根提示 zone 在本地迭代时必须存在，发行版默认配置通常已包含：

```c
zone "." {
    type hint;
    file "/usr/share/dns/root.hints";   # RHEL 系常见路径为 /var/named/named.ca
};
```

验证：

```bash
named-checkconf -z
rndc status
dig @127.0.0.1 example.com A
dig @127.0.0.1 example.com A +norecurse
rndc recursing        # 查看当前正在进行的递归查询
rndc flush            # 清空缓存
```

权威与递归分离的 view 写法：

```c
view "internal" {
    match-clients { trusted; };
    recursion yes;
    allow-recursion { trusted; };
    zone "." { type hint; file "/usr/share/dns/root.hints"; };
    // 内网 zone ...
};

view "external" {
    match-clients { any; };
    recursion no;
    allow-query { any; };
    // 对外权威 zone ...
};
```

要点：

- `allow-recursion` 未显式设置时会从 `allow-query-cache` / `allow-query` 推导，不同版本和发行版默认值存在差异。只放宽 `allow-query` 可能意外放开递归，生产环境应把三条 ACL 都写清楚。
- `forwarders` 的默认语义是 `forward first`，即上游失败后回退到本地迭代；`forward only` 则强制只走转发。
- 权威与递归放在同一进程会增加攻击面，也容易混用缓存。常见做法是拆成独立实例或独立机器，或用 view 按来源分流。
- `dnssec-validation auto` 依赖根信任锚和准确时钟，时间偏差会导致验证失败。
- 公网实例需限制 `allow-recursion`、收紧 `allow-transfer`，并考虑启用 `rate-limit` 响应速率限制。

## Unbound 与 BIND9 对比

| 维度 | Unbound | BIND9 |
|---|---|---|
| 定位 | 专用递归解析器 | 权威与递归一体 |
| 默认递归 | 开启，默认仅本机可用 | 由配置决定，需关注 ACL |
| 迭代起点 | 内置根提示或 `root-hints` | 内置或 `zone "." type hint` |
| 转发 | `forward-zone`，可选 `forward-first` | `forwarders` + `forward first/only` |
| DNSSEC | `auto-trust-anchor-file` | `dnssec-validation auto` |
| 缓存调优 | `msg-cache-size`、`rrset-cache-size`、`prefetch` | `max-cache-size`、`prefetch` |
| 运维工具 | `unbound-checkconf`、`unbound-control` | `named-checkconf`、`rndc` |
| 典型场景 | 纯递归解析器、DNSSEC 验证器 | 已有权威 DNS、需要一体化或 view 分流 |

## IPv6、DoT、DoH 支持矩阵

| 能力 | Unbound 支持状态 | 关键配置 |
|---|---|---|
| IPv6 监听与上游传输 | 全版本支持 | `do-ip6`、`interface: ::0`、`access-control: ::1 allow` |
| DoT 服务端（下游） | 2011 年起支持 | `tls-service-key`、`tls-service-pem`、`tls-port` |
| DoT 上游（转发到上游） | 1.9.0 起支持 | `forward-tls-upstream`、`tls-cert-bundle` |
| DoH 服务端（下游） | 1.12.0 起支持 | `https-port`、`http-endpoint`，需 `libnghttp2` |
| DoH 上游（客户端） | 不支持 | 无对应配置项 |
| DoQ 服务端 | 较新版本可选 | `quic-port`，需 ngtcp2/quictls |

Unbound 的加密传输能力分成两个方向：下游是客户端连 Unbound，上游是 Unbound 连别的解析器。DoT 两个方向都支持，DoH 只支持下游。

### IPv6

```conf
server:
    do-ip4: yes
    do-ip6: yes              # 默认 yes
    interface: 0.0.0.0
    interface: ::0           # 监听所有 IPv6 地址
    # interface: ::1         # 只监听回环

    access-control: 127.0.0.0/8 allow
    access-control: ::1 allow
    access-control: 192.168.0.0/16 allow
    access-control: 2001:db8:1::/64 allow

    prefer-ip6: yes          # 默认 no，由 RTT 选择；yes 优先走 IPv6 上游
    # outgoing-interface: 2001:db8:1::/64
```

要点：

- `do-ip6: no` 会同时关闭 IPv6 监听和 IPv6 上游传输，但 AAAA 记录仍会正常返回；主机没有 IPv6 连通性时关闭它可以避免上游超时。
- 默认隐式放行的是 `127.0.0.0/8`，IPv6 客户端（包括 `::1`）需要在 `access-control` 中显式允许。
- 自定义 `root-hints` 文件需要包含根服务器的 AAAA 记录；内置根提示已经包含。
- 双栈监听时，防火墙需要同时放行 v4/v6 的 53、853、443（DoQ 为 UDP 853）。

## DoT 服务端与上游客户端

### 作为 DoT 服务端

```conf
server:
    interface: 0.0.0.0@853
    interface: ::0@853

    tls-service-key: "/etc/unbound/tls/unbound_server.key"
    tls-service-pem: "/etc/unbound/tls/unbound_server.pem"
    tls-port: 853

    tls-protocols: "TLSv1.2 TLSv1.3"
    tls-ciphers: "HIGH:!aNULL"
    tls-ciphersuites: "TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256"
    tls-session-ticket-keys: "/etc/unbound/tls/ticket.key"
```

- `tls-service-key` 和 `tls-service-pem` 同时启用 DoT 与 DoH 服务；具体哪个接口提供哪种服务由端口决定。
- 绑定到 `tls-port` 的接口只提供 DoT，普通 DNS TCP 不会在该端口响应。
- 额外端口用 `tls-additional-port: 8853` 声明。
- 私钥需要 unbound 用户可读，或者在降权/chroot 前可读；证书更新后可 `unbound-control reload`，权限受限时需要重启。
- `access-control` 同样作用于 DoT 客户端。
- 旧配置里的 `ssl-service-key`、`ssl-service-pem`、`ssl-port` 是同一组选项的别名。

### 作为 DoT 客户端

DoT 上游只适用于 `forward-zone` 和 `stub-zone`。纯迭代解析无法使用 DoT，因为根和顶级域服务器不提供 DoT。

```conf
server:
    tls-cert-bundle: "/etc/ssl/certs/ca-certificates.crt"
    # 或者 tls-system-cert: yes

forward-zone:
    name: "."
    forward-tls-upstream: yes
    forward-addr: 1.1.1.1@853#cloudflare-dns.com
    forward-addr: 1.0.0.1@853#cloudflare-dns.com
    forward-addr: 2606:4700:4700::1111@853#cloudflare-dns.com
```

- `IP@端口#认证名` 是固定语法；`#` 后面的名字用于 SNI 和证书校验，建议始终填写。
- 没有 `tls-cert-bundle` 或 `tls-system-cert: yes` 时，证书无法验证，连接会失败。
- `forward-first: yes` 会在 DoT 上游不可用时回退到普通迭代，这等于允许降级；默认 `no`。
- `stub-zone` 用 `stub-tls-upstream: yes`；全局 `tls-upstream: yes` 对全部 forward/stub 生效。

## DoH 服务端

DoH 支持自 1.12.0 起，编译时需要 `libnghttp2`：

```bash
./configure --with-libnghttp2
unbound -V | grep -i nghttp2
```

配置：

```conf
server:
    interface: 0.0.0.0@443
    interface: ::0@443

    tls-service-key: "/etc/unbound/tls/unbound_server.key"
    tls-service-pem: "/etc/unbound/tls/unbound_server.pem"

    https-port: 443
    http-endpoint: "/dns-query"
    http-max-streams: 100
    http-query-buffer-size: 4m
    http-response-buffer-size: 4m
    http-nodelay: yes
```

- DoH 只走 HTTP/2 + TLS，通过 ALPN 协商 `h2`；媒体类型为 `application/dns-message`，支持 GET（`?dns=` base64url）和 POST。
- 默认端口 443，默认路径 `/dns-query`；访问其他路径返回 404。
- 请求体上限受 `msg-buffer-size` 限制，超限返回 413/414。
- `http-notls-downstream: yes` 可以关闭下游 TLS，用于放在 TLS 终止反向代理之后；此时 `access-control` 看到的是代理地址。
- 443 和 853 属于特权端口，非 root 运行需要 `CAP_NET_BIND_SERVICE`。

Unbound 不提供 DoH 客户端功能，`forward-zone` 没有 HTTPS 选项。需要 DoH 上游时，常见做法是在本机运行 `dnscrypt-proxy`、`cloudflared` 等 DoH 客户端，让 Unbound 转发到它们的本地端口；或者直接使用 DoT 上游。

## `http-notls-downstream` 与反向代理

`http-notls-downstream: yes` 让 Unbound 的 DoH 监听端口改用明文 HTTP/2（h2c），不再使用 TLS。它面向的部署形态是：反向代理或负载均衡器负责 TLS 终止，Unbound 作为本机或内网后端，只处理 HTTP/2 上的 DNS 消息。

```text
客户端 --HTTPS/HTTP3--> Caddy / Envoy / HAProxy --h2c 明文--> Unbound:8053/dns-query
```

该选项自 Unbound 1.13.0 起提供（DoH 服务端本身自 1.12.0 起提供）。

| 项目 | 默认（no） | `yes` |
|---|---|---|
| DoH 监听协议 | HTTPS（TLS + HTTP/2） | HTTP/2 cleartext（h2c） |
| 是否需要证书 | 需要 `tls-service-key` / `tls-service-pem` | 该监听不需要证书 |
| ALPN | 协商 `h2` | 不使用 ALPN |
| HTTP 版本 | HTTP/2 | HTTP/2（prior knowledge） |
| 端口标记 | `https-port` | 仍由 `https-port` 标记 |
| DoT 监听 | 不受影响 | 不受影响 |

配置示例：

```conf
server:
    interface: 127.0.0.1@8053
    https-port: 8053
    http-notls-downstream: yes

    http-endpoint: "/dns-query"
    http-max-streams: 100
    http-query-buffer-size: 4m
    http-response-buffer-size: 4m
    http-nodelay: yes

    access-control: 127.0.0.1 allow
```

- 接口端口必须与 `https-port` 一致，Unbound 才会把它识别为 DoH 服务端口。
- 使用 8053 这类非特权端口可以避免授予 `CAP_NET_BIND_SERVICE`。
- 绑定 `127.0.0.1` 或独立内网地址，避免明文 DoH 暴露到不可信网络。
- 不配置 `tls-service-key` 也能启动；配置之后该 DoH 端口仍然走明文，TLS 只用于 DoT。
- `http-notls-downstream` 是全局开关，一个 Unbound 实例里的所有 DoH 监听都会变成明文。需要在同一实例同时提供 HTTPS DoH 和 h2c DoH 时，只能拆成两个实例，或者由前置代理统一终止 TLS。

反向代理必须支持 HTTP/2 cleartext 到后端：

- **Caddy**：`transport http { versions h2c }`
- **Envoy**：cluster 上设置 `http2_protocol_options: {}`
- **HAProxy**：后端 server 行使用 `proto h2`
- **开源版 nginx**：`proxy_pass` 只能向 upstream 发送 HTTP/1.x，Unbound 会拒绝。用 `stream` 模块做四层透传可以连通，但这样就失去了在 nginx 上终止 TLS 的意义。

Caddy 示例：

```caddy
dns.example.com {
    reverse_proxy 127.0.0.1:8053 {
        transport http {
            versions h2c
        }
    }
}
```

这种架构的常见收益：

- 证书申请、续期、OCSP 和密码套件策略集中在代理层。
- 代理可以对客户端提供 HTTP/3（DoH3），Unbound 后端仍使用 h2c。
- 代理层统一做访问日志、WAF、限速和多实例负载均衡。
- Unbound 侧减少 TLS 握手开销。

安全与运维注意点：

- 代理到 Unbound 这一段是明文，只应走回环地址、Unix 域套接字所在主机或受控内网，并用防火墙限制来源。
- Unbound 看到的客户端地址是代理地址。`access-control`、按 IP 的 `ratelimit`、`wait-limit` 都按代理 IP 计算，无法区分真实客户端。
- Unbound 的 DoH 监听不支持 PROXYv2，也不会解析 `X-Forwarded-For`，所以无法通过这两种方式恢复真实客户端 IP。
- 该模式没有客户端证书认证，也没有传输层加密，不要直接暴露到公网。
- 代理的健康检查应发送合法的 DoH 请求；对 `/dns-query` 的空 GET 会得到 400。

## RHEL 8/9/10 的 DoT/DoH 打包差异

RHEL 8、9、10 的官方 `unbound` RPM 都自带 DoT 服务端支持（基于 OpenSSL）。DoH 的差别来自打包时的编译开关：

- **RHEL 9 / RHEL 10**：官方包已带 `--with-libnghttp2`，DoH 开箱可用，不需要自己编译。
- **RHEL 8**：即使后期版本已升到 1.16.2（上游支持 DoH），RPM 仍未带 nghttp2，DoH 不可用，需要自行重编 SRPM 或使用前置 DoH 代理。
- **DoT 上游转发**：需要 Unbound ≥ 1.9.0，RHEL 8.7+、RHEL 9、RHEL 10 支持；RHEL 8.0–8.6 的 1.7.3 不支持。

CentOS Stream、Rocky Linux、AlmaLinux、Oracle Linux 重新构建同一份 RHEL SRPM，因此特性矩阵与对应 RHEL 版本一致。

| 发行版 / 次版本 | 自带 unbound | DoT 服务端 | DoT 上游 | DoH 服务端 | 官方包是否需编译 |
|---|---|---|---|---|---|
| RHEL 7（EOL） | 1.6.x | 支持（`ssl-*`） | 不支持 | 不支持 | DoH 需 |
| RHEL 8.0–8.6 | 1.7.3 | 支持（`ssl-*`） | 不支持 | 不支持 | DoH、DoT 上游需 |
| RHEL 8.7–8.10 | 1.16.2 | 支持（`tls-*`） | 支持 | 不支持（未带 nghttp2） | DoH 需重编 |
| RHEL 9.0 | 1.13.1 | 支持 | 支持 | 支持 | 不需要 |
| RHEL 9.1–9.7 | 1.16.2 | 支持 | 支持 | 支持 | 不需要 |
| RHEL 9.8 | 1.24.2 | 支持 | 支持 | 支持 | 不需要 |
| RHEL 10.0–10.1 | 1.20.0 | 支持 | 支持 | 支持 | 不需要 |
| RHEL 10.2 | 1.24.2 | 支持 | 支持 | 支持 | 不需要 |

RHEL 9.8 和 RHEL 10.2 的 1.24.2 包还额外带 DoQ 支持（`quic-port`）；RHEL 10.0 的 1.20.0 包未带 DoQ。次版本矩阵以发布时 Red Hat 包信息为准。

### 同一个 1.16.2，RHEL 8 和 RHEL 9 不同

RHEL 8.7 起把 unbound 升到了 1.16.2，上游版本完全支持 DoH。但 RHEL 8 的 spec 文件：

- 没有 `%bcond_without doh` 开关；
- 没有 `BuildRequires: libnghttp2-devel`；
- `%configure` 参数中没有 `--with-libnghttp2`。

所以 RHEL 8 的二进制里能解析 `http-notls-downstream` 之类的配置项，但 HTTP/2 和 DoH 代码没有被编译进去，启动 DoH 监听时只会得到“not compiled with nghttp2”的警告。

RHEL 9 和 RHEL 10 的 spec 则包含：

```spec
%bcond_without doh
...
%if %{with doh}
BuildRequires: libnghttp2-devel
%endif
...
%if %{with doh}
            --with-libnghttp2 \
%endif
```

`%bcond_without doh` 的默认含义是开启，因此官方构建默认带 DoH。

### 在机器上确认

```bash
rpm -q unbound
unbound -V
```

看 `Configure line` 是否包含 `--with-libnghttp2`：

```text
# RHEL 9/10 典型输出
Configure line: --with-libevent --with-pthreads --with-ssl ... --with-libnghttp2 ...

# RHEL 8 的输出不含 --with-libnghttp2
```

补充检查：

```bash
rpm -q --requires unbound | grep -i nghttp2
ldd /usr/sbin/unbound | grep -i nghttp2
```

RHEL 9/10 通常能看到 `libnghttp2.so.14` 依赖。`unbound -V` 的 configure 行是最直接的判断依据。

### RHEL 8 想用 DoH 的三条路

**方案一：重编 SRPM，保留系统包管理。**

```bash
dnf install rpm-build dnf-plugins-core
dnf download --source unbound
rpm -ivh unbound-*.src.rpm
```

编辑 `~/rpmbuild/SPECS/unbound.spec`，加入：

```spec
BuildRequires: libnghttp2-devel
```

并在 `%configure` 参数中加入：

```spec
--with-libnghttp2
```

构建并安装：

```bash
rpmbuild -ba ~/rpmbuild/SPECS/unbound.spec
dnf install ~/rpmbuild/RPMS/x86_64/unbound-*.rpm
```

RHEL 8 的 spec 没有 `%bcond_with doh`，因此需要手动加依赖和 configure 参数，不能只靠 `--with doh` 宏。

**方案二：容器运行新版 Unbound。** 用 Podman 运行来自 RHEL 9/10 或 Fedora 的新版 unbound，把 53/853/443 映射到宿主机。适合不想改动系统包的场景，但要注意容器网络、SELinux 端口标签和 systemd 集成。

**方案三：前置 DoH 代理。** 在 Unbound 前面放一个支持 DoH 服务端的组件（例如 dnsdist），由它终止 TLS 和 HTTP/2，再以普通 DNS 转发到本机 Unbound 的 53 端口。这样 RHEL 8 的 Unbound 继续做递归解析，DoH 能力由前端提供。

### 容易混淆的点

- RHEL 8 的 1.16.2 有 DoT 上游，只是没有 DoH。DoT 和 DoH 是两个独立特性，DoT 只依赖 OpenSSL。
- DoH 上游在 Unbound 中始终不支持，RHEL 9/10 也一样。需要加密转发时使用 DoT 上游；需要 DoH 上游时只能在本机放 DoH 客户端代理。
- 安装 `nghttp2` 命令行包不会给 Unbound 增加 DoH。决定因素是 unbound 二进制是否带 `--with-libnghttp2` 编译。
- RHEL 8 的 1.7.3 使用 `ssl-service-key` / `ssl-port`；新文档里的 `tls-service-key` / `tls-port` 在该版本中不存在。
- RHEL 9.0 的 1.13.1 已经支持 DoH 和 `http-notls-downstream`，不必等到 1.16.2。

## 用 acme.sh 管理 Unbound 证书

acme.sh 负责三件事：签发证书、自动续期、在续期后触发部署动作。Unbound 只负责读取两个文件：

- `tls-service-key`：私钥 PEM。
- `tls-service-pem`：证书 PEM，使用包含中间证书的 fullchain。

把 acme.sh 的 `--install-cert` 指向这两个路径，并用 `--reloadcmd` 在每次签发/续期后修正权限并 reload Unbound，就完成了集成。

```text
acme.sh --issue --> 证书目录 --> --install-cert --> /etc/unbound/tls/
                                                      |
                                                      +-- reloadcmd --> systemctl reload unbound
```

### 选择验证方式

| 方式 | 要求 | 适用场景 |
|---|---|---|
| HTTP-01 | 公网 80 端口可达 | 80 端口空闲，或已有 Web 服务器 |
| DNS-01 | 能通过 API 修改 DNS | 推荐；支持泛域名，不需要开放入站端口 |
| TLS-ALPN-01 | 公网 443 端口可达 | 443 被 Unbound DoH 占用时不可用 |

DoT/DoH 服务器通常只开放 853/443，推荐 DNS-01。如果 80 端口空闲，`--standalone` 也可以。

### 签发证书

```bash
curl https://get.acme.sh | sh -s email=admin@example.com
source ~/.bashrc
acme.sh --set-default-ca --server letsencrypt
```

DNS-01（以 Cloudflare 为例）：

```bash
export CF_Token="你的 API Token"
export CF_Account_ID="你的 Account ID"

acme.sh --issue --dns dns_cf -d dns.example.com --keylength ec-256
```

HTTP-01：

```bash
# 80 端口空闲
acme.sh --issue -d dns.example.com --standalone --keylength ec-256

# 已有 Web 服务器
acme.sh --issue -d dns.example.com --webroot /var/www/html --keylength ec-256
```

注意：

- 泛域名必须用 DNS-01，例如 `-d example.com -d '*.example.com'`。
- 测试阶段加 `--staging`，避免触发 Let's Encrypt 速率限制。
- 使用 `--keylength ec-256` 时，后续 `--install-cert` 必须加 `--ecc`。
- 证书域名必须是客户端实际使用的名字，DoT 客户端通过 SNI/主机名校验证书。

### 部署到 Unbound

```bash
acme.sh --install-cert -d dns.example.com --ecc \
  --key-file       /etc/unbound/tls/unbound.key \
  --fullchain-file /etc/unbound/tls/unbound.pem \
  --reloadcmd      "/usr/local/sbin/unbound-cert-reload"
```

`--install-cert` 会在首次安装和每次续期后执行 `--reloadcmd`。

`/usr/local/sbin/unbound-cert-reload`：

```bash
#!/bin/bash
set -euo pipefail

install -d -m 0750 -o root -g unbound /etc/unbound/tls
chown root:unbound /etc/unbound/tls/unbound.key /etc/unbound/tls/unbound.pem
chmod 640 /etc/unbound/tls/unbound.key
chmod 644 /etc/unbound/tls/unbound.pem

/usr/sbin/unbound-checkconf
systemctl reload unbound
```

关键点：

- 私钥权限设为 `root:unbound 0640`。Unbound 启动时以 root 读取私钥，但 SIGHUP reload 时以 unbound 用户重新读取；私钥如果保持 `0600 root`，reload 会读不到，只能重启。
- `unbound-checkconf` 失败时脚本退出，不执行 reload，正在运行的 Unbound 继续使用内存中的旧证书。
- 目录权限保持 `0750 root:unbound`，不要让 unbound 用户可写。
- 如果使用 chroot，证书路径必须位于 chroot 内，并符合 Unbound 的路径调整规则。

### Unbound 配置

DoT + DoH 共用同一份证书：

```conf
server:
    interface: 0.0.0.0@853
    interface: ::0@853
    interface: 0.0.0.0@443
    interface: ::0@443

    tls-service-key: "/etc/unbound/tls/unbound.key"
    tls-service-pem: "/etc/unbound/tls/unbound.pem"

    tls-port: 853
    https-port: 443
    http-endpoint: "/dns-query"

    access-control: 192.168.0.0/16 allow
    access-control: 2001:db8:1::/64 allow
```

RHEL 8.0–8.6 的 Unbound 1.7.3 使用旧选项名：

```conf
server:
    interface: 0.0.0.0@853
    ssl-service-key: "/etc/unbound/tls/unbound.key"
    ssl-service-pem: "/etc/unbound/tls/unbound.pem"
    ssl-port: 853
```

### 自动续期

acme.sh 安装时会写入 cron 任务，每天检查一次：

```bash
acme.sh --list          # 查看证书和下次续期时间
acme.sh --cron          # 手动触发检查
```

`--reloadcmd` 会保存在证书配置里，续期成功后自动执行。可以手动模拟一次续期：

```bash
acme.sh --renew -d dns.example.com --ecc --force
```

或者直接测试 reload 脚本：

```bash
/usr/local/sbin/unbound-cert-reload
systemctl status unbound
journalctl -u unbound -n 50 --no-pager
```

### 结合反向代理

如果 DoH 由 Caddy、nginx、Envoy 终止 TLS，Unbound 使用 `http-notls-downstream: yes` 提供 h2c 后端，那么证书只需要部署在代理上：

- **Caddy**：内置 ACME，不需要 acme.sh；证书和续期由 Caddy 管理。
- **nginx**：用 acme.sh 签发后 `--install-cert --reloadcmd "systemctl reload nginx"`，Unbound 不配置证书。
- **acme.sh + Unbound 直连**：适用于 Unbound 自己监听 853/443 的场景。

这种拆分的好处是证书轮换只影响代理，Unbound 的 reload 与证书生命周期解耦。

## 验证与排障

### 检查服务与端口

```bash
unbound-checkconf
unbound -V | grep -Ei 'nghttp2|openssl'
ss -lntup | grep unbound
```

### IPv6

```bash
dig @::1 example.com A
```

### DoT

```bash
dig @127.0.0.1 -p 853 +tls example.com
dig @127.0.0.1 -p 853 +tls +tls-hostname=dns.example.com \
    +tls-ca=/etc/ssl/certs/ca-certificates.crt example.com
kdig @127.0.0.1 +tls example.com
```

### DoH

```bash
# GET，base64url 查询为 example.com A
curl --http2 -k -sS \
  'https://127.0.0.1/dns-query?dns=AAABAAABAAAAAAAAB2V4YW1wbGUDY29tAAABAAE' \
  -o /tmp/answer.bin

# POST，query.bin 为 DNS wire format 查询
curl --http2 -k -sS -H 'content-type: application/dns-message' \
  --data-binary @query.bin https://127.0.0.1/dns-query -o /tmp/answer.bin

unbound-control stats_noreset | grep -E 'num.query.(tls|https)'
```

直连 h2c 时必须显式使用 prior knowledge：

```bash
curl -v --http2-prior-knowledge \
  -H 'content-type: application/dns-message' \
  --data-binary @query.bin \
  http://127.0.0.1:8053/dns-query -o /tmp/answer.bin
```

### 检查证书

```bash
openssl s_client -connect dns.example.com:853 \
  -servername dns.example.com -showcerts </dev/null 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates

openssl s_client -connect dns.example.com:443 \
  -servername dns.example.com -alpn h2 </dev/null 2>/dev/null \
  | openssl x509 -noout -subject -issuer -dates
```

### 常见问题

| 现象 | 原因与处理 |
|---|---|
| 续期成功但 Unbound 仍返回旧证书 | `--reloadcmd` 未配置或 reload 失败；检查 `journalctl -u unbound` |
| reload 后证书加载失败 | 私钥权限为 `0600 root`；改为 `root:unbound 0640` |
| 客户端报证书链不完整 | 使用了 `cert.pem`；改用 `fullchain.cer` / `--fullchain-file` |
| `--install-cert` 找不到证书 | ECC 证书缺少 `--ecc` 参数 |
| HTTP-01 验证失败 | 80 端口不可达或被防火墙拦截；改用 DNS-01 |
| 泛域名签发失败 | HTTP-01 不支持泛域名；使用 DNS-01 |
| 443 被占用导致 `--alpn` 失败 | Unbound DoH 已监听 443；改用 DNS-01 或 HTTP-01 |
| SELinux 拒绝读取私钥 | `ausearch -m avc -ts recent`，用 `restorecon` 或 `semanage fcontext` 修正标签 |
| 证书时间异常 | 检查 chrony/NTP，避免“not yet valid”或过期 |
| 用 `https://127.0.0.1:8053` 握手失败 | 该监听是明文 HTTP，应使用 `http://` |
| `curl --http2 http://...` 失败或返回空 | 客户端尝试 HTTP/1.1 Upgrade，应改用 `--http2-prior-knowledge` |
| 反向代理返回 502 | 代理向上游发送 HTTP/1.1，需启用 h2c 后端传输 |
| 启动日志提示没有 TLS key | `http-notls-downstream` 未生效或写成了 `no` |
| 端口无响应 | 接口 `@port` 与 `https-port` 不一致，或 `access-control` 未放行代理地址 |
| 所有请求来源都是 127.0.0.1 | 代理在中间，Unbound 只能看到代理地址 |
| 配置了证书但 DoH 仍是明文 | `http-notls-downstream: yes` 是全局的，该实例所有 DoH 端口都走 h2c |

### 排查顺序

1. 用 `unbound-checkconf` 或 `named-checkconf` 检查语法。
2. 用 `ss -lntup` 确认监听地址和端口。
3. 用 `dig +norecurse` 区分缓存/权威回答与真正递归。
4. 检查 ACL、防火墙和 SELinux。
5. 检查上游 53/853/443 是否可达，根提示文件是否过期。
6. 检查证书链、SNI、系统时间。

`dig +trace` 由 dig 自身完成迭代，绕开本机递归器，无法用来验证服务器的递归配置。

## 参考与时效

- 本文整理自 2026-11-14 的 Grok 技术会话，配置示例以 Unbound 和 BIND9 官方文档的选项语义为准。
- RHEL 次版本、unbound RPM 版本和 DoH 编译开关会随发行版更新变化，部署前用 `rpm -q unbound`、`unbound -V` 和 `rpm -q --requires unbound` 在目标机器上确认。
- 证书命令以 acme.sh 当前版本为准，生产环境先用 `--staging` 验证流程。
- 示例中的域名、IP 和邮箱均为文档占位符，请替换为实际环境值。
