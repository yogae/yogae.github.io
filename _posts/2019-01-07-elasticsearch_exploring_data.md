---
layout: post
title:  "Exploring Your Data"
date: 2019-01-07
categories: ES
author: yogae
---

## Sample Dataset
```json
# `bank` index
{
    "account_number": 0,
    "balance": 16623,
    "firstname": "Bradshaw",
    "lastname": "Mckenzie",
    "age": 29,
    "gender": "F",
    "address": "244 Columbus Place",
    "employer": "Euron",
    "email": "bradshawmckenzie@euron.com",
    "city": "Hobucken",
    "state": "CO"
}
```

document 삽입 curl 명령어입니다.

```http
curl -X POST "localhost:9200/bank/doc/bulk?pretty&refresh" -H 'Content-Type: application/json' -d'
{
    "account_number": 0,
    "balance": 16623,
    "firstname": "Bradshaw",
    "lastname": "Mckenzie",
    "age": 29,
    "gender": "F",
    "address": "244 Columbus Place",
    "employer": "Euron",
    "email": "bradshawmckenzie@euron.com",
    "city": "Hobucken",
    "state": "CO"
}
'
```



##  The Search API

검색하는 방법은 2가지가 있습니다.  검색 parameter를 REST request URI에 보내는 방법과 REST request body에 보내는 방법이 있습니다. 

검색을 위한 REST API은 `_search` endpoint를 통하여 접근가능합니다.

```http
GET /bank/_search?q=*&sort=account_number:asc&pretty
```

request body를 사용하는 방법입니다.

```http
GET /bank/_search
{
  "query": { "match_all": {} },
  "sort": [
    { "account_number": "asc" }
  ]
}
```

response에서는 아래의 field를 확인할 수 있습니다.

- `took` – time in milliseconds for Elasticsearch to execute the search
- `timed_out` – tells us if the search timed out or not
- `_shards` – tells us how many shards were searched, as well as a count of the successful/failed searched shards
- `hits` – search results
- `hits.total` – total number of documents matching our search criteria
- `hits.hits` – actual array of search results (defaults to first 10 documents)
- `hits.sort` - sort key for results (missing if sorting by score)
- `hits._score` and `max_score` - ignore these fields for now

일단 검색 결과를 다시 얻으면 Elasticsearch는 요청에 대해 완전히 완료되고 결과에 서버 측 resource나 open cursors를 유지하지 않는다는 것을 이해하는 것이 중요합니다.

## Introducing the Query Language

```http
GET /bank/_search
{
  "query": { "match_all": {} }
}
```

`query` 는 query 정의에 대하여 말해주고 `match_all` 는 전체 document를 query할 때 사용합니다.

```http
GET /bank/_search
{
  "query": { "match_all": {} },
  "from": 10,
  "size": 10,
  "sort": { "balance": { "order": "desc" } }
}
```

`size` 얼마나 많은 document를 반환할 것인지를 나타냅니다. default는 10입니다.

`from` 는 docment의 시작할 index을 나타냅니다. 위의 예시에서는 10번째 document 부터 19번째 document를 반환하게 됩니다.

`sort` document의 정렬 기준을 나타냅니다.

```http
GET /bank/_search
{
  "query": { "match_all": {} },
  "_source": ["account_number", "balance"]
}
```

`_source` 는 전체 document를 반환받고 싶지 않다면 `_source` 에 field 명을 추가하여 필요한 field 정보만 받아올 수 있습니다.







