---
layout: post
title: php实现https(ssl)双向认证
categories: https
---

# php实现https(tls/ssl)双向认证
通常情况下，在部署https的时候，是基于ssl单向认证的，也就是说只要客户端认证服务器，而服务器不需要认证客户端。

但在一些安全性较高的场景，如银行，金融等领域，通常会要求进行客户端认证。从而实现ssl的双向认证。

由于nginx的ssl_client_certificate参数只能指定一个客户端公钥，如果增加一个客户端进行通信就要重新配一个server。
n:1的模式是通过CA的级联证书模式实现的，首先自己生成一套CA根级证书，再借助其生成二级证书作为client证书。
此时client私钥签名不仅可以通过对应的client公钥验证，还可通过根证书的公钥进行验证。

看到这里应该豁然开朗了吧，下面简单介绍下具体怎么操作：

## 1 准备工作

### 1.1 openssl目录准备
一般情况下openssl的配置文件都在这个目录/etc/pki/tls，so：
```
mkdir /etc/pki/ca_linvo
cd /etc/pki/ca_linvo
mkdir root server client newcerts
echo 01 > serial
echo 01 > crlnumber
touch index.txt
```

### 1.2 openssl配置准备
修改openssl配置
```
vi /etc/pki/tls/openssl.cnf
```
找到这句注释掉，替换为下面那句
```
#default_ca      = CA_default
default_ca      = CA_linvo
```
把[ CA_default ]整个部分拷贝一份，改成上面的名字[ CA_linvo ]
修改里面的如下参数：
```
dir = /etc/pki/ca_linvo
certificate = $dir/root/ca.crt
private_key = $dir/root/ca.key
```
保存退出

## 2 创建CA根级证书
```
生成key：openssl genrsa -out /etc/pki/ca_linvo/root/ca.key
生成csr：openssl req -new -key /etc/pki/ca_linvo/root/ca.key -out /etc/pki/ca_linvo/root/ca.csr
生成crt：openssl x509 -req -days 3650 -in /etc/pki/ca_linvo/root/ca.csr -signkey /etc/pki/ca_linvo/root/ca.key -out /etc/pki/ca_linvo/root/ca.crt
生成crl：openssl ca -gencrl -out /etc/pki/ca_linvo/root/ca.crl -crldays 7
```
生成的根级证书文件都在/etc/pki/ca_linvo/root/目录下
注意：创建证书时，建议证书密码设置长度>=6位，因为Java的keytool工具貌似对它有要求。

## 3 创建server证书
```
生成key：openssl genrsa -out /etc/pki/ca_linvo/server/server.key
生成csr：openssl req -new -key /etc/pki/ca_linvo/server/server.key -out /etc/pki/ca_linvo/server/server.csr
生成crt：openssl ca -in /etc/pki/ca_linvo/server/server.csr -cert /etc/pki/ca_linvo/root/ca.crt -keyfile /etc/pki/ca_linvo/root/ca.key -out /etc/pki/ca_linvo/server/server.crt -days 3650
```
说明：
1、这里生成的crt是刚才ca根级证书下的级联证书，其实server证书主要用于配置正常单向的https，所以不使用级联模式也可以：
```
openssl rsa -in /etc/pki/ca_linvo/server/server.key -out /etc/pki/ca_linvo/server/server.key
openssl x509 -req -in /etc/pki/ca_linvo/server/server.csr -signkey /etc/pki/ca_linvo/server/server.key -out /etc/pki/ca_linvo/server/server.crt -days 3650
```
2、-days 参数可根据需要设置证书的有效期，例如默认365天

## 4 创建client证书
```
生成key：openssl genrsa -des3 -out /etc/pki/ca_linvo/client/client.key 1024
生成csr：openssl req -new -key /etc/pki/ca_linvo/client/client.key -out /etc/pki/ca_linvo/client/client.csr
生成crt：openssl ca -in /etc/pki/ca_linvo/client/client.csr -cert /etc/pki/ca_linvo/root/ca.crt -keyfile /etc/pki/ca_linvo/root/ca.key -out /etc/pki/ca_linvo/client/client.crt -days 3650
```
说明：
1、这里就必须使用级联证书，并且可以重复该步骤，创建多套client证书
2、生成crt时可能会遇到如下报错：
openssl TXT_DB error number 2 failed to update database
可参照这里进行操作。
我使用的是方法一，即将index.txt.attr中unique_subject = no

## 5 配置nginx
这里只列出server段的关键部分：
```
ssl_certificate  /etc/pki/ca_linvo/server/server.crt;#server公钥
ssl_certificate_key  /etc/pki/ca_linvo/server/server.key;#server私钥
ssl_client_certificate   /etc/pki/ca_linvo/root/ca.crt;#根级证书公钥，用于验证各个二级client
ssl_verify_client on;
```
重启Nginx

## 6 测试

### 6.1 浏览器测试
由于是双向认证，直接通过浏览器访问https地址是被告知400 Bad Request（No required SSL certificate was sent）的，需要在本机安装client证书。
windows上安装的证书需要pfx格式，也叫p12格式，生成方式如下：
```
openssl pkcs12 -export -inkey /etc/pki/ca_linvo/client/client.key -in /etc/pki/ca_linvo/client/client.crt -out /etc/pki/ca_linvo/client/client.pfx
```
然后考到windows中双击即可进行安装，安装时会提示输入生成证书时设置的密码。
安装成功后，重启浏览器输入网址访问，浏览器可能会提示你选择证书，选择刚才安装的那个证书即可。
此时有些浏览器会提示用户该证书不受信任，地址不安全之类，这是因为我们的server证书是我们自己颁发的，而非真正的权威CA机构颁布（通常很贵哦~），忽略它既可。

