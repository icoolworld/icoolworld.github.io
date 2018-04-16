---
layout: post
title: 基于rsync+sersync实现双向同步备份
categories: linux
---

# 基于rsync+sersync实现双向同步备份

## 一.为什么要实现同步备份

      服务器上有些重要文件或数据时，可以把他们多备份一份到其他服务器上，这样就不怕数据或文件丢失了。

## 二.为什么是Rsync+sersync

1.sersync是基于Inotify开发的，类似于Inotify-tools的工具

sersync可以记录下被监听目录中发生变化的（包括增加、删除、修改）具体某一个文件或某一个目录的名字，然后使用rsync同步的时候，只同步发生变化的这个文件或者这个目录。

2.rsync在同步的时候，只同步发生变化的这个文件或者这个目录（每次发生变化的数据相对整个同步目录数据来说是很小的，rsync在遍历查找比对文件时，速度很快），因此，效率很高。

小结：当同步的目录数据量不大时，建议使用Rsync+Inotify-tools；当数据量很大（几百G甚至1T以上）、文件很多时，建议使用Rsync+sersync。

> 查看服务器内核是否支持inotify

```
ll /proc/sys/fs/inotify
```

## 三.修改inotify默认参数（inotify默认内核参数值太小）

    ```
    查看系统默认参数值：
    sysctl -a | grep max_queued_events
    结果是：fs.inotify.max_queued_events = 16384
    sysctl -a | grep max_user_watches
    结果是：fs.inotify.max_user_watches = 8192
    sysctl -a | grep max_user_instances
    结果是：fs.inotify.max_user_instances = 128

    修改参数：
    sysctl -w fs.inotify.max_queued_events="99999999"
    sysctl -w fs.inotify.max_user_watches="99999999"
    sysctl -w fs.inotify.max_user_instances="65535"

    vi /etc/sysctl.conf #添加以下代码

    fs.inotify.max_queued_events=99999999
    fs.inotify.max_user_watches=99999999
    fs.inotify.max_user_instances=65535
    :wq! #保存退出

    参数说明：
    max_queued_events：
    inotify队列最大长度，如果值太小，会出现"** Event Queue Overflow **"错误，导致监控文件不准确
    max_user_watches：
    要同步的文件包含多少目录，可以用：find /home/www.osyunwei.com -type d | wc -l 统计，必须保证max_user_watches值大于统计结果（这里/home/www.osyunwei.com为同步文件目录）

    max_user_instances：
    每个用户创建inotify实例最大值
    ```


## 四.环境的搭建

      服务器A：192.168.1.10 源服务器

      服务器B: 192.168.1.20 目的服务器

     我们要实现的就是把A服务器上的文件同步到B服务器上，从而实现备份。我们主要是在B服务器上安装配置rsync，在A服务器上安装配置sersync,通过sersync把文件推送到B服务器上

## 五.开始搭建

> 从B服务器开始：

### 1.关闭selinux，在/etc/sysconfig/selinux 这个文件，设置SELINUX=disable

### 2.防火墙开通873端口   
```
vi /etc/sysconfig/iptables 
-A INPUT -m state --state NEW -m tcp -p tcp --dport 873 -j ACCEPT
```

### 3.开始安装rsync
```
yum install rsync -y
```

### 4.配置rsync
> rsync的配置文件是/etc/rsyncd.conf 



图下方需要注意的地方：secrets file这个是配置同步的密码文件的。[rsynctest]这个是配置同步模块的名称，path是配置同步的目录，hosts allow是允许同步的主机，hosts deny：拒绝同步的主机

### 5.创建同步的用户与密码的文件
即上图中的secrets file这个配置选项中的文件。/etc/rsync.passwd，同进要设置这个文件的权限为600

  ```
    echo "user:password" >> /etc/rsync.passwd
    chmod 600 /etc/rsync.passwd
  ```

### 6.创建同步的目录：即上图中path配置选项中的目录。
  ```
    mkdir /home/rsynctest
  ```

### 7.启动rsync
  ```
     rsync  --daemon --config=/etc/rsyncd.conf
  ```
   
   接着重启一下xinetd
   ```
   /etc/init.d/xinetd restart
   ```

### 8.配置开机启动 
```
echo "rsync --daemon --config=/etc/rsyncd.conf" >> /etc/rc.d/rc.local
```

到这样B服务器基本就配置完成了。

> 接着配置A服务器：

### 1.先到sersync官网下载sersync:
```
    http://sersync.sourceforge.net/
    wget http://sersync.googlecode.com/files/sersync2.1_64bit_binary.tar.gz
    wget https://sourceforge.net/projects/sersync/files/sersync2.1_64bit_binary.tar.gz
```
   
### 2.安装sersync
```
  mkdir /usr/local/sersync
  mkdir /usr/local/sersync/conf
  mkdir /usr/local/sersync/bin
  mkdir /usr/local/sersync/log
  tar zxvf sersync2.5_32bit_binary_stable_final.tar.gz
  cd sersync2.1_64bit_binary/
  cp confxml.xml /usr/local/sersync/conf
  cp sersync2 /usr/local/sersync/bin
```
 

