---
layout: post
title: mysqld_multi使用说明
categories: mysql
---

#mysqld_multi使用说明

mysqld_multi是一个用来管理多个mysqld实例的工具，可以监听不同的TCP/IP端口，可以启动关闭多个服务，显示服务的状态等。

mysqld_multi会搜索配置文件my.cnf下命名为[mysqldN]的组配置(也可以通过--defaults-file选项指定配置文件路径)。其中N，可以是任意有效的数字。

数字N，用来区分不同的配置，并且告诉mysqld_multi将要指定哪个服务被启动，关闭，显示状态等。组里面的配置同[mysqld]的配置格式是一样的。每个组的配置，有一些参数必需是不同的，如data目录，端口号，pid路径，socket路径，日志路径等

##mysqld_multi调用方式如下：
```
shell> mysqld_multi [options] {start|stop|reload|report} [GNR[,GNR] ...]
```
其中GNR是组数字N，可以指定多个，表示对多个实例进行启动，关闭，报告状态等。
如果没有指定GNR，则将对配置文件中的所有[mysqldN]实例，执行相应的操作
还可以指定数字的范围，用-符号相连，数字之间不要有空格，如下表示，停止8,10,11,12,13几个服务。
```
mysqld_multi stop 8,10-13
```

如下命令可以显示配置案例
```
shell> mysqld_multi --example
```

可以通过--defaults-file=file_name指定配置文件的路径，或者使用--no-defaults不指定配置文件
如果不指定任何参数，会按照配置文件的搜索路径进行搜索，如果指定了选项defaults-extra-file=file_name ，额外的配置文件也将被包含

mysqld_multi程序会搜索配置文件中的[mysqld_multi]和[mysqldN]组配置，[mysqld_multi]是用来给mysqld_multi程序使用，[mysqldN]是用来传递给mysqld实例的

[mysqld] 或者 [mysqld_safe]组配置，可以设置成通用的配置，给mysqld,mysqld_safe使用。

可以给每个实例指定配置文件，这样相应的实例会使用相应的配置文件。

##mysqld_multi 支持以下参数配置：

 --help
帮助信息

 --example
输出配置案例

 --log=file_name
日志文件的位置

 --mysqladmin=prog_name
指定mysqladmin程序的位置，用来关闭mysql服务


 --mysqld=prog_name

指定mysqld程序的位置，也可以指定mysqld_safe，如果指定为mysqld_safe，则需要在相应的配置组[mysqldN]中加入ledir,或mysqld配置，告诉mysqld_safe在哪里找到mysqld程序如：
```
[mysqld38]
mysqld = mysqld-debug
ledir  = /opt/local/mysql/libexec
```

 --no-log
输出日志到终端，不到日志文件

 --password=password
调用mysqladmin所需要的密码配置,该参数是必需配置的

 --silent
静默模式，不提示任何警告信息

 --tcp-ip
通过TCP/IP端口连接MYSQL服务，不通过socket file方式，默认是使用socket file方式

 --user=user_name
调用mysqladmin的mysql帐户

 --verbose
显示详细的信息

 --version
显示版本并退出

##注意事项
1.请确保对每个启动mysqld服务的unix帐户，拥有对mysql的数据目录的完全访问权限，不要使用root帐户。
2.确保每个实例用来停止mysqld服务的mysql帐户(供mysqladmin程序使用),有相同的帐户名称和密码，并且拥有SHUTDOWN权限。
如可以每个实例设置一个相同的帐户名称密码(如multi_admin)，用来关闭多实例服务,连接每个mysql实例，进行如下设置
```
shell> mysql -u root -S /tmp/mysql.sock -p
Enter password:
mysql> CREATE USER 'multi_admin'@'localhost' IDENTIFIED BY 'multipass';
mysql> GRANT SHUTDOWN ON *.* TO 'multi_admin'@'localhost';
```

连接不同的mysql实例，请改变客户端连接参数的配置，如
```
mysql -h 127.0.0.1 -u root -p123456 -P 3306
mysql -h 127.0.0.1 -u root -p123456 -P 3307

```

##如果启动mysqld_multi出现错误提示
```
WARNING: my_print_defaults command not found.
Please make sure you have this command available and
in your path. The command is available from the latest
MySQL distribution.
ABORT: Can't find command 'my_print_defaults'.
This command is available from the latest MySQL
distribution. Please make sure you have the command
in your PATH.
```
将mysql/bin的路径加入环境变量
```
vi /etc/profile
export PATH=/usr/local/mysql/bin/:$PATH
```
source /etc/profile

##mysqld_multi无法关闭的原因
发现在配置文件中[mysqld_multi]指定password后也无法停止mysql实例
经排查发现，password被转化成***,传递给了mysqladmin
使用命令行选项指定password即可,如
```
bin/mysqld_multi --password=123456 stop 2
```
还有用来管理mysql多实例的帐户，需要授权shutdown权限


##以下是多实例my.cnf的参考配置

```
# This is an example of a my.cnf file for mysqld_multi.
# Usually this file is located in home dir ~/.my.cnf or /etc/my.cnf

[mysqld_multi]
mysqld     = /usr/local/mysql/bin/mysqld_safe
mysqladmin = /usr/local/mysql/bin/mysqladmin
user       = multi_admin
password   = my_password

[mysqld2]
socket     = /tmp/mysql.sock2
port       = 3307
pid-file   = /usr/local/mysql/data2/hostname.pid2
datadir    = /usr/local/mysql/data2
language   = /usr/local/mysql/share/mysql/english
user       = unix_user1

[mysqld3]
mysqld     = /path/to/mysqld_safe
ledir      = /path/to/mysqld-binary/
mysqladmin = /path/to/mysqladmin
socket     = /tmp/mysql.sock3
port       = 3308
pid-file   = /usr/local/mysql/data3/hostname.pid3
datadir    = /usr/local/mysql/data3
language   = /usr/local/mysql/share/mysql/swedish
user       = unix_user2

[mysqld4]
socket     = /tmp/mysql.sock4
port       = 3309
pid-file   = /usr/local/mysql/data4/hostname.pid4
datadir    = /usr/local/mysql/data4
language   = /usr/local/mysql/share/mysql/estonia
user       = unix_user3
 
[mysqld6]
socket     = /tmp/mysql.sock6
port       = 3311
pid-file   = /usr/local/mysql/data6/hostname.pid6
datadir    = /usr/local/mysql/data6
language   = /usr/local/mysql/share/mysql/japanese
user       = unix_user4
```


http://dev.mysql.com/doc/refman/5.7/en/mysqld-multi.html