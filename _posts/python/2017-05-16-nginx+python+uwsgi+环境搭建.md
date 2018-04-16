---
layout: post
title: nginx+python+uwsgi+环境搭建
categories: python
---

# Nginx+Python+uwsgi+Django的web开发环境安装及配置

## nginx安装  
这里就略过了...  

## python安装
通常系统已经自带了,这里也略过

## uwsgi安装

> 官网 http://uwsgi-docs.readthedocs.io/en/latest/

安装步骤如下：
```
yum -y install python-devel
wget -c https://projects.unbit.it/downloads/uwsgi-2.0.14.tar.gz
tar zxf uwsgi-2.0.14.tar.gz
cd uwsgi-2.0.14
make
# python uwsgiconfig.py --build

```

报错处理
```
plugins/python/uwsgi_python.h:2:20: fatal error: Python.h: No such file or directory
```
主要是没有安装python-devel
yum install python-devel


## 让Nginx支持uwsgi配置

相关网址  
http://uwsgi-docs.readthedocs.io/en/latest/Nginx.html

```
#uwsgi_pass unix:///tmp/uwsgi.sock;
uwsgi_pass 127.0.0.1:6000;
include uwsgi_params;
```

uwsgi_params文件内容
```
uwsgi_param QUERY_STRING $query_string;
uwsgi_param REQUEST_METHOD $request_method;
uwsgi_param CONTENT_TYPE $content_type;
uwsgi_param CONTENT_LENGTH $content_length;
uwsgi_param REQUEST_URI $request_uri;
uwsgi_param PATH_INFO $document_uri;
uwsgi_param DOCUMENT_ROOT $document_root;
uwsgi_param SERVER_PROTOCOL $server_protocol;
uwsgi_param REMOTE_ADDR $remote_addr;
uwsgi_param REMOTE_PORT $remote_port;
uwsgi_param SERVER_ADDR $server_addr;
uwsgi_param SERVER_PORT $server_port;
uwsgi_param SERVER_NAME $server_name;
```

集群配置
```
upstream uwsgicluster {
  server unix:///tmp/uwsgi.sock;
  server 192.168.1.235:3031;
  server 10.0.0.17:3017;
}
uwsgi_pass uwsgicluster;
```

## 配置uwsgi
配置说明  
http://uwsgi-docs.readthedocs.io/en/latest/Configuration.html  
相关配置选项  
http://uwsgi-docs.readthedocs.io/en/latest/Options.html  

进入刚安装uwsgi的目录
执行./uwsgi
可以查看已经安装成功

有多种方式可以进行uwsgi配置，可以使用命令行进行配置，也可以使用配置文件
配置文件有ini xml json yaml等4种方式的配置方式，任选一种

命令行示例：  
```
uwsgi --http-socket :9090 --psgi myapp.pl
uwsgi 的参数： 
    -M 开启Master进程 
    -p 4 开启4个进程 
    -s 使用的端口或者socket地址 
    -d 使用daemon的方式运行, 注意, 使用-d后, 需要加上log文件地址, 比如-d /var/log/uwsgi.log 
    -R 10000 开启10000个进程后, 自动respawn下 
    -t 30 设置30s的超时时间, 超时后, 自动放弃该链接 
    -limit-as 32 将进程的总内存量控制在32M
    -x  使用配置文件模式
```

等价于配置文件  
```
[uwsgi]
http-socket = :9090
psgi = myapp.pl
```

也可配置好后，通过命令行载入配置文件
```
uwsgi --ini http://uwsgi.it/configs/myapp.ini # HTTP
uwsgi --xml - # standard input
uwsgi --yaml fd://0 # file descriptor
uwsgi --json 'exec://nc 192.168.11.2:33000' # arbitrary executable
```


