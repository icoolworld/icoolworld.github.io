---
layout: post
title: 基于nginx+lua+redis高性能api应用实践
categories: lua
---

# 基于nginx+lua+redis高性能api应用实践

## 前言

> 比较传统的服务端程序（PHP、FAST CGI等），大多都是通过每产生一个请求，都会有一个进程与之相对应，请求处理完毕后相关进程自动释放。由于进程创建、销毁对资源占用比较高，所以很多语言都通过常驻进程、线程等方式降低资源开销。即使是资源占用最小的线程，当并发数量超过1k的时候，操作系统的处理能力就开始出现明显下降，因为有太多的CPU时间都消耗在系统上下文切换。

> lua-nginx-module模块将lua嵌入到nginx，让nginx高效执行lua脚本，高并发，非阻塞的处理各种请求。Lua内建协程，这样就可以很好的将异步回调转换成顺序调用的形式。ngx_lua在Lua中进行的IO操作都会委托给Nginx的事件模型，从而实现非阻塞调用。

>  每个NginxWorker进程持有一个Lua解释器或者LuaJIT实例，被这个Worker处理的所有请求共享这个实例。每个请求的Context会被Lua轻量级的协程分割，从而保证各个请求是独立的。 ngx_lua采用“one-coroutine-per-request”的处理模型，对于每个用户请求，ngx_lua会唤醒一个协程用于执行用户代码处理请求，当请求处理完成这个协程会被销毁。每个协程都有一个独立的全局环境（变量空间），继承于全局共享的、只读的“comman data”。所以，被用户代码注入全局空间的任何变量都不会影响其他请求的处理，并且这些变量在请求处理完成后会被释放，这样就保证所有的用户代码都运行在一个“sandbox”（沙箱），这个沙箱与请求具有相同的生命周期。 得益于Lua协程的支持，ngx_lua在处理10000个并发请求时只需要很少的内存。根据测试，ngx_lua处理每个请求只需要2KB的内存，如果使用LuaJIT则会更少。所以ngx_lua非常适合用于实现可扩展的、高并发的服务。


## nginx+lua安装

**环境需求：**

* 需要lua或luajit支持

> Lua和Luajit的区别

Lua是一个可扩展的轻量级脚本语言，它是用C语言编写的。Lua的设计目是为了嵌入应用程序中，从而为应用程序提供灵活的扩展和定制功能。Lua代码简洁优美，几乎在所有操作系统和平台上都可以编译、运行。

> 一个完整的Lua解释器不过200k

LuaJIT是采用C语言写的Lua的解释器。LuaJIT被设计成全兼容标准Lua 5.1, 因此LuaJIT代码的语法和标准Lua的语法没多大区别。LuaJIT和Lua的一个区别是，LuaJIT的运行速度比标准Lua快数十倍，可以说是一个lua的高效率版本。

```
官网
www.lua.org
http://luajit.org/download.html
```

* 安装luajit

```
wget -c http://luajit.org/download/LuaJIT-2.0.4.tar.gz
tar zxf LuaJIT-2.0.4.tar.gz
cd LuaJIT-2.0.4
make && make install

or指定安装位置
make install PREFIX=/usr/local/luajit2.0.4
```


* 下载ngx_devel_kit (NDK) module 模块,不需要安装
```
https://github.com/simpl/ngx_devel_kit/tags
```


* 下载nginx的lua模块,不需要安装
```
HttpLuaModule ：http://wiki.nginx.org/HttpLuaModule
https://github.com/openresty/lua-nginx-module#installation
https://github.com/openresty/lua-nginx-module/tags
wget -c https://github.com/openresty/lua-nginx-module/archive/v0.10.7.tar.gz
```

* 编译nginx(传统编译)

> 导入环境变量，告诉nginx编译系统,在哪查找luajit或lua
如果luajit使用默认安装，会在以下路径找到
```
# export LUAJIT_LIB=/usr/local/lib
# export LUAJIT_INC=/usr/local/include/luajit-2.0
```

