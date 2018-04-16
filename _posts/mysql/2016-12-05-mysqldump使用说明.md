---
layout: post
title: mysqldump使用说明
categories: mysql
---

#mysqldump 使用说明 

##A Database Backup Program
	mysqldump客户端是一款实用的mysql备份程序，可以对数据库的定义及数据表内容，进行备份生成相应的SQL语句。它可以对一个或多个数据库进行备份，或转数据移到另一个SQL Server。mysqldump命令可以生成输出CSV，其他分隔符的文本，或XML格式。

	推荐使用mysql5.7.9以后的mysqldump工具，之前的工具，对表的列定义有一些BUG，可以使用INFORMATION_SCHEMA.COLUMNS 表来确定需要生成列的表。

	mysqldump需要SELECT权限来导出表，SHOW VIEW来导出视图，TRIGGER来导出触发器，如果没有使用--single-transaction 选项，需要LOCK TABLES锁表，其他的导出功能还需要其他的权限。

	导入一个dump导出的文件，需要具有执行它所包含的语句的权限，例如语句中包含CREATE等。

	如果在windows中导出，默认的文件格式是UTF-16,它是不允许的连接字符集。这种格式载入的时候将产生错误。
	mysqldump [options] > dump.sql
	加上--result-file导出ASCII格式
	mysqldump [options] --result-file=dump.sql

##性能和可扩展方面的考虑  Performance and Scalability Considerations

	mysqldump的优点是它提供一个较为方便和灵活的方式，可以在导出前进行查看和编辑。你可以将数据库进行拷备，用来做为开发环境的，或是一些其他的用途。

	如果进行备份大量的数据，它不是一个好的方案。备份步骤需要一些时间，数据恢复会很慢，因为重新导入SQL语句涉及磁盘I/O插入，创建索引，等等。

	对于大规模的备份和还原，物理备份是比较合适的，以他们的原始格式复制数据文件，可以快速恢复

	mysqldump可以检索和备份数据以一行一行的方式。或者它可以检索在内存中的表，在导出之前。但是如果表是很大的话，使用内存中的表可能会有一些问题。默认是一行一行的方式读取数据的，即启用了--quick选项(--opt),如果要使用内存表，使用--skip-quick选项。

	如果使用较新的mysqldump导出了数据，但是恢复到一个较老的mysql版本中,使用 --skip-opt选项代替--opt，或使用--extended-insert选项

##调用语法 Invocation Syntax

	一般有以下三种方式使用mysqldump,调用一个库的一张或多张表，一个或多个库，或者全部的数据库。
	```
	shell> mysqldump [options] db_name [tbl_name ...]
	shell> mysqldump [options] --databases db_name ...
	shell> mysqldump [options] --all-databases
	```

	如果没有--databases选项，则不导出create database和use语句，如mysqldump test > dump.sql导出
	这样的话，必需在重新导入的时候，指定特定的数据库名称。可以是和原库的名称不一样，如果指定的数据库不存在，必需先创建它。可以使用如下方式导入：mysql db1 < dump.sql

> 选项配置

