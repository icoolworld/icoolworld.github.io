---
layout: page
title: About Me
description: 因码而生,我是码农
keywords: 码农,it
comments: true
menu: 关于
permalink: /about/
---

我是IT码农，三十而立

仰慕「优雅编码的艺术」。

坚信熟能生巧，努力改变人生。

## 教育背景

> 2005.9-2009.7　福建师范大学　计算机科学与技术专业

## 工作经历

### 搜狐畅游17173 　(2018.5-至今)

* 职位

> 资深php开发工程师

* 工作内容：

> 1、负责公司You料社交App项目的开发、维护工作

> 2、负责技术部门Gitlab代码管理平台的日常升级维护、权限管理等

> 3、Devops职责，为项目的发布、测试、上线等，提供CI/CD持续集成解决方案

> 4、优化提升项目的性能与并发能力

> 5、调研研究学习前沿的技术、为产品开发，提供高效解决方案

### 百度 　(2014.10-2017.10)

* 职位

> 高级研发工程师

* 工作内容：

> 一、负责公司内部系统的开发工作：

> CMS内容管理系统、

> App服务端基于Restful 的Api接口开发、

> 微信开放平台应用开发、

> 运营活动系统、

> 数据爬虫系统等

> 所负责开发的内容管理系统，支撑每天千万级的流量访问。

> 二、linux服务器运维管理工作

> 负责线上近50台linux服务器的日常运维管理工作，shell脚本编写，包括Nginx、Mysql、Redis、Memcached、Mongodb等服务

> 三、为部门提供技术支持、保障业务需求
> 为部门各项业务需求，提供技术支持(开发、维护、升级等)，及时完成业务方的需求。
> 所负责的部分web站点：
```
http://shouji.baidu.com（百度手机助手）
http://ivr.baidu.com（百度VR）
http://www.91.com （91门户）
http://www.hiapk.com （安卓网）
```
> 四、优化改善部门团队技术现状，提升团队整体技术水平

> 如：在任职期间，改善部门技术现状，规范化建设等：

> 1)、推动nginx+lua高性能架构的运用

> 2)、docker容器化部署运用

> 3)、推动api接口规范化、遵循Restful设计

> 4)、统一部门对外接口通信机制，基于oauth2授权

> 5)、推动apidoc文档规范化注释的使用

### 海邦（福建）商贸有限公司 　(2010.6-2014.9)

* 职位

> php开发工程师

* 工作内容：

> 1.负责公司外贸商城的日常开发及维护

> 2.负责公司旗下官方企业网站 、母婴商城、批发系统、淘宝商城等开发维护

> 3.负责公司内部的订单系统、广告系统的开发维护

> 4.web前端开发工作(html+div+css+jquery/ajax)、浏览器兼容测试等

> 5.负责基于Ecshop、Zencart、Wordpress、Discuz等开源程序的二次开发工作

### 福州天盟数码有限公司 　(2009.6-2010.6)

* 职位

> 网站策划

* 工作内容：

> 校招实习、负责公司游戏官网策划设计等工作


## Contact

{% for website in site.data.social %}
* {{ website.sitename }}：[@{{ website.name }}]({{ website.url }})
{% endfor %}

## 专业技能点 

{% for category in site.data.skills %}
### {{ category.name }}
<div class="btn-inline">
{% for keyword in category.keywords %}
<button class="btn btn-outline" type="button">{{ keyword }}</button>
{% endfor %}
</div>
{% endfor %}
