]# vi /etc/sysconfig/iptables

5 ����ǽ���Ŷ˿ڣ�������ֱ�ӹر� /etc/init.d/iptables stop��
1�����Ŷ˿�
iptables -I INPUT -p udp --dport 137 -j ACCEPT
iptables -I INPUT -p udp --dport 138 -j ACCEPT
iptables -I INPUT -p tcp --dport 139 -j ACCEPT   
iptables -I INPUT -p tcp --dport 445 -j ACCEPT
2����������
/etc/init.d/iptables save
3����������ǽ
/etc/init.d/iptables restart

 

6 ����samba����
/etc/init.d/smb start

 

7 ��������
chkconfig smb on

 

8 windows����
\\�������ַ