##连接服务器相关配置 Connection Options

	--bind-address=ip_address
	如果一台计算机上有多个网络接口，使用bind-address=ip_address选项，还指定连接到服务器的哪个接口

	--compress, -C
	如果支持压缩，客户端与服务端之间的信息传输，将被压缩。

	--default-auth=plugin
	A hint about the client-side authentication plugin to use. See Section 7.3.8, “Pluggable Authentication”. 

	--enable-cleartext-plugin
	Enable the mysql_clear_password cleartext authentication plugin. (See Section 7.5.1.8, “The Cleartext Client-Side Authentication Plugin”.) 
	This option was added in MySQL 5.7.10. 

	--host=host_name, -h host_name
	指定从哪台mysql服务器dump数据，默认是localhost

	--login-path=name
	Read options from the named login path in the .mylogin.cnf login path file. A “login path” is an option group containing options that specify which MySQL server to connect to and which account to authenticate as. To create or modify a login path file, use the mysql_config_editor utility. See Section 5.6.6, “mysql_config_editor — MySQL Configuration Utility”. 

	--password[=password], -p[password]
	连接mysql的密码，可以使用缩写-p选项，如果使用-p,则密码与参数之间不能有空格，可以在配置文件中[mysqldump]指定password

	--pipe, -W
	在windows中使用--pipe
	On Windows, connect to the server using a named pipe. This option applies only if the server supports named-pipe connections. 

	--port=port_num, -P port_num
	mysql 的 TCP/IP 端口，默认是3306

	--protocol={TCP|SOCKET|PIPE|MEMORY}
	连接协议，有TCP|SOCKET|PIPE|MEMORY几种可供使用

	--secure-auth
	不要以旧的密码格式发送到服务器，这将阻止连接，除非使用新的密码格式。5.7.4新增。5.7.5被丢弃。

	--socket=path, -S path
	在本地localhost连接mysql是，将使用socket连接，windows使用的是pipe

	--ssl*
	是否使用ssl连接到mysql服务

	--tls-version=protocol_list

	The protocols permitted by the client for encrypted connections. The value is a comma-separated list containing one or more protocol names. The protocols that can be named for this option depend on the SSL library used to compile MySQL. For details, see Section 7.4.3, “Secure Connection Protocols and Ciphers”. 

	This option was added in MySQL 5.7.10. 

	--user=user_name, -u user_name
	连接服务的mysql帐户名

	You can also set the following variables by using --var_name=value syntax: 
	max_allowed_packet

	The maximum size of the buffer for client/server communication. The default is 24MB, the maximum is 1GB. 

	net_buffer_length
	client/server连接通信时的初始化buffer大小，当使用--extended-insert or --opt选项创建多行插入语句时，mysqldump会创建行达到net_buffer_length字节长度。

	The initial size of the buffer for client/server communication. When creating multiple-row INSERT statements (as with the --extended-insert or --opt option), mysqldump creates rows up to net_buffer_length bytes long. If you increase this variable, ensure that the MySQL server net_buffer_length system variable has a value at least this large. 


##配置文件相关的选项  Option-File Options

	--defaults-extra-file=file_name
	额外的配置文件，将会在读取全局配置文件之后，用户配置文件之前，读取该配置文件内容。如果指定的文件不存在或不可访问，将发生一个错误。

	--defaults-file=file_name
	mysql配置文件，如果指定的文件不存在或不可访问，将发生一个错误。

	--defaults-group-suffix=str
	通常情况下mysqldump会读取[client],[mysqdump]组的配置，使用该选项，可以指定读取其他组配置，如--defaults=group-suffix=other,将还会读取[client_other],[mysqldump_other]组配置。

	--no-defaults
	不读取任何配置文件
	如果存在.mylogin.cnf文件，不管什么情况都会读取该配置文件。它将阻止password被使用在命令行方式。而使用一个更加安全的方式。
	The exception is that the .mylogin.cnf file, if it exists, is read in all cases. This permits passwords to be specified in a safer way than on the command line even when --no-defaults is used. (.mylogin.cnf is created by the mysql_config_editor utility. See Section 5.6.6, “mysql_config_editor — MySQL Configuration Utility”.) 

	 --print-defaults 
	 打印从配置文件读取的所有配置信息。


## DDL选项

	--add-drop-database
	在每个CREATE DATABASE之前，增加DROP DATABASE语句，通常和 --all-databases or --databases 一起使用，因为如果不使用这其中之一的选项，将不会创建CREATE DATABASE语句

	--add-drop-table
	添加DROP TABLE 语句在每个 CREATE TABLE之前

	--add-drop-trigger
	添加DROP TRIGGER 触发器语句，在每个 CREATE TRIGGER 之前

	--all-tablespaces, -Y
	该选项是和NDB集群相关的，其他类型无效。每个表需要创建tablespaces

	--no-create-db, -n
	不创建CREATE DATABASE语句，和 --all-databases or --databases 一起使用才生效。

	--no-create-info, -t
	不创建CREATE TABLE语句

	This option does not exclude statements creating log file groups or tablespaces from mysqldump output; however, you can use the --no-tablespaces option for this purpose.

	--no-tablespaces, -y
	不输出所有 CREATE LOGFILE GROUP 和 CREATE TABLESPACE语句

	--replace
	使用REPLACE而不是INSERT


