---
layout: post
title: linux环境下解决git log 乱码问题
categories: git
---

# linux环境下解决git log 乱码问题

## 执行一下命令
```
$ git config --global core.quotepath false          # 显示 status 编码
$ git config --global gui.encoding utf-8            # 图形界面编码
$ git config --global i18n.commit.encoding utf-8    # 提交信息编码
$ git config --global i18n.logoutputencoding utf-8  # 输出 log 编码
$ export LESSCHARSET=utf-8
```

## 修改文件 
vi /etc/profile
```
export LESSCHARSET=utf-8
```

最后一条命令是因为 git log 默认使用 less 分页，所以需要 bash 对 less 命令进行 utf-8 编码
