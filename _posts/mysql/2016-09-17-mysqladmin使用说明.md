---
layout: post
title: mysqladmin使用说明
categories: mysql
---

mysqladmin使用说明
Client for Administering a MySQL Server


mysqladmin是执行管理操作的客户端程序。您可以使用它来检查服务器的配置和当前状态，创建和删除数据库等。


查看mysql版本
```
bin/mysqladmin version
bin/mysqladmin variables
```
如果设置了密码,使用-p
```
shell> bin/mysqladmin -u root -p version
Enter password: (enter root password here)
```

Invoke mysqladmin like this:

shell> mysqladmin [options] command [command-arg] [command [command-arg]] ...
mysqladmin supports the following commands. Some of the commands take an argument following the command name.

 create db_name

Create a new database named db_name.

 debug

Tell the server to write debug information to the error log. Format and content of this information is subject to change.

This includes information about the Event Scheduler. See Section 21.4.5, “Event Scheduler Status”.

 drop db_name

Delete the database named db_name and all its tables.

 extended-status

Display the server status variables and their values.

 flush-hosts

Flush all information in the host cache.

 flush-logs [log_type ...]

Flush all logs.

As of MySQL 5.7.5, the mysqladmin flush-logs command permits optional log types to be given, to specify which logs to flush. Following the flush-logs command, you can provide a space-separated list of one or more of the following log types: binary, engine, error, general, relay, slow. These correspond to the log types that can be specified for the FLUSH LOGS SQL statement.

 flush-privileges

Reload the grant tables (same as reload).

 flush-status

Clear status variables.

 flush-tables

Flush all tables.

 flush-threads

Flush the thread cache.

 kill id,id,...

Kill server threads. If multiple thread ID values are given, there must be no spaces in the list.

 old-password new_password

This is like the password command but stores the password using the old (pre-4.1) password-hashing format. (See Section 7.1.2.4, “Password Hashing in MySQL”.)

This command was removed in MySQL 5.7.5.

 password new_password

Set a new password. This changes the password to new_password for the account that you use with mysqladmin for connecting to the server. Thus, the next time you invoke mysqladmin (or any other client program) using the same account, you will need to specify the new password.

If the new_password value contains spaces or other characters that are special to your command interpreter, you need to enclose it within quotation marks. On Windows, be sure to use double quotation marks rather than single quotation marks; single quotation marks are not stripped from the password, but rather are interpreted as part of the password. For example:

shell> mysqladmin password "my new password"
In MySQL 5.7, the new password can be omitted following the password command. In this case, mysqladmin prompts for the password value, which enables you to avoid specifying the password on the command line. Omitting the password value should be done only if password is the final command on the mysqladmin command line. Otherwise, the next argument is taken as the password.

Caution
Do not use this command used if the server was started with the --skip-grant-tables option. No password change will be applied. This is true even if you precede the password command with flush-privileges on the same command line to re-enable the grant tables because the flush operation occurs after you connect. However, you can use mysqladmin flush-privileges to re-enable the grant table and then use a separate mysqladmin password command to change the password.

 ping

Check whether the server is available. The return status from mysqladmin is 0 if the server is running, 1 if it is not. This is 0 even in case of an error such as Access denied, because this means that the server is running but refused the connection, which is different from the server not running.

 processlist

Show a list of active server threads. This is like the output of the SHOW PROCESSLIST statement. If the --verbose option is given, the output is like that of SHOW FULL PROCESSLIST. (See Section 14.7.5.29, “SHOW PROCESSLIST Syntax”.)

 reload

Reload the grant tables.

 refresh

Flush all tables and close and open log files.

 shutdown

Stop the server.

 start-slave

Start replication on a slave server.

 status

Display a short server status message.

 stop-slave

Stop replication on a slave server.

 variables

Display the server system variables and their values.

 version

Display version information from the server.

All commands can be shortened to any unique prefix. For example:

shell> mysqladmin proc stat
+----+-------+-----------+----+---------+------+-------+------------------+
| Id | User  | Host      | db | Command | Time | State | Info             |
+----+-------+-----------+----+---------+------+-------+------------------+
| 51 | monty | localhost |    | Query   | 0    |       | show processlist |
+----+-------+-----------+----+---------+------+-------+------------------+
Uptime: 1473624  Threads: 1  Questions: 39487
Slow queries: 0  Opens: 541  Flush tables: 1
Open tables: 19  Queries per second avg: 0.0268
The mysqladmin status command result displays the following values:

 Uptime

The number of seconds the MySQL server has been running.

 Threads

The number of active threads (clients).

 Questions

The number of questions (queries) from clients since the server was started.

 Slow queries

The number of queries that have taken more than long_query_time seconds. See Section 6.4.5, “The Slow Query Log”.

 Opens

The number of tables the server has opened.

 Flush tables

The number of flush-*, refresh, and reload commands the server has executed.

 Open tables

The number of tables that currently are open.

If you execute mysqladmin shutdown when connecting to a local server using a Unix socket file, mysqladmin waits until the server's process ID file has been removed, to ensure that the server has stopped properly.