### 6.2 php curl测试
这里只列出关键的需要设置的curl参数：
```
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false); // 信任任何证书，不是CA机构颁布的也没关系  
curl_setopt($ch, CURLOPT_SSL_VERIFYHOST, 1); // 检查证书中是否设置域名，如果不想验证也可设为0  
curl_setopt($ch, CURLOPT_VERBOSE, '1'); //debug模式，方便出错调试  
curl_setopt($ch, CURLOPT_SSLCERT, CLIENT_CRT); //client.crt文件路径，这里我用常量代替  
curl_setopt($ch, CURLOPT_SSLCERTPASSWD, CRT_PWD); //client证书密码  
curl_setopt($ch, CURLOPT_SSLKEY, CLIENT_KEY); //client.key文件路径  

CURLOPT_TIMEOUT：超时时间
CURLOPT_RETURNTRANSFER：是否要求返回数据
CURLOPT_SSL_VERIFYPEER：是否检测服务器的证书是否由正规浏览器认证过的授权CA颁发的
CURLOPT_SSL_VERIFYHOST：是否检测服务器的域名与证书上的是否一致
CURLOPT_SSLCERTTYPE：证书类型，"PEM" (default), "DER", and"ENG".
CURLOPT_SSLCERT：证书存放路径
CURLOPT_SSLCERTPASSWD：证书密码,没有可以留空
CURLOPT_SSLKEYTYPE：私钥类型，"PEM" (default), "DER", and"ENG".
CURLOPT_SSLKEY：私钥存放路径


function curl_post_ssl($url, $vars, $second=30,$aHeader=array())
{
    $ch = curl_init();
    //curl_setopt($ch,CURLOPT_VERBOSE,'1');
    curl_setopt($ch,CURLOPT_TIMEOUT,$second);
    curl_setopt($ch,CURLOPT_RETURNTRANSFER, 1);
    curl_setopt($ch,CURLOPT_URL,$url);
    curl_setopt($ch,CURLOPT_SSL_VERIFYPEER,false);
    curl_setopt($ch,CURLOPT_SSL_VERIFYHOST,false);
    curl_setopt($ch,CURLOPT_SSLCERTTYPE,'PEM');
    curl_setopt($ch,CURLOPT_SSLCERT,'/data/cert/php.pem');
    curl_setopt($ch,CURLOPT_SSLCERTPASSWD,'1234');
    curl_setopt($ch,CURLOPT_SSLKEYTYPE,'PEM');
    curl_setopt($ch,CURLOPT_SSLKEY,'/data/cert/php_private.pem');

    if( count($aHeader) >= 1 ){
            curl_setopt($ch, CURLOPT_HTTPHEADER, $aHeader);
    }

    curl_setopt($ch,CURLOPT_POST, 1);
    curl_setopt($ch,CURLOPT_POSTFIELDS,$vars);
    $data = curl_exec($ch);
    curl_close($ch);
    if($data)
            return $data;
    else   
            return false;
}
```

验证失败，nginx的错误日志中，会有如下信息
```
2017/06/05 17:45:07 [crit] 16084#0: *27458991 SSL_do_handshake() failed (SSL: error:04067084:rsa routines:RSA_EAY_PUBLIC_DECRYPT:data too large for modulus e
rror:1408807A:SSL routines:ssl3_get_cert_verify:bad rsa signature) while SSL handshaking, client: 116.255.208.194, server: 0.0.0.0:443
```

### 6.3 php soap测试
首先需要构建client的pem格式证书，通过openssl命令也可以，不过因为我们已经有了crt和key，所以手动合并也很简单：
新建一个文件，把crt中-----BEGIN CERTIFICATE-----和-----END CERTIFICATE-----之间的base64内容（包括这两个分割线）拷贝进去，然后把key中-----BEGIN RSA PRIVATE KEY-----和-----END RSA PRIVATE KEY-----之间的内容也复制进去，然后保存为client.pem即可。
其实更省事的话可以如下命令，直接合并两个文件：
```
cat /etc/pki/ca_linvo/client/client.crt /etc/pki/ca_linvo/client/client.key > /etc/pki/ca_linvo/client/client.pem
有了pem文件，下面可以使用php内置的SoapClient进行调用，构造函数需要设置第二个参数：
$header = array(          
    'local_cert' => CLIENT_PEM, //client.pem文件路径  
    'passphrase' => CRT_PWD //client证书密码  
    );  
$client = new SoapClient(FILE_WSDL, $header); //FILE_WSDL为要访问的https地址  
```
上一篇博客里最后说到local_cert设置成远程路径的话会报错，好像是因为第一次获取wsdl时并没有使用client证书的原因，需要将wsdl保持成本地文件进行调用；
但是这次测试却没问题，不用另存为本地文件，直接远程获取即可。
本来认为是之前的证书有问题，但是使用之前的那套证书依然可以，很是诡异~~~~~

参考：http://blog.csdn.net/linvo/article/details/9173511