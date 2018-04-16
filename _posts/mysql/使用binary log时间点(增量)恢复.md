#ʹ�ö�������־�����ָ�
ͨ������֮ǰ��ĳ��ʱ���ָ������ݣ������������������µ�״̬��

##�����ָ���һЩ��ز���

1.Ҫʹ�������ָ���������迪����������־--log-bin,����Ҫ֪����ǰ�������ļ���λ�ã�����ʹ����������鿴��������־�ļ��б�
```
mysql> SHOW BINARY LOGS;
```
�鿴��ǰ�Ķ������ļ�����ʹ��
```
mysql> SHOW MASTER STATUS;
```
2.mysqlbinlog���߿��Խ���������־�ļ��е��¼�ת��Ϊtext�Ա��Ķ���ִ����ز�����mysqlbinlog�п�ѡ������¼�ʱ�������־�ļ�λ�á�

3.ʹ��mysql�ͻ���ִ��mysqlbinlog�����
```
shell> mysqlbinlog binlog_files | mysql -u root -p
```
4.ʹ��mysqlbinlog�鿴��־
```
shell> mysqlbinlog binlog_files | more
����������ļ�
shell> mysqlbinlog binlog_files > tmpfile
shell> ... edit tmpfile ...
```

5.����������־�ļ������һ���ļ��������õģ�
����������Ϊһ��������ִ�е����ݣ��粻С��DROP DATABASE�ˡ���������ִ��������֮ǰ���Ӹ��ļ���ɾ������ִ�е��κ���䡣�༭�ļ���ִ���������ݣ� 
```
shell> mysql -u root -p < tmpfile
```

6.����ж����������־�ļ�Ҫ��ִ�У���ȫ�������ǽ�������־�ļ�����һ��������������ִ�У���
```
shell> mysqlbinlog binlog.000001 binlog.000002 | mysql -u root -p
```
�����ǽ����ж�������־�ļ����������һ����ʱ�ļ���Ȼ����ͳһִ�У���
```
shell> mysqlbinlog binlog.000001 >  /tmp/statements.sql
shell> mysqlbinlog binlog.000002 >> /tmp/statements.sql
shell> mysql -u root -p -e "source /tmp/statements.sql"
```
�����־�а�����GTIDs������ʹ��--skip-gtids����
```
shell> mysqlbinlog --skip-gtids binlog.000001 >  /tmp/dump.sql
shell> mysqlbinlog --skip-gtids binlog.000002 >> /tmp/dump.sql
shell> mysql -u root -p -e "source /tmp/dump.sql"
```

�ֿ�ִ�е������ǲ���ȫ�ģ���Ϊ�����һ����־�ļ��а���һ��CREATE TEMPORARY TABLE ������ʱ�����䣬�ڶ������ʹ�õ��˾��������һ�����ӳ��������⣬�ڶ������޷�ִ�С���
```
shell> mysqlbinlog binlog.000001 | mysql -u root -p # DANGER!!
shell> mysqlbinlog binlog.000002 | mysql -u root -p # DANGER!!
```

##ʹ�û���ʱ���������ָ�Point-in-Time Recovery Using Event Times

ʹ��--start-datetime and --stop-datetime ѡ�������ƻָ��Ŀ�ʼ�ͽ���ʱ��

����ĳ�첻С��ɾ���˲���ɾ�����ݣ�����ʹ��--stop-datetime��ȷ�Ļָ���ɾ����ǰһ��
```
mysqlbinlog --stop-datetime="2005-04-20 9:59:59" \
         /var/log/mysql/bin.123456 | mysql -u root -p
```
�ָ���ĳʱ�̿�ʼ�������¼�

```
mysqlbinlog --start-datetime="2005-04-20 10:01:00" \
         /var/log/mysql/bin.123456 | mysql -u root -p
```
		 
##ʹ�û����¼���������ָ�Point-in-Time Recovery Using Event Positions

������ʹ��������䣬����ĳһ��ʱ��Ĳ������鿴��position,positionͨ����log_pos �����һ������

```
shell> mysqlbinlog --start-datetime="2005-04-20 9:55:00" \
         --stop-datetime="2005-04-20 10:05:00" \
         /var/log/mysql/bin.123456 > /tmp/mysql_restore.sql
```

Ȼ��ʹ���¼���ָ�

```
shell> mysqlbinlog --stop-position=368312 /var/log/mysql/bin.123456 \
         | mysql -u root -p

shell> mysqlbinlog --start-position=368315 /var/log/mysql/bin.123456 \
         | mysql -u root -p
```


		 
http://dev.mysql.com/doc/refman/5.7/en/point-in-time-recovery.html
http://dev.mysql.com/doc/refman/5.7/en/point-in-time-recovery-times.html
http://dev.mysql.com/doc/refman/5.7/en/point-in-time-recovery-positions.html