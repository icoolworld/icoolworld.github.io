---
layout: post
title: python中使用uswgi详解
categories: python
---

# python中使用uswgi详解

## 启动uwsgi
```
uwsgi --http :9090 --wsgi-file foobar.py
```

> 当你有一个前端web服务器，或者你正进行某些形式的基准时，不要使用 --http ，使用 --http-socket 。继续阅读快速入门来了解原因。


## 添加并发和监控

你可以用 --processes 选项添加更多的进程，或者使用 --threads 选项添加更多的线程 (或者可以同时添加)。

这将会生成4个进程 (每个进程有2个线程)，一个master进程 (在Inc死掉的时候会生成它们) 和HTTP路由器 (见前面)。

```
uwsgi --http :9090 --wsgi-file foobar.py --master --processes 4 --threads 2
```

一个重要的任务是监控。在生产部署上，了解正在发生的事情是至关重要的。stats子系统允许你将uWSGI的内部统计数据作为JSON导出：

```
uwsgi --http :9090 --wsgi-file foobar.py --master --processes 4 --threads 2 --stats 127.0.0.1:9191
```

## 将它放在一个完整的web服务器之后

即使uWSGI HTTP路由器是稳定并且高性能的，但是你或许想要将你的应用放在一个全功能的web服务器之后。

uWSGI原生支持HTTP, FastCGI, SCGI及其特定的名为”uwsgi”的协议 (是哒，错误的命名选择)。最好的协议显然是uwsgi，nginx和Cherokee已经支持它了 (虽然有各种Apache模块可用)
```
location / {
    include uwsgi_params;
    uwsgi_pass 127.0.0.1:3031;
}

```

现在，我们可以生成uWSGI来本地使用uwsgi协议：

```
uwsgi --socket 127.0.0.1:3031 --wsgi-file foobar.py --master --processes 4 --threads 2 --stats 127.0.0.1:9191
```

## 部署Django

Django大概是最常使用的Python web框架了。部署它是相当容易的 (我们继续配置4个进程，每个进程有2个线程)。

假设Django工程位于 /home/foobar/myproject:
```
uwsgi --socket 127.0.0.1:3031 --chdir /home/foobar/myproject/ --wsgi-file myproject/wsgi.py --master --processes 4 --threads 2 --stats 127.0.0.1:9191

```

(使用 --chdir ，我们移到指定的目录下)。在Django中，需要使用它来正确加载模块。

以上命令行太长了，且不便管理，使用配置文件：

```
[uwsgi]
socket = 127.0.0.1:3031
chdir = /home/foobar/myproject/
wsgi-file = myproject/wsgi.py
processes = 4
threads = 2
stats = 127.0.0.1:9191
```
仅需运行：
```
uwsgi yourfile.ini
```

## 关于Python线程的注意事项
如果你想要维护Python线程支持，而不为你的应用启动多线程，那么仅需添加 --enable-threads 选项 (或者在ini风格的文件中添加 enable-threads = true )。

## 安全性和可用性

总是 避免以root用户运行你的uWSGI实例。你可以使用 uid 和 gid 选项来去除权限：
```
[uwsgi]
https = :9090,foobar.crt,foobar.key
uid = foo
gid = bar
chdir = path_to_web2py
module = wsgihandler
master = true
processes = 8
```

如果你需要绑定到特许端口 (例如用于HTTPS的443)，那么使用共享socket。它们在去除权限之前创建，并且可以通过 =N 语法引用，其中， N 是socket号 (从0开始)：

```
[uwsgi]
shared-socket = :443
https = =0,foobar.crt,foobar.key
uid = foo
gid = bar
chdir = path_to_web2py
module = wsgihandler
master = true
processes = 8
```


web应用部署的一个常见问题是“卡住的请求”。你所有的线程/worker都卡住了 (请求阻塞) ，而你的应用无法接收更多的请求。要避免这个问题，你可以设置一个 harakiri 定时器。它是一个监控器 (由master进程管理)，会摧毁那些卡住超过指定秒数的进程 (小心选择 harakiri 值)。例如，你也许想要摧毁那些阻塞超过30秒的worker：

```
[uwsgi]
shared-socket = :443
https = =0,foobar.crt,foobar.key
uid = foo
gid = bar
chdir = path_to_web2py
module = wsgihandler
master = true
processes = 8
harakiri = 30
```


---

## 其他

## Python自动重载 (DEVELOPMENT ONLY!)
只在开发时使用它。

```
[uwsgi]
...
py-autoreload = 2
```


## 全栈CGI设置

我们在/var/www中有静态文件，在/var/cgi中有cgi。将会使用/cgi-bin挂载点访问cgi。所以将会在到/cgi-bin/foo.lua的请求上运行/var/cgi/foo.lua
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

## Nginx支持

一般来说，你只需包含uwsgi_params文件 (包含在nginx发行版本中)，使用uwsgi_pass指令来设置uWSGI socket的地址。

```
uwsgi_pass unix:///tmp/uwsgi.sock;
include uwsgi_params;
—— 或者如果你使用的是TCP socket，
uwsgi_pass 127.0.0.1:3031;
include uwsgi_params;
```

## 集群
对于所有的上游处理程序，Nginx支持漂亮的集群集成。

添加一个 upstream 指令到server配置块外:

```
upstream uwsgicluster {
  server unix:///tmp/uwsgi.sock;
  server 192.168.1.235:3031;
  server 10.0.0.17:3017;
}
```
然后修改你的uwsgi_pass指令:
```
uwsgi_pass uwsgicluster;
```

## 动态应用
当传递特殊变量的使用，uWSGI服务器可以按需加载应用。
如果请求设置了 UWSGI_SCRIPT 变量，那么服务器将会加载指定的模块:
```
location / {
  root html;
  uwsgi_pass uwsgicluster;
  uwsgi_param UWSGI_SCRIPT testapp;
  include uwsgi_params;
}
```
你甚至还可以在每个location内配置多个应用:
```
location / {
  root html;
  uwsgi_pass uwsgicluster;
  uwsgi_param UWSGI_SCRIPT testapp;
  include uwsgi_params;
}

location /django {
  uwsgi_pass uwsgicluster;
  include uwsgi_params;
  uwsgi_param UWSGI_SCRIPT django_wsgi;
}
```

## 在同一个进程中托管多个应用 (亦称管理SCRIPT_NAME和PATH_INFO)
WSGI标准决定了 SCRIPT_NAME 是一个用来选择特定应用的变量。不幸的是， nginx不能够根据SCRIPT_NAME重写PATH_INFO。出于这样的原因，你需要指示uWSGI在所谓的“挂载点”中映射特定的应用，并且自动重写SCRIPT_NAME和PATH_INFO：
```
[uwsgi]
socket = 127.0.0.1:3031
; mount apps
mount = /app1=app1.py
mount = /app2=app2.py
; rewrite SCRIPT_NAME and PATH_INFO accordingly
manage-script-name = true

[uwsgi]
socket = 127.0.0.1:3031
; mount apps
mount = the_app1=app1.py
mount = the_app2=app2.py


[uwsgi]
socket = 127.0.0.1:3031
; mount apps
mount = example.com=app1.py
mount = foobar.it=app2.py
```

# clear environment on exit
vacuum          = true
