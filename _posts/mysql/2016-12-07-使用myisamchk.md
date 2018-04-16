---
layout: post
title: 使用myisamchk
categories: mysql
---

#使用myisamchk

如果服务器运行外部锁定功能，你可以用myisamchk随时检查表。在这种情况下，如果服务器试图更新一个表，myisamchk正在操作，服务器将等待myisamchk执行完成。

如果使用myisamchk来修复或优化相关表，必需确保mysqld服务没有在使用表，如果你不停止mysqld服务，至少应该在操作之前，使用刷新表语句mysqladmin flush-tables 。你的表可能会损坏如果mysqld服务器和myisamchk同时访问表。

myisam表的相关文件说明
File	Purpose
tbl_name.frm	表定义文件Definition (format) file
tbl_name.MYD	表数据文件Data file
tbl_name.MYI	表索引文件Index file


myisamchk通过创建一个临时的.MVD数据文件的复本，以一行行的方式。在结修复结束的时候，将旧的.MYD文件重命名为原文件名。如果你使用--quick选项，myisamchk不创建一个临时的.MYD文件，相反，而是假设.MYD文件是正确的，只产生一个新的索引文件不碰.MYD文件。这是安全的，因为myisamchk自动检测.MYD文件是否损坏并中止修复。你也可以指定2次--quick选项，在这种情况下，myisamchk不中止对一些错误（如重复键错误duplicate-key errors）而是试图解决通过修改MYD文件。通常使用两个--quick选项是有用的，如果你的的空闲磁盘空间不足以进行一个正常的修复。在这种情况下，你应该至少在运行myisamchk前对表进行备份。


To check MyISAM tables, use CHECK TABLE.

To repair MyISAM tables, use REPAIR TABLE.

To optimize MyISAM tables, use OPTIMIZE TABLE.

To analyze MyISAM tables, use ANALYZE TABLE.

##如何检查check myisam表

myisamchk tbl_name
它可以发现99.99%的错误，不使用选项，或者使用-s（安静）模式。

myisamchk -m tbl_name
这发现所有错误的99.999%。它首先检查所有的索引项的错误，然后读取所有行。它计算出所有行的所有关键值校验，并且验证校验是否和索引树中的keys校验匹配。

myisamchk -e tbl_name
他对所有数据做了一个完整和彻底的检查 (-e means “extended check”).
它会对每一行的每一个键做一个只读的检查，以验证它们确实指向正确的行。这可能需要很长的时间，一个大的表有许多索引。通常，myisamchk发现第一个错误后即停止。如果你想获得更多的信息，你可以添加-v（verbose）选项。这使得myisamchk继续前进，通过最多20个错误。

myisamchk -e -i tbl_name
和上面的命令类似，但是会打印额外的统计信息。

通常情况下不带参数的命令已经足够检查。

##如何修复repair myisam表
这里将介绍如何通过myisamchk来用在myisam表上(.MYI,.MYD)。你也可以使用CHECK TABLE和REPAIR TABLE语句进行。

损坏的表的症状包括意外中止查询，和可观察到的错误例如：
tbl_name.frm is locked against change
Can't find file tbl_name.MYI (Errcode: nnn) 找不到表索引文件
Unexpected end of file 错误的文件结束
Record file is crashed 记录文件崩溃
Got error nnn from table handler

可以使用perror nnn，其中nnn是错误的码，来显示相关的错误信息。
```
shell> perror 126 127 132 134 135 136 141 144 145
MySQL error code 126 = Index file is crashed
MySQL error code 127 = Record-file is crashed
MySQL error code 132 = Old database file
MySQL error code 134 = Record was already deleted (or record file crashed)
MySQL error code 135 = No more room in record file
MySQL error code 136 = No more room in index file
MySQL error code 141 = Duplicate unique key or constraint on write or update
MySQL error code 144 = Table is crashed and last repair failed
MySQL error code 145 = Table was marked as crashed and should be repaired

```
对于 error 135 (no more room in record file) and error 136 (no more room in index file)不是错误，可以通过下面的方式解决。
```
ALTER TABLE tbl_name MAX_ROWS=xxx AVG_ROW_LENGTH=yyy;
```

对于其他的错误,myisamchk可以检测到和修复大部分错误。

开始检查之前，先进入mysql安装目录，确保运行mysqld服务系统帐户，有权限修改相关的数据文件。
在开始repair之前，先停止mysqld服务，使用mysqladmin shutdown停止mysqld服务。
分4个步骤进行：

**Stage 1: Checking your tables**

