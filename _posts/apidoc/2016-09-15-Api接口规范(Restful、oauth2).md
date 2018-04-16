---
layout: post
title: Api接口规范(Restful、oauth2)
categories: apidoc
---

## 请求-响应规范

## 概要：
通用Api基于Restful的设计原则，uri资源的设计，使用基于名词(复数形式)设计，而非动词。如
```
GET /articles - 获取文章列表
GET /articles/12 - 获取文章内容 #12
POST /articles - 创建一篇文章内容
PUT /articles/12 - 更新文章内容 #12
PATCH /articles/12 - 部分更新文章内容 #12
DELETE /articles/12 - 删除文章内容 #12
```
所有的请求和响应都将基于JSON encoded,包括error输出


## 关联关系处理
通常一个资源，可能与另外的资源相关联，如文章可能有很多的评论内容，这些评论内容，可通过/articles为入口，来获取相应在评论内容
```
GET /articles/12/comments - 获取文章12的评论列表 #12
GET /articles/12/comments/5 - 获取文章ID为12的评论ID为5的内容 
POST /articles/12/comments -给文章ID为12，添加评论 #12
PUT /articles/12/comments/5 - 修改文章ID12,评论5的内容 
PATCH /articles/12/comments/5 - 部分更新评论ID5
DELETE /articles/12/comments/5 - 删除评论文章ID为12，评论ID为5的内容
```

## 一些操作，用CRUD来表示并不太合适，如何定义？
有一些操作，如激活用户、点赞、搜索等，CRUD似乎不太能代表其含义，该类操作比较模糊的、有许多方法：  

1、重组该操作，使之看起来像是资源的一个字段，如激活用户操作。可通过传入一个active字段，通过PATCH来修改操作 /api/users
```
PATCH /api/users
```
2、也可以把该操作当成一个子资源，如给文章点赞
```
点赞
PUT /api/articles/star
取消点赞
DELETE /api/articles/star
```
3、有时候一种操作、不能完全对应哪个RESTful的资源，如一个搜索操作，需要搜索所有的相关内容，包括图片、视频、文章等。此时可以使用/search来代表如
```
/api/search?q=三国
```



## Authentication 验证授权
调用所有的Api资源，都要经过oauth2授权验证。在调用Api接口时，将获取到的access_token，放入Header头中，如下示例：（获取access_token信息，请查看下方TOKEN调用说明）。
```
Authorization: Bearer a14afef0f66fcffce3e0fcd2e34f6ff4

curl -H "Authorization: Bearer a14afef0f66fcffce3e0fcd2e34f6ff4" "https://api.qt.baidu.com/v1/user/~me" 

也可以参数形式传递
curl "https://api.qt.baidu.com/v1/user/~me?access_token=OAUTH-TOKEN
```

## Requests 请求
所有的POST,PUT,PATCH请求，将是JSON encoded的，必需设置content type 为application/json，否则api将会返回415 Unsupported Media Type status code.
```
Content-Type: application/json

$ curl -H "Authorization: Bearer  https://api.qt.baidu.com/api/v1/users/543abc \
    -X PATCH \
    -H "Authorization: Bearer a14afef0f66fcffce3e0fcd2e34f6ff4"
    -H 'Content-Type: application/json' \
    -d '{"first_name":"John"}'
```

## Responses 响应
目前所有的服务端将返回JSON encoded的内容。对于空字段，将会返回null,如果该字段是一个数组，则返回空数组[]
```
一个单独的资源，将以JSON object对象方式返回
{
  "field1": "value",
  "field2": true,
  "field3": null
}
集合资源，将以JSON 数组方式返回
[
  {
    "field1": "value",
    "field2": true,
    "field3": []
  },
  {
    "field1": "another value",
    "field2": false,
    "field3": []
  }
]
```



## HTTP Verbs HTTP请求方式
使用标准的HTTP动词来表示一个请求的意图  
GET - 用来检索一个资源或资源的集合  
POST - 用来创建一个资源  
PATCH - 用来修改一个资源(部分修改)  
PUT - 用来修改一个资源(完整的实体)
DELETE - 用来删除一个资源  

2个比较少用的HTTP方式
HEAD – 检索返回资源的元信息，通过header返回，如hash,修改时间等
OPTIONS – 查询资源允许的操作

## HTTP请求方式兼容
如果你使用的客户端，不支持PUT,PATCH,DELETE,则发送一个POST请求，通过header增加X-HTTP-Method-Override来指定需要进行的操作
```
$ curl -H "Authorization: Bearer  https://api.qt.baidu.com/api/v1/users/543abc \
    -X POST \
    -H "X-HTTP-Method-Override: DELETE"
```


## HTTP Status Codes 返回 HTTP 状态响应码说明

