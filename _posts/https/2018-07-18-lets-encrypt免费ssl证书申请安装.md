---
layout: post
title: lets-encrypt免费ssl证书申请安装
categories: https
---

# Let's Encrypt 免费证书申请安装指南


## step1:创建RSA私钥
> 用于Let's Encrypt 识别你的身份：account.key

```
openssl genrsa 4096 > account.key
```

## step2:生成证书请求CSR文件

> 一条命令，同时生成csr证书请求和私钥key

```
openssl req -new -sha256 -nodes -out server.csr -newkey rsa:4096 -keyout server_private.key -reqexts SAN -config server.csr.cnf

or手动执行输入
openssl req -new -sha256 -key server_private.key -out server.csr
```

> -reqexts SAN 支持SAN扩展  
> -config server.csr.cnf 指定配置文件
> server.csr.cnf配置文件内容如下

```
[req]
default_bits = 4096
prompt = no
default_md = sha256
distinguished_name = dn

[dn]
C=CN
ST=Beijing
L=Beijing
O=domain
OU=domain com
emailAddress=admin@domain.com
CN = alicorn.domain.com

[SAN]
subjectAltName=DNS:alicorn.domain.com
subjectAltName=DNS:alicorn.domain.com,DNS:www.domain.com,
```

## step3:向Let's Encrypt申请crt证书

> 注意，为了让Let's Encrypt 验证你的是服务器的所有者，需要让http://yourhost.name/.well-known/acme-challenge/能被Let's Encrypt访问到

> 我们知道，CA 在签发 DV（Domain Validation）证书时，需要验证域名所有权。传统 CA 的验证方式一般是往 admin@yoursite.com 发验证邮件，而 Let's Encrypt 是在你的服务器上生成一个随机验证文件，再通过创建 CSR 时指定的域名访问，如果可以访问则表明你对这个域名有控制权。

**创建目录用来保存生成的验证文件**

```
    mkdir /home/www/challenges/
```

**配置Nginx**

> 让http://yourhost.name/.well-known/acme-challenge/能被Let's Encrypt访问到

```
server {

    location ^~ /.well-known/acme-challenge/ {
        alias /home/www/challenges/;
        try_files $uri =404;
    }
}
```

**向Let's Encrypt申请crt证书，执行如下命令**

```
wget https://raw.githubusercontent.com/diafygi/acme-tiny/master/acme_tiny.py
python acme_tiny.py --account-key ./account.key --csr ./server.csr --acme-dir /home/www/challenges/ > ./signed.crt
```

## step4:合并中间证书

```
wget -O - https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem > intermediate.pem
cat signed.crt intermediate.pem > chained.pem
```

## step5:为了后续能顺利启用 OCSP Stapling，我们再把根证书和中间证书合在一起：

```
wget -O - https://letsencrypt.org/certs/isrgrootx1.pem > root.pem
cat intermediate.pem root.pem > full_chained.pem
```


## step6:Last Step

> 配置Nginx支持ssl

```
ssl_certificate     ~/www/ssl/chained.pem;
ssl_certificate_key ~/www/ssl/server_private.key;
```

> 恭喜，你已经大功告成了！


## 后话

> Let's Encrypt 签发的证书只有 90 天有效期，推荐使用脚本定期更新。例如我就创建了一个 renew_cert.sh 并通过 chmod a+x renew_cert.sh 赋予执行权限。文件内容如下：

```
#!/bin/bash

cd /home/xxx/www/ssl/
python acme_tiny.py --account-key account.key --csr server.csr --acme-dir /home/xxx/www/challenges/ > signed.crt || exit
wget -O - https://letsencrypt.org/certs/lets-encrypt-x3-cross-signed.pem > intermediate.pem
cat signed.crt intermediate.pem > chained.pem
service nginx reload
```