```
 # tell nginx's build system where to find LuaJIT 2.0:
 export LUAJIT_LIB=/path/to/luajit/lib
 export LUAJIT_INC=/path/to/luajit/include/luajit-2.0

 # tell nginx's build system where to find LuaJIT 2.1:
 export LUAJIT_LIB=/path/to/luajit/lib
 export LUAJIT_INC=/path/to/luajit/include/luajit-2.1

 # or tell where to find Lua if using Lua instead:
 #export LUA_LIB=/path/to/lua/lib
 #export LUA_INC=/path/to/lua/include

 # Here we assume Nginx is to be installed under /opt/nginx/.
 ./configure --prefix=/opt/nginx \
         --with-ld-opt="-Wl,-rpath,/path/to/luajit-or-lua/lib" \
         --add-module=/path/to/ngx_devel_kit \
         --add-module=/path/to/lua-nginx-module

编译参数实例
 ./configure --prefix=/usr/local/nginx-1.10.2 --with-http_stub_status_module --with-http_sub_module --with-http_ssl_module --with-pcre=../pcre-8.39 --with-http_realip_module --with-http_gzip_static_module --with-zlib=../zlib-1.2.8 --with-openssl=../openssl-1.0.2h --with-ld-opt="-Wl,-rpath,/usr/local/luajit/lib"  --add-module=/home/wwwroot/ngx_devel_kit-0.3.0/ --add-module=/home/wwwroot/lua-nginx-module-0.10.7/


 ./configure --prefix=/usr/local/nginx-1.7.3-lua --with-http_stub_status_module --with-http_sub_module --with-http_ssl_module --with-pcre=../pcre-8.39 --with-http_realip_module --with-http_gzip_static_module --with-zlib=../zlib-1.2.8 --with-openssl=../openssl-1.0.2h --with-ld-opt="-Wl,-rpath,/usr/local/luajit2.0.4/lib" --add-module=../ngx_devel_kit-0.3.0 --add-module=../lua-nginx-module-0.10.7 

 make -j2
 make install
```

* 编译nginx动态模块(和以上方式二选一)

> nginx从1.9.11版本开始，开始支持编译动态模块，通过在./configure命令使用--add-dynamic-module=PATH选项替代--add-module=PATH选项。同时在nginx配置文件顶层通过load_module来加载模块，例如：

```
./configure --add-dynamic-module=PATH 编译动态模块
make modules
```

编译nginx动态库，需要先安装pcre库，否则会报错
```
pcre相关网址
http://www.pcre.org/
ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/
https://sourceforge.net/projects/pcre/files/pcre/

wget -c ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.40.tar.gz
使用以下源下载，速度更快
wget -c https://sourceforge.net/projects/pcre/files/pcre/8.39/pcre-8.39.tar.gz/download
tar zxf pcre-8.39.tar.gz
cd pcre-8.39

./configure
make
make install

同时在编译nginx的时候，加上--with-ld-opt="-lpcre -Wl,-rpath,/usr/local/lib" 参数
```

* 编译nginx动态模块实例

> 注意！编译动态模块时，使用编译参数需要和当前环境的nginx编译参数相同、nginx版本一致，否则加载动态模块时，有可能会报不兼容错误。使用nginx -V查看当前编译参数。

