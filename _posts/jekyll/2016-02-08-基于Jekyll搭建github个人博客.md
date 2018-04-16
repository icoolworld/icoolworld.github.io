---
layout: post
title: 基于Jekyll搭建github个人博客
categories: jekyll
---

---
layout: post
title: 基于Jekyll搭建github个人博客
categories: jekyll
---
# 基于Jekyll搭建github个人博客

## 背景
为了方便日常记录，搭建一个博客系统，考虑到基于github可以免费使用其空间，而github推荐使用jekyll来搭建博客

## jekyll介绍

Jekyll 是一个简单的博客形态的静态站点生产机器。它有一个模版目录，其中包含原始文本格式的文档，通过 Markdown （或者 Textile） 以及 Liquid 转化成一个完整的可发布的静态网站，你可以发布在任何你喜爱的服务器上。Jekyll 也可以运行在 GitHub Page 上，也就是说，你可以使用 GitHub 的服务来搭建你的项目页面、博客或者网站，而且是完全免费的。

　使用 Jekyll 搭建博客之前要确认下本机环境，Git 环境（用于部署到远端）、Ruby 环境（Jekyll 是基于 Ruby 开发的）、包管理器 RubyGems 
　　如果你是 Mac 用户，你就需要安装 Xcode 和 Command-Line Tools了。下载方式 Preferences → Downloads → Components。

## 系统环境
```
centos6.7+ruby+gem+jekyll
```

## 相关知识

**ruby与ruby gem的关系**

ruby是一种脚本语言

ruby的其中一个“程序”叫rubygems，简称 gem(ruby 1.9.2及其以上就已经默认安装了ruby gem的，所以无需再次手动安装)

**ruby与jekyll的关系**

jekyll是基于ruby的，所以搭建jekyll之前必须确保ruby正常安装 注意，必须ruby大于2.0.0

**jekyll与python的关系**

jekyll3.0之前，有一个语法高亮插件"Pygments"，这玩意是基于python的，所以才会有各种教程里面都说搭建jekyll之前需要python环境

但是,请注意 jekyll3.0以后，语法高亮插件已经默认改成了 “rouge‘ 而它是基于ruby的，也就是说 现在搭建jekyll,我们完全不必要再安装python 这样可以减少很大一部分工作量

**为什么ruby要改用source来源**

不管是那一篇教程，都会告诉你安装完ruby后需要通过gem命令将官方源改成淘宝源或ruby china源，这是因为默认的官方源在国外，国内几乎是无法访问的(具体原因么...)

所以才会必须改成其否源，否则无法使用，但是，请注意 现在淘宝源已经停止维护了，最新搭建jekyll 都应该要改成 ruby china的源
```
http://gems.ruby-china.org
```

如何解决jekyll安装过程中的问题

首先，在确保ruby(2.0.0以上)正常安装，并且切换了ruby china源(或者淘宝源)后，其它遇到的所有问题几乎都是 确实某些ruby程序的问题，所以只需要根据提示 通过相应命令，比如 gem install ... 即可解决

## jekyll安装步骤如下

1.安装ruby(2.0.0以上)
2.切换ruby的source来源
3.通过gem命令安装jekyll
4.github上fork心仪的jekyll模板，本地jekyll serve运行相应的博客

## 一.ruby安装
进入官网`https://www.ruby-lang.org/en/downloads/`,下载页面
```
wget -c https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.1.tar.gz
tar -zxf ruby-2.4.1.tar.gz
cd ruby-2.4.1
./configure --prefix=/usr/local/ruby-2.4.1
make -j 8 && make install
```

安装ruby遇到问题
```
*** Following extensions failed to configure:
../.././ext/gdbm/extconf.rb:0: Failed to configure gdbm. It will not be installed.
```

解决方法
```
yum -y install gdbm gdbm-devel
```

## 二.安装gem
进入官网`https://rubygems.org/pages/download`
```
wget https://rubygems.org/rubygems/rubygems-2.6.12.tgz
tar -zxf rubygems-2.6.12.tgz
cd rubygems-2.6.12
ruby setup.rb
```

## 三.更换source源
```
gem sources -l 查看当前源
gem sources -r https://rubygems.org/ 
gem sources -r https://ruby.taobao.org/
gem sources -a http://gems.ruby-china.org
```

## 四.安装jekyll
```
安装jekyll前先按照依赖包bundler
gem install bundler
gem install jekyll
```

## 五.创建博客
```
jekyll new myblog
```

## 六.运行博客
```
cd myblog
jekyll serve
jekyll serve --detach 后端运行

如果启动server出现错误，尝试安装项目依赖的所有gem包
bundle install
```


## 关于bundle命令
```
显示所有的依赖包 
bundle show
检查系统中缺少那些项目依赖的gem包 
bundle check
安装项目依赖的所有gem包 
bundle install
更新依赖包
bundle update
```

```
错误提示：
# Could not find a JavaScript runtime. See https://github.com/sstephenson/execjs #for a list of available runtimes. #(ExecJS::RuntimeUnavailable)   

解决方案：修改Gemfile文件，新增 
gem 'execjs'
gem 'therubyracer'
```


## github本地配置

    为了将本地的代码发布到github上，需要在本地安装git环境，并做相应的配置
    后面的your_email@youremail.com改为你在github上注册的邮箱，之后会要求确认路径和输入密码，我们这使用默认的一路回车就行。成功的话会在~/下生成.ssh文件夹，进去，打开id_rsa.pub，复制里面的key。
    回到github上，进入 Account Settings（账户配置），左边选择SSH Keys，Add SSH Key,title随便填，粘贴在你电脑上生成的key。

    ```
    ssh-keygen -t rsa -C "your_email@youremail.com"
    ```

    验证是否成功
    ```
    ssh -T git@github.com
    ```

    配置github的username,emai等信息
    ```
    git config --global user.name "your name"
    git config --global user.email "your_email@youremail.com"
    ```

## 推送内容到github
```
git clone https://github.com/icoolworld/shell.git
git status 查看修改的文件
git add file
git commit -m "提交修改"
git push origin master
```


### 参考

```
http://www.jianshu.com/p/27de87d4447e
http://www.jianshu.com/p/333d05315308
https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/
```