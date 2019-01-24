---
layout: post
title:  "Index API"
date: 2019-01-24
categories: ES
author: yogae
---

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

## Automatic Index Creation

index operation은 index가 생성되어 있지않으면 자동으로 index를 생성합니다. 또한 동적인 type을 생성합니다. 그 동적으로 생성된 type은 유연하고 shema-free 합니다.

## Versioning

각각의 index된 document는 version number가 주어집니다. index API request에 response의 한 부분으로 version number가 반환됩니다.

```http
PUT twitter/_doc/1?version=2
{
    "message" : "elasticsearch now has versioning support, double cool!"
}
```

## Operation Type

 index operation은 create operation을 강제하기 위해  `op_type` 을 사용할 수 있습니다. create를 사용할 때 이미 index가 존재하면 index operation은 실패합니다.

```http
PUT twitter/_doc/1?op_type=create
{
    "user" : "kimchy",
    "post_date" : "2009-11-15T14:12:12",
    "message" : "trying out Elasticsearch"
}
```

##  Routing

shard 배치 또는 routing은 문서의 id 값의 해시를 사용하여 제어됩니다. 좀 더 명확한 제어를 위해 라우터가 사용하는 해시 함수에 입력 된 값을 `routing` 매개 변수를 사용하여 직접 지정할 수 있습니다.

```http
POST twitter/_doc?routing=kimchy
{
    "user" : "kimchy",
    "post_date" : "2009-11-15T14:12:12",
    "message" : "trying out Elasticsearch"
}
```

## Wait For Active Shards

write의 탄력성을 향상시키기 위해 index operation은 특정 수의 shard 복사본이 끝나는 것을 기다리는 설정을 할 수 있습니다. 설정한 수의 shard 복사본이 사용가능하지 않다면 설정한 수의 shard 복사본이 사용가능해 지거나 timeout이 발생할 때까지 write operaion을 대기하고 다시 시도합니다. default로 write operation은 오직 primary shard가 사용가능할 때까지만 대기합니다.

## Timeout

default로 index operation은 primary shard가 이용가능해지는 것을 기다리거나 1분까지 기다립니다. `timeout` parameter를 사용하여 timeout시간을 설정할 수 있습니다.

```http
PUT twitter/_doc/1?timeout=5m
{
    "user" : "kimchy",
    "post_date" : "2009-11-15T14:12:12",
    "message" : "trying out Elasticsearch"
}
```