```
导入luajit环境变量
export LUAJIT_LIB=/usr/local/luajit2.0.4/lib
export LUAJIT_INC=/usr/local/luajit2.0.4/include/luajit-2.0/


./configure --prefix=/usr/local/nginx-1.10.2 --with-http_stub_status_module --with-http_sub_module --with-http_ssl_module --with-pcre=../pcre-8.34 --with-http_realip_module --with-http_gzip_static_module  --with-ld-opt="-lpcre -Wl,-rpath,/usr/local/luajit2.0.4/lib" --add-dynamic-module=../ngx_devel_kit-0.3.0 --add-dynamic-module=../lua-nginx-module-0.10.7

./configure --prefix=/usr/local/nginx-1.10.1 --with-http_stub_status_module --with-http_sub_module --with-http_ssl_module --with-pcre=../pcre-8.39 --with-http_realip_module --with-http_gzip_static_module --with-zlib=../zlib-1.2.8 --with-openssl=../openssl-1.0.2h --with-ld-opt="-lpcre -Wl,-rpath,/usr/local/luajit2.0.4/lib" --add-dynamic-module=../ngx_devel_kit-0.3.0 --add-dynamic-module=../lua-nginx-module-0.10.7


./configure --with-pcre=../pcre-8.39 \
--with-openssl=../openssl-1.0.2h \
--with-zlib=../zlib-1.2.8 --with-http_ssl_module \
--with-ld-opt="-Wl,-rpath,/usr/local/luajit2.0.4/lib" \
--add-dynamic-module=../ngx_devel_kit-0.3.0 \
--add-dynamic-module=../lua-nginx-module-0.10.7

make modules

查看刚编译的模块
cd objs 

拷备so文件到nginx目录
mkdir -p /usr/local/nginx/modules
cp ndk_http_module.so ngx_http_lua_module.so /usr/local/nginx/modules/
```

然后在nginx.conf配置文件中（配置环境main），通过load_module来加载动态模块

```
load_module modules/ndk_http_module.so;
load_module modules/ngx_http_lua_module.so;
```



## 错误处理

* 启动NGINX报如下错误 
[root@695c1860c6f7 nginx-1.10.2]# nginx -t
```
nginx: error while loading shared libraries: libluajit-5.1.so.2: cannot open shared object file: No such file or directory
```

* 解决方法：（根据luajit安装路径）
默认安装
```
# ln -s /usr/local/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2
luajit已指定安装路径
ln -s /usr/local/luajit2.0.4/lib/libluajit-5.1.so.2 /lib64/libluajit-5.1.so.2
```

[root@695c1860c6f7 nginx-1.10.2]# nginx -t
```
nginx: the configuration file /usr/local/nginx-1.10.2/conf/nginx.conf syntax is ok
nginx: configuration file /usr/local/nginx-1.10.2/conf/nginx.conf test is successful
```

* nginx加载动态模块，报错
```
nginx: [emerg] dlopen() "/usr/local/nginx-1.10.1/modules/ngx_http_lua_module.so" failed (/usr/local/nginx-1.10.1/modules/ngx_http_lua_module.so: undefined symbol: pcre_dfa_exec) in /usr/local/nginx-1.10.1/conf/nginx.conf:13
```

* 解决方法
ngx_http_lua_module，使用了pcre库，需要安装pcre库
```
pcre相关网址
http://www.pcre.org/
ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/
https://sourceforge.net/projects/pcre/files/pcre/


wget -c ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre-8.40.tar.gz

使用以下源下载，速度更快
wget -c https://sourceforge.net/projects/pcre/files/pcre/8.39/pcre-8.39.tar.gz/download
tar zxf pcre-8.39.tar.gz
cd pcre-8.39

./configure
make
make install

同时在编译nginx的时候，加上--with-ld-opt="-lpcre -Wl,-rpath,/usr/local/lib" 参数
```
至此nginx+lua环境安装成功

在nginx配置文件，server中，加入如下配置，进行测试,curl http://localhost/lua
```
location = /lua {
    default_type 'text/plain';
    content_by_lua_block {
        ngx.say('hello lua')
    }
}
```

## 安装lua的扩展包，以支持redis,cson解析

* 1.下载nginx lua redis包
```
git clone https://github.com/openresty/lua-resty-redis.git
tar解压到某个目录即可，稍后在lua程序中调用
```

* 2.下载lua cjson包，用于json解析
```
https://openresty.org/cn/lua-cjson-library.html
git clone https://github.com/openresty/lua-cjson/
wget -c https://www.kyne.com.au/~mark/software/download/lua-cjson-2.1.0.tar.gz
```

