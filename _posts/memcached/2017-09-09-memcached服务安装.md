---
layout: post
title: memcached服务安装
categories: memcached
---

# memcached简介

Memcached 是一个高性能的分布式内存对象缓存系统，用于动态Web应用以减轻数据库负载。它通过在内存中缓存数据和对象来减少读取数据库的次数，从而提高动态、数据库驱动网站的速度。Memcached基于一个存储键/值对的hashmap。其守护进程（daemon ）是用C写的，但是客户端可以用任何语言来编写，并通过memcached协议与守护进程通信。

memcache分为服务端和客户端程序

服务端程序用来支持存储k-v值,程序名称memcached

客户端与服务端通信,进行存取值(常用的如php的memcache扩展,memcached扩展等)


> memcached服务端安装过程如下

## 一.下载memcached相关源码

### 1. 下载libevent(memcached服务端需要用到)

    ```
    下载地址：http://libevent.org/ 
    wget -c https://github.com/libevent/libevent/releases/download/release-2.0.22-stable/libevent-2.0.22-stable.tar.gz
    ```

### 2. memcached下载,服务端程序

    ```
    下载地址：http://memcached.org/
    wget -c http://www.memcached.org/files/memcached-1.4.26.tar.gz
    ```

## 二.编译安装memcached

### 1. 安装libevent

```
    tar zxf libevent-2.0.22-stable.tar.gz #解压包
    cd libevent-2.0.22-stable #进入到解压的目录
    ./configure --prefix=/usr/local #编译前配置，生成Makefile文件，路径可自行更改
    make; make install #编译+安装
```

查看是否安装成功 

```
    ls -al  /usr/local/lib |grep libevent
```


### 2. 安装memcached

    ```
    tar zxf memcached-1.4.26.tar.gz #解压包
    cd memcached-1.4.26 #进入到解压的目录
     ./configure --with-libevent=/usr/local #编译前配置，生成Makefile文件，路径必须与libevent中一致
    make; make install #编译+安装
    ```

## 三.启动memcached

    Memcached启动脚本,复制memcached源码目录下scripts/memcached.sysv到/etc/init.d/memcached

    ```
    cp memcached-1.4.26/scripts/memcached.sysv /etc/init.d/memcached
    ```

    需要修改/etc/init.d/memcached如下行：
    ```
    chown $USER /usr/local/bin/memcached  
    daemon /usr/local/bin/memcached -d -p $PORT -u $USER  -m $CACHESIZE -c $MAXCONN -P /var/run/memcached/memcached.pid $OPTIONS  
    ```
    然后执行如下命令即可:  
    ```
    chmod 755 memcached  
    chkconfig --add memcached   
    chkconfig  --level 235  memcached  on
    ```

    **启动memcached服务**
    ```
    脚本启动方式
    service memcached start
    命令启动方式
    /usr/local/memcached/bin/memcached -d -m 1024 -u root  -p 11211 -c 1000 -P /tmp/memcached.pid
    ```

##【附：启动命令参数如下表】

    **启动方式：**
    -d 以守护程序（daemon）方式运行
    -u root 指定用户，如果当前为 root ，需要使用此参数指定用户
    -P /tmp/a.pid 保存PID到指定文件


    **内存设置：**
    -m 1024 数据内存数量，不包含memcached本身占用，单位为 MB

    -M 内存不够时禁止LRU，报错
    -n 48 初始chunk=key+suffix+value+32结构体，默认48字节
    -f 1.25 增长因子，默认1.25
    -L 启用大内存页，可以降低内存浪费，改进性能

    **安全设置：**
    -S 启用sasl安全验证功能,开启后，客户端需要提供用户名密码方能访问memcached

    **连接设置：**
    -l 127.0.0.1 监听的 IP 地址，本机可以不设置此参数
    -p 11211 TCP端口，默认为11211，可以不设置
    -U 11211 UDP端口，默认为11211，0为关闭

    **并发设置：**
    -c 1024 最大并发连接数，默认1024，最好是200
    -t 4 线程数，默认4。由于memcached采用NIO，所以更多线程没有太多作用
    -R 20 每个event连接最大并发数，默认20
    -C 禁用CAS命令（可以禁止版本计数，减少开销）


## memcached客户端安装,这里主要是php的memcache扩展

    安装php的memcache|memcached扩展(有2种扩展，一种是memcache，另一种是memcached)
    Memcache for PHP Module

    pecl.php.net有两个memcache扩展：

    memcache   memcached extension
    memcached PHP extension for interfacing with memcached via libmemcached library

    memcached 的版本比较新，而且使用的是 libmemcached 库。libmemcached 被认为做过更好的优化，应该比 php only 版本的 memcache 有着更高的性能。所以这里安装的是memcached(假设php5.4已经安装在在/usr/local/php). 


### php的memcache扩展安装

    1. php的memcache扩展下载地址
    ```
    http://pecl.php.net/package/memcache
    wget -c http://pecl.php.net/get/memcache-2.2.7.tgz
    ```

    2. php的memcache安装

    ```
    tar vxzf memcached-2.2.0.tgz  
    cd memcache-2.2.0
    /usr/local/php/bin/phpize  
    ./configure --with-php-config=/usr/local/php-5.4.41/bin/php-config 
    make  
    make install  
    ```

### php的memcached扩展安装

    1. php的memcached扩展下载地址
    ```
    http://pecl.php.net/package/memcached
    wget -c http://pecl.php.net/get/memcached-2.2.0.tgz(必须要有libmemcached library)

    libmemcached :
    libraryhttps://launchpad.net/libmemcached/+download
    wget -c https://launchpad.net/libmemcached/1.0/1.0.18/+download/libmemcached-1.0.18.tar.gz
    ```
    
    2. php的memcached安装

    1)、先安装依赖库
    ```
    tar -xzvf libmemcached-1.0.18.tar.gz
    cd libmemcached-1.0.18.tar.gz
    ./configure  
    make  
    make install  
    ```

    2)、安装memcached扩展
    ```
    tar vxzf memcached-2.2.0.tgz  
    cd memcache-2.2.0
    /usr/local/php/bin/phpize  
    如需启用sasl
    启用SASL验证功能需要在编译时指定--enable-sasl参数，否则安装成功后，无法启用SASL
    ./configure --with-php-config=/usr/local/php-5.4.41/bin/php-config --enable-memcached --with-libmemcached-dir=/usr/local --disable-memcached-sasl
    make  
    make install  
    ```

### php连接memcache测试

    ```
    <?php  
    //memcached
    $m = new Memcached();  
    $m->addServer('localhost', 11211);  
    $m->set('username', 'Allen');  
    var_dump($m->get('username'));  

    //memcache
    $mem = new Memcache;
    $mem->connect("127.0.0.1", 11211);
    $key = 'memcache_key';
    $mem->set($key, 'just a test',60);
    $val = $mem->get($key);
    echo $val;
    ```