## 调试选项配置  Debug Options

	--allow-keywords
	允许创建带mysql系统关键字的列字段，但是会在字段前加上表名前缀。如table_cloumn

	--comments, -i
	在导出的文件中添加如version,host等信息，默认启用，可以使用 --skip-comments不输出这些信息

	--debug[=debug_options], -# [debug_options]

	Write a debugging log. A typical debug_options string is d:t:o,file_name. The default value is d:t:o,/tmp/mysqldump.trace.

	--debug-check

	Print some debugging information when the program exits.

	--debug-info

	Print debugging information and memory and CPU usage statistics when the program exits. 


	--dump-date
	如果--comments开户，则使用该选项，将会在结尾，输出导出的时间，格式如下 
	-- Dump completed on DATE

	--force, -f
	忽略所有错误，继续执行导出，如果同时指定了--ignore-error ，那么 --force优先


	--log-error=file_name
	输出警告和错误信息到日志文件

	--skip-comments
	不显示相关版本信息等

	--verbose, -v
	print显示程序的详细信息

## 帮助选项 Help Options

	The following options display information about the mysqldump command itself.

    --help, -?

    Display a help message and exit.

    --version, -V

    Display version information and exit. 



##国际化选项 Internationalization Options

	--character-sets-dir=dir_name
	The directory where character sets are installed. See Section 11.5, “Character Set Configuration”. 

	--default-character-set=charset_name
	设置默认的字符集，默认是utf8

	--no-set-names, -N
	不写入SET NAMES default_character_set到文件。和--skip-set-charset一样。

	--set-charset
	写入 SET NAMES default_character_set 到导出文件，默认是开启的。使用--skip-set-charset关闭



