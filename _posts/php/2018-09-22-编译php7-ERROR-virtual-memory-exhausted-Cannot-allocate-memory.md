---
layout: post
title: 编译php7时：virtual memory exhausted Cannot allocate memory 
categories: php
---

## 编译php7时：virtual memory exhausted Cannot allocate memory

> 当安装虚拟机时系统时没有设置swap大小或设置内存太小，编译程序会出现virtual memory exhausted: Cannot allocate memory的问题，可以用swap扩展内存的方法。

解决方法：

```
    mkdir /opt/images/  
    rm -rf /opt/images/swap  
    dd if=/dev/zero of=/opt/images/swap bs=1024 count=2048000  
    mkswap /opt/images/swap  
    swapon /opt/images/swap  
    free -m
```

用完之后，删除swap(也可以不删)
```
    swapoff swap  
    rm -f /opt/images/swap  
```
