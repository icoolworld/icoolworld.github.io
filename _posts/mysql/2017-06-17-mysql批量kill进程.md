---
layout: post
title: mysql批量kill进程
categories: mysql
---


##通过information_schema.processlist表中的连接信息生成需要处理掉的MySQL连接的语句临时文件，然后执行临时文件中生成的指令。
desc information_schema.processlist ;
SELECT concat('KILL ',id,';') FROM information_schema.processlist WHERE user='root'; 
SELECT concat('KILL ',id,';') FROM information_schema.processlist WHERE user='root' INTO OUTFILE '/tmp/a.txt';
source /tmp/a.txt;


/usr/local/mysql/bin/mysql -uroot -pbdweb..pw..1999yy -S /tmp/mysql.sock -e "show processlist" | grep Query | awk '{print "kill "$1";"}' > /tmp/kill.sql

/usr/local/mysql/bin/mysql -uroot -pbdweb..pw..1999yy -S /tmp/mysql.sock -e "source /tmp/kill.sql;"


##杀掉当前所有的MySQL连接
mysqladmin -uroot -p processlist|awk -F "|" '{print $2}'|xargs -n 1 mysqladmin -uroot -p kill


##通过SHEL脚本实现,杀掉锁定的MySQL连接
for id in `mysqladmin processlist|grep -i locked|awk '{print $1}'`
do
   mysqladmin kill ${id}
done

##通过Maatkit工具集中提供的mk-kill命令进行

#杀掉超过60秒的sql
mk-kill -busy-time 60 -kill
#如果你想先不杀，先看看有哪些sql运行超过60秒
mk-kill -busy-time 60 -print
#如果你想杀掉，同时输出杀掉了哪些进程
mk-kill -busy-time 60 -print –kill