---
layout: post
title: 复制vmware中的centos后无法上网问题
categories: linux
---

# 复制vmware中的centos后无法上网问题

## 查看IP命令
```
ip addr
```

网卡信息

```
eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP qlen 1000
```

使用的是eth1网卡


主要修改两个文件：

## 1.修改网卡配置文件中的设备名称,物理地址
```
vi /etc/sysconfig/network-scripts/ifcfg-eht1
DEVICE=eth1
HWADDR=00:0C:29:26:04:57
```

其中，DEVICE，HWADDR要和下面文件中的NAME,和ATTR(address)一致


## 2.`vi /etc/udev/rules.d/70-persistent-net.rules` 文件

```
SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*", ATTR{address}=="00:0c:29:26:04:57", ATTR{type}=="1", KERNEL=="eth*", NAME="eth1"
```
	

