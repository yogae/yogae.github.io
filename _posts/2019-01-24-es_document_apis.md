---
layout: post
title:  "Document APIs"
date: 2019-01-24
categories: ES
author: yogae
---

## Index API

index api JSON document를 특정 index에 추가하거나 업데이트합니다.

```http
PUT twitter/_doc/1
{
    "user" : "kimchy",
    "post_date" : "2009-11-15T14:12:12",
    "message" : "trying out Elasticsearch"
}

{
    "_shards" : {
        "total" : 2, # shard 복제(primary and replica shards) 수
        "failed" : 0, # 실패한 shard 복제 수
        "successful" : 2 # 성공한 shard 복제 수
    },
    "_index" : "twitter",
    "_type" : "_doc",
    "_id" : "1",
    "_version" : 1,
    "_seq_no" : 0,
    "_primary_term" : 1,
    "result" : "created"
}
```

### Automatic Index Creation

index operation은 index가 생성되어 있지않으면 자동으로 index를 생성합니다. 또한 동적인 type을 생성합니다. 그 동적으로 생성된 type은 유연하고 shema-free 합니다.

### Versioning

각각의 index된 document는 version number가 주어집니다. index API request에 response의 한 부분으로 version number가 반환됩니다.

```http
PUT twitter/_doc/1?version=2
{
    "message" : "elasticsearch now has versioning support, double cool!"
}
```

### Operation Type

 index operation은 create operation을 강제하기 위해  `op_type` 을 사용할 수 있습니다. create를 사용할 때 이미 index가 존재하면 index operation은 실패합니다.

```http
PUT twitter/_doc/1?op_type=create
{
    "user" : "kimchy",
    "post_date" : "2009-11-15T14:12:12",
    "message" : "trying out Elasticsearch"
}
```

### Routing

shard 배치 또는 routing은 문서의 id 값의 해시를 사용하여 제어됩니다. 좀 더 명확한 제어를 위해 라우터가 사용하는 해시 함수에 입력된 값을 `routing` 매개 변수를 사용하여 직접 지정할 수 있습니다.

```http
POST twitter/_doc?routing=kimchy
{
    "user" : "kimchy",
    "post_date" : "2009-11-15T14:12:12",
    "message" : "trying out Elasticsearch"
}
```

### Wait For Active Shards

write의 탄력성을 향상시키기 위해 index operation은 특정 수의 shard 복사본이 끝나는 것을 기다리는 설정을 할 수 있습니다. 설정한 수의 shard 복사본이 사용가능하지 않다면 설정한 수의 shard 복사본이 사용가능해 지거나 timeout이 발생할 때까지 write operaion을 대기하고 다시 시도합니다. default로 write operation은 오직 primary shard가 사용가능할 때까지만 대기합니다.

### Timeout

default로 index operation은 primary shard가 이용가능해지는 것을 기다리거나 1분까지 기다립니다. `timeout` parameter를 사용하여 timeout시간을 설정할 수 있습니다.

```http
PUT twitter/_doc/1?timeout=5m
{
    "user" : "kimchy",
    "post_date" : "2009-11-15T14:12:12",
    "message" : "trying out Elasticsearch"
}
```

## Get API

### Realtime

### Check existentce

`HEAD` method를 사용하여 document의 존재 여부를 확인할 수 있습니다.

```js
HEAD twitter/_doc/1/_source
```

### Source filtering

Get operation은 `stored_fields` parameter가 사용되거나 `_source` field를 disable 시키지 않으면 default로 `_source` field의 contents를 반환합니다. `_source` parameter를 사용하여 `_source` field를 반환되는 값에서 제외시킬 수 있습니다.

```http
GET twitter/_doc/0?_source=false
```

`_source_includes` & `_source_excludes` parameters를 사용하여 필요한 부분만 추가하거나 filter할 수 있습니다.

```http
GET twitter/_doc/0?_source_includes=*.id&_source_excludes=entities
```

```http
GET twitter/_doc/0?_source=*.id,retweeted
```

`/{index}/{type}/{id}/_source`  endpoint를 사용하여 document의 `_source` field만 반환할 수 있습니다.

```js
GET twitter/_doc/1/_source
```

### Stored Fields

`stored_fields` field를 추가하여 stored fields의 집합만 반환할 수 있습니다. 요청한 field가 저장되어 있지 않으면 무시됩니다. 

```http
PUT twitter
{
   "mappings": {
      "_doc": {
         "properties": {
            "counter": {
               "type": "integer",
               "store": false
            },
            "tags": {
               "type": "keyword",
               "store": true
            }
         }
      }
   }
}
```

