---
layout: post
title: linux下java环境jdk安装
categories: java
---

1、下载jdk8

　　登录网址：http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html

　　选择对应jdk版本下载。（Tips：可在Windows下载完成后，通过FTP或者SSH到发送到Linux上）

2、 登录Linux，切换到root用户

　　su root 获取root用户权限，当前工作目录不变(需要root密码)
　　或者
　　sudo -i 不需要root密码直接切换成root（需要当前用户密码）

3、在usr目录下建立java安装目录

　　cd /usr

　　mkdir java

4、将jdk-8u60-linux-x64.tar.gz拷贝到java目录下

　　cp /mnt/hgfs/linux/jdk-8u60-linux-x64.tar.gz /usr/java/

5、解压jdk到当前目录,得到文件夹 jdk1.8.0_*　　(注意：下载不同版本的JDK目录名不同！)

　　tar -zxvf jdk-8u60-linux-x64.tar.gz

6、安装完毕为他建立一个链接以节省目录长度

　　ln -s /usr/java/jdk1.8.0_60/ /usr/jdk

7、编辑配置文件，配置环境变量

　　vim /etc/profile

　　在文本的末尾添加如下内容：

JAVA_HOME=/usr/jdk
CLASSPATH=.:$JAVA_HOME/lib/
PATH=$PATH:$JAVA_HOME/bin
export PATH JAVA_HOME CLASSPATH


 JAVA_HOME=/usr/local/java/jdk1.8.0_144
 CLASSPATH=.:$JAVA_HOME/lib/:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
 PATH=$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/bin/
 export PATH JAVA_HOME CLASSPATH
 
 
 
8、重启机器或执行命令 ：source /etc/profile

　　sudo shutdown -r now

9、查看安装情况

　　java -version

　　java version "1.8.0_60"
　　Java(TM) SE Runtime Environment (build 1.8.0_60-b27)
　　Java HotSpot(TM) Client VM (build 25.60-b23, mixed mode)

ps:可能出现的错误信息：

　　bash: ./java: cannot execute binary file

　出现这个错误的原因可能是在32位的操作系统上安装了64位的jdk，
　　1、查看jdk版本和Linux版本位数是否一致。
　　2、查看你安装的Ubuntu是32位还是64位系统：

1
sudo uname -m
　　附：i686    //表示是32位
　　     x86_64  // 表示是64位