mysqladmin supports the following options, which can be specified on the command line or in the [mysqladmin] and [client] groups of an option file. For information about option files used by MySQL programs, see Section 5.2.6, “Using Option Files”.

Table 5.9 mysqladmin Options

Format	Description	Introduced	Deprecated
--bind-address	Use specified network interface to connect to MySQL Server	 	 
--compress	Compress all information sent between client and server	 	 
--connect_timeout	Number of seconds before connection timeout	 	 
--count	Number of iterations to make for repeated command execution	 	 
--debug	Write debugging log	 	 
--debug-check	Print debugging information when program exits	 	 
--debug-info	Print debugging information, memory, and CPU statistics when program exits	 	 
--default-auth	Authentication plugin to use	 	 
--default-character-set	Specify default character set	 	 
--defaults-extra-file	Read named option file in addition to usual option files	 	 
--defaults-file	Read only named option file	 	 
--defaults-group-suffix	Option group suffix value	 	 
--enable-cleartext-plugin	Enable cleartext authentication plugin	 	 
--force	Continue even if an SQL error occurs	 	 
--help	Display help message and exit	 	 
--host	Connect to MySQL server on given host	 	 
--login-path	Read login path options from .mylogin.cnf	 	 
--no-beep	Do not beep when errors occur	 	 
--no-defaults	Read no option files	 	 
--password	Password to use when connecting to server	 	 
--pipe	On Windows, connect to server using named pipe	 	 
--plugin-dir	Directory where plugins are installed	 	 
--port	TCP/IP port number to use for connection	 	 
--print-defaults	Print default options	 	 
--protocol	Connection protocol to use	 	 
--relative	Show the difference between the current and previous values when used with the --sleep option	 	 
--secure-auth	Do not send passwords to server in old (pre-4.1) format	5.7.4	5.7.5
--shared-memory-base-name	The name of shared memory to use for shared-memory connections	 	 
--show-warnings	Show warnings after statement execution	5.7.2	 
--shutdown_timeout	The maximum number of seconds to wait for server shutdown	 	 
--silent	Silent mode	 	 
--sleep	Execute commands repeatedly, sleeping for delay seconds in between	 	 
--socket	For connections to localhost, the Unix socket file to use	 	 
--ssl	Enable secure connection	 	 
--ssl-ca	Path of file that contains list of trusted SSL CAs	 	 
--ssl-capath	Path of directory that contains trusted SSL CA certificates in PEM format	 	 
--ssl-cert	Path of file that contains X509 certificate in PEM format	 	 
--ssl-cipher	List of permitted ciphers to use for connection encryption	 	 
--ssl-crl	Path of file that contains certificate revocation lists	 	 
--ssl-crlpath	Path of directory that contains certificate revocation list files	 	 
--ssl-key	Path of file that contains X509 key in PEM format	 	 
--ssl-mode	Security state of connection to server	5.7.11	 
--ssl-verify-server-cert	Verify server certificate Common Name value against host name used when connecting to server	 	 
--tls-version	Protocols permitted for secure connections	5.7.10	 
--user	MySQL user name to use when connecting to server	 	 
--verbose	Verbose mode	 	 
--version	Display version information and exit	 	 
--vertical	Print query output rows vertically (one line per column value)	 	 
--wait	If the connection cannot be established, wait and retry instead of aborting	 	 

 --help, -?

Display a help message and exit.

 --bind-address=ip_address

On a computer having multiple network interfaces, use this option to select which interface to use for connecting to the MySQL server.

 --character-sets-dir=dir_name

The directory where character sets are installed. See Section 11.5, “Character Set Configuration”.

 --compress, -C

Compress all information sent between the client and the server if both support compression.

 --count=N, -c N

The number of iterations to make for repeated command execution if the --sleep option is given.

 --debug[=debug_options], -# [debug_options]

Write a debugging log. A typical debug_options string is d:t:o,file_name. The default is d:t:o,/tmp/mysqladmin.trace.

 --debug-check

Print some debugging information when the program exits.

 --debug-info

Print debugging information and memory and CPU usage statistics when the program exits.

 --default-auth=plugin

A hint about the client-side authentication plugin to use. See Section 7.3.8, “Pluggable Authentication”.

 --default-character-set=charset_name

Use charset_name as the default character set. See Section 11.5, “Character Set Configuration”.

 --defaults-extra-file=file_name

Read this option file after the global option file but (on Unix) before the user option file. If the file does not exist or is otherwise inaccessible, an error occurs. file_name is interpreted relative to the current directory if given as a relative path name rather than a full path name.

 --defaults-file=file_name

Use only the given option file. If the file does not exist or is otherwise inaccessible, an error occurs. file_name is interpreted relative to the current directory if given as a relative path name rather than a full path name.

 --defaults-group-suffix=str

Read not only the usual option groups, but also groups with the usual names and a suffix of str. For example, mysqladmin normally reads the [client] and [mysqladmin] groups. If the --defaults-group-suffix=_other option is given, mysqladmin also reads the [client_other] and [mysqladmin_other] groups.

 --enable-cleartext-plugin

Enable the mysql_clear_password cleartext authentication plugin. (See Section 7.5.1.8, “The Cleartext Client-Side Authentication Plugin”.)

 --force, -f

