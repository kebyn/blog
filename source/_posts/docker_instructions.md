---
title: docker
date: 2017-06-08 10:17:43
tags:
- docker
- docker engine
- docker proxy
- docker command
- docker-compose
---
Docker 安装、代理与常用命令备忘。

<!-- more -->

1. docker engine安装
  - [docker install](https://docs.docker.com/engine/installation/#supported-platforms)
  - [debian install](https://store.docker.com/editions/community/docker-ce-server-debian)
  - [centos install](https://store.docker.com/editions/community/docker-ce-server-centos)
  - [windows install](https://store.docker.com/editions/community/docker-ce-desktop-windows)
  ```
  curl -fsSL https://get.docker.com | bash

  dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  curl -s https://download.docker.com/linux/centos/docker-ce.repo -o /etc/yum.repos.d/docker-ce.repo
  yum install -y docker-ce




2. docker官方文档
  - [docker administrator guide](https://docs.docker.com/engine/admin/start-containers-automatically/#restart-policy-details)
  - [docker user guide](https://docs.docker.com/engine/userguide/)
  - [docker proxy](https://stackoverflow.com/questions/23111631/cannot-download-docker-images-behind-a-proxy)
          ```
          $ cat /etc/docker/daemon.json
            {
              "registry-mirrors": ["https://www.example.cc"],
              "data-root": "/data/docker",
              "proxies": {
                "http-proxy": "http://proxy.example.com:8080",
                "https-proxy": "http://proxy.example.com:8080",
                "no-proxy": "localhost,127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
              },
              "exec-opts": ["native.cgroupdriver=systemd"],
              "log-driver": "json-file",
              "log-opts": {
                "max-size": "100m",
                "max-file": "3",
                "tag": "{{.ImageName}}|{{.Name}}|{{.ImageFullID}}|{{.FullID}}"
              },
              "storage-driver": "overlay2"
            }
          $ cat /etc/systemd/system/docker.service.d
            Environment="HTTP_PROXY=http://proxy.example.com:8080"
            Environment="HTTPS_PROXY=http://proxy.example.com:8080"
            Environment="NO_PROXY=localhost,127.0.0.0/8,10.0.0.0/8,172.16.0.0/12,192.168.0.0/16"
          $ systemctl daemon-reload && systemctl restart docker
          $ systemctl show --property Environment docker
            Environment=HTTP_PROXY=http://proxy.example.com:8080
          ```
<!-- more-->
  - [docker command](https://docs.docker.com/engine/reference/run/)
    ```
    docker version/info/login
    docker run
    docker run -i -t
    docker pull/search/commit/push
    docker start/stop/kill/restart
    docker ps       正在运行的docker
    docker ps -a    所有的docker
    docker ps -l    最近运行的docker
    docker rm       删除docker
    docker images   列出image
    docker rmi     删除image
    docker rmi `docker images -f dangling=true -q`
    docker save/load

    docker network inspect bridge
    docker inspect ID/Name
    ```
3. ~~docker-compose~~`docker compose` `v3`版本是`docker`的子命令
  - [docker-compose command](https://docs.docker.com/compose/reference/overview/)
  - [docker-compose install](https://github.com/docker/compose/releases)
    ```
    curl -L https://github.com/docker/compose/releases/download/1.14.0-rc2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ```