## 主从复制相关  Replication Options

	--master-data[=value]
	使用--master-data这个选项将主复制服务器生成转储文件,可用于建立另一个maste的slave服务器,它会使导出语句包含CHANGE MASTER TO语句，它说明了二进制日志的坐标(file name和position),这些坐标信息将告诉slave服务器，在导入数据之后，从哪里开始复制maste服务器的信息，

	如果master-data被设置为2，CHANGE MASTER TO语句将被导出为注释语句，将不会生效，如果设置为1，在导入文件后将立即生效。默认值是1

	该选项需要数据库的RELOAD权限，并且 binary log被启用。

	master-data选项，会自动关闭--lock-tables。并且会使用--lock-all-tables, 除非设置了--single-transaction选项，在这种情况下，在导出开始前，会在短时间里，获得一个全局的只读lock锁。
	在所有情况下，日志中的任何操作都会发生在转储的确切时刻。 

	也可以使用--dump-slave选项，从一个slave导出数据，它会覆盖--master-data配置，如果2个选项都都使用，会使--master-data被忽略。

	Use this option to dump a master replication server to produce a dump file that can be used to set up another server as a slave of the master. It causes the dump output to include a CHANGE MASTER TO statement that indicates the binary log coordinates (file name and position) of the dumped server. These are the master server coordinates from which the slave should start replicating after you load the dump file into the slave. 

	If the option value is 2, the CHANGE MASTER TO statement is written as an SQL comment, and thus is informative only; it has no effect when the dump file is reloaded. If the option value is 1, the statement is not written as a comment and takes effect when the dump file is reloaded. If no option value is specified, the default value is 1. 

	This option requires the RELOAD privilege and the binary log must be enabled. 

	 The --master-data option automatically turns off --lock-tables. It also turns on --lock-all-tables, unless --single-transaction also is specified, in which case, a global read lock is acquired only for a short time at the beginning of the dump (see the description for --single-transaction). In all cases, any action on logs happens at the exact moment of the dump.

	It is also possible to set up a slave by dumping an existing slave of the master, using the --dump-slave option, which overrides --master-data and causes it to be ignored if both options are used. 


	--delete-master-logs
	在一个主复制服务器，在执行dump操作后，通过向服务器发送 PURGE BINARY LOGS语句，删除binary logs，该选项自动启用--master-data
	On a master replication server, delete the binary logs by sending a PURGE BINARY LOGS statement to the server after performing the dump operation. This option automatically enables --master-data. 


	--set-gtid-purged=value

	这个选项可以控制全局事务ID(GTID)信息写入到转储文件,通过指示是否添加一组@@global.gtid_purged语句输出。这个选项也可能导致输出一组SQL语句到文件，有可能禁用二进制日志,当转储文件被重新加载。

	该选项有3个值：OFF,ON,AUTO，默认是AUTO（即ON）
	--set-gtid-purged=OFF:不会向导出文件写入SET @@SESSION.SQL_LOG_BIN=0;（不禁用二进制日志）
	--set-gtid-purged=ON:向导出文件写入SET @@SESSION.SQL_LOG_BIN=0;（禁用二进制日志）

	This option enables control over global transaction ID (GTID) information written to the dump file, by indicating whether to add a SET @@global.gtid_purged statement to the output. This option may also cause a statement to be written to the output that disables binary logging while the dump file is being reloaded.

	The following table shows the permitted option values. The default value is AUTO.
	Value	Meaning
	OFF	Add no SET statement to the output.
	ON	Add a SET statement to the output. An error occurs if GTIDs are not enabled on the server.
	AUTO	Add a SET statement to the output if GTIDs are enabled on the server.

	The --set-gtid-purged option has the following effect on binary logging when the dump file is reloaded:

	--set-gtid-purged=OFF: SET @@SESSION.SQL_LOG_BIN=0; is not added to the output.

	--set-gtid-purged=ON: SET @@SESSION.SQL_LOG_BIN=0; is added to the output.

	--set-gtid-purged=AUTO: SET @@SESSION.SQL_LOG_BIN=0; is added to the output if GTIDs are enabled on the server you are backing up (that is, if AUTO evaluates to ON). 


	--dump-slave[=value]

	该选项和 --master-data 选项类似，但是它可以用来从一个slave导出文件，并且将导出的文件导入另一个mysql服务器，用来启动另一个slave服务器，这样它们所属的maste是一样的。这样导出的文件，将会包含 CHANGE MASTER TO 语句，它包含了slave服务器所属的maste的坐标(file name 和position)。 CHANGE MASTER TO 会读取Relay_Master_Log_File 和Exec_Master_Log_Pos 的值(SHOW SLAVE STATUS 可以显示)，将它们的值分别赋值给 MASTER_LOG_FILE 和 MASTER_LOG_POS respectively.这些值是告诉slave该从master的哪个位置开始复制信息。

	注意！如果已执行的中继日志(relay log)中的事务序列不一致,会导致错误的位置被使用
	--dump-slave 使用的是master主服务器的坐标被使用，而不是导出它的那台服务器。它和--master-data是一样的。另外使用--dump-slave将导致master-data覆盖

	警告！如果使用了 gtid_mode=ON and MASTER_AUTOPOSITION=1这2个选项，将不能使用该选项。

	该选项的值和--master-data是一样的。
	如果被设置为2，CHANGE MASTER TO语句将被导出为注释语句，将不会生效，如果设置为1，在导入文件后将立即生效。默认值是1，锁表机制也和master-data是一样的。

	该选项将停止slave thread线程，在导出前停止，导完后重新启动。

	结合 --dump-slave选项，dump-slave——apply-slave-statements和include-master-host-port选项也可以使用。

	This option is similar to --master-data except that it is used to dump a replication slave server to produce a dump file that can be used to set up another server as a slave that has the same master as the dumped server. It causes the dump output to include a CHANGE MASTER TO statement that indicates the binary log coordinates (file name and position) of the dumped slave's master. The CHANGE MASTER TO statement reads the values of Relay_Master_Log_File and Exec_Master_Log_Pos from the SHOW SLAVE STATUS output and uses them for MASTER_LOG_FILE and MASTER_LOG_POS respectively. These are the master server coordinates from which the slave should start replicating.


	Note

	Inconsistencies in the sequence of transactions from the relay log which have been executed can cause the wrong position to be used. See Section 18.4.1.34, “Replication and Transaction Inconsistencies” for more information.

	--dump-slave causes the coordinates from the master to be used rather than those of the dumped server, as is done by the --master-data option. In addition, specfiying this option causes the --master-data option to be overridden, if used, and effectively ignored.
	Warning

	This option should not be used if the server where the dump is going to be applied uses gtid_mode=ON and MASTER_AUTOPOSITION=1.

	The option value is handled the same way as for --master-data (setting no value or 1 causes a CHANGE MASTER TO statement to be written to the dump, setting 2 causes the statement to be written but encased in SQL comments) and has the same effect as --master-data in terms of enabling or disabling other options and in how locking is handled.

	This option causes mysqldump to stop the slave SQL thread before the dump and restart it again after.

	In conjunction with --dump-slave, the --apply-slave-statements and --include-master-host-port options can also be used. 


	--apply-slave-statements

	在slave库中使用--dump-slave导出文件的时候，可以在CHANGE MASTER TO的前面加上STOP SLAVE语句，并且在导出文件的最后加上START SLAVE语句。这样可以在重新导入的时候stop slave,导入完成后start slave

	For a slave dump produced with the --dump-slave option, add a STOP SLAVE statement before the CHANGE MASTER TO statement and a START SLAVE statement at the end of the output. 


	--include-master-host-port

	在slave库中使用--dump-slave导出文件的时候， 添加MASTER_HOST 和 MASTER_PORT选项配置，指明主库master的host name和tcp/ip端口。

	For the CHANGE MASTER TO statement in a slave dump produced with the --dump-slave option, add MASTER_HOST and MASTER_PORT options for the host name and TCP/IP port number of the slave's master. 


