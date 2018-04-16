---
layout: post
title: linux挂载本地windows分区或目录
categories: linux
---

#linux挂载本地windows分区或目录

##一、linux挂载本地windows硬盘分区

###向虚拟机Centos添加本地windows硬盘
    注：(添加物理硬盘后，在centos操作会直接写入本地硬盘)

操作步骤：
虚拟机 > 设置 > 添加 > 硬盘 > 下一步 > 

虚拟磁盘类型：选择SCSI推荐即可  
模式：如果不勾选独立，则在centos写入操作生效，删除操作不会反映到磁盘  
如果勾选独立，选择永久，则虚拟机中的所有操作写入磁盘  
如果勾选独立，选择非永久，则在虚拟机中的所有操作不写入磁盘  

下一步 > 使用物理磁盘 > 使用单个分区 > 选中要添加的分区

###centos挂载本地windows分区
1.在虚拟机centos 中 使用命令fdisk -l 查看是否添加成功，其中/dev/sdb7为我们刚添加的windows分区
```
fdisk -l

Disk /dev/sdb: 1000.2 GB, 1000204886016 bytes
255 heads, 63 sectors/track, 121601 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x68b56149

   Device Boot      Start         End      Blocks   Id  System
/dev/sdb1               1      121601   976760001    f  W95 Ext'd (LBA)
/dev/sdb5               1       40469   325067179+  2d  Unknown
/dev/sdb6           40470       81069   326119468+  2d  Unknown
/dev/sdb7           81070      121601   325573258+   7  HPFS/NTFS
```


2.进行挂载
```
mount -t ntfs /dev/sdb7  /data/mnt/windows
```
出现如下错误(不能直接挂载ntfs分区)，解决方法如下

###mount: unknown filesystem type 'ntfs'
issue:
```
wget -c https://tuxera.com/opensource/ntfs-3g_ntfsprogs-2016.2.22.tgz
解压
tar xzvf 
安装
./configure
make
make install # or 'sudo make install' if you aren't root

挂载命令
mount -t ntfs-3g /dev/sdb7 /data/mnt/windows

开机自动挂载
vi /etc/fstab
/dev/sdb7 /data/mnt/windows ntfs-3g defaults 0 0
```

##二、linux挂载本地windows目录
    将window的目录挂载到虚拟机centos的目录

1.在虚拟机centos安装vmware_tools 虚拟机 > 安装vmware_tools
进入centos
```
mkdir -p /mnt/cdrom
mount /dev/cdrom /mnt/cdrom
tar xzvf  VMwareTools-9.6.2-1688356.tar.gz
cd ./vmware-tools-distrib
./vmware-install.pl
一路enter回车，默认安装
出现Would you like to enable VMware automatic kernel modules?时 输入yes

```

2.虚拟机设置共享目录
 虚拟机 > 设置 > 选项 > 共享文件夹 > 总是启用 > 添加文件夹

 3.进入centos查看共享目录
```
cd /mnt
出现一个hgfs目录,里面是共享的文件夹
[root@bogon mnt]# ll
total 11
dr-xr-xr-x. 2 root root 2048 Mar 22  2014 cdrom
dr-xr-xr-x. 1 root root 4192 Apr 27  2016 hgfs
drwxr-xr-x. 2 root root 4096 Apr 27 11:16 test

cd hgfs
ls hgfs

[root@bogon hgfs]# ll
total 0
drwxrwxrwx. 1 root root 0 Apr 27 10:43 windows_data

将windwos共享目录挂载到centos其他目录
mount -t vmhgfs  .host:/   /data/mnt

开机自动挂载
vi /etc/fstab
.host:/                 /data/mnt               vmhgfs  defaults        0 0
```