相关配置  
```
[uwsgi]
socket = 127.0.0.1:3031
chdir = /home/foobar/myproject/
wsgi-file = myproject/wsgi.py
processes = 4
生产环境推荐开启
master = true
threads = 2
stats = 127.0.0.1:9191
python自动重载，当修改py文件后,自动重新载入,仅开发时用
py-autoreload = 2
```

```
[uwsgi]
workdir = /var
ipaddress = 0.0.0.0

; start an http router on port 8080
http = %(ipaddress):8080
; enable the stats server on port 9191
stats = 127.0.0.1:9191
; spawn 2 threads in 4 processes (concurrency level: 8)
processes = 4
threads = 2
; drop privileges
uid = nobody
gid = nogroup

; serve static files in /var/www
static-index = index.html
static-index = index.htm
check-static = %(workdir)/www

; skip serving static files ending with .lua
static-skip-ext = .lua

; route requests to the CGI plugin
http-modifier1 = 9
; map /cgi-bin requests to /var/cgi
cgi = /cgi-bin=%(workdir)/cgi
; only .lua script can be executed
cgi-allowed-ext = .lua
; .lua files are executed with the 'lua' command (it avoids the need of giving execute permission to files)
cgi-helper = .lua=lua
; search for index.lua if a directory is requested
cgi-index = index.lua
```

https支持
```
openssl genrsa -out foobar.key 2048
openssl req -new -key foobar.key -out foobar.csr
openssl x509 -req -days 365 -in foobar.csr -signkey foobar.key -out foobar.crt

[uwsgi]
https = :9090,foobar.crt,foobar.key
chdir = path_to_web2py
module = wsgihandler
master = true
processes = 8
```

## 启动uwsgi

```
uwsgi --ini /configs/myapp.ini
uwsgi --http-socket 127.0.0.1:3031 --wsgi-file foobar.py --master --processes 4 --threads 2 --stats 127.0.0.1:9191
uwsgi --socket 127.0.0.1:3031 --chdir /home/foobar/myproject/ --wsgi-file myproject/wsgi.py --master --processes 4 --threads 2 --stats 127.0.0.1:9191
```

## 重新启动uwsgi
```
# using kill to send the signal
kill -HUP `cat /tmp/project-master.pid`
# or the convenience option --reload
uwsgi --reload /tmp/project-master.pid
# or if uwsgi was started with touch-reload=/tmp/somefile
touch /tmp/somefile
```

## 停止uwsgi
```
kill -INT `cat /tmp/project-master.pid`
# or for convenience...
uwsgi --stop /tmp/project-master.pid
```

## 开机启动uwsgi
/etc/rc.local中添加启动脚本,如
```
/usr/local/bin/uwsgi --emperor /etc/uwsgi/vassals --uid www-data --gid www-data --daemonize /var/log/uwsgi-emperor.log
```

## xinted方式
相关文档
http://uwsgi-docs.readthedocs.io/en/latest/Inetd.html

```
service uwsgi
    {
            disable         = no
            id              = uwsgi-000
            type            = UNLISTED
            socket_type     = stream
            server          = /root/uwsgi/uwsgi
            server_args     = --chdir /root/uwsgi/ --module welcome --logto /tmp/uwsgi.log
            port            = 3031
            bind            = 127.0.0.1
            user            = root
            wait            = yes
    }
```

## 关于socket,http,http-socket,uwsgi-socket的区别

    socket绑定到特定的unix/tcp socket使用默认协议,如将py请求转发至后端socket接口,如nginx转发请求，可以开启该接口
    可以是一个端口：如 socket = :6000,对应的nginx配置为uwsgi_pass 127.0.0.1:6000
    也可以是一个sock文件 socket = /tmp/uwsgi.sock,对应的nginx配置为uwsgi_pass unix:///path/to/your/mysite/mysite.sock;
    http,绑定到特定的unix/tcp socket使用http协议,端口会暴露在外
    http-socket绑定到特定的unix/tcp socket使用http协议,本地http协议，端口不会暴露在外
    uwsgi-socket 绑定到特定的unix/tcp socket使用uwsgi的协议,类似socket,nginx也可转发到该选项配置的端口
	
	
