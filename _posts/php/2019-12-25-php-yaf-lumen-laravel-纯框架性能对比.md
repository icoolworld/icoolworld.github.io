---
layout: post
title: php-yaf-lumen-laravel纯框架性能分析对比 
categories: docker
---

### php框架性能分析(纯框架)

> 采用同一服务器环境，同一压测客户端环境，ab测试


> 结论

原生性能**100%**  
（ab测试，1000并发，10万请求量，**qps接近4500**）  

yaf原生性能**80%**  
（ab测试，1000并发，10万请求量，**qps接近3500**，是lumen性能3倍，是laravel5.7性能的15倍）  

lumen原生性能**25%**  
(ab测试，1000并发，10万请求量，**qps接近1200**，是laravel5.7性能的5倍的)  

larvel，原生性能**5%**  
（ab测试，200并发，1万请求量，**qps近270**)  

> 其中laravel在200并发情况下，服务器几乎满负载，top达到100，机器运行异常缓慢，存在大量IO等待


### 原生php 压测情况
![ys](https://raw.githubusercontent.com/icoolworld/icoolworld.github.io/master/images/ys.png)
### yaf 压测情况
![yaf](https://raw.githubusercontent.com/icoolworld/icoolworld.github.io/master/images/yaf.png)
### lumen 压测情况
![lumen](https://raw.githubusercontent.com/icoolworld/icoolworld.github.io/master/images/lumen.png)
### laravel 压测情况
![laravel](https://raw.githubusercontent.com/icoolworld/icoolworld.github.io/master/images/laravel.png)

