---
layout: post
title: docker-compose安装配置
categories: docker
---

# docker-compose的安装配置
## 关于docker-compose
Docker Compose是用python编写的一个管理多容器的工具。
Docker Compose它是一个定义及运行多个Docker容器的工具。使用Docker Compose你只需要在一个配置文件中定义多个Docker容器，然后使用一条命令将多个容器启动，Docker Compose会通过解析容器件的依赖关系（link, 网络容器 –net-from或数据容器 –volume-from）按先后顺序启动所定义的容器。

## docker-compose安装
方式1：采用CURL方式安装
```
curl -L https://github.com/docker/compose/releases/download/1.7.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose 
```

方式2：---Install as a container---
```
curl -L https://github.com/docker/compose/releases/download/1.7.0/run.sh > /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```

方式3：采用pip安装
```
pip install docker-compose

DEPRECATION: Python 2.6 is no longer supported by the Python core team, please upgrade your Python. A future version of pip will drop support for Python 2.6
```

## 测试安装是否成功
```
docker-compose --version
```


