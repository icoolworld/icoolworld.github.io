---
layout: post
title: nginx+lua+redis
categories: lua
---

# nginx+lua+redis
如果使用openresty，则不需要使用下面的步骤，以下方法适合使用已经安装nginx，再安装扩展的情况

1、下载nginx lua redis包
git clone https://github.com/openresty/lua-resty-redis.git

2.下载lua cjson包，用于json解析
```
https://openresty.org/cn/lua-cjson-library.html
git clone https://github.com/openresty/lua-cjson/
wget -c https://www.kyne.com.au/~mark/software/download/lua-cjson-2.1.0.tar.gz
```

3.安装lua cjson包
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

4、nginx.conf相关配置
```
# you do not need the following line if you are using
# the OpenResty bundle:
lua_package_path "/path/to/lua-resty-redis/lib/redis.lua;;";

location /api {
        default_type 'text/plain';
        content_by_lua_file /home/www/lua/api/api.lua;
}

location /get_api_from_redis {
        default_type 'text/plain';
        content_by_lua_file /home/www/lua/api/redis.lua;
}
```


vim /home/www/lua/api/api.lua
```
-- nginx vars
local ngx_vars = ngx.var
-- ngx.say("uri=",ngx_vars['uri'])
-- ngx.say("uri=",ngx_vars.uri)
-- ngx.say("reuqest method=",ngx_vars.request_method)
-- ngx.say("reuqest args=",ngx_vars.args)

-- HTTP GET method,get data from redis
if ngx_vars.request_method == "GET" then
    local key = ngx_vars.request_uri
    local res = ngx.location.capture("/get_api_from_redis",{args={cache_key = key}})
    ngx.say("body=",res.body)
end
```

vim /home/www/lua/api/redis.lua
```
local redis = require "resty.redis"
local red = redis:new()

red:set_timeout(1000) -- 1 sec

-- or connect to a unix domain socket file listened
-- by a redis server:
--     local ok, err = red:connect("unix:/path/to/redis.sock")

local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
    ngx.say("failed to connect: ", err)
    return
end

red:set("dog","a test")
local res, err = red:get("dog")
if not res then
    ngx.say("failed to get dog: ", err)
    return
end

if res == ngx.null then
    ngx.say("dog not found.")
    return
end
-- cache key--by-url
-- ngx.say(ngx.var.arg_cache_key)
ngx.say(res)
```

example:
```
/api?xxx=ddd&aaa==ccc
```