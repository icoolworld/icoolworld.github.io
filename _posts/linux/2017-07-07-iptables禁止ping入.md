---
layout: post
title: iptables禁止ping入
categories: linux
---

# iptables禁止ping入


以下设置将允许自己往外ping
不允许别人ping自己

## 1.加入如下2条规则

`vi /etc/sysconfig/iptables`

```
-A INPUT -p icmp --icmp-type 0 -j ACCEPT
-A OUTPUT -p icmp --icmp-type 8 -j ACCEPT
```

## 2.重启iptables

```
service iptables restart
```