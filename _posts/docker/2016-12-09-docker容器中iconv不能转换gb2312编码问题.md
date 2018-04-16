---
layout: post
title: docker容器中iconv不能转换gb2312编码问题
categories: docker
---


# docker容器中iconv转换编码不能使用

iconv -f gb2312 -t utf-8

> 错误提示：
```
iconv: conversion from `gb2312' is not supported
```

查看语言环境

```
[root@183c08d4f3f7 yum.repos.d]# locale -a
C
POSIX
```

发现,没有utf-8支持,语言包不完整，语言包是在glibc-common包中

查看glibc版本

```
[root@183c08d4f3f7 yum.repos.d]# yum list glibc
Loaded plugins: fastestmirror
Loading mirror speeds from cached hostfile
 * base: centos.ustc.edu.cn
 * extras: mirrors.163.com
 * updates: mirrors.163.com
Installed Packages
glibc.x86_64                                                           2.12-1.209.el6_9.2                                                           @updates
Available Packages
glibc.i686                                                             2.12-1.209.el6_9.2         
```

重新安装glibc
```
yum -y reinstall glibc
yum -y reinstall glibc-common
```

重新安装后语言出现
```
locale -a

_SN.utf8
xh_ZA
xh_ZA.iso88591
xh_ZA.utf8
yi_US
yi_US.cp1255
yi_US.utf8
yo_NG
yo_NG.utf8
zh_CN
zh_CN.gb18030
zh_CN.gb2312
zh_CN.gbk
zh_CN.utf8
zh_HK
zh_HK.big5hkscs
zh_HK.utf8
zh_SG
zh_SG.gb2312
zh_SG.gbk
zh_SG.utf8
zh_TW
zh_TW.big5
zh_TW.euctw
zh_TW.utf8
zu_ZA
zu_ZA.iso88591
zu_ZA.utf8
```

也可从官网下载最新glibc源码，编译安装

```
wget http://ftp.gnu.org/gnu/glibc/glibc-2.18.tar.gz
mkdir glibc-build
tar zxf glibc-2.18.tar.gz
cd glibc-build
../glibc-2.18/configure --prefix=/usr
make -j 8
make install
```

至此,iconv编码转换正常