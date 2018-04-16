#mysql服务器日志的维护管理 Server Log Maintenance

mysql可以创建多种不同的日志文件，为了节省磁盘空间，需要定期的清理一些日志。

可以使用脚本，执行定时任务cron进行清理。

对于二进制日志，可以使用expire_logs_days 系统变量设置日志几天后自动过期。也可以使用PURGE BINARY LOGS 根据需要来清除日志。

也可以强制让mysql启动新的日志文件通过FLUSH LOGS 或者 mysqladmin flush-logs, mysqladmin refresh, mysqldump --flush-logs, or mysqldump --master-data 等相关命令

另外binary log当日志文件大小达到  max_binlog_size 设置的值时，会自动刷新

FLUSH LOGS支持选择性的刷新，如 FLUSH BINARY LOGS 只刷新二进制日志

日志刷新操作按以下规则：
1.如果常规日志和慢查询日志被开启，mysql服务将关闭并且重新打开日志文件。
2.如果二进制日志被开启，mysql服务将关闭当前的二进制日志文件，且打开一个新的二进制文件，文件包含下一个连续的数字结尾。
3.如果开启了错误日志，mysql服务将关闭并且重新打开日志文件。

对于二进制日志，FLUSH操作会创建一个新的日志文件，而常规日志和慢日志只是关闭和重新打开，原内容还在，如果要创建一个空的内容的日志，在flush操作前重命名当前日志，然后在FLUSH(同样适用于错误日志)这样通常可以用来备份日志。如
```
shell> cd mysql-data-directory
shell> mv mysql.log mysql.old
shell> mv mysql-slow.log mysql-slow.old
shell> mysqladmin flush-logs
```
也可以先关闭日志，然后重命名，再开启日志
```
SET GLOBAL general_log = 'OFF';
SET GLOBAL slow_query_log = 'OFF';

shell> mv mysql.log mysql.old
shell> mv mysql-slow.log mysql-slow.old

SET GLOBAL general_log = 'ON';
SET GLOBAL slow_query_log = 'ON';
```