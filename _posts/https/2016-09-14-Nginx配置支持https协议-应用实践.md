---
layout: post
title: Nginx配置支持https协议-应用实践
categories: https
---

# Nginx配置支持https协议-应用实践

## https简介

HTTPS 是运行在 TLS/SSL 之上的 HTTP，与普通的 HTTP 相比，在数据传输的安全性上有很大的提升。

TLS是传输层安全协议（Transport Layer Security）的缩写，是一种对基于网络的传输的加密协议，可以在受信任的第三方公证基础上做双方的身份认证。TLS可以用在TCP上，也可以用在无连接的UDP报文上。协议规定了身份认证、算法协商、密钥交换等的实现。

SSL是TLS的前身，现在已不再更新

证书是TLS协议中用来对身份进行验证的机制，是一种数字签名形式的文件，包含证书拥有者的公钥及第三方的证书信息。

证书分为2类：自签名证书和CA证书。一般自签名证书不能用来进行身份认证，如果一个server端使用自签名证书，client端要么被设置为无条件信任任何证书，要么需要将自签名证书的公钥和私钥加入受信任列表。但这样一来就增加了server的私钥泄露风险。


https能够有效的防止流量劫持，对内容加密（中间者无法直接查看原始内容）、身份认证、数据完整性（防止内容被第三方冒充或者篡改）

## openssl工具简介

openSSL是一款功能强大的加密工具、我们当中许多人已经在使用openSSL、用于创建RSA私钥或证书签名请求、不过、你可知道可以使用openSSL来测试计算机速度？或者还可以用它来对文件或消息进行加密。

openssl是一个开源程序的套件、这个套件有三个部分组成、
一是libcryto、这是一个具有通用功能的加密库、里面实现了众多的加密库、
二是libssl、这个是实现ssl机制的、他是用于实现TLS/SSL的功能、
三是openssl、是个多功能命令行工具、他可以实现加密解密、甚至还可以当CA来用、可以让你创建证书、吊销证书

这里我们用openssl enc对一个文件进行加密看看：
```
openssl enc -des3 -a -salt -in /etc/fstab -out /tmp/fstab.cipher   加密
cat /tmp/fstab.cipher
openssl enc -d -des3 -a -salt -in /tmp/fstab.cipher -out/path/to/fstab.cipher   解密
```


## 一.用openssl生成相关文件

1.先生成私钥key
```
openssl genrsa -out ssl.key 2048
```
2.生成证书请求csr,其中days参数是证书有效期.
```
openssl req -new -key ssl.key -days 3650 -out ssl.csr
```
生成的ssl.csr就是证书请求了. 一般来说证书请求是发给公开的CA签名, 但私有接口就没必要去CA签名了.

**也可一键生成csr和key文件**
```
openssl req -new -newkey rsa:2048 -sha256 -nodes -out test_com.csr -keyout test_com.key -subj "/C=CN/ST=Beijing/L=Beijing/O=website Inc./OU=Web Securi
ty/CN=*.test.com"
```

3.去CA机构，申请证书，需要将csr上传给CA机构。CA会根据你的申请返回一个证书给你。此时你已经有了ssl通信所需要的所有文件。目前有这么多免费的CA机构，这里就不再赘述

4.如果要生成私有的证书，可以直接用自己的私钥签名刚刚生成的证书请求:
```
openssl x509 -req -in ssl.csr -signkey ssl.key -out ssl.crt
```

至此已经得到ssl所需要的crt,key,去nginx配置即可

## 二.nginx配置支持https
```
ssl on;
listen 443 ;
ssl_certificate   /etc/nginx/ssl/ssl.crt;
ssl_certificate_key  /etc/nginx/ssl/ssl.key;
ssl_session_timeout 5m;
ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE:ECDH:AES:HIGH:!NULL:!aNULL:!MD5:!ADH:!RC4;
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_prefer_server_ciphers on;

```

至此，已经可以使用https访问你的网站了


## 生成更多的证书
不过如果需要签更多证书请求或者要使用CA证书的话, 就需要自己生成私有CA证书:
```
openssl x509 -req -in ssl.csr -extensions v3_ca -signkey ssl.key -out sign.crt
```

用CA证书给自己的证书请求签名:
```
openssl x509 -req -in ssl.csr -extensions v3_usr -CA sign.crt -CAkey ssl.key -CAcreateserial -days 3650 -out ssl.crt
```

## 客户端信任证书

如果证书是私有证书, 客户端要信任证书需要做一些操作. 如果是浏览器, 直接根据浏览器的步骤信任证书即可. 本人使用的是requests模块, 信任证书需要在发起请求(get 或 post)时添加verify参数, 值为证书的CA_BUNDLE. CA_BUNDLE可以在服务器端生成, 不过要传给客户端比较麻烦. 本人直接使用firefox浏览器导出证书(x.509含链证书), 并在请求时添加即可:

requests.get('https://exaple.com', verify='ca.crt')

## 验证客户端请求
HTTPS虽然也有验证客户端证书的方式, 但为每个请求的客户端配置证书比较麻烦, 且也不是所有服务器程序都支持验证客户端证书.

本人使用的验证方式为客户端请求多添加一个参数, 参数值为修改版的TOTP与MD5结合. 具体算法自行定义即可, 只要满足:

1. 允许一定的时间误差; 
2. 不容易被猜测出算法; 
3. 方便修改算法密钥

## 参考

```
https://chroming.gitlab.io/2017/04/26/add_https_and_comfirm/
http://www.cnblogs.com/kyrios/p/tls-and-certificates.html
http://seanlook.com/2015/01/18/openssl-self-sign-ca/
http://blog.chinaunix.net/uid-12818265-id-2914434.html
https://imququ.com/post/letsencrypt-certificate.html
http://blog.csdn.net/napolunyishi/article/details/42425827
```
