---
layout: post
title: Relay_Master_Log_File等含义
categories: mysql
---

1) The position, ON THE MASTER, from which the I/O thread is reading: Master_Log_File/Read_Master_Log_Pos. 
-----相对于主库,从库读取主库的二进制日志的位置,是IO线程
Master_Log_File：The name of the master binary log currently being read from the master
Read_Master_Log_Pos： 	The current position within the master binary log that have been read from the master


2) The position, IN THE RELAY LOGS, at which the SQL thread is executing: Relay_Log_File/Relay_Log_Pos 
----相对于从库,是从库的sql线程执行到的位置
Relay_Log_File：	The name of the current relay log file
Relay_Log_Pos：	The current position within the relay log file; events up to this position have been executed on the slave database


3) The position, ON THE MASTER, at which the SQL thread is executing: Relay_Master_Log_File/Exec_Master_Log_Pos 
----相对于主库,是从库的sql线程执行到的位置
Relay_Master_Log_File：	The name of the master binary log file from which the events in the relay log file were read
Exec_Master_Log_Pos：	The equivalent position within the master's binary log file of events that have already been executed


从上面可以看到,read_master_log_pos 始终会大于exec_master_log_pos的值(也有可能相等):因为一个值是代表io线程,一个值代表sql线程;sql线程肯定在io线程之后.(当然,io线程和sql线程要读写同一个文件,否则比较就失去意义了) .