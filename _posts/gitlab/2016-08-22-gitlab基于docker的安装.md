---
layout: post
title: gitlab基于docker的安装
categories: gitlab
---

# gitlab/gitlab-ce基于docker的安装部署

> gitlab-ce是gitlab社区版本,还有gitlab-ee,gitlab-runner等版本

## 环境需求

强烈推荐部署在4GB以上内存的系统
4GB RAM is the recommended memory size for all installations and supports up to 100 users

## 拉取GitLab镜像

```
docker pull gitlab/gitlab-ce
```


## 运行GitLab

```
sudo docker run --detach \
    --hostname 192.168.110.128 \
    --publish 44300:443 --publish 8000:80 --publish 2200:22 \
    --name gitlab \
    --restart always \
    --volume /data/gitlab/config:/etc/gitlab \
    --volume /data/gitlab/logs:/var/log/gitlab \
    --volume /data/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest
```

## 配置GitLab

`vi /etc/gitlab/gitlab.rb`

> 配置文件为/etc/gitlab/gitlab.rb
> 可以配置external_url为gitlab的外网访问地址

```
sudo docker exec -it gitlab /bin/bash
sudo docker exec -it gitlab vi /etc/gitlab/gitlab.rb
```

## 邮箱配置

`vi /etc/gitlab/gitlab.rb`

```
 gitlab_rails['smtp_enable'] = true
 gitlab_rails['smtp_address'] = "smtp.qq.com"
 gitlab_rails['smtp_port'] = 25
 gitlab_rails['smtp_user_name'] = "278767718@qq.com"
 gitlab_rails['smtp_password'] = "vxkukwfjxcwobgcf"
 gitlab_rails['smtp_domain'] = "smtp.qq.com"
 gitlab_rails['smtp_authentication'] = :plain
 gitlab_rails['smtp_enable_starttls_auto'] = true
 gitlab_rails['gitlab_email_from'] = "278767718@qq.com"
 user['git_user_email'] = "278767718@qq.com"

vxkukwfjxcwobgcf
lumshqswwlggbjee

gitlab_rails['smtp_enable'] = true
gitlab_rails['smtp_address'] = "smtp.server"
gitlab_rails['smtp_port'] = 465
gitlab_rails['smtp_user_name'] = "smtp user"
gitlab_rails['smtp_password'] = "smtp password"
gitlab_rails['smtp_domain'] = "example.com"
gitlab_rails['smtp_authentication'] = "login"
gitlab_rails['smtp_enable_starttls_auto'] = true
gitlab_rails['smtp_openssl_verify_mode'] = 'peer'

# If your SMTP server does not like the default 'From: gitlab@localhost' you
# can change the 'From' with this setting.
gitlab_rails['gitlab_email_from'] = 'gitlab@example.com'
gitlab_rails['gitlab_email_reply_to'] = 'noreply@example.com'
```

> 配置好之后运行gitlab-ctl reconfigure

## https配置

`vi /etc/gitlab/gitlab.rb`

```
# note the 'https' below
external_url "https://gitlab.example.com"
```

omnibus-gitlab将会在以下位置查找ssl证书文件
```
/etc/gitlab/ssl/gitlab.example.com.key
/etc/gitlab/ssl/gitlab.example.com.crt
==============
mkdir -p /etc/gitlab/ssl
chmod 700 /etc/gitlab/ssl
cp gitlab.example.com.key gitlab.example.com.crt /etc/gitlab/ssl/
```

> 配置好之后运行gitlab-ctl reconfigure

## http直接跳转到https

`vi /etc/gitlab/gitlab.rb`

```
external_url "https://gitlab.example.com"
nginx['redirect_http_to_https'] = true
```


## 更改默认端口和证书的位置 

`vi /etc/gitlab/gitlab.rb`

```
external_url "https://gitlab.example.com:2443"
# For GitLab
nginx['ssl_certificate'] = "/etc/gitlab/ssl/gitlab.example.com.crt"
nginx['ssl_certificate_key'] = "/etc/gitlab/ssl/gitlab.example.com.key"
```

> 配置好之后运行gitlab-ctl reconfigure


## 升级GitLab到最新版本

```
docker stop gitlab
docker rm gitlab
docker pull gitlab/gitlab-ce:latest

sudo docker run --detach \
--hostname gitlab.example.com \
--publish 443:443 --publish 80:80 --publish 22:22 \
--name gitlab \
--restart always \
--volume /srv/gitlab/config:/etc/gitlab \
--volume /srv/gitlab/logs:/var/log/gitlab \
--volume /srv/gitlab/data:/var/opt/gitlab \
gitlab/gitlab-ce:latest
```

## 运行GitLab CE绑定外网IP

```
sudo docker run --detach \
    --hostname gitlab.example.com \
    --publish 1.1.1.1:443:443 \
    --publish 1.1.1.1:80:80 \
    --publish 1.1.1.1:22:22 \
    --name gitlab \
    --restart always \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest
```

## 使用不同的端口 Expose GitLab on different ports 

容器默认启用以下端口

> 注意不要使用8080端口，否则会冲突

```
80 (HTTP)
443 (if you configure HTTPS)
8080 (used by Unicorn)
22 (used by the SSH daemon)
```

使用不同端口
```
sudo docker run --detach \
    --hostname gitlab.example.com \
    --publish 8929:80 --publish 2289:22 \
    --name gitlab \
    --restart always \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest
```

当修改了端口，需要修改配置

`vi /etc/gitlab/gitlab.rb`

```
# For HTTP
external_url "http://gitlab.example.com:8929"

> 遇到的坑，添加了external_url后NGINX会按设置的端口监听，这里还是监听80(docker映射的是80端口)

nginx['listen_port'] = 80

or

# For HTTPS (notice the https)
external_url "https://gitlab.example.com:8929"

gitlab_rails['gitlab_shell_ssh_port'] = 2289
```

## 查看日志

```
docker logs gitlab
```

> ref

```
https://hub.docker.com/r/gitlab/gitlab-ce/
https://docs.gitlab.com/omnibus/docker/
https://gitlab.com/gitlab-org/omnibus-gitlab/tree/master/docker
https://docs.gitlab.com/omnibus/settings/
https://docs.gitlab.com/omnibus/settings/smtp.html
https://docs.gitlab.com/omnibus/settings/nginx.html#enable-https
https://docs.gitlab.com/ce/README.html
端口变更问题
https://gitlab.com/gitlab-org/gitlab-ce/issues/20131
```
