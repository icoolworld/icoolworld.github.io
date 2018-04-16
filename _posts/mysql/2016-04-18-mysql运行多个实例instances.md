---
layout: post
title: mysql运行多个实例instances
categories: mysql
---

#在一台机器上运行多个mysql实例

在某些情况下，你可能要运行MySQL的多个实例在同一台机器。你可能想要测试一个新的MySQL版本而使现有的生产环境不受干扰。或者你可能想给不同的用户访问不同的mysqld服务，让他们自己管理。（例如，你可能是一个互联网服务提供商要为不同客户提供独立的MySQL安装。）

每个实例可以使用不同的mysql服务程序，或者使用相同的mysql服务程序，或者是2者的组合。

例如，你可能想支行一个mysql5.6版本的服务，同时运行一个mysql5.7的服务，看看不同版本的mysql对负载的处理能力。
或者是同一版本的mysql，运行多个实例，每个实例管理不同的数据库

不管是否使用不同版本的mysql服务,每个实例必需配置一些参数值是唯一的（稍后将会给出）。参数可以在命令行或配置文件中设置。使用SHOW VARIABLES可以查看参数值的设置。

mysql实例主要的资源管理，是数据库的data目录，每个实例都应该有一个自己的data目录，使用 --datadir指定


除了使用不同的数据目录外，其他几个选项对于每个服务器实例都必须有不同的值：

端口号必需唯一，或者如果有多个IP地址，可以使用--bind-address为每个实例监听不同的地址

--port=port_num

--port controls the port number for TCP/IP connections. Alternatively, if the host has multiple network addresses, you can use --bind-address to cause each server to listen to a different address.

socket值必需不同，它是unix socket文件的路径(通常如/tmp/mysql.sock)

--socket={file_name|pipe_name}

--socket controls the Unix socket file path on Unix or the named pipe name on Windows. On Windows, it is necessary to specify distinct pipe names only for those servers configured to permit named-pipe connections.

该项值仅用在windows环境下
--shared-memory-base-name=name

This option is used only on Windows. It designates the shared-memory name used by a Windows server to permit clients to connect using shared memory. It is necessary to specify distinct shared-memory names only for those servers configured to permit shared-memory connections.

pid-file，mysql进程ID文件位置也必需不同
--pid-file=file_name

This option indicates the path name of the file in which the server writes its process ID.

如果使用了日志文件，以下几项配置还必需不同
If you use the following log file options, their values must differ for each server:

通用查询日志文件
--general_log_file=file_name

二进制日志，常用于备份和复制
--log-bin[=file_name]

mysql查询慢日志文件
--slow_query_log_file=file_name

mysql错误日志文件
--log-error[=file_name]

For further discussion of log file options, see Section 6.4, “MySQL Server Logs”.

To achieve better performance, you can specify the following option differently for each server, to spread the load between several physical disks:

为了更好的性能，下面参数也必需设置为不同的值，同时也更容易区分是哪个mysql服务创建了临时文件
--tmpdir=dir_name

如果是将不同版本的mysql安装在不同的目录，假设使用的是二进制解压安装方式，那么使用mysqld_safe默认初始化后，只要设置--socket和--port不同即可，因为其他参数都是相对于basedir目录的




http://dev.mysql.com/doc/refman/5.7/en/multiple-servers.html
http://dev.mysql.com/doc/refman/5.7/en/multiple-data-directories.html

http://dev.mysql.com/doc/refman/5.7/en/multiple-unix-servers.html