http Success codes: 成功状态码
```
200 OK - 请求成功(GET,PUT,PATCH,或DELETE,或者对于POST操作，但不是创建资源的操作)
201 Created - 对于POST操作，资源创建成功
204 No Content - 请求成功，但是无响应内容，如一些DELETE操作
```

http Error codes:错误请求
```
400 Bad Request - 无效的请求,如body无法解析等
401 Unauthorized - 没有 authentication 验证信息，或者无效
403 Forbidden - 授权已经通过，但是无该资源的访问权限
404 Not Found - 访问一个不存在的资源
415 Unsupported Media Type - 不支持的content-type类型。POST/PUT/PATCH request 请求，其header的content-type设置为 application/json 
422 Unprocessable Entry - 创建或修改一个资源的时候，出错提示信息
429 Too Many Requests - Request rejected due to rate limiting
500, 501, 502, 503, etc - An internal server error occured
```

## API版本化
关于Api的版本，如V1.0,V2.0版本，从理论上，放在header上，也可以放在url中，如api/v1/，目前先设计成根据Url来区分api的版本

## Errors 错误提示

所有类似400的错误(400, 401, 403, etc) 将会以json形式返回错误提示,如
{
   "error" : "invalid_request",
   "error_description": "无效的请求"
}

## Validation Errors验证错误

在 POST/PUT/PATCH 请求时，会有一些验证逻错误提示，如字段长度不足等，对此类提示，http状态将返回422 Unprocessable Entry，响应body将返回JSON encoded格式
```
{
  "message": "Validation Failed",
  "errors": [
    {
      "message": "Field is not valid"
    },
    {
      "message": "OtherField is already used"
    }
  ]
}
```

## Embedding 嵌入相关内容
有时需要返某资源的相关信息，如文章内容，同时需要嵌入返回相关的文章等，可以通过embed参数来控制
```
GET /api/v1/articles/543abc?embed=labels

{
  "id": "543add",
  "type": "email",
  "label_ids": [ "123abc", "234bcd" ],
  "labels": [
    {
      "id": "123abc",
      "name": "Refund"
    },
    {
      "id": "234bcd",
      "name": "VIP"
    }
  ],
  ... other ticket fields ...
}
```

## HATEOAS

## Counting 资源计数
可以通过count=true来获取资源集合的统计数量信息(全部)，统计信息会通过header返回，如
```
GET /api/v1/articles?count=true

200 OK
Total-Count: 135
Rate-Limit-Limit: 100
Rate-Limit-Remaining: 98
Rate-Limit-Used: 2
Rate-Limit-Reset: 20
Content-Type: application/json

[
  ... results ... 
]
```


## Enveloping 包裹
如果你的http客户端对于获取http状态码，或者headers头信息比较困难，提供一种兼容性解决方案，使用envelope=true请求参数，api将会一直返回http 200状态码，真实的http状态码、headers头信息、响应内容将会包含在body中如

```
GET /api/v1/users/does-not-exist?envelope=true

200 OK
{
  "status": 404,
  "headers": {
    "Rate-Limit-Limit": 100,
    "Rate-Limit-Remaining": 50,
    "Rate-Limit-Used": 0,
    "Rate-Limit-Reset": 25
  },
  "response": {
    "message": "Not Found"
  }
}
```


## Pagination 分页
部分api资源支持分页功能，使用page参数表示当前页码、per_page表示每页显示数量，(如果不传per_page参数，默认由服务端控制显示数量)如
```
GET /api/v1/articles?per_page=15&page=2
```

## Field Filtering 返回字段限制
可以通过fields字段来限制你想要返回的字段，多个字段，通过逗号分开(如果不传该参数，默认由服务端控制返回字段)
如
```
GET /api/v1/users?fields=id,first_name
```

## Filter、Searching 过滤、搜索查询
如只想查询状态为正常的文章，可以通过state=open来查询，有时候一些基本的过滤，不足以满足过滤要求,需要一些搜索功能，可以使用q关键词，如
```
GET /articles?q=精品&state=open&sort=-priority,created_at
```

## Sorting 排序
可以通过sort参数进行排序(如果不传该参数，默认由服务端控制排序)，如
```
GET /api/v1/articles?sort=-updated_at
```

## Referer 引用参考
```
http://restful-api-design.readthedocs.io/en/latest/
https://www.thoughtworks.com/insights/blog/rest-api-design-resource-modeling
http://blog.mwaysolutions.com/2014/06/05/10-best-practices-for-better-restful-api/
https://codeplanet.io/principles-good-restful-api-design/
http://dev.enchant.com/api/v1
http://www.vinaysahni.com/best-practices-for-a-pragmatic-restful-api
https://developer.github.com/v3/
```
