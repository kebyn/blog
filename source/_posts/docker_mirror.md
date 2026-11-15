---
title: Docker Mirror
date: 2024-08-21 01:44:23
tags:
- docker
- docker-registry
- docker-mirror
---

# Harbor Docker 镜像加速器
> https://github.com/goharbor/harbor/blob/main/contrib/Configure_mirror.md
<!-- more -->

```
storage:
  filesystem:
    rootdirectory: /var/lib/registry
    # rootdirectory: /var/lib/registry-ghcr

proxy:
  remoteurl: https://registry-1.docker.io
  # remoteurl: https://ghcr.io
  username: $USERNAME

http:
  addr: 192.168.128.1:5000
  # addr: 192.168.128.1:5001

storage_service:
  s3:
    accesskey: xxxxxxx
    secretkey: xxxxxxx
    bucket: some-docker-registry
    regionendpoint: https://s3.xxx.com
    region: default
    v4auth: false
    chunksize: 5242880  #分段上传（由 WriteStream 执行）到 S3 的默认分段大小。
    multipartcopychunksize: 33554432
    multipartcopymaxconcurrency: 100
    multipartcopythresholdsize: 33554432 #这个值需要调大，最大5G
    rootdirectory: /
 redirect:
    disabled: true
```

# Docker registry
```
version: 0.1
log:
  fields:
    service: registry
# storage:
#   cache:
#     blobdescriptor: inmemory
#   filesystem:
#     rootdirectory: /var/lib/registry
storage:
  s3:
    accesskey: XXXXXXXXXXXXXXXXXXXXXXX
    secretkey: YYYYYYYYYYYYYYYYYYYYYYYYY
    region: us-west-1
    bucket: my-docker-registry
    secure: true
    v4auth: true
    chunksize: 5242880
  cache:
    blobdescriptor: inmemory
  maintenance:
    uploadpurging:
      enabled: true
      age: 168h
      interval: 24h
      dryrun: false
    
http:
  addr: 0.0.0.0:5000
  headers:
    X-Content-Type-Options: [nosniff]
health:
  storagedriver:
    enabled: true
    interval: 10s
    threshold: 3
proxy:
  remoteurl: https://registry-1.docker.io
delete:
  enabled: true
maintenance:
  uploadpurging:
    enabled: true
    age: 24h
    interval: 1h
    dryrun: false
  readonly:
    enabled: false
  ```