##格式化选项 Format Options

	--compact
	产生较为紧凑的输出，该选项相当于使用了 --skip-add-drop-table, --skip-add-locks, --skip-comments, --skip-disable-keys, 和 --skip-set-charset options选项的功能。

	--compatible=name
	导出兼容其他数据库系统，或旧版本的mysql语句的文件，值可以是 ansi, mysql323, mysql40, postgresql, oracle, mssql, db2, maxdb, no_key_options, no_table_options, or no_field_options. 多个值可以使用','分开。该选项和SQL mode相关

	This option does not guarantee compatibility with other servers. It only enables those SQL mode values that are currently available for making dump output more compatible. For example, --compatible=oracle does not map data types to Oracle types or use Oracle comment syntax. 

	至少需要4.1.0上版本才能使用该选项

	--complete-insert, -c
	导出完整的插入语句，包括列名。

	--create-options
	Include all MySQL-specific table options in the CREATE TABLE statements. 

	--tab=dir_name, -T dir_name

	指定一个目录(该目录针对运行mysql进程的系统帐户要有写入权限，且执行导出的mysql帐户要有FILE权限)，用来存储导出的mysql文件。将为每张表tbl_name.sql文件，包含表的创建语句。同时创建 一个tbl_name.txt文件，包含表数据的内容。

	其中tbl_name.txt表的数据内容，字段之间，默认用tab分开，行默认使用\n分开。

	可以通过指定--fields-terminated-by=..., --fields-enclosed-by=..., --fields-optionally-enclosed-by=..., --fields-escaped-by=... --lines-terminated-by=...设置分隔符。这些选项的含义和 LOAD DATA INFILE的使用是相关的。

	字段的内容是按--default-character-set 选项指定的编码进行存储的。

	--hex-blob
	导出二进制数据使用十六进制的方式存储（如将'abc' 变成 0x616263）受影响的数据类型有 BINARY, VARBINARY, the BLOB types, and BIT. 


	--quote-names, -Q
	如database, table, and column 使用"`"字符，默认是开启的。--skip-quote-names跳过该功能。如果使用 ANSI_QUOTES SQL mode模式，将使用双引号'"'

	--result-file=file_name, -r file_name
	该选项输出指定的文件，并覆盖之前存在的内容，即使产生了错误。
	该选项在windows中可用来避免产生\r\n格式的换行。

	--tz-utc
	导出文件中将包含 SET TIME_ZONE='+00:00' 类似的信息，可以避免不同服务器时区不同的问题

	--xml, -X
	导出XML格式的文件
	NULL, 'NULL', 空字符
	```
	NULL (unknown value)	
	<field name="column_name" xsi:nil="true" />

	'' (empty string)	
	<field name="column_name"></field>

	'NULL' (string value)	
	<field name="column_name">NULL</field> 
	```

