---
layout: post
title: celery与django集成
categories: python
---


# celery与django集成

## 准备工作：

### 1.拉取python镜像

```
docker pull python:3.6.4-alpine3.7
```

### 2.运行python镜像

```
docker run -it -p 6666:6666 --name celery-django -v "$PWD":/usr/src/myapp -w /usr/src/myapp python:3.6.4-alpine3.7 sh
```


## 安装celery

> 进入容器后，执行以下命令

```
pip install celery
pip install redis
```

## 安装django

```
pip install Django==2.0.1
python -m django --version
```

* 创建djano项目
```
django-admin startproject task
```


* 配置settints.py 让host可以访问
```
cd task/
vi task/settings.py

ALLOWED_HOSTS = ['192.168.110.128', 'localhost', '127.0.0.1']
```

* 启动django服务器
```
python manage.py migrate
python manage.py runserver 0.0.0.0:5000
```


## 安装django-celery

> celery任务调试django app

```
pip install django-celery
pip install sqlalchemy

```


## django配置集成celery

### 1.在task项目下，添加celery.py文件，用来创建celery  app实例

> vi task/task/celery.py

在django项目的settings配置中，管理celery的配置项，并且所有的 celery配置，namespace为大写，表示所有的celery配置项将是以CELERY且为大写，如在celery中broker_url，此处为CELERY_BROKER_URL，autodiscover_tasks()可以自动发现每个模块的任务

```
from __future__ import absolute_import, unicode_literals
import os
from celery import Celery

# set the default Django settings module for the 'celery' program.
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'task.settings')

app = Celery('task')

# Using a string here means the worker doesn't have to serialize
# the configuration object to child processes.
# - namespace='CELERY' means all celery-related configuration keys
#   should have a `CELERY_` prefix.
app.config_from_object('django.conf:settings', namespace='CELERY')

# Load task modules from all registered Django app configs.
app.autodiscover_tasks()


@app.task(bind=True)
def debug_task(self):
    print('Request: {0!r}'.format(self.request))
```


### 2.然后,修改task项目的__init__.py，加入以下代码

> vi task/__init__.py

```
from __future__ import absolute_import, unicode_literals

# This will make sure the app is always imported when
# Django starts so that shared_task will use this app.
from .celery import app as celery_app

__all__ = ('celery_app',)
```

### 3.在django项目的settings.py中加入如下配置

> vi task/settings.py

```
from __future__ import absolute_import, unicode_literals
# ^^^ The above is required if you want to import from the celery
# library.  If you don't have this then `from celery.schedules import`
# becomes `proj.celery.schedules` in Python 2.x since it allows
# for relative imports by default.

# Celery settings

CELERY_BROKER_URL = 'redis://192.168.110.128:6379/0'

#: Only add pickle to this list if your broker is secured
#: from unwanted access (see userguide/security.html)
CELERY_ACCEPT_CONTENT = ['json']
CELERY_RESULT_BACKEND = 'db+sqlite:///results.sqlite'
CELERY_TASK_SERIALIZER = 'json'

# Django settings for proj project.



INSTALLED_APPS += ("djcelery", )
import djcelery
djcelery.setup_loader()
```


## django-celery-results扩展，用于后端数据存储
1.安装app
```
pip install django-celery-results
```

2.修改settings.py
```
INSTALLED_APPS = (
    ...,
    'django_celery_results',
)
```

3.执行数据库脚本
```
python manage.py migrate django_celery_results
python manage.py migrate
```

4.配置settints.py
```
CELERY_RESULT_BACKEND = 'django-db'
#or
#CELERY_RESULT_BACKEND = 'django-cache'
```


## 启动celery守护进程

```
celery -A task worker -l info
celery -A task beat -l info --scheduler djcelery.schedulers:DatabaseScheduler
```



---

## django-celery-beat - Database-backed Periodic Tasks with Admin interface.

### install django-celery-beat

```
# alpine need musl-dev gcc library
apk add --update musl-dev gcc
pip install django-celery-beat
````

### 2.settings.py
```
INSTALLED_APPS = (
    ...,
    'django_celery_beat',
)
```

### 3.数据数据库
```
python manage.py migrate
```

### 4.Start the celery beat service
```
celery -A task beat -l info --scheduler django_celery_beat.schedulers:DatabaseScheduler
```


---

## 后话，flower
> 可用于监控管理celery，remote control ,websocket支持等

### install
```
pip install flower
```
 

### 启动flower
```
celery flower -A task --address=127.0.0.1 --port=5000 --broker=redis://192.168.110.128:6379/0
```

## 使用restful api投递任务
```
curl -i -X POST -H "'Content-type':'application/json'"  -d '{"args" :[1,2]}' http://192.168.110.128:5000/api/task/send-task/remote.tasks.add
```



## 部署django静态资源
```
1.确认django.contrib.staticfiles 包含在你的INSTALLED_APPS 中。

2.在你的settings 文件中定义STATIC_URL，例如：
STATIC_URL = '/static/'

3.设置settings.py
STATIC_ROOT = "/var/www/example.com/static/"
STATIC_ROOT = BASE_DIR + STATIC_ROOT
STATIC_ROOT = os.path.join(BASE_DIR, "static/")
4.收集静态资源
python manage.py collectstatic

5.nginx指定配置
```


# 运行容器
```
docker run -d celery uwsgi --socket :6000 --master --processes 4 --threads 2 --vhost --pidfile=/var/run/uwsgi.pid --vacuum --thunder-lock
```

> ref

```
https://docs.djangoproject.com/en/2.0/intro/tutorial01/
http://docs.celeryproject.org/en/latest/django/first-steps-with-django.html
https://github.com/celery/django-celery

http://docs.celeryproject.org/en/latest/userguide/periodic-tasks.html#beat-custom-schedulers
```
