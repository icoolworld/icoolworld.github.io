---
layout: post
title: 任务调度系统celery使用详解
categories: python
---

# 任务调度系统celery使用详解

## 消息中间件 Choosing a Broker

RabbitMQ
Redis

## 使用redis
### 安装
```
pip install -U "celery[redis]"
```

### 配置
```
app.conf.broker_url = ':'

==format==
redis://:password@hostname:port/db_number
```

### Visibility Timeout
> The visibility timeout defines the number of seconds to wait for the worker to acknowledge the task before the message is redelivered to another worker. Be sure to see Caveats below.

```
app.conf.broker_transport_options = {'visibility_timeout': 3600}  # 1 hour.
```

### 保存结果 Results
```
app.conf.result_backend = 'redis://localhost:6379/0'
```

## 安装Celery Installing Celery

```
pip install celery
```

## 应用 Application
> 使用celery，需要创建一个应用实例
第一个参数是任务名称，第二个参数是消息队列配置
```
from celery import Celery

#app = Celery('tasks', broker='pyamqp://guest@localhost//')
app = Celery('tasks', broker='redis://192.168.110.128:6379/0')

@app.task
def add(x, y):
    return x + y
```

## 启动celery work服务
```
celery -A tasks worker --loglevel=info
```

## 投递任务
delay是apply_async函数的别名
```
from tasks import add
add.delay(4, 4)

发送一个名称为lopri的队列，并在10秒后开始执行，传递参数为2,2
add.apply_async((2, 2), queue='lopri', countdown=10)

res = add.delay(2, 2)
res.get(timeout=1)
4

#获取任务ID
res.id
d6b3aea2-fb9b-4ebc-8da4-848818db9114

>>> res = add.delay(2)
>>> res.get(timeout=1)
>>> 
#get会传播异常，可使用以下参数禁用
res.get(propagate=False)

Traceback (most recent call last):
File "<stdin>", line 1, in <module>
File "/opt/devel/celery/celery/result.py", line 113, in get
    interval=interval)
File "/opt/devel/celery/celery/backends/rpc.py", line 138, in wait_for
    raise meta['result']
TypeError: add() takes exactly 2 arguments (1 given)


res.failed()
True

res.successful()
False

>>> res.state
'FAILURE'
任务可能的状态
PENDING -> STARTED -> SUCCESS
```


## 保存结果 Keeping Results
> broker指定消息队列中间件，backend指定将结果存放在哪
```
app = Celery('tasks', backend='redis://localhost', broker='pyamqp://')
```

```
result = add.delay(4, 4)
result.ready()
result.get(timeout=1)
result.get(propagate=False)
result.traceback
```

##配置
```
# 从对象加载配置
app.config_from_object('celeryconfig')

celeryconfig.py:

broker_url = 'pyamqp://'
result_backend = 'rpc://'

task_serializer = 'json'
result_serializer = 'json'
accept_content = ['json']
timezone = 'Europe/Oslo'
enable_utc = True

# 验证配置
python -m celeryconfig

http://docs.celeryproject.org/en/latest/userguide/configuration.html#configuration
```

## 后端运行 In the background
```
celery multi start w1 -A proj -l info

# restart
celery  multi restart w1 -A proj -l info

# stop
celery multi stop w1 -A proj -l info

# 等待当前任务执行完成后再stop
celery multi stopwait w1 -A proj -l info

默认会在当前项目路径下创建pid,log文件，为了避免多work冲突，可指定pidfile,logfile
celery multi start w1 -A proj -l info --pidfile=/var/run/celery/%n.pid \
                                        --logfile=/var/log/celery/%n%I.log

celery multi start 10 -A proj -l info -Q:1-3 images,video -Q:4,5 data \
    -Q default -L:4,5 debug
```


## Remote Control

查看worker当前在执行什么任务

```
celery -A proj inspect active

celery -A proj inspect active --destination=celery@example.com

celery -A proj inspect --help

celery -A proj control enable_events

celery -A proj events --dump

celery -A proj events

celery -A proj control disable_events
```


> http://docs.celeryproject.org/en/latest/getting-started/first-steps-with-celery.html#first-steps
> 
> http://docs.celeryproject.org/en/latest/getting-started/brokers/redis.html#broker-redis
> 
> http://docs.celeryproject.org/en/latest/getting-started/next-steps.html#next-steps