##过滤选项  Filtering Options
	以下选项控制哪种模式对象写入到转储文件:按类别,如触发或事件;按名称如,选择哪个数据库和表转储;甚至从表数据过滤行使用WHERE子句。

	--all-databases, -A
	导出全部数据库中的所有表

	 --databases, -B
	 导出部分数据库，通常情况导出数据，第一个参数是数据库名，之后的是表名，使用该选项，所有的参数都是数据库名

	--events, -E
	导出事件调度到文件，该选项需要EVENT权限。导出的文件将包含CREATE EVENT语句，不包含event 创建和修改的时间戳timestamps，如果被重新导入，将是载入时的时间戳。如果需要导入时间戳，使用mysql.event表中的内容
	 
	 --ignore-error=error[,error]... 
	忽略错误，也可以使用--force

	--ignore-table=db_name.tbl_name
	忽略表名，不导出指定的表名，必需指定数据库名和表名，如果要忽略多个表，使用多个该选项配置，如--ignore-table=db_name.tbl_name1 --ignore-table=db_name.tbl_name2。
	该选项还可用来忽略VIEW视图

	--no-data, -d
	不导出数据表的内容，如果只想导出表结构，可以使用该选项。

	--routines, -R
	导出包括存储程序(过程和函数)的数据。使用这个选项需要mysql.proc表的SELECT权限。
	导出的数据将包含 CREATE PROCEDURE and CREATE FUNCTION 语句，该选项也不会导出相应的时间戳。如果要包含时间戳，使用mysql.proc 表的内容


	-tables
	重写 --databases or -B option ，该参数后的所有参数都是表名。


	--where='where_condition', -w 'where_condition'
	过滤行选项。
	Examples:
	```
	--where="user='jimf'"
	-w"userid>1"
	-w"userid<1"
	```

##性能选项  Performance Options
	通常性能受事务选项配置transactional options的影响
	--disable-keys, -K
	通常在insert语句的前后，写入 /*!40000 ALTER TABLE tbl_name DISABLE KEYS */; 和 /*!40000 ALTER TABLE tbl_name ENABLE KEYS */; 语句。这样在导入数据时将变得更快，因为索引是在所有行数据插入后才创建的。这个选项仅对没有唯一索引的myisam表有效。

	--extended-insert, -e
	将以INSERT多行的方式导出到文件，这样生成的文件将更小，且在导入数据的时候速度将更快

	--insert-ignore
	使用insert-ignore语句而不是insert

	--opt
	该选项默认被启用，相当于是开启了 --add-drop-table --add-locks --create-options --disable-keys --extended-insert --lock-tables --quick --set-charset选项。这个选项使导出更快，导入也更快。

	使用--skip-opt 选项跳过该功能

	--quick, -q
	如果导出的表非常大，该选项非常有用，使用一行一行的检索方式，而不是从缓存中读取全部行

##事务选项 Transactional Options

	--add-locks
	在导出的文件中添加LOCK TABLES and UNLOCK TABLES语句，这样在重新导入的时候更快。

	--flush-logs, -F
	在导出前刷新logs，该选项需要RELOAD权限。如果配合使用 --all-databases选项，所有库的日志将被刷新。除非开启了 --lock-all-tables, --master-data, or --single-transaction，这种情况只刷新一次logs,对应的那一刻，所有表是锁着的。
	如果想让你导出的文件的那一刻和刷新日志在同一精确的时间，应该使用 --lock-all-tables, --master-data, or --single-transaction. 

	--flush-privileges
	为导出的文件添加FLUSH PRIVILEGES语句。如果从旧版mysql升级到新5.7.2或更高版本，不要使用该选项。

	--lock-all-tables, -x
	锁住所有库的所有表，这将在导出数据期间，获取一个全局的只读锁。该选项会自动关闭--single-transaction and --lock-tables选项。

	--lock-tables, -l
	针对Myisam表，在导出前将锁住所有表，获得的是 READ LOCAL锁 ，期间允许并发写入。
	针对事务型的表,如Innodb,使用--single-transaction 选项更为合适。因为它不需要锁表。
	因为--lock-tables是针对每个表进行锁表的，并不保证每个导出的数据库文件在逻辑上的一致性。不同的database可能有不同的状态。

	--no-autocommit
	在每个导出的表的INSERT语句的周围写入 SET autocommit = 0 and COMMIT statements. 

	--order-by-primary
	按表的主键转储行数据，或者按唯一索引。这在将myisam表导入到Innodb表的时候非常有用，但是会消耗更多的时间。

	--single-transaction
	这个选项，在导出之前，设置事务隔离模式为可重复读取( REPEATABLE READ)并且发送一个开始事务( START TRANSACTION )SQL语句。这对事务型的表如Innodb很有用。因为它保持一致的状态，当使用START TRANSACTION被执行，并不会阻塞其他的应用。

	记住，myisam或者MEMORY类型的表的状态依旧会改变。

	当开启了--single-transaction ，为了确保导出文件有效(正确的表内容，和binary log coordinates)，不能有如下的修改表的操作：
	 ALTER TABLE, CREATE TABLE, DROP TABLE, RENAME TABLE, TRUNCATE TABLE
	 使用这些操作不能保证读的一致性。会产生读表内容出错。

	--single-transaction和--lock-tables选项是互斥的，因为lock tables会导致挂起的事务被提交。

	 The --single-transaction option and the --lock-tables option are mutually exclusive because LOCK TABLES causes any pending transactions to be committed implicitly. 

	导出大的表，可以使用--single-transaction 结合 --quick 选项。


