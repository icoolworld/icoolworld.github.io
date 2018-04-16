---
layout: post
title: openssl建立二级CA
categories: https
---

# openssl建立二级CA


用Openssl建立私有CA并颁发证书 

1.建立CA根证书 

1.1生成私钥 
```
openssl req -newkey rsa:1024 -sha1 -config ./myopenssl.cnf -keyout rootkey.pem -out rootreq.pem -days 3650 
```

1.2生成证书，并用私钥签名 

```
openssl x509 -req -in rootreq.pem -sha1 -extfile ./myopenssl.cnf -extensions v3_ca -signkey rootkey.pem -out rootcert.pem -days 3650 
```


1.3组合证书与私钥，形成CA根证书 

```
cat rootcert.pem rootkey.pem > root.pem 
```


1.4显示，检查根证书主题与发行者 

```
openssl x509 -subject -issuer -noout -in root.pem 
```


2.创建，颁发二级CA证书 

2.1创建二级CA跟证书私钥 

```
openssl req -newkey rsa:1024 -sha1 -config ./myopenssl.cnf -keyout serverCAkey.pem -out serverCAreq.pem -days 3650 
```


2.2生成二级CA证书，并用CA证书签名 

```
openssl x509 -req -in serverCAreq.pem -sha1 -extfile ./myopenssl.cnf -extensions v3_ca -CA root.pem -CAkey root.pem -CAcreateserial -out serverCAcert.pem -days 3650 
```


2.3组合二级CA证书与二级CA私要，形成二级CA证书 

```
cat serverCAcert.pem serverCAkey.pem rootcert.pem >serverCA.pem 
```


2.4显示，检查二级CA根证书主题与发行者 

```
openssl x509 -subject -issuer -noout -in serverCA.pem 
```


3.创建，颁发服务端证书 

3.1创建服务端正书私钥 

```
openssl req -newkey rsa:1024 -sha1 -config ./myopenssl.cnf -keyout serverkey.pem -out serverreq.pem -days 3650 
```



3.2创建服务端正书，并签名 

```
openssl x509 -req -in serverreq.pem -sha1 -extfile ./myopenssl.cnf -extensions usr_cert -CA serverCA.pem -CAkey serverCA.pem -CAcreateserial -out servercert.pem -days 3650 
```



3.3组合私钥与证书，形成服务端正书 
```
cat servercert.pem serverkey.pem serverCAcert.pem rootcert.pem > server.pem 
```


3.4显示，检查服务段证书的主题与发行者 
```
openssl x509 -subject -issuer -noout -in server.pem 
```


4.创建颁发客户端证书 

4.1创建客户端证书私钥 

```
openssl req -newkey rsa:1024 -sha1 -config ./myopenssl.cnf -keyout clientkey.pem -out clientreq.pem -days 3650 
```


4.2创建客户端证书，并签名 
```
openssl x509 -req -in clientreq.pem -sha1 -extfile ./myopenssl.cnf -extensions usr_cert -CA root.pem -CAkey root.pem -CAcreateserial -out clientcert.pem -days 3650 
```


4.3组合私钥与证书，形成客户端证书 
```
cat clientcert.pem clientkey.pem rootcert.pem > client.pem 
```


4.4显示，检查服务段证书的主题与发行者 
```
openssl x509 -subject -issuer -noout -in client.pem 
```


5.随机数生成 

5.1生成512bit大数 
```
openssl dhparam -check -text -5 512 -out dh512.pem 
```


5.2生成1024bit大数 openssl dhparam -check -text -5 1024 -out dh1024.pem 



6.验证证书有效性 

6.1用二级CA验证服务器证书 
```
openssl verify -CAfile serverCA.pem server.pem
```

## 参考
```
http://blog.csdn.net/lsj19830812/article/details/8167068
```