Do not ask for confirmation for the drop db_name command. With multiple commands, continue even if an error occurs.

 --host=host_name, -h host_name

Connect to the MySQL server on the given host.

 --login-path=name

Read options from the named login path in the .mylogin.cnf login path file. A “login path” is an option group containing options that specify which MySQL server to connect to and which account to authenticate as. To create or modify a login path file, use the mysql_config_editor utility. See Section 5.6.6, “mysql_config_editor — MySQL Configuration Utility”.

 --no-beep, -b

Suppress the warning beep that is emitted by default for errors such as a failure to connect to the server.

 --no-defaults

Do not read any option files. If program startup fails due to reading unknown options from an option file, --no-defaults can be used to prevent them from being read.

The exception is that the .mylogin.cnf file, if it exists, is read in all cases. This permits passwords to be specified in a safer way than on the command line even when --no-defaults is used. (.mylogin.cnf is created by the mysql_config_editor utility. See Section 5.6.6, “mysql_config_editor — MySQL Configuration Utility”.)

 --password[=password], -p[password]

The password to use when connecting to the server. If you use the short option form (-p), you cannot have a space between the option and the password. If you omit the password value following the --password or -p option on the command line, mysqladmin prompts for one.

Specifying a password on the command line should be considered insecure. See Section 7.1.2.1, “End-User Guidelines for Password Security”. You can use an option file to avoid giving the password on the command line.

 --pipe, -W

On Windows, connect to the server using a named pipe. This option applies only if the server supports named-pipe connections.

 --plugin-dir=dir_name

The directory in which to look for plugins. Specify this option if the --default-auth option is used to specify an authentication plugin but mysqladmin does not find it. See Section 7.3.8, “Pluggable Authentication”.

 --port=port_num, -P port_num

The TCP/IP port number to use for the connection.

 --print-defaults

Print the program name and all options that it gets from option files.

 --protocol={TCP|SOCKET|PIPE|MEMORY}

The connection protocol to use for connecting to the server. It is useful when the other connection parameters normally would cause a protocol to be used other than the one you want. For details on the permissible values, see Section 5.2.2, “Connecting to the MySQL Server”.

 --relative, -r

Show the difference between the current and previous values when used with the --sleep option. This option works only with the extended-status command.

 --show-warnings

Show warnings resulting from execution of statements sent to the server. This option was added in MySQL 5.7.2.

 --secure-auth

Do not send passwords to the server in old (pre-4.1) format. This prevents connections except for servers that use the newer password format. This option was added in MySQL 5.7.4.

As of MySQL 5.7.5, this option is deprecated and will be removed in a future MySQL release. It is always enabled and attempting to disable it (--skip-secure-auth, --secure-auth=0) produces an error. Before MySQL 5.7.5, this option is enabled by default but can be disabled.

Note
Passwords that use the pre-4.1 hashing method are less secure than passwords that use the native password hashing method and should be avoided. Pre-4.1 passwords are deprecated and support for them is removed in MySQL 5.7.5. For account upgrade instructions, see Section 7.5.1.3, “Migrating Away from Pre-4.1 Password Hashing and the mysql_old_password Plugin”.

 --shared-memory-base-name=name

On Windows, the shared-memory name to use, for connections made using shared memory to a local server. The default value is MYSQL. The shared-memory name is case sensitive.

The server must be started with the --shared-memory option to enable shared-memory connections.

 --silent, -s

Exit silently if a connection to the server cannot be established.

 --sleep=delay, -i delay

Execute commands repeatedly, sleeping for delay seconds in between. The --count option determines the number of iterations. If --count is not given, mysqladmin executes commands indefinitely until interrupted.

 --socket=path, -S path

For connections to localhost, the Unix socket file to use, or, on Windows, the name of the named pipe to use.

 --ssl*

Options that begin with --ssl specify whether to connect to the server using SSL and indicate where to find SSL keys and certificates. See Section 7.4.5, “Command Options for Secure Connections”.

 --tls-version=protocol_list

The protocols permitted by the client for encrypted connections. The value is a comma-separated list containing one or more protocol names. The protocols that can be named for this option depend on the SSL library used to compile MySQL. For details, see Section 7.4.3, “Secure Connection Protocols and Ciphers”.

This option was added in MySQL 5.7.10.

 --user=user_name, -u user_name

The MySQL user name to use when connecting to the server.

 --verbose, -v

Verbose mode. Print more information about what the program does.

 --version, -V

Display version information and exit.

 --vertical, -E

Print output vertically. This is similar to --relative, but prints output vertically.

 --wait[=count], -w[count]

If the connection cannot be established, wait and retry instead of aborting. If a count value is given, it indicates the number of times to retry. The default is one time.

You can also set the following variables by using --var_name=value.

 connect_timeout

The maximum number of seconds before connection timeout. The default value is 43200 (12 hours).

 shutdown_timeout

The maximum number of seconds to wait for server shutdown. The default value is 3600 (1 hour).


更多功能请参考http://dev.mysql.com/doc/refman/5.7/en/mysqladmin.html
