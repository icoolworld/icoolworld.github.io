---
layout: post
title: docker容器内无法telnet宿主机的端口
categories: docker
---

## docker容器内无法telnet宿主机的端口

vim /etc/sysconfig/iptables

在宿主机加入如下配置
```
-A INPUT -i docker0 -j ACCEPT 
```

最终配置：
```
 # Firewall configuration written by system-config-firewall
 # Manual customization of this file is not recommended.
 *filter
 :INPUT ACCEPT [0:0]
 :FORWARD ACCEPT [0:0]
 :OUTPUT ACCEPT [0:0]
 -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
 -A INPUT -p icmp -j ACCEPT
 -A INPUT -i lo -j ACCEPT
 -A INPUT -i docker0 -j ACCEPT
 -A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
 -A INPUT -j REJECT --reject-with icmp-host-prohibited
 -A FORWARD -j REJECT --reject-with icmp-host-prohibited
 COMMIT
```