* 3.安装lua cjson包
```
tar zxf lua-cjson-2.1.0.tar.gz
cd lua-cjson-2.1.0

vim Makefile 

可以用lua5.1或luajit进行编译，安装的是luajit，这里在PREFIX指定luajit的安装路径，LUA_INCLUDE_DIR为包含lua.h的路径

##### Build defaults #####
LUA_VERSION =       5.1
TARGET =            cjson.so
PREFIX =            /usr/local/luajit2.0.4
#CFLAGS =            -g -Wall -pedantic -fno-inline
CFLAGS =            -O3 -Wall -pedantic -DNDEBUG
CJSON_CFLAGS =      -fpic
CJSON_LDFLAGS =     -shared
LUA_INCLUDE_DIR =   $(PREFIX)/include/luajit-2.0
LUA_CMODULE_DIR =   $(PREFIX)/lib/lua/$(LUA_VERSION)
LUA_MODULE_DIR =    $(PREFIX)/share/lua/$(LUA_VERSION)
LUA_BIN_DIR =       $(PREFIX)/bin

最后make install
或是make,然后手动拷备
cp cjson.so /usr/local/luajit2.0.4/lib/lua/5.1/ 
```

## 配置nginx.conf,支持lua解析

* vim nginx.conf，加入如下配置
```
http{
    #指定刚下载的redis扩展程序存放目录
    lua_package_path "/home/wwwroot/luacode/vendor/?.lua;;";
    #指定so模式的lua扩展包,基于c编译的,如cjson包
    lua_package_cpath '/usr/local/luajit2.0.4/lib/lua/5.1/?.so;;';
    #lua nginx worker共享缓存
    lua_shared_dict data 100m;
    init_by_lua_file /home/wwwroot/luacode/init.lua;    
}

upstream backend{
    server 10.101.35.51:8800;
}

server{
    location /api {
        default_type 'text/plain';
        #access_by_lua_file /home/wwwroot/luacode/auth.lua;
        #GET方式的请求，通过lua解析
        if ($request_method = "GET") {
            content_by_lua_file /home/wwwroot/luacode/content.lua;
        }
        if ($request_method != "GET") {
            proxy_pass http://backend;
        }
    }

    location ~ /backend/(.*) {
        internal;
		rewrite /backend/(.*) /index.php?$1 last;
        #rewrite /backend/(.*) $1 break;
        #proxy_pass http://backend;
    }
}
```

## 部署lua代码

* vim init.lua

```
config = {}
config["redis"] = {
    host = "10.99.206.208",
    port = "8379",
    db   = 6,
    timeout = "1000",
    keepalive = {idle = 10000, size = 100},
}
config['nginx'] = {
    ngx_shared_timeout = 120
}

```

* vim content.lua

