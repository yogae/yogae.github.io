---
layout: post
title:  "집계"
date: 2019-03-06
categories: ES
author: yogae
---

집계 쿼리의 형식

```http
POST /<index_name>/<type_name>/_search
{
    "aggs": {},
    "query": {},
    "size": 0
}
```

query 요소를 명시하지 않으면 집계는 주어진 인덱스와 타입에 있는 모든 도큐먼트를 반환합니다(match_all 쿼리와 같다.). 집계 결과를 얻는 데 관심이 있는 경우, 집계 결과와 함께 결과가 표시되지 않도록 size를 0으로 설정해야합니다.

elasticsearch가 지원하는 집계는 네가지 타입으로 구분할 수 있습니다.

- Bucket 집계
- Metric 집계
- Matrix 집계
- Pipeline 집계

### Bucket 집계

Bucket 집계는 컨텍스트에 있는 각 도큐먼트가 어떤 버킷에 속해 있는지 결정해 평가합니다. 개별 버킷 키와 버킷에 속하는 도큐먼트가 있는 버킷 집합을 갖습니다.

### Metric 집계

필드에서 숫자 타닙으로 동작하며, 주어진 컨텍스트에서 숫자 필드의 집계값을 계산하는데 사용합니다.

- Sum 예시

  ```http
  GET bigginsight/_search
  {
      "aggregations": {
      	"download_sum": {
              "sum": {
                  "field": "downloadTotal"
              }
      	}
  	},
  	"size": 0
  }
  ```

- Average 집계

  ```http
  GET bigginsight/_search
  {
      "aggregations": {
      	"download_average": {
              "avg": {
                  "field": "downloadTotal"
              }
      	}
  	},
  	"size": 0
  }
  ```


### Matrix 집계

여러 필드에서 동작하고 쿼리 컨텍스트 내의 모든 도큐먼트에 걸쳐 메트릭을 계산합니다. 

### Pipeline 집계

다른 타입의 집계 결과를 다시 집계할 수 있는 상위 레벨의 집계입니다.  