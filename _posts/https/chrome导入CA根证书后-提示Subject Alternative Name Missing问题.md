# chrome58版本以后-自签名证书Subject Alternative Name Missing问题


    从chrome58版本开始，使用`SAN (Subject Alternative Name)`来代替比较流行的`Common Name (CN)`，如果使用自签名的证书，你只定义了CN，则将会出现`Subject Alternative Name Missing`错误

```
Since version 58, Chrome requires SSL certificates to use SAN (Subject Alternative Name) instead of the popular Common Name (CN), thus CN support has been removed.
If you're using self signed certificates (but not only!) having only CN defined, you get an error like this when calling a website using the self signed certificate:
```

## chrome浏览器F12的Security选项提示：
```
Subject Alternative Name Missing

The certificate for this site does not contain a Subject Alternative Name extension containing a domain name or IP address.


Certificate Error
There are issues with the site's certificate chain (net::ERR_CERT_COMMON_NAME_INVALID).

SHA-1 Certificate
The certificate chain for this site contains a certificate signed using SHA-1.
```

## 解决方案：
在利用openssl生成根证书的时候，加上以下参数
```
-sha256 -extfile v3.ext
```

其中v3.ext是一个文件，%%DOMAIN%%用来代替Common Name，即你的域名

v3.ext文件内容
```
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = %%DOMAIN%%
```


##  详细流程

### 1.创建CA根证书,createRootCA.sh

```
#!/usr/bin/env bash
mkdir ~/ssl/
openssl genrsa -des3 -out ~/ssl/rootCA.key 2048
openssl req -x509 -new -nodes -key ~/ssl/rootCA.key -sha256 -days 1024 -out ~/ssl/rootCA.pem
```

### 2.创建自签名的服务器证书createselfsignedcertificate.sh

```
#!/usr/bin/env bash
sudo openssl req -new -sha256 -nodes -out server.csr -newkey rsa:2048 -keyout server.key -config server.csr.cnf 

sudo openssl x509 -req -in server.csr -CA ~/ssl/rootCA.pem -CAkey ~/ssl/rootCA.key -CAcreateserial -out server.crt -days 500 -sha256 -extfile v3.ext
```

### 3.创建配置文件 server.csr.cnf，用于上步的`-config  server.csr.cnf`命令

```
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[dn]
C=US
ST=New York
L=Rochester
O=End Point
OU=Testing Domain
emailAddress=admin@myhost.com
CN = myhost.com
```

### 4.现在，我们需要创建一个v3.ext文件，以便创建一个X509 v3证书，而不是一个v1,如果不指定，以下将是默认值，其中DNS.1的值，为你自己域名的值

```
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
```

    先执行createRootCA.sh，然后执行reateselfsignedcertificate.sh生成自签名的证书，使用SAN和CN

    为了让浏览器信任你，需要将rootCA.pem导入浏览器受信任的根证书。之后使用server.key和server.crt在你的服务器配置

你也可以验证你的证书是否包含SAN信息：
```
openssl x509 -text -in server.crt -noout
```



## google原文摘录

```
Error: "Subject Alternative Name Missing" or NET::ERR_CERT_COMMON_NAME_INVALID or "Your connection is not private"
During Transport Layer Security (TLS) connections, Chrome browser checks to make sure the connection to the site is using a valid, trusted server certificate.

For Chrome 58 and later, only the subjectAlternativeName extension, not commonName, is used to match the domain name and site certificate. The certificate subject alternative name can be a domain name or IP address. If the certificate doesn’t have the correct subjectAlternativeName extension, users get a NET::ERR_CERT_COMMON_NAME_INVALID error letting them know that the connection isn’t private. If the certificate is missing a subjectAlternativeName extension, users see a warning in the Security panel in Chrome DevTools that lets them know the subject alternative name is missing.

Some public key infrastructures (PKIs), legacy systems, and older versions of network monitoring software use certificates without subjectAlternativeName extensions. If you’re having issues with any of these, contact the software vendor or administrator and ask them to generate a new certificate.

For Microsoft® Windows®, you can use the PowerShell Cmdlet New-SelfSignedCertificate and specify the DnsName parameter.

For OpenSSL, you can use the subjectAltName extension to specify the subject alternative name.

If needed, until Chrome 65, you can set the EnableCommonNameFallbackForLocalAnchors policy. This lets Chrome use the commonName of a certificate to match a hostname if the certificate is missing a subjectAlternativeName extension.
```


### 参考：
```
https://stackoverflow.com/questions/43665243/chrome-invalid-self-signed-ssl-cert-subject-alternative-name-missing
https://alexanderzeitler.com/articles/Fixing-Chrome-missing_subjectAltName-selfsigned-cert-openssl/
https://textslashplain.com/2017/03/10/chrome-deprecates-subject-cn-matching/
https://www.openssl.org/docs/man1.0.2/apps/x509v3_config.html#Subject-Alternative-Name
https://support.google.com/chrome/a/answer/7391219?hl=en
```