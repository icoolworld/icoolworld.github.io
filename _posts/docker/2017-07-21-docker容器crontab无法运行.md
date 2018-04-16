---
layout: post
title: docker容器crontab无法运行
categories: docker
---


vim /etc/pam.d/crond     
注释以下行session    required   pam_loginuid.so
```
 account    required   pam_access.so
 account    include    password-auth
 #session    required   pam_loginuid.so
 session    include    password-auth
 auth       include    password-auth
```

重启服务
/etc/init.d/crond restart