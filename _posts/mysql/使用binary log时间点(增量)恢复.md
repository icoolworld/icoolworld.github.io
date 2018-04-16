#使用二进制日志增量恢复
通常是在之前的某个时间点恢复了数据，现在增量更新至最新的状态。

##增量恢复的一些相关操作

1.要使用增量恢复，服务必需开启二进制日志--log-bin,必需要知道当前二进制文件的位置，可以使用如下命令查看二进制日志文件列表
```
mysql> SHOW BINARY LOGS;
```
查看当前的二进制文件名，使用
```
mysql> SHOW MASTER STATUS;
```
2.mysqlbinlog工具可以将二进制日志文件中的事件转化为text以便阅读或执行相关操作。mysqlbinlog有可选项基于事件时间或者日志文件位置。

3.使用mysql客户端执行mysqlbinlog的输出
```
shell> mysqlbinlog binlog_files | mysql -u root -p
```
4.使用mysqlbinlog查看日志
```
shell> mysqlbinlog binlog_files | more
或者输出到文件
shell> mysqlbinlog binlog_files > tmpfile
shell> ... edit tmpfile ...
```

5.将二进制日志文件输出到一个文件中是有用的，
可以用来作为一个初步的执行的内容，如不小心DROP DATABASE了。您可以在执行其内容之前，从该文件中删除不被执行的任何语句。编辑文件后，执行以下内容： 
```
shell> mysql -u root -p < tmpfile
```

6.如果有多个二进制日志文件要被执行，安全的做法是将所有日志文件放在一个单独的连接中执行，如
```
shell> mysqlbinlog binlog.000001 binlog.000002 | mysql -u root -p
```
或者是将所有二进制日志文件内容输出到一个临时文件，然后再统一执行，如
```
shell> mysqlbinlog binlog.000001 >  /tmp/statements.sql
shell> mysqlbinlog binlog.000002 >> /tmp/statements.sql
shell> mysql -u root -p -e "source /tmp/statements.sql"
```
如果日志中包含了GTIDs，可以使用--skip-gtids跳过
```
shell> mysqlbinlog --skip-gtids binlog.000001 >  /tmp/dump.sql
shell> mysqlbinlog --skip-gtids binlog.000002 >> /tmp/dump.sql
shell> mysql -u root -p -e "source /tmp/dump.sql"
```

分开执行的做法是不安全的，因为如果第一个日志文件中包含一个CREATE TEMPORARY TABLE 创建临时表的语句，第二个语句使用到了经，如果第一个连接出现了问题，第二个将无法执行。如
```
shell> mysqlbinlog binlog.000001 | mysql -u root -p # DANGER!!
shell> mysqlbinlog binlog.000002 | mysql -u root -p # DANGER!!
```

##使用基于时间点的增量恢复Point-in-Time Recovery Using Event Times

使用--start-datetime and --stop-datetime 选项来控制恢复的开始和结束时间

如你某天不小心删除了不该删的数据，可以使用--stop-datetime精确的恢复到删除的前一秒
```
mysqlbinlog --stop-datetime="2005-04-20 9:59:59" \
         /var/log/mysql/bin.123456 | mysql -u root -p
```
恢复从某时刻开始的所有事件

```
mysqlbinlog --start-datetime="2005-04-20 10:01:00" \
         /var/log/mysql/bin.123456 | mysql -u root -p
```
		 
##使用基于事件点的增量恢复Point-in-Time Recovery Using Event Positions

可以先使用如下语句，导出某一段时间的操作，查看其position,position通常是log_pos 后跟着一个数字

```
shell> mysqlbinlog --start-datetime="2005-04-20 9:55:00" \
         --stop-datetime="2005-04-20 10:05:00" \
         /var/log/mysql/bin.123456 > /tmp/mysql_restore.sql
```

然后使用事件点恢复

```
shell> mysqlbinlog --stop-position=368312 /var/log/mysql/bin.123456 \
         | mysql -u root -p

shell> mysqlbinlog --start-position=368315 /var/log/mysql/bin.123456 \
         | mysql -u root -p
```


		 
http://dev.mysql.com/doc/refman/5.7/en/point-in-time-recovery.html
http://dev.mysql.com/doc/refman/5.7/en/point-in-time-recovery-times.html
http://dev.mysql.com/doc/refman/5.7/en/point-in-time-recovery-positions.html