```
-- author ljh
-- version 1.0
local redis = require("resty.redis")
local cjson = require("cjson")
local ngx_log = ngx.log
local ngx_ERR = ngx.ERR
local ngx_exit = ngx.exit
local ngx_print = ngx.print
-- local ngx_re_match = ngx.re.match
local ngx_var = ngx.var
local ngx_shared_data = ngx.shared.data
local red = redis:new()

-- 响应输出内容
-- body   http输出body内容
-- status http状态码
-- header http响应头,table格式
local function response(body,status,header)
    ngx.status = status
    if header then
        for key, val in pairs(header) do
            ngx.header[key] = val
        end
    end
    ngx_print(body)
    ngx_exit(ngx.status)
end

-- 通过http回后端请求数据
local function read_http(id)
    ngx_log(ngx_ERR, "request http uri :", id)
    local resp = ngx.location.capture("/backend/"..id)
    if not resp then
        ngx_log(ngx_ERR, "request error :", err)
        return 
    end
    response(resp.body,resp.status,resp.header)
    -- return resp
end

--关闭redis连接
local function close_redis(red)
    if not red then
        return
    end
    local pool_max_idle_time = config.redis.keepalive.idle
    local pool_size = config.redis.keepalive.size
    -- Basically if your NGINX handle n concurrent requests and your NGINX has m workers, then the connection pool size should be configured as n/m
    -- redis连接放入连接池
    local ok, err = red:set_keepalive(pool_max_idle_time, pool_size)
    if not ok then
        ngx_log(ngx_ERR, "set redis keepalive error : ", err)
    end
end

-- 验证access token是否有效
local function validToken(data)
    if not data then
        return false
    end
    if data == ngx.null then
        return false
    end
    local json = cjson.decode(data)
    if 'table' ~= type(json) then
        return false
    end
    local expire_time = json.expire_time
    local current_time = os.time()
    if ((expire_time > 0) and (current_time > expire_time)) then
        return false
    end
    return true
end

-- get access token from http request (header or query params)
local function getAccessToken()
    --str = ngx.req.get_headers()["Authorization"]
    --for i in string.gmatch(str, "%S+") do
    --  ngx.say(i)
    --end
    local access_token = nil
    -- get access_token from header
    local auth_code = ngx.req.get_headers()["Authorization"]
    if auth_code then
        -- the header is Authorization:bearer xxxx
        access_token = string.sub(auth_code,8)
    else
        -- get access token from GET MEquery params
        access_token = ngx.var.arg_access_token
    end
    return access_token
end

-- 验证http请求,如果通过返回token,否则返回false
local function auth()
    local access_token = getAccessToken()
    if not access_token then
        return false
    end
    key = "access-token-key-"..ngx.md5(access_token)
    local token = red:get(key)
    if not validToken(token) then
        return false
    end
    return cjson.decode(token)
end

-- main function
local function main()
    local status = 200
    local header = {}
    local content = nil
    local resp = nil
    local client_id = nil
    header['content_type'] = 'application/json'
    -- 连接redis,失败转后端处理
    red:set_timeout(config.redis.timeout)
    local ok, err = red:connect(config.redis.host, config.redis.port)
    if not ok then
        ngx_log(ngx_ERR, "connect to redis error : ", err)
        read_http(ngx_var.request_uri)
    end
    -- select redis db,失败转后端处理
    local ok, err = red:select(config.redis.db)
    if not ok then
        ngx_log("failed to select redis db: ", err)
        read_http(ngx_var.request_uri)
    end
    -- 验证token,失败回后端(这里是通过redis验证,考虑redis失效等情况)
    local token = auth()
    if not token or not token.client_id then
        read_http(ngx_var.request_uri)
    end
    -- 获取client_id,结合request_uri组成redis缓存key
    client_id = token.client_id
    -- cache_key,request_uri md5 key
    local cache_key = 'api_clientid_'..client_id..'_request_uri_'..ngx.md5(ngx_var.request_uri)
    -- 从nginx的共享内存中取数据(减少redis的tcp连接)
    local content = ngx_shared_data:get(cache_key)
    -- nginx共享内存有数据,直接返回
    if content  then
        response(content,status,header)
    end
    -- nginx共享内存没有数据，则请求redis缓存
    if not content or content == ngx.null then 
        ngx_log(ngx_ERR, "nginx shared memory not found content, back to reids, id : ", cache_key)
        content = red:get(cache_key)
    end 
    -- redis 没有数据,将请求转发到后端
    if not content or content == ngx.null then 
        -- ngx.say('no redis data')
        ngx_log(ngx_ERR, "redis not found content, back to http, request_uri : ", ngx_var.request_uri)
        read_http(ngx_var.request_uri)
    else
        close_redis(red)
        -- 加入nginx共享缓存，worker共享
        ngx_shared_data:set(cache_key,content,config.nginx.ngx_shared_timeout)
        response(content,status,header)
    end
end
main()
```