##选项组 Option Groups
	--opt
	--compact
	如果想选择性的禁用或启用组选项中的设置，顺序是很重要的，指令将从头到尾的被执行。
	如果使用 --disable-keys --lock-tables --skip-opt这3个参数，则无法禁用keys和锁表，因为最后一条跳过了。


##例子

	1.备份某个库的所有内容
	```
	shell> mysqldump db_name > backup-file.sql
	```

	2.从备份中恢复
	```
	shell> mysql db_name < backup-file.sql
	```

	3.另外一种方式恢复数据
	```
	shell> mysql -e "source /path-to-backup/backup-file.sql" db_name
	```
	4.使用mysqldump导出数据到其他数据库
	```
	shell> mysqldump --opt db_name | mysql --host=remote_host -C db_name
	```

	5.备份多个数据库的
	```
	shell> mysqldump --databases db_name1 [db_name2 ...] > my_databases.sql
	```

	6.备份所有数据库
	```
	shell> mysqldump --all-databases > all_databases.sql
	```

	7.在线备份Innodb表
	```
	shell> mysqldump --all-databases --master-data --single-transaction > all_databases.sql
	```
	这种备份方式，需要为所有的表，获取一个全局的只读锁(在dump操作前，使用FLUSH TABLES WITH READ LOCK获取)。一旦全局只读锁获取，binary log  coordinates将被获取，此时锁被释放。如果在使用FLUSH操作期间，有一个update操作占用了较长时间，mysql服务器将会无响应，直到update操作结束。此后锁被释放，可以进行对表的读写操作。

	为了恢复到某一个时间点的备份，通常使用  binary log，或者要知道 在导出数据时，binary log的坐标。
	```
	shell> mysqldump --all-databases --master-data=2 > all_databases.sql
	或者
	shell> mysqldump --all-databases --flush-logs --master-data=2  > all_databases.sql
	```
	如果是Innodb表备份，可以使用同时使用--master-data  --single-transaction选项备份某个时间点的数据。


	如果想使用--opt的全部选项，除了extended-insert，quick 。使用--skip，如  --opt --skip-extended-insert --skip-quick（--opt可省略，因为默认启用）

	如果想跳过--opt,只使用disable-keys，lock-tables功能。使用--skip-opt --disable-keys --lock-tables

	8.备份表定义和表内容相互分离
	```
	shell> mysqldump --no-data test > dump-defs.sql
	shell> mysqldump --no-create-info test > dump-data.sql
	```


##限制

	mysqldump操作，默认不导出以下数据库，INFORMATION_SCHEMA, performance_schema, or (as of MySQL 5.7.8) sys schema 
	如果想导出，则使用明确说明的方式 --databases INFORMATION_SCHEMA等。对INFORMATION_SCHEMA 和 performance_schema, 通常使用 --skip-lock-tables 选项。

	mysqldump不会导出 MySQL Cluster ndbinfo信息

	不推荐在5.6.9之前使用GTIDs功能导出

	mysqldump包含了mysql库中的general_log and slow_query_log 表，Log表内容不会被导出。

##参考：
	http://dev.mysql.com/doc/refman/5.7/en/mysqldump.html
	http://dev.mysql.com/doc/refman/5.7/en/using-mysqldump.html
	http://dev.mysql.com/doc/refman/5.7/en/mysqldump-sql-format.html
	http://dev.mysql.com/doc/refman/5.7/en/reloading-sql-format-dumps.html
	http://dev.mysql.com/doc/refman/5.7/en/mysqldump-delimited-text.html
	http://dev.mysql.com/doc/refman/5.7/en/reloading-delimited-text-dumps.html
	http://dev.mysql.com/doc/refman/5.7/en/mysqldump-tips.html