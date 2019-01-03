---
layout: post
title:  "Exploring Your Cluster"
date: 2019-01-02
categories: ES
author: yogae
---

## The REST API

API를 사용하여 할 수 있는 기능

- cluster, node 그리고 index의 health, status, statistics를 확인 할 수 있습니다.
- Cluster, node 그리고 index data, metadata를 관리할 수 있습니다.
- CRUD 그리고 index로 검색이 가능합니다.
- Paging, sorting, filtering, scripting, aggregations 등의 고급 검색 기능을 수행할 수 있습니다.

##Cluster Health

cluster healch를 확인하기 위해서는 `_cat` API를 사용합니다.

``` http
GET /_cat/health?v

# curl
# curl -X GET "localhost:9200/_cat/health?v"
```

cluster health를 요청하면 green, yellow, 또는 red 중 하나의 상태 정보를 얻게됩니다.

- Green - 잘 작동하고 있음
- Yellow - 모든 data가 사용가능하지만 어떤 replica에는 아직 할당되지 않음
- Red - 어떤 data가 사용불 가능함 - 이용가능한 shard에 계속 search 요청을 할 수 있으나 할당 되지 않은 shard가 존재하므로 가능한 빨리 수정해야합니다.

cluster에 있는 node의 list를 받아올 수 있습니다.

```http
GET /_cat/nodes?v

# curl
# curl -X GET "localhost:9200/_cat/nodes?v"
```

지수를 확인할 수 있습니다.

```http
GET /_cat/indices?v

# curl
# curl -X GET "localhost:9200/_cat/indices?v"
```

## Create an Index

"customer"라는 index를 만들고 모든 index의 list를 부릅니다.

```http
PUT /customer?pretty
GET /_cat/indices?v

# curl
# curl -X PUT "localhost:9200/customer?pretty"
# curl -X GET "localhost:9200/_cat/indices?v"
```

`put` method를 사용하여 "customer"라는 index를 생성합니다. `pretty`를 끝에 추가하여 pretty-print JSON 응답을 얻을 수 있습니다.

customer index가 yellow health라는 것을 확인할 수 있을 것 입니다. 그 이유는 default로 Elasticsearch가 하나의 replica를 생성하기 때문입니다. 하나의 node만 운영하고 있기 때문에 다른 node를 추가하기 전에는 replica는 아직 할당될 수 없습니다. 두번째 node를 추가하면 health 상태는 green으로 변경될 것 입니다.

## Index and Query a Document

customer index에 id가 1인 customer docment를 생성합니다.

```http
PUT /customer/_doc/1?pretty
{
  "name": "John Doe"
}

# curl
# curl -X PUT "localhost:9200/customer/_doc/1?pretty" -H 'Content-Type: application/json' -d'
{
  "name": "John Doe"
}'
```

Elasticsearch에서는 document를 index하기 전에 명시적으로 index를 생성할 필요가 없습니다. Elasticsearch는 document를 index할 때 index가 존재하지 않으면 자동으로 index를 생성합니다.

document를 검색합니다.

```http
GET /customer/_doc/1?pretty

# curl
# curl -X GET "localhost:9200/customer/_doc/1?pretty"
```

## Delete an Index

index를 삭제합니다.

```http
DELETE /customer?pretty

# curl
# curl -X DELETE "localhost:9200/customer?pretty"
```

