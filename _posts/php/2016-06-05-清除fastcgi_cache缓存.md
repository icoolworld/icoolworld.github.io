---
layout: post
title: 清除fastcgi_cache缓存
categories: php
---


> 对于使用了fastcgi_cache的URL，可以使用以下方法来清除fastcgi_cache缓存
```
<?php
$cache_path = '/etc/nginx/cache/';
$url = parse_url($_POST['url']);
if(!$url)
{
    echo 'Invalid URL entered';
    die();
}
$scheme = $url['scheme'];
$host = $url['host'];
$requesturi = $url['path'];
$hash = md5($scheme.'GET'.$host.$requesturi);
var_dump(unlink($cache_path . substr($hash, -1) . '/' . substr($hash,-3,2) . '/' . $hash));
?>
```