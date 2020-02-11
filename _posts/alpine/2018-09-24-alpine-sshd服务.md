---
layout: post
title: alpine-sshd服务
categories: alpine
---

alpine 安装 sshd服务

```
apk add --no-cache openssh

ssh-keygen -f /etc/ssh/ssh_host_rsa_key -N '' -t rsa
ssh-keygen -f /etc/ssh/ssh_host_dsa_key -N '' -t dsa

passwd root

/usr/sbin/sshd -D

ssh -p 3333 ip 
```
