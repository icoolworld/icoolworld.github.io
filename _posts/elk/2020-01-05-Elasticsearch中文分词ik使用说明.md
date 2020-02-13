---
layout: post
title: Elasticsearch中文分词ik使用说明
categories: elk
---


# Elasticsearch中文分词ik使用说明 

> ElasticSearch 是一个基于 Lucene 的搜索服务器。它提供了一个分布式多用户能力的全文搜索引擎，基于 RESTful web 接口。Elasticsearch 是用 Java 开发的，并作为Apache许可条款下的开放源码发布，是当前流行的企业级搜索引擎。设计用于云计算中，能够达到实时搜索，稳定，可靠，快速，安装使用方便。

> Elasticsearch中，内置了很多分词器（analyzers）。

默认的中文分词是按单字拆分，无法较好的满足搜索需求，需要通过NLP进行中文分词

NLP常见的中文分词有：结巴分词、hanlp、ik-analyzer、NLPIR等

> 本文使用ik分词插件

### 关于停用词
> 无意义的词，如：的、是等等

### 自定义分词
> 对一些词汇无法识别，可以自定义词组，用来分词

### 安装ik

```
./bin/elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v6.3.0/elasticsearch-analysis-ik-7.1.0.zip
```
### 自定义分词|停用词

> vi /usr/share/elasticsearch/plugins/ik/config/IKAnalyzer.cfg.xml 

```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">
<properties>
	<comment>IK Analyzer 扩展配置</comment>
	<!--用户可以在这里配置自己的扩展字典 -->
    <entry key="ext_dict">custom/custom_dict.dic</entry>
	 <!--用户可以在这里配置自己的扩展停止词字典-->
    <entry key="ext_stopwords">custom/stop_words.dic</entry>
 	<!--用户可以在这里配置远程扩展字典 -->
	<!-- <entry key="remote_ext_dict">location</entry> -->
 	<!--用户可以在这里配置远程扩展停止词字典-->
	<!-- <entry key="remote_ext_stopwords">http://xxx.com/xxx.dic</entry> -->
</properties>
```

###　测试分词、查询等

> 创建索引

```
curl -XPUT http://localhost:9200/index
```

> 设置mapping

```
curl -XPOST http://localhost:9200/index/_mapping -H 'Content-Type:application/json' -d'
{
        "properties": {
            "content": {
                "type": "text",
                "analyzer": "ik_max_word",
                "search_analyzer": "ik_smart"
            }
        }

}'
```

> 测试分词(治愈系，是一个新词，无法被ik识别，手动配置了该词后可以识别了)

```
curl -XPOST http://localhost:9200/index/_analyze -H 'Content-Type:application/json' -d'
{
    "text": "治愈系漫画很好看",
    "analyzer": "ik_max_word"
}'
```

> 分词结果如下：看到　治愈、治愈系都被成功识别, 而且无意义的停用词，没有出现在结果中

```
{
    "tokens": [
        {
            "token": "治愈系",
            "start_offset": 0,
            "end_offset": 3,
            "type": "CN_WORD",
            "position": 0
        },
        {
            "token": "治愈",
            "start_offset": 0,
            "end_offset": 2,
            "type": "CN_WORD",
            "position": 1
        },
        {
            "token": "系",
            "start_offset": 2,
            "end_offset": 3,
            "type": "CN_CHAR",
            "position": 2
        },
        {
            "token": "漫画",
            "start_offset": 3,
            "end_offset": 5,
            "type": "CN_WORD",
            "position": 3
        },
        {
            "token": "很好",
            "start_offset": 5,
            "end_offset": 7,
            "type": "CN_WORD",
            "position": 4
        },
        {
            "token": "好看",
            "start_offset": 6,
            "end_offset": 8,
            "type": "CN_WORD",
            "position": 5
        }
    ]
}
```

> 增加一些doc

```
curl -XPOST http://localhost:9200/index/_create/1 -H 'Content-Type:application/json' -d'
{"content":"治愈系漫画很好看"}
'
curl -XPOST http://localhost:9200/index/_create/2 -H 'Content-Type:application/json' -d'
{"content":"治愈系是指电视上演出的女性艺人中能让人感到平静,治愈,舒畅的人,以及她们的动作"}
'
```

> 查询(治愈) 

```
curl -XPOST http://localhost:9200/index/_search  -H 'Content-Type:application/json' -d'
{
    "query" : { "match" : { "content" : "治愈" }},
    "highlight" : {
        "pre_tags" : ["<tag1>", "<tag2>"],
        "post_tags" : ["</tag1>", "</tag2>"],
        "fields" : {
            "content" : {}
        }
    }
}
'
```
> 查询结果

```
{
    "took": 2,
    "timed_out": false,
    "_shards": {
        "total": 1,
        "successful": 1,
        "skipped": 0,
        "failed": 0
    },
    "hits": {
        "total": {
            "value": 2,
            "relation": "eq"
        },
        "max_score": 0.22667006,
        "hits": [
            {
                "_index": "index",
                "_type": "_doc",
                "_id": "2KD7PXABbGQ4CYiTeFFq",
                "_score": 0.22667006,
                "_source": {
                    "content": "治愈系漫画很好看"
                },
                "highlight": {
                    "content": [
                        "<tag1>治愈</tag1>系漫画很好看"
                    ]
                }
            },
            {
                "_index": "index",
                "_type": "_doc",
                "_id": "56D7PXABbGQ4CYiTo1Eb",
                "_score": 0.22096938,
                "_source": {
                    "content": "治愈系是指电视上演出的女性艺人中能让人感到平静,治愈,舒畅的人,以及她们的动作"
                },
                "highlight": {
                    "content": [
                        "<tag1>治愈</tag1>系是指电视上演出的女性艺人中能让人感到平静,<tag1>治愈</tag1>,舒畅的人,以及她们的动作"
                    ]
                }
            }
        ]
    }
}
```
> 查询(治愈系)

```
curl -XPOST http://localhost:9200/index/_search  -H 'Content-Type:application/json' -d'
{
    "query" : { "match" : { "content" : "治愈系" }},
    "highlight" : {
        "pre_tags" : ["<tag1>", "<tag2>"],
        "post_tags" : ["</tag1>", "</tag2>"],
        "fields" : {
            "content" : {}
        }
    }
}
'
```

> 查询结果

```
{
    "took": 2,
    "timed_out": false,
    "_shards": {
        "total": 1,
        "successful": 1,
        "skipped": 0,
        "failed": 0
    },
    "hits": {
        "total": {
            "value": 2,
            "relation": "eq"
        },
        "max_score": 0.22667006,
        "hits": [
            {
                "_index": "index",
                "_type": "_doc",
                "_id": "2KD7PXABbGQ4CYiTeFFq",
                "_score": 0.22667006,
                "_source": {
                    "content": "治愈系漫画很好看"
                },
                "highlight": {
                    "content": [
                        "<tag1>治愈系</tag1>漫画很好看"
                    ]
                }
            },
            {
                "_index": "index",
                "_type": "_doc",
                "_id": "56D7PXABbGQ4CYiTo1Eb",
                "_score": 0.22096938,
                "_source": {
                    "content": "治愈系是指电视上演出的女性艺人中能让人感到平静,治愈,舒畅的人,以及她们的动作"
                },
                "highlight": {
                    "content": [
                        "<tag1>治愈系</tag1>是指电视上演出的女性艺人中能让人感到平静,<tag1>治愈</tag1>,舒畅的人,以及她们的动作"
                    ]
                }
            }
        ]
    }
}
```
