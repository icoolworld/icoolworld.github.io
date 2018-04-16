---
layout: post
title: mysql对已经存在的列，添加唯一键unique
categories: mysql
---

# mysql添加唯一键unique

如果列中存在重复的值，添加unique key将失败

解决方案如下：
```
set session old_alter_table =on;
ALTER IGNORE TABLE pre_common_member ADD UNIQUE loginname (loginname);
```