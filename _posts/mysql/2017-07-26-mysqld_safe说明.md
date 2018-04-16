---
layout: post
title: mysqld_safe说明
categories: mysql
---

bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data --log-error=/usr/local/mysql/logs/log.err


 --defaults-file=file_name


http://dev.mysql.com/doc/refman/5.7/en/server-options.html

http://dev.mysql.com/doc/refman/5.7/en/server-configuration-defaults.html

http://dev.mysql.com/doc/refman/5.7/en/option-files.html

http://dev.mysql.com/doc/refman/5.7/en/data-directory-initialization-mysqld.html

##mysqld-safe启动脚本说明(MySQL Server Startup Script)

推荐使用mysqld-safe来启动mysqld服务，它增加了一些安全特性，如重启服务发生错误时会写入日志文件，运行时错误信息写入等

mysqld_safe会尝试启动一个名称叫mysqld的可执行程序，如果想指定一个特定的程序名称，使用--mysqld 或 --mysqld-version选项。还可以用--ledir选项指定在哪个目录搜索mysqld程序

mysqld_safe的许多选项配置是和mysqld一样的,如果指定了一个mysqld_safe不存在的参数，将传递给mysqld，但是如果在配置文件中指定了mysqld_safe组选项，将忽略

mysqld_safe会从配置文件中读取mysqld,server,mysqld_safe等项的配置内容

如你在配置文件中指定了如下信息

```
[mysqld]
log-error=error.log
```
mysqld_safe会找到它并用--log-error初始化它

mysqld_safe接受命令行参数配置和配置文件参数配置

如果使用 --defaults-file or --defaults-extra-file配置文件，则参数必需在第一个

```
mysqld_safe --defaults-file=file_name --port=port_num
```
mysqld_safe启动要满足下面2个条件中的任意一个

1.mysqld服务程序,data目录可以在相对于工作目录(调用mysqld_safe的目录)目录下找到。
如果是二进制安装，mysqld_safe会搜索bin,data目录下的内容
如果是源码编译安装，mysqld_safe会搜索libexec和var目录下的内容

2.如果工作目录(调用mysqld_safe的目录)下没有mysqld,data程序，它会尝试调用绝对路径，通常是/usr/local/libexec and /usr/local/var目录，如果在配置时指定了相应的目录，应该是以配置的为准。

所以可以在mysql的安装目录（可以是任何位置,如/usr/local/mysql）用以下命令启动mysqld
```
shell> cd mysql_installation_directory
shell> bin/mysqld_safe &
```

如果启动失败，可以用 --ledir 和 --datadir 选项指定mysqld服务所在位置，和数据文件目录位置

可以用以下配置，设置mysql错误日志文件位置

--log-error=file_name 写入错误信息到相应的位置,默认是在data目录下的host_name.err文件
--syslog 同时写入错误信息到syslog
--skip-syslog 不写入错误信息到syslog
默认使用--skip-syslog


以下是mysqld_safe接受的命令行参数和配置文件参数。更多的配置文件参数，请参数配置文件说明

Table 5.1 mysqld_safe Options

Format	Description	Introduced
--basedir	Path to MySQL installation directory	 
--core-file-size	Size of core file that mysqld should be able to create	 
--datadir	Path to data directory	 
--defaults-extra-file	Read named option file in addition to usual option files	 
--defaults-file	Read only named option file	 
--help	Display help message and exit	 
--ledir	Path to directory where server is located	 
--log-error	Write error log to named file	 
--malloc-lib	Alternative malloc library to use for mysqld	 
--mysqld	Name of server program to start (in ledir directory)	 
--mysqld-safe-log-timestamps	Timestamp format for logging	5.7.11
--mysqld-version	Suffix for server program name	 
--nice	Use nice program to set server scheduling priority	 
--no-defaults	Read no option files	 
--open-files-limit	Number of files that mysqld should be able to open	 
--pid-file	Path name of process ID file	 
--plugin-dir	Directory where plugins are installed	 
--port	Port number on which to listen for TCP/IP connections	 
--skip-kill-mysqld	Do not try to kill stray mysqld processes	 
--skip-syslog	Do not write error messages to syslog; use error log file	 
--socket	Socket file on which to listen for Unix socket connections	 
--syslog	Write error messages to syslog	 
--syslog-tag	Tag suffix for messages written to syslog	 
--timezone	Set TZ time zone environment variable to named value	 
--user	Run mysqld as user having name user_name or numeric user ID user_id	 

参考http://dev.mysql.com/doc/refman/5.7/en/mysqld-safe.html
