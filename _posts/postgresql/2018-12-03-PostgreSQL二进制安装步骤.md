## PostgreSQL 9.6.5 Binaries - Linux64 安装

## 下载64位二进制PostgreSQL程序，免去编译过程

```
https://www.enterprisedb.com/postgresql-965-binaries-linux64?ls=Crossover&type=Crossover

mkdir -p /data/opensource/
cd /data/opensource/
wget -c https://get.enterprisedb.com/postgresql/postgresql-9.6.5-1-linux-x64-binaries.tar.gz
```

## 用户创建
```
groupadd postgres
useradd -g postgres postgres
```

## 解压安装postgreSQL程序,创建数据存储目录
```
tar zxf postgresql-9.6.5-1-linux-x64-binaries.tar.gz -C /usr/local/
mkdir -p /data/postgresql/data
```

## 指定用户组
```
授权：
chown -R postgres.postgres /usr/local/pgsql
chown -R postgres.postgres /data/postgresql/data

这里如果不授权，后面初始化时候会报权限错误：
fixing permissions on existing directory /data/service/postgresql/data ... initdb: could not change permissions of directory "/data/service/postgresql/data": Operation not permitted
```

## 初始化安装

```
cd /usr/local/pgsql/
su postgres
bin/initdb -E utf8 -D /data/postgresql/data
```

> 安装过程：

```
The files belonging to this database system will be owned by user "postgres".
This user must also own the server process.

The database cluster will be initialized with locale "C".
The default text search configuration will be set to "english".

Data page checksums are disabled.

fixing permissions on existing directory /data/postgresql/data ... ok
creating subdirectories ... ok
selecting default max_connections ... 100
selecting default shared_buffers ... 128MB
selecting dynamic shared memory implementation ... posix
creating configuration files ... ok
running bootstrap script ... ok
performing post-bootstrap initialization ... No usable system locales were found.
Use the option "--debug" to see details.
ok
syncing data to disk ... ok

WARNING: enabling "trust" authentication for local connections
You can change this by editing pg_hba.conf or using the option -A, or
--auth-local and --auth-host, the next time you run initdb.

Success. You can now start the database server using:

    bin/pg_ctl -D /data/postgresql/data -l logfile start
```

OK 看到这个表示已经初始化成功了。

我们先使用默认配置启动postgresql，如需修改配置参数，可以在data的目录下的postgresql.conf修改。


## 启动postgresql

启动注意必须使用postgres用户启动

```
/usr/local/pgsql/bin/pg_ctl -D /data/postgresql/data -l logfile start
```

## 登录postgresql
```
/usr/local/pgsql/bin/psql   
```

## 创建数据库和用户
```
create user work with password '123456';

postgres=# create user work with password '123456';
CREATE ROLE

create database mydb with encoding='utf8' owner=work;
```


## 验证客户端登录

```
/usr/local/pgsql/bin/psql -h 127.0.0.1 -U work -d mydb     
```


## 端口开放问题
```
vim /data/postgresql/data/postgresql.conf
listen_addresses = '*' 监听所有地址

修改listen_addresses为对外的interface的ip地址

重启pgsql，ok
```
## 常用命令
```
1 命令行登录数据库

有两种方式，一是直接在系统shell下执行psql命令；而是先进入psql环境，然后再连接数据库。下面分别给出实例：
(1)直接登录

执行命令：psql -h 172.16.35.179 -U username -d dbname ，其中username为数据库用户名，dbname为要连接的数据库名，执行后提示输入密码如下：
Password for user username: （在此输入密码）
输入密码后即可进入psql环境了。
(2)切换数据库

有时候需要在psql环境下切换数据库，此时执行如下psql命令：
\c dbname username serverIP port
其中除了数据库名外，其他的参数都是可选的，如果使用默认值可以使用-作为占位符
执行这个命令后，也是提示输入密码。

2 查看帮助

psql提供了很好的在线帮助文档，总入口命令是help，输入这个命令就可以看到
vsb9=# help
You are using psql, the command-line interface to PostgreSQL.
Type:  \copyright for distribution terms
       \h for help with SQL commands
       \? for help with psql commands
       \g or terminate with semicolon to execute query
       \q to quit

可以看到，标准SQL命令的帮助和psql特有命令的帮助是分开的。输入\?查看psql命令，会发现所有的psql命令都是以\开头，这就很容易和标准的SQL命令进行区分开来。

3 常用命令

为了便于记忆，这里把对应的mysql命令也列出来了。

(1)列出所有的数据库

mysql: show databases
psql: \l或\list
(2)切换数据库

mysql: use dbname
psql: \c dbname

(3)列出当前数据库下的数据表

mysql: show tables
psql: \d

(4)列出指定表的所有字段

mysql: show columns from table name
psql: \d tablename

(5)查看指定表的基本情况

mysql: describe tablename
psql: \d+ tablename

(6)退出登录

mysql: quit 或者\q
psql:\q

```


## 导出数据
```
pg_dump -U postgres(用户名)  (-t 表名)  数据库名(缺省时同用户名)  > 路径/文件名.sql

 pg_dump -U pgsqlwork uniii_raddit > ./uniii_raddit.sql  
 pg_dump -U pgsqlwork -t * uniii_raddit > ./uniii_raddit.sql  
```

## 导入数据
```
导入数据时首先创建数据库再用psql导入：
$ createdb newdatabase
$ psql -d newdatabase -U postgres -f mydatabase.sql   // sql 文件在当前路径下

$ psql -d databaename(数据库名) -U username(用户名) -f < 路径/文件名.sql  // sql 文件不在当前路径下
```

```
出现以下问题，解决方案：

vim /data/postgresql/data/pg_hba.conf 
host  all   ambari 0.0.0.0/0  trust 



08:25:01 ERROR     [console] Error thrown while running command "doctrine:migrations:migrate". Message: "An exception occured in driver: SQLSTATE[08006] [7] FATAL:  no pg_hba.conf entry for host "172.17.42.1", user "work", database "mydb", SSL off" ["error" => Doctrine\DBAL\Exception\ConnectionException { …},"command" => "doctrine:migrations:migrate","message" => "An exception occured in driver: SQLSTATE[08006] [7] FATAL:  no pg_hba.conf entry for host "172.17.42.1", user "work", database "mydb", SSL off"] []

In AbstractPostgreSQLDriver.php line 85:
                                                                                                                                                  
  An exception occured in driver: SQLSTATE[08006] [7] FATAL:  no pg_hba.conf entry for host "172.17.42.1", user "work", database "mydb", SSL off  
                                                                                                                                                  

In PDOConnection.php line 47:
                                                                                                                  
  SQLSTATE[08006] [7] FATAL:  no pg_hba.conf entry for host "172.17.42.1", user "work", database "mydb", SSL off  
                                                                                                                  

In PDOConnection.php line 43:
                                                                                                                  
  SQLSTATE[08006] [7] FATAL:  no pg_hba.conf entry for host "172.17.42.1", user "work", database "mydb", SSL off  
```
### 参考 

```
http://blog.csdn.net/wlzjsj/article/details/52301156
```