document 생성:

```http
PUT twitter/_doc/1
{
    "counter" : 1,
    "tags" : ["red"]
}
```

stored_fields parameters를 사용한 get request:

```http
GET twitter/_doc/1?stored_fields=tags,counter
```

응답:

```json

{
   "_index": "twitter",
   "_type": "_doc",
   "_id": "1",
   "_version": 1,
   "_seq_no" : 22,
   "_primary_term" : 1,
   "found": true,
   "fields": {
      "tags": [
         "red"
      ]
   }
}
```

### Routing

### Refresh

### Distributed

### Version support

## Delete API

### Optimistic concurrency control

Delete operations은 선택적으로 수행 할 수 있고 문서의 마지막 수정에 `if_seq_no` 및` if_primary_term` parameters로 지정된 일련 번호 및 기본 용어가 지정된 경우에만 수행될 수 있습니다.

> 참고: [Optimistic concurrency control](https://www.elastic.co/guide/en/elasticsearch/reference/current/optimistic-concurrency-control.html)

### Versioning

### Routing

### Automatic index creation

### Distributed

### Wait For Active Shards

### Refresh

### Timeout

## Delete By Query API

`_delete_by_query` 은 query에 일치되는 모든 document를 제거합니다.

```http
POST twitter/_delete_by_query
{
  "query": { 
    "match": {
      "message": "some message"
    }
  }
}
```

> search API처럼 query는 `query` key에 값을 넣어야합니다. `q` parameter를 사용할 수 있습니다.

```json
# return
{
  "took" : 147, # The number of milliseconds from start to end of the whole operation.
  "timed_out": false, # This flag is set to true if any of the requests executed during the delete by query execution has timed out.
  "deleted": 119, # The number of documents that were successfully deleted.
  "batches": 1, # The number of scroll responses pulled back by the delete by query.
  "version_conflicts": 0, # The number of version conflicts that the delete by query hit.
  "noops": 0, # This field is always equal to zero for delete by query. It only exists so that delete by query
  "retries": { # The number of retries attempted by delete by query.
    "bulk": 0, 
    "search": 0
  },
  "throttled_millis": 0, # Number of milliseconds the request slept to conform to requests_per_second.
  "requests_per_second": -1.0, # The number of requests per second effectively executed during the delete by query.
  "throttled_until_millis": 0, # This field should always be equal to zero in a _delete_by_query response. It only has meaning when using the Task API
  "total": 119, # The number of documents that were successfully processed.
  "failures" : [ ] # Array of failures if there were any unrecoverable errors during the process.
}
```

`internal` versioning을 사용하여  `_delete_by_query`를 시작하고 찾은 document를 제거할 때  index의 snapshot을 사용합니다. 이것은 version 충돌이 발생할 수 있다는 것을 의미합니다.(snapshot을 만드는 시간과 delete request가 처리되는 시간사이에 document가 변경되었을 때 충돌이 발생합니다.)

`_delete_by_query` 요청을 실행하는 동안 multiple search request(delete되는 document를 찾는 request)는 순자적으로 실행됩니다. document의 batch가 발견되면 관련된 bulk request는 모든 document를 삭제하기 위해 실행됩니다.  search나 bulk request가 reject된 경우 `_delete_by_query` 은 reject된 request를 기본정책(exponential back off 으로 10번 까지 재시도)으로 다시 시도합니다. 최대 재시도 제한에 도달하면 `_delete_by_query` 는 중단되고 `failures` 에 모든 실패가 반환됩니다. 중단된 process는 rolled back되지 않습니다. 

Version 충돌에 대하여 중단되는 것보다 계산하기를 원한다면 url에 `conflicts=proceed` 을 추가하거나 request body에 `"conflicts": "proceed"` 를 추가해야합니다.

```http
POST twitter/_doc/_delete_by_query?conflicts=proceed
{
  "query": {
    "match_all": {}
  }
}
```

### Slicing

Delete-by-query는 수평적인 deleting 처리를 위하여 Sliced Scroll을 지원합니다. parallelization은 효율설을 향상시키고 request를 작은 단위로 분리하는 방법을 제공합니다.

#### Manually slicing

```http
POST twitter/_delete_by_query
{
  "slice": {
    "id": 0,
    "max": 2
  },
  "query": {
    "range": {
      "likes": {
        "lt": 10
      }
    }
  }
}
```

```http
POST twitter/_delete_by_query
{
  "slice": {
    "id": 1,
    "max": 2
  },
  "query": {
    "range": {
      "likes": {
        "lt": 10
      }
    }
  }
}
```

#### Automatic slicing

```http
POST twitter/_delete_by_query?refresh&slices=5
{
  "query": {
    "range": {
      "likes": {
        "lt": 10
      }
    }
  }
}
```

slices에 auto를 설정하면 사용할 slices의 개수를 Elasticsearc가 선택합니다. shard 별로 하나의 slice를 사용하게 됩니다. 여러 soruce indices가 있다면 slices의 수를 index에서 사용하는 shard의 가장 작은 개수로 선택하게 됩니다.

> Query performance is most efficient when the number of `slices` is equal to the number of shards in the index. If that number is large, (for example, 500) choose a lower number as too many `slices`will hurt performance. Setting `slices` higher than the number of shards generally does not improve efficiency and adds overhead.

## Update API

get과 reindex를 하는 동안 update가 발생하지 않도록 versioning을 사용합니다.

### Scriped Updates

counter를 증가시키는 script 예시

```http
POST test/_doc/1/_update
{
    "script" : {
        "source": "ctx._source.counter += params.count",
        "lang": "painless",
        "params" : {
            "count" : 4
        }
    }
}
```

tag list에 tag 추가 예시

```http
POST test/_doc/1/_update
{
    "script" : {
        "source": "ctx._source.tags.add(params.tag)",
        "lang": "painless",
        "params" : {
            "tag" : "blue"
        }
    }
}
```

tag list에서 tag를 삭제하는 예시

```http
POST test/_doc/1/_update
{
    "script" : {
        "source": "if (ctx._source.tags.contains(params.tag)) { ctx._source.tags.remove(ctx._source.tags.indexOf(params.tag)) }",
        "lang": "painless",
        "params" : {
            "tag" : "blue"
        }
    }
}
```

`ctx` map으로 접근할 수 있는 variable:

- `_source`
- `_index`
-  `_type`
-  `_id`
-  `_version`
-  `_routing` 
-  `_now`

새로운 field 추가, 삭제 예시

```http
POST test/_doc/1/_update
{
    "script" : "ctx._source.new_field = 'value_of_new_field'"
}
```

```http
POST test/_doc/1/_update
{
    "script" : "ctx._source.remove('new_field')"
}
```

### Updates with a partial document

존재하는 document에 merge(simple recursive merge, inner merging of objects, replacing core "keys/values" and arrays)됩니다. 존재하는 docment를 완전히 대체하려면 index API를 사용해야합니다.

```http
POST test/_doc/1/_update
{
    "doc" : {
        "name" : "new_name"
    }
}
```

### Detecting noop updates

default로 변화되는 것이 감지되지 않으면 update request는 무시되고 "result":"noop"을 반환합니다.

```json
# response
{
   "_shards": {
        "total": 0,
        "successful": 0,
        "failed": 0
   },
   "_index": "test",
   "_type": "_doc",
   "_id": "1",
   "_version": 7,
   "result": "noop"
}
```

"detect_noop": false를 설정하여 disable 시킬 수 있습니다.

```http
POST test/_doc/1/_update
{
    "doc" : {
        "name" : "new_name"
    },
    "detect_noop": false
}
```

### Upserts

document가 존재하지 않으면 upsert 요소의 contents를 새로운 document로 삽입할 수 있습니다. document가 존재하면  대신에 script를 실행합니다.

```http
POST test/_doc/1/_update
{
    "script" : {
        "source": "ctx._source.counter += params.count",
        "lang": "painless",
        "params" : {
            "count" : 4
        }
    },
    "upsert" : {
        "counter" : 1
    }
}
```

#### scripted_upsert

document의 유무와 상관없이 script를 실행하려면 scripted_upsert를 true로 설정해야합니다.

```http
POST sessions/session/dh3sgudg8gsrgl/_update
{
    "scripted_upsert":true,
    "script" : {
        "id": "my_web_session_summariser",
        "params" : {
            "pageViewEvent" : {
                "url":"foo.com/bar",
                "response":404,
                "time":"2014-01-01 12:32"
            }
        }
    },
    "upsert" : {}
}
```

#### doc_as_upsert

doc_as_upsert를 true로 설정하면 doc의 contents를 upsert의 값으로 사용합니다.

```http
POST test/_doc/1/_update
{
    "doc" : {
        "name" : "new_name"
    },
    "doc_as_upsert" : true
}
```

### Parameters

| `retry_on_conflict`      | In between the get and indexing phases of the update, it is possible that another process might have already updated the same document. By default, the update will fail with a version conflict exception. The `retry_on_conflict` parameter controls how many times to retry the update before finally throwing an exception. |
| ------------------------ | ------------------------------------------------------------ |
| `routing`                | Routing is used to route the update request to the right shard and sets the routing for the upsert request if the document being updated doesn’t exist. Can’t be used to update the routing of an existing document. |
| `timeout`                | Timeout waiting for a shard to become available.             |
| `wait_for_active_shards` | The number of shard copies required to be active before proceeding with the update operation. See [here](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-index_.html#index-wait-for-active-shards) for details. |
| `refresh`                | Control when the changes made by this request are visible to search. See[*?refresh*](https://www.elastic.co/guide/en/elasticsearch/reference/current/docs-refresh.html). |
| `_source`                | Allows to control if and how the updated source should be returned in the response. By default the updated source is not returned. See [`source filtering`](https://www.elastic.co/guide/en/elasticsearch/reference/current/search-request-source-filtering.html) for details. |
| `version`                | The update API uses the Elasticsearch’s versioning support internally to make sure the document doesn’t change during the update. You can use the `version` parameter to specify that the document should only be updated if its version matches the one specified. |

## Update By Query API

```http
POST twitter/_update_by_query?conflicts=proceed
```

Delete By Query API와 비슷하게 동작함

## Multi Get API

Muti Get API는 Index, type(optional)과 id를 기반으로 여러 document를 받을 수 있습니다. 응답에는 multi-get request에 대응하여 가져온 모든 document를 포함합니다. 성공한 응답의 구조는 get API에서 제공되는 document의 구조와 유사합니다.

 ```http
GET /_mget
{
    "docs" : [
        {
            "_index" : "test",
            "_type" : "_doc",
            "_id" : "1"
        },
        {
            "_index" : "test",
            "_type" : "_doc",
            "_id" : "2"
        }
    ]
}
 ```

`mget` endpoint는 index에 대하여 사용할 수 있습니다.

```http
GET /test/_mget
{
    "docs" : [
        {
            "_type" : "_doc",
            "_id" : "1"
        },
        {
            "_type" : "_doc",
            "_id" : "2"
        }
    ]
}
```

`mget` endpoint는 type에 대하여 사용할 수 있습니다.

```http
GET /test/_doc/_mget
{
    "docs" : [
        {
            "_id" : "1"
        },
        {
            "_id" : "2"
        }
    ]
}
```

```http
GET /test/_doc/_mget
{
    "ids" : ["1", "2"]
}
```

### Source filtering

default로 `_source` field를 포함된 document를 반환합니다. get API와 유사하게  `_source` parameter를 사용하여 `_source` 의 부분만 검색할 수 있습니다. 

```http
GET /_mget
{
    "docs" : [
        {
            "_index" : "test",
            "_type" : "_doc",
            "_id" : "1",
            "_source" : false
        },
        {
            "_index" : "test",
            "_type" : "_doc",
            "_id" : "2",
            "_source" : ["field3", "field4"]
        },
        {
            "_index" : "test",
            "_type" : "_doc",
            "_id" : "3",
            "_source" : {
                "include": ["user"],
                "exclude": ["user.location"]
            }
        }
    ]
}
```

### Fields

특정 stored fields만 검색할 수 있습니다.

```http
GET /_mget
{
    "docs" : [
        {
            "_index" : "test",
            "_type" : "_doc",
            "_id" : "1",
            "stored_fields" : ["field1", "field2"]
        },
        {
            "_index" : "test",
            "_type" : "_doc",
            "_id" : "2",
            "stored_fields" : ["field3", "field4"]
        }
    ]
}
```

```http
GET /test/_doc/_mget?stored_fields=field1,field2
{
    "docs" : [
        # field1과 field2 반환
        {
            "_id" : "1" 
        },
        # field3과 field4 반환
        {
            "_id" : "2",
            "stored_fields" : ["field3", "field4"] 
        }
    ]
}
```

### Routing

routing 값을 parameter에 사용할 수 있습니다.

```http
GET /_mget?routing=key1
{
    "docs" : [
        {
            "_index" : "test",
            "_type" : "_doc",
            "_id" : "1",
            "routing" : "key2"
        },
        {
            "_index" : "test",
            "_type" : "_doc",
            "_id" : "2"
        }
    ]
}
```

## Bulk API

bulk API는 single API call에서 여러 index/delete operation을 수행할 수 있습니다. REST API endpoint는 `/_bulk`(`/{index}/_bulk` 또는 `/{index}/{type}/_bulk`) 이고 newline delimited JSON 형식을 따릅니다.

```json
action_and_meta_data\n
optional_source\n
action_and_meta_data\n
optional_source\n
....
action_and_meta_data\n
optional_source\n
```

data의 마지막 line은 newline character(`\n`) 으로 끝나야합니다. endpoint에 요청을 보낼 때 `Content-Type` header에 `application/x-ndjson` 을 설정해야합니다.

가능한 action은 `index`, `create`, `delete`, `update` 입니다. `index`와 `create` 는 다음 line에서 source 정보를 입력해야합니다. `delete` 에서는 다음 line에 source 정보를 넣을 필요가 없습니다. `update` 에서는 다음 line에 부분적인 doc, upset, script, 그리고 특정 option이 필요합니다.

```http
POST _bulk
{ "index" : { "_index" : "test", "_type" : "_doc", "_id" : "1" } }
{ "field1" : "value1" }
{ "delete" : { "_index" : "test", "_type" : "_doc", "_id" : "2" } }
{ "create" : { "_index" : "test", "_type" : "_doc", "_id" : "3" } }
{ "field1" : "value3" }
{ "update" : {"_id" : "1", "_type" : "_doc", "_index" : "test"} }
{ "doc" : {"field2" : "value2"} }
```

```json
# response
{
   "took": 30,
   "errors": false,
   "items": [
      {
         "index": {
            "_index": "test",
            "_type": "_doc",
            "_id": "1",
            "_version": 1,
            "result": "created",
            "_shards": {
               "total": 2,
               "successful": 1,
               "failed": 0
            },
            "status": 201,
            "_seq_no" : 0,
            "_primary_term": 1
         }
      },
      {
         "delete": {
            "_index": "test",
            "_type": "_doc",
            "_id": "2",
            "_version": 1,
            "result": "not_found",
            "_shards": {
               "total": 2,
               "successful": 1,
               "failed": 0
            },
            "status": 404,
            "_seq_no" : 1,
            "_primary_term" : 2
         }
      },
      {
         "create": {
            "_index": "test",
            "_type": "_doc",
            "_id": "3",
            "_version": 1,
            "result": "created",
            "_shards": {
               "total": 2,
               "successful": 1,
               "failed": 0
            },
            "status": 201,
            "_seq_no" : 2,
            "_primary_term" : 3
         }
      },
      {
         "update": {
            "_index": "test",
            "_type": "_doc",
            "_id": "1",
            "_version": 2,
            "result": "updated",
            "_shards": {
                "total": 2,
                "successful": 1,
                "failed": 0
            },
            "status": 200,
            "_seq_no" : 3,
            "_primary_term" : 4
         }
      }
   ]
}
```

어떤 action이 다른 node의 shard로 redirect될 때, request를 받은 node에서는 `action_meta_data` 부분만 parsing합니다.

response에서는 request에서 action의 같은 순서로 각각의 action이 반환됩니다. single action의 실패는 다른 action에 영향을 주지 않습니다.

single bulk call에서 이상적인 action의 개수는 없습니다. HTTP API를 사용하면 속도를 늦추기 때문에 HTTP chunk를 보내지 않도록 합니다.

### Optimistic concurrency control

### Versioning

### Routing

### Wait For Active Shards

### Refresh

### update

update action을 사용할 때 version 충돌의 경우에 얼마나 다시 시도할지 정해주기 위하여 `retry_on_conflict` field를 추가할 수 있습니다.

## Reindex API

`_reindex` 는 오직 document만 복사합니다. (source index의 setting을 복사하지 않습니다. `_reindex` 를 실행하기 전에 destination index의 mapping, shard counts, replicas, etc을 설정해야 합니다.)

```http
POST _reindex
{
  "source": {
    "index": "twitter"
  },
  "dest": {
    "index": "new_twitter"
  }
}
```

```json
{
  "took" : 147,
  "timed_out": false,
  "created": 120,
  "updated": 0,
  "deleted": 0,
  "batches": 1,
  "version_conflicts": 0,
  "noops": 0,
  "retries": {
    "bulk": 0,
    "search": 0
  },
  "throttled_millis": 0,
  "requests_per_second": -1.0,
  "throttled_until_millis": 0,
  "total": 120,
  "failures" : [ ]
}
```

## Term Vectors

특정 document의 field에 대한 정보와 statistics를 반환합니다. 

```http
GET /twitter/_doc/1/_termvectors
```

특정 field 지정

```http
GET /twitter/_doc/1/_termvectors?fields=message
```

### return values

