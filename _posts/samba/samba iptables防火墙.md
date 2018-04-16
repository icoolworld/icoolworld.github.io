]# vi /etc/sysconfig/iptables

5 防火墙开放端口（或者是直接关闭 /etc/init.d/iptables stop）
1）开放端口
iptables -I INPUT -p udp --dport 137 -j ACCEPT
iptables -I INPUT -p udp --dport 138 -j ACCEPT
iptables -I INPUT -p tcp --dport 139 -j ACCEPT   
iptables -I INPUT -p tcp --dport 445 -j ACCEPT
2）保存配置
/etc/init.d/iptables save
3）重启防火墙
/etc/init.d/iptables restart

 

6 启动samba服务
/etc/init.d/smb start

 

7 开机启动
chkconfig smb on

 

8 windows访问
\\虚拟机地址