如果你有足够的时间，运行：myisamchk *.MYI 或 myisamchk -e *.MYI，可以使用-s阻止不必要的信息输出。
使用--update-state 选项告诉myiasmchk标记为"checked"
只针对那些myisamchk报告出错的表进行修复，跳到步骤2
如果在check的时候，你得到意想不到的错误检查时（如内存不足错误），或者myisamchk崩溃，跳到步骤3

**Stage 2: Easy safe repair**
首先尝试 myisamchk -r -q tbl_name (-r -q means “quick recovery mode”)，这将尝试修复索引文件，不接触数据文件
如果数据文件包含它应该和在数据文件中的正确位置的删除链接点的一切，则应该工作，并且该表被修复。开始修复下一个表。否则，使用下面的方式：

1)在继续操作前，备份数据文件
2)使用myisamchk -r tbl_name (-r means “recovery mode”).它会从数据文件中移除错误的行数据，并且重新构建索引文件。
3)如果之前2步都失败了，使用myisamchk --safe-recover tbl_name。安全模式恢复，使用旧的恢复方式处理一些常规模式下没有的情况。但是比较慢。

注意！
如果你想要让repair修复操作变得更快，可以设置 sort_buffer_size 和 key_buffer_size变量的值,各自达到系统内存的25%，在你运行myisamchk的时候。


**Stage 3: Difficult repair**
你到达该步骤，应当只有在索引文件中的第一个16KB块被破坏或包含不正确的信息，或者索引文件丢失。在这种情况下，有必要创建一个新的索引文件。这样做如下：
1)移动数据文件到一个安全的地方
2)用下面的命令操作
```
shell> mysql db_name
mysql> SET autocommit=1;
mysql> TRUNCATE TABLE tbl_name;
mysql> quit
```
3)拷备旧的数据文件到到新创建的数据文件中。（不要将旧文件移动到新文件上。 保留一份拷贝以万一出了什么问题。）

注意！
如果你使用主从复制(replication),需要停止mysqld,因为这些包含文件系统的操作，并且不会记录到日志中。

回到步骤2，myisamchk -r -q 应该可以工作了。

你也可以使用 REPAIR TABLE tbl_name USE_FRM 语句，它会自动的执行修复操作。

**Stage 4: Very difficult repair**
你到达该步骤，通常只有一种可能是.frm文件奔崩了。这一般是不应该发生的。因为表的定义在表创建后是不会改变的。

1)从一个旧的备份中拷备文件，然后返回步骤3。你也可以恢复一个索引文件，然后返回步骤2.
2)如果没有备份的文件，但你知道表是如何创建的，在另一个库中创建这个表，然后复制其中的.FRM .MYI文件到你奔崩的数据库中，回到步骤2，重建索引文件。


##如何优化optimization myisam表
对表进行优化，消除一些浪费空间的行(通常执行delete或update之后产生)

```
shell> myisamchk -r tbl_name
```
你也可以使用 OPTIMIZE TABLE 语句进行优化。它会进行表的修复，key分析，索引排序操作，所以看起来会比较快。

myisamchk 一些增加表性能的选项优化选项：

--analyze or -a: Perform key distribution analysis. This improves join performance by enabling the join optimizer to better choose the order in which to join the tables and which indexes it should use.

--sort-index or -S: Sort the index blocks. This optimizes seeks and makes table scans that use indexes faster.

--sort-records=index_num or -R index_num: Sort data rows according to a given index. This makes your data much more localized and may speed up range-based SELECT and ORDER BY operations that use this index.

##制定MyISAM表的维护计划
可以使用定时任务，进行定期表检查如：
```
35 0 * * 0 /path/to/myisamchk --fast --silent /path/to/datadir/*/*.MYI
```
通常情况下，MySQL表需要很少的维护。如果您正在执行更新MyISAM表动态大小的行（VARCHAR，BLOB，或文本列）或有许多已删除的行，你可能想时不时的整理/回收空间。您可以通过使用OPTIMIZE TABLE优化表来进行。或者，如果你能停一会mysqld服务器，进行mysql安装目录，当服务器停止使用此命令：
```
shell> myisamchk -r -s --sort-index --myisam_sort_buffer_size=16M */*.MYI
```

http://dev.mysql.com/doc/refman/5.7/en/myisamchk.html
http://dev.mysql.com/doc/refman/5.7/en/myisam-crash-recovery.html
http://dev.mysql.com/doc/refman/5.7/en/myisam-check.html
http://dev.mysql.com/doc/refman/5.7/en/myisam-repair.html
http://dev.mysql.com/doc/refman/5.7/en/myisam-table-maintenance.html