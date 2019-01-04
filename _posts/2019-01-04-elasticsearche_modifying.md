---
layout: post
title:  "Modifying Your Data"
date: 2019-01-04
categories: ES
author: yogae
---

Elasticsearch는 near real time으로 data를 조작하고 검색할 수 있습니다. SQL과 같은 다른 platform과의 중요한 차이는 transaction이 완료된 이후 바로 사용가능하다는 것 입니다. 

## Indexing/Replacing Documents

다른 document로 같은 id에 put 명령을 실행하면 Elasticsearch는 새로운 document로 대체할 것 입니다. 

indexing할 때 ID part는 optional입니다. 특정 ID를 정하지 않는다면 Elasticsearch는 random한 ID를 생성하고 documnet를 index할 것입니다. 

```http
POST /customer/_doc?pretty
{
  "name": "Jane Doe"
}
```

특정 ID를 지정하지 않을 때는 `PUT` 대신 `POST`를 사용합니다.

## Updaing Documents

Elasticsearch는 이전 document를 삭제하고 새로운 document를 index합니다.

```http
POST /customer/_doc/1/_update?pretty
{
  "doc": { "name": "Jane Doe" }
}
```

```http
POST /customer/_doc/1/_update?pretty
{
  "doc": { "name": "Jane Doe", "age": 20 }
}
```

```http
POST /customer/_doc/1/_update?pretty
{
  "script" : "ctx._source.age += 5"
}
```

`ctx._source`는 update할 현재 document를 말합니다. Elasticsearch는 여러 document를 한번에 update할 수 있는 기능을 제공합니다. [`docs-update-by-query` API](https://www.elastic.co/guide/en/elasticsearch/reference/6.5/docs-update-by-query.html)

## Deleting Documents

```http
DELETE /customer/_doc/2?pretty
```

query에 검색하여 모든 document를 제거하기 위해서는  [`_delete_by_query` API](https://www.elastic.co/guide/en/elasticsearch/reference/6.5/docs-delete-by-query.html) 를 사용합니다. 

## Batch Processing

