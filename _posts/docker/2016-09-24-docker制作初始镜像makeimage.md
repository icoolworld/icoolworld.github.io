---
layout: post
title: docker制作初始镜像makeimage
categories: docker
---

# 创建初始centos镜像

```
./build.sh -y /etc/yum.conf centos6
```

> 参考

    https://docs.docker.com/engine/userguide/eng-image/baseimages/
    https://github.com/docker/docker/blob/master/contrib/mkimage-yum.sh