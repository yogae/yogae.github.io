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

account_number가 20인 query 결과를 반환합니다.

```http
GET /bank/_search
{
  "query": { "match": { "account_number": 20 } }
}
```

address에 "mill"을 포함하고 있는 결과를 반환합니다. 

```http
GET /bank/_search
{
  "query": { "match": { "address": "mill" } }
}
```

address에 "mill" 또는 "lane"을 포함하고 있는 결과를 반환합니다.

```http
GET /bank/_search
{
  "query": { "match": { "address": "mill lane" } }
}
```

 "mill lane"을 포함하고 있는 결과를 반환합니다.

```http
GET /bank/_search
{
  "query": { "match_phrase": { "address": "mill lane" } }
}
```

`bool` query는 boolean logic을 사용하여 짧은 query를 결합하여 더 긴 query를 만들 수 있도록 합니다.

address에 "mill"과 "lane"을 포함하고 있는 결과를 반환합니다.

```http
GET /bank/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "address": "mill" } },
        { "match": { "address": "lane" } }
      ]
    }
  }
}
```

address에 "mill" 또는 "lane"을 포함하고 있는 결과를 반환합니다.

```http
GET /bank/_search
{
  "query": {
    "bool": {
      "should": [
        { "match": { "address": "mill" } },
        { "match": { "address": "lane" } }
      ]
    }
  }
}
```

address에 "mill"이나 "lane"을 포함하지 않는 결과를 반환합니다.

```http
GET /bank/_search
{
  "query": {
    "bool": {
      "must_not": [
        { "match": { "address": "mill" } },
        { "match": { "address": "lane" } }
      ]
    }
  }
}
```

`must`, `must_not`, `should` 를 결합하여 사용가능합니다.

```http
GET /bank/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "age": "40" } }
      ],
      "must_not": [
        { "match": { "state": "ID" } }
      ]
    }
  }
}
```

## Executing Filters

`range` query는 값의 범위를 정하여 document를 filter합니다. `range` query는 numeric 또는 date filtering에 많이 사용됩니다.

```http
GET /bank/_search
{
  "query": {
    "bool": {
      "must": { "match_all": {} },
      "filter": {
        "range": {
          "balance": {
            "gte": 20000,
            "lte": 30000
          }
        }
      }
    }
  }
}
```

## Executing Aggregations

aggregation은 data를 group화 하고 지표를 추출하는 기능을 제공합니다. 

state로 document를 그룹화합니다.(default: top 10, state로 내림차순 정렬)

```http
GET /bank/_search
{
  "size": 0,
  "aggs": {
    "group_by_state": {
      "terms": {
        "field": "state.keyword"
      }
    }
  }
}
```

hit에 대한 검색 결과를 받아오지 않기 위해 size = 0을 설정하였습니다. aggregation 결과의 정보만 보기 위하여 size = 0을 설정하였습니다. 

state로 그룹화하고 balance의 평균을 계산합니다. 

```http
GET /bank/_search
{
  "size": 0,
  "aggs": {
    "group_by_state": {
      "terms": {
        "field": "state.keyword"
      },
      "aggs": {
        "average_balance": {
          "avg": {
            "field": "balance"
          }
        }
      }
    }
  }
}
```

`group_by_state` aggregation안에 `average_balance` aggregation이 존재합니다. 

age가 20-30, 30-40, 40-50인 범위와 gender로 group을 만들고 그 결과를 age와 gebder별로 평균을 만드는 예제입니다.

```http
GET /bank/_search
{
  "size": 0,
  "aggs": {
    "group_by_age": {
      "range": {
        "field": "age",
        "ranges": [
          {
            "from": 20,
            "to": 30
          },
          {
            "from": 30,
            "to": 40
          },
          {
            "from": 40,
            "to": 50
          }
        ]
      },
      "aggs": {
        "group_by_gender": {
          "terms": {
            "field": "gender.keyword"
          },
          "aggs": {
            "average_balance": {
              "avg": {
                "field": "balance"
              }
            }
          }
        }
      }
    }
  }
}
```