## Django安装
下载源码 https://www.djangoproject.com/download/
```
python setup.py install
出现错误
ImportError: No module named setuptools

参考
https://docs.djangoproject.com/en/1.8/howto/deployment/wsgi/uwsgi/
配置uwsgi
#socket  = :6000
#http = :6000
uwsgi-socket  = :6000
#http-socket  = :6000
master = true
chdir = /home/www/django/mysite
#wsgi-file = /home/www/django/mysite/manage.py 
processes = 4
stats = 127.0.0.1:9090
daemonize = /home/log/log.log
pidfile = /tmp/uwsgi.pid
vacuum = true
#disable-logging = true
py-autoreload = 2
vacuum=True
module=mysite.wsgi:application
```

可以配置开机启动,一个简单的配置/etc/init/uwsgi.conf
配置文件添加以下代码

```
# simple uWSGI script

description "uwsgi tiny instance"
start on runlevel [2345]
stop on runlevel [06]

respawn

exec uwsgi --master --processes 4 --die-on-term --socket :3031 --wsgi-file /var/www/myapp.wsgi

```
或者使用Emperor，可以配置多个app,在/etc/uwsgi目录下添加多个配置
```
# Emperor uWSGI script

description "uWSGI Emperor"
start on runlevel [2345]
stop on runlevel [06]

respawn

exec uwsgi --master --die-on-term --emperor /etc/uwsgi
```

## nginx+uwsgi的配置实例
http://uwsgi-docs.readthedocs.io/en/latest/tutorials/Django_and_nginx.html  

## 实战nginx配置,测试用
```
# the upstream component nginx needs to connect to
upstream django {
    # server unix:///path/to/your/mysite/mysite.sock; # for a file socket
    server 127.0.0.1:6000; # for a web port socket (we'll use this first)
}

server {
        listen       8080;
        server_name  uwsgi.com;


location /hi {
        alias /home/www/hi/;
}

location ~* .*\.py($|/) {
# uwsgi_pass 127.0.0.1:6000;
uwsgi_pass django;
include uwsgi_params;
#    uwsgi_param UWSGI_SCRIPT index;   
#    uwsgi_param UWSGI_PYHOME $document_root; 
#    uwsgi_param UWSGI_CHDIR  $document_root; 
        }

        access_log  /home/httplogs/test.com-access.log main;
        error_log  /home/httplogs/test.com-error.log;
}
```

## 实战uwsgi配置,测试用
```
[uwsgi]
# socket  = :6000
# http = :6000
uwsgi-socket  = :6000
# http-socket  = :6000
master = true
chdir = /home/www/
wsgi-file = /home/www/test.py
processes = 4
stats = 127.0.0.1:9090
daemonize = /home/log/log.log
pidfile = /tmp/uwsgi.pid
vacuum = true
# disable-logging = true
py-autoreload = 2
```

## 多应用部署  
http://uwsgi-docs.readthedocs.io/en/latest/Emperor.html  
http://uwsgi-docs.readthedocs.io/en/latest/Nginx.html?highlight=mount  
```
[uwsgi]
socket = 127.0.0.1:3031
; mount apps
mount = /app1=app1.py
mount = /app2=app2.py
; rewrite SCRIPT_NAME and PATH_INFO accordingly
manage-script-name = true
```

使用virtualenv方式


## 容器启动
```
docker run -it -v /home/www/python/:/home/www/django/ --name python_django_study -p 8600:8080 nginx_uwsgi_python_django
进入容器后，执行shell,启动uwsgi
uwsgi --ini /etc/uwsgi/default.ini 
```

host不能访问问题
DisallowedHost at /
Invalid HTTP_HOST header: 'x.x.x.x:8600'. You may need to add u'x.x.x.x' to ALLOWED_HOSTS.

vim mysite/settings.py
```
ALLOWED_HOSTS = ['*']
```