### 3.创建密码文件

同B服务器一样，不过这个文件只要保存一个密码就行了，不用用户名,权限也是600
```
  echo "password" >> /etc/rsync.passwd
  chmod 600 /etc/rsync.passwd
```
 

### 4.配置sersync

配置文件就是上第二步复制的confxml.xml这个文中，路径在/usr/local/sersync/conf中

---------------------------------------------------------------------------------------------------------------------------

```
<?xml version="1.0" encoding="ISO-8859-1"?>

<head version="2.5">

   # 设置本地IP和端口

   <host hostip="localhost" port="8008"></host>

   # 开启DUBUG模式  

   <debug start="false"/>

   # 开启xfs文件系统

   <fileSystem xfs="false"/>

   # 同步时忽略推送的文件(正则表达式),默认关闭

   <filter start="false">

       <exclude expression="(.*)\.svn"></exclude>

       <exclude expression="(.*)\.gz"></exclude>

       <exclude expression="^info/*"></exclude>

       <exclude expression="^static/*"></exclude>

   </filter>

   <inotify>

   # 设置要监控的事件

       <delete start="true"/>

       <createFolder start="true"/>

       <createFile start="true"/>

       <closeWrite start="true"/>

       <moveFrom start="true"/>

       <moveTo start="true"/>

       <attrib start="true"/>

       <modify start="true"/>

</inotify>

   <sersync>

   # 本地同步的目录路径

       <localpath watch="/data">

   # 远程IP和rsync模块名  

           <remote ip="192.168.1.20" name="data"/>  

           <!--<remote ip="192.168.8.39" name="tongbu"/>-->

           <!--<remote ip="192.168.8.40" name="tongbu"/>-->

       </localpath>

       <rsync>

   # rsync指令参数

           <commonParams params="-auvzP"/>

   # rsync同步认证

           <auth start="true" users="user" passwordfile="/etc/rsync.passwd"/>

   # 设置rsync远程服务端口，远程非默认端口则需打开自定义

           <userDefinedPort start="false" port="874"/><!-- port=874 -->

   # 设置超时时间

           <timeout start="true" time="100"/><!-- timeout=100 -->

   # 设置rsync+ssh加密传输模式,默认关闭，开启需设置SSH加密证书

           <ssh start="false"/>

       </rsync>

    # sersync传输失败日志脚本路径，每隔60会重新执行该脚本，执行完毕会自动清空。

       <failLog path="/usr/local/sersync/log/rsync_fail_log.sh" timeToExecute="60"/><!--default every 60mins execute once-->

    # 设置rsync+crontab定时传输，默认关闭

       <crontab start="false" schedule="600"><!--600mins-->

           <crontabfilter start="false">

               <exclude expression="*.php"></exclude>

               <exclude expression="info/*"></exclude>

           </crontabfilter>

       </crontab>

   # 设置sersync传输后调用name指定的插件脚本，默认关闭

       <plugin start="false" name="command"/>

   </sersync>

   # 插件脚本范例

   <plugin name="command">

       <param prefix="/bin/sh" suffix="" ignoreError="true"/>  <!--prefix /opt/tongbu/mmm.sh suffix-->

       <filter start="false">

           <include expression="(.*)\.php"/>

           <include expression="(.*)\.sh"/>

       </filter>

   </plugin>

   # 插件脚本范例

   <plugin name="socket">

       <localpath watch="/opt/tongbu">

           <deshost ip="192.168.138.20" port="8009"/>

       </localpath>

   </plugin>

   <plugin name="refreshCDN">

       <localpath watch="/data0/htdocs/cms.xoyo.com/site/">

           <cdninfo domainname="ccms.chinacache.com" port="80" username="xxxx" passwd="xxxx"/>

           <sendurl base="http://pic.xoyo.com/cms"/>

           <regexurl regex="false" match="cms.xoyo.com/site([/a-zA-Z0-9]*).xoyo.com/images"/>

       </localpath>

   </plugin>

</head>
```

------------------------------------------------------------------------------------------------------------------

### 5.创建同步目录：

```
mkir /home/rsynctest
```

### 6.设置环境变量：

```
# echo "export PATH=$PATH:/usr/local/sersync/bin/" >> /etc/profile
# source /etc/profile
```
 
### 7.启动sersync

```
sersync2 -r -d -o /usr/local/sersync/conf/confxml.xml
```

> 注：重启操作如下：

```
killall sersync2 && sersync2 -r -d -o /usr/local/sersync/conf/confxml.xml
```
 
### 8.设置开机启动

```
echo "sersync2 -r -d -o /usr/local/sersync/conf/confxml.xml" >> /etc/rc.local
```
 

好了，两台机器的配置都已经完成，现在你在A服务器的/home/rsynctest这个目录下创建文件，看看B服务器同样目录下是不是也生成了这个文件，如果是，那就恭喜，你成功了！

 