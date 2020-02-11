---
layout: post
title: ELK搭建日志分析系统
categories: elk
---


# ELK搭建日志分析系统

## Filebeat

轻量级数据收集引擎。基于原先 Logstash-fowarder 的源码改造出来。换句话说：Filebeat就是新版的 Logstash-fowarder，也会是 ELK Stack 在 Agent 的第一选择。

## Kafka 
数据缓冲队列。作为消息队列解耦了处理过程，同时提高了可扩展性。具有峰值处理能力，使用消息队列能够使关键组件顶住突发的访问压力，而不会因为突发的超负荷的请求而完全崩溃。

## Logstash
数据收集处理引擎。支持动态的从各种数据源搜集数据，并对数据进行过滤、分析、丰富、统一格式等操作，然后存储以供后续使用。

## Elasticsearch
分布式搜索引擎。具有高可伸缩、高可靠、易管理等特点。可以用于全文检索、结构化检索和分析，并能将这三者结合起来。Elasticsearch 基于 Lucene 开发，现在使用最广的开源搜索引擎之一，Wikipedia 、StackOverflow、Github 等都基于它来构建自己的搜索引擎。

## Kibana
可视化化平台。它能够搜索、展示存储在 Elasticsearch 中索引数据。使用它可以很方便的用图表、表格、地图展示和分析数据。

## 基于docker-composer快速搭建ELK日志系统
```
version: '2'

services:
  filebeat:
    # Need to override user so we can access the log files, and docker.sock
    user: root
    build:
      context: filebeat/
      args:
        ELK_VERSION: $ELK_VERSION
    volumes:
      - ./filebeat/config/filebeat.yml:/usr/share/filebeat/filebeat.yml:ro
      - ./filebeat/config/module/nginx/access/ingest/default.json:/usr/share/filebeat/module/nginx/access/ingest/default.json:ro
        #- ./filebeat/config/fields.yml:/usr/share/filebeat/fields.yml:ro
      - /data/online_logs/:/var/lib/docker/containers:ro
      - /var/run/docker.sock:/var/run/docker.sock:ro
    restart: always
    networks:
      - elk_elk
    command: ["--strict.perms=false"]

  elasticsearch:
    build:
      context: elasticsearch/
      args:
        ELK_VERSION: $ELK_VERSION
    volumes:
      - ./elasticsearch/config/elasticsearch.yml:/usr/share/elasticsearch/config/elasticsearch.yml:ro
      - ./elasticsearch/data:/usr/share/elasticsearch/data
    ports:
      - "9200:9200"
      - "9300:9300"
    environment:
      ES_JAVA_OPTS: "-Xmx2G -Xms2G"
      ELASTIC_PASSWORD: changeme
    shm_size: 2G
    restart: always
    ulimits:
      nproc: 65535
      nofile:
        soft: 65535
        hard: 65535
      memlock:
        soft: -1
        hard: -1

    networks:
      - elk

  logstash:
    build:
      context: logstash/
      args:
        ELK_VERSION: $ELK_VERSION
    volumes:
      - ./logstash/config/logstash.yml:/usr/share/logstash/config/logstash.yml:ro
      - ./logstash/pipeline:/usr/share/logstash/pipeline:ro
    ports:
      - "5000:5000"
      - "9600:9600"
    restart: always
    environment:
      LS_JAVA_OPTS: "-Xmx256m -Xms256m"
    networks:
      - elk
    depends_on:
      - elasticsearch

  kibana:
    build:
      context: kibana/
      args:
        ELK_VERSION: $ELK_VERSION
    volumes:
      - ./kibana/config/kibana.yml:/usr/share/kibana/config/kibana.yml:ro
      - ./kibana/data:/usr/share/kibana/data
    ports:
      - "5601:5601"
    restart: always
    networks:
      - elk
    depends_on:
      - elasticsearch

networks:

  elk:
    driver: bridge

```
### 效果图 
![pic](https://raw.githubusercontent.com/icoolworld/icoolworld.github.io/master/images/elk.jpg)
