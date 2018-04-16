---
layout: post
title: python-mysql模块
categories: python
---

# python mysql模块安装


1.MySQL-python,是python社区开发的一个驱动

https://pypi.python.org/pypi/MySQL-python
https://pypi.python.org/pypi/MySQL-python/1.2.5
wget -c https://pypi.python.org/packages/a5/e9/51b544da85a36a68debe7a7091f068d802fc515a3a202652828c73453cad/MySQL-python-1.2.5.zip#md5=654f75b302db6ed8dc5a898c625e030c

```
cd MySQL-python-1.2.5
python setup.py build
```

2.mysql官方提供的connector-ptyon驱动

http://dev.mysql.com/get/Downloads/Connector-Python/mysql-connector-python-2.1.4.tar.gz

```
shell> tar xzf mysql-connector-python-VER.tar.gz
shell> cd mysql-connector-python-VER
shell> sudo python setup.py install
```


pip search mysql-connector | grep --color mysql-connector-python

pip install mysql-connector-python-rf