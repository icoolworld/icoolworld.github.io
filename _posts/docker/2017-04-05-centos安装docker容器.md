---
layout: post
title: centos安装docker容器
categories: docker
---

# centos安装docker容器

### 系统环境需求
docker要运行在centos7系统中，系统为64位机器上，内核最小版本在3.10以上  
如果系统为centos6，后面有附带的安装方法
```
uname -r (查看linux内核版本)
```
2.6.32-431.el6.x86_64
需要升级linux内核至3.10.0以上


### 安装docker

官方有2种安装方式：1）采用yum方式 2）采用curl脚本方式

#### 方法一：采用yum安装

step1:更新系统相关包到最新状态
```
yum update 
```

step2:添加yum源到系统中
```
tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF
```

step3:安装docker服务
```
yum install docker-engine
```

step4:启动docker服务
```
service docker start
```

#### 方法二：采用curl脚本方式

输入如下命令，会自动安装docker及相关的依赖，稍等片刻自动完成docker安装

如果是非root用户,能要输入密码

step1:更新系统相关包到最新状态
```
yum update 
```

step2:运行curl命令,实际上该脚本会创建docker.repo源，也是通过yum安装的
```
curl -fsSL https://get.docker.com/ | sh
```

step3:启动docker服务
```
service docker start
```


### 测试docker是否安装正确
```
docker run hello-world
```
如果出现类似如下错误提示

Post http:///var/run/docker.sock/v1.19/containers/create: dial unix /var/run/docker.sock: no such file or directory. Are you trying to connect to a TLS-enabled daemon without TLS?

*这是docker服务没有启动*

### docker -d

docker -d 以守护进程方式运行
```
[root@bogon ~]# docker -d
WARN[0000] You are running linux kernel version 2.6.32-431.el6.x86_64, which might be unstable running docker. Please upgrade your kernel to 3.10.0. 
INFO[0000] Listening for HTTP on unix (/var/run/docker.sock) 
docker: relocation error: docker: symbol dm_task_get_info_with_deferred_remove, version Base not defined in file libdevmapper.so.1.02 with link time reference
```
以上提示会出现内核版本太低的警告,

docker: relocation error: 解决,更新相关包
```
yum upgrade device-mapper-libs
```

### 把非root用户添加用户到docker组

```
groupadd docker
useradd  docker -g docker
usermod -aG docker your_username
```

### 将docker加入开机启动
```
chkconfig docker on
```

### docker卸载
step1:找到docker相关的包
```
yum list installed | grep docker
```
step2:卸载包
```
yum -y remove docker-engine.x86_64
```
step3:删除所有镜像，容器等，使用如下命令
```
rm -rf /var/lib/docker
```



### centos6.7安装docker，亲测
    基于centos6.7 64位测试过正常，centos6.5有时运行会卡死系统，需要内核升级
参考 http://www.linuxidc.com/Linux/2014-09/106671.htm
先更换YUM源wget http://mirrors.163.com/.help/CentOS6-Base-163.repo
加载eple源：
rpm -Uvh http://ftp.sjtu.edu.cn/fedora/epel/6/i386/epel-release-6-8.noarch.rpm
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
安装docker
yum -y install docker-io
升级： yum -y update docker-io(可省略)
yum -y upgrade device-mapper-libs
卸载epel
rpm -e epel-release


### centos6关于docker的安装方法

```
升级内核后

编辑grub.conf文件，修改Grub引导顺序    
vim /etc/grub.conf

修改grub的主配置文件/etc/grub.conf，设置default=0，表示第一个title下的内容为默认启动的kernel（一般新安装的内核在第一个位置）。

首先关闭selinux：
setenforce 0
sed -i '/^SELINUX=/c\SELINUX=disabled' /etc/selinux/config

在Fedora EPEL源中已经提供了docker-io包，下载安装epel：
rpm -ivh http://dl.Fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6

安装docker
yum -y install docker-io

查看docker日志：
cat /var/log/docker
```

### 其他关于docker的安装方法2
```
升级前系统镜像：CentOS 6.5 64位

内核版本：2.6.32-431.23.3.el6_x86_64

1、导入public key    
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

2、安装elrepo到内核为2.6.32的CentOS中    
rpm -Uvh http://www.elrepo.org/elrepo-release-6-6.el6.elrepo.noarch.rpm

3、安装kernel-lt(long term support)长期支持版本    
yum --enablerepo=elrepo-kernel install kernel-lt -y

推荐采用rpm的方式安装kernel-lt：
访问http://elrepo.org/linux/kernel/el6/x86_64/RPMS/下载对应的rpm包，通过rpm方式安装：   
rpm -ivh kernel-lt-3.10.93-1.el6.elrepo.x86_64.rpm
关于kernel-lt的介绍可以参考elrepo官网介绍：http://elrepo.org/tiki/kernel-lt

编辑grub.conf文件，修改Grub引导顺序    
vim /etc/grub.conf
确认安装的新内核的位置，将default的值调整为新内核的顺序，如本次升级案例中新装的内核位置为0，所以将default修改为0，保存退出，reboot重启服务器。

重启系统
```