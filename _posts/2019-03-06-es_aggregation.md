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

- 문자열 데이터
  - Terms 집계

    특정 필드에서 고유한 값으로 데이터를 분할하거나 그룹화하는데 유용합니다.

    ```http
    GET bigginsight/userReport/_search
    {
        "aggs": {
        	"byCategory": {
                "terms": {
                    "field": "category",
                    "size": 15 # 반환될 Terms 버킷의 최대 개수
                }
        	}
    	},
    	"size": 0
    }
    ```

- 숫자열 데이터
  - Histogram 집계

    데이터를 숫자 필드 기반의 여러 버킷으로 분할할 수 있습니다. 각 분할 범위는 쿼리 입력에 지정할 수 있습니다.

    ```http
    GET bigginsight/_search?size=0
    {
        "aggs": {
        	"byUsage": {
                "histogram": {
                    "field": "usage",
                    "interval": 1000 # bucket 분할 간격
                }
        	}
    	},
    	"size": 0
    }
    ```

  - Range 집계

    크기가 다른 버킷을 만들 수 있습니다.

    ```http
    GET bigginsight/_search?size=0
    {
        "aggs": {
        	"byUsage": {
                "range": {
                    "field": "usage",
                    "ranges": [
                        { "to": 1024 },
                        { "from": 1024, "to": 102400 },
                        { "from": 102400 }
                        # { "key": "a", "to": 1024 },
                        # { "key": "b", "from": 1024, "to": 102400 },
                        # { "key": "c", "from": 102400 },
                    ]
                }
        	}
    	},
    	"size": 0
    }
    ```

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

- Stats 집계

  단일 요청에서 도큐먼트의 합계, 평균, 최소, 최대, 개수를 계산합니다.

  extended_stats 집계는 stats 집계 결과에 추가 통계 정보를 더해 반환합니다.

  ```http
  GET bigginsight/_search
  {
      "aggregations": {
      	"download_stats": {
              "stats": {
                  "field": "downloadTotal"
              }
      	}
  	},
  	"size": 0
  }
  ```

- Cardinality 집계

  특정 필드의 고유한 값의 개수를 찾는데 유용합니다. 예를 들어 주간, 원간 순 방문자수를 찾을 수 있습니다.

  ```http
  GET bigginsight/_search
  {
      "aggregations": {
      	"unique_visitors": {
              "cardinality": {
                  "field": "username"
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

## 복잡한 집계

### 필터 데이터 집계

집계를 적용하기 전에 일부 필터를 적용하는 작업을 적용할 수 있습니다.

```http
GET bigginsight/userReport/_search
{
	"query": {
      	"term": {
            "customer": "Linkedin"
      	}  
	},
    "aggs": {
    	"byCategory": {
            "terms": {
                "field": "category"
            }
    	}
	},
	"size": 0
}
```

### 중첩 집계

Bucket 집계 안에서 Metric 집계를 중첩해 사용하면 각 버킷 내에서 Metric 집계를 계산할 수 있습니다.

```http
GET bigginsight/userReport/_search
{
	"query": {
		"bool": {
            "must": [
      			{ "term": { "customer": "Linkedin" }},
                { "range": { "time": { "gte": 1000, "lte": "2000" }}}
            ]
		}
	},
    "aggs": {
    	"byUsers": {
            "terms": {
                "field": "username",
                "order": { "total_usage": "desc" }
            }
    	}
    	"aggs": {
            "total_usage": {
                "sum": { "field": "usage" }
            }
    	}
	},
	"size": 0
}
```

### Date Histgram 집계

Date Histogram 집계를 사용해 날짜 필드에 버킷을 만들 수 있습니다.

```http
GET /bigginsight/useageReport/_search?size=0
{
    "aggs": {
        "counts_over_time": {
            "date_histogram": {
                "field": "time",
                "interval": "1d",
                "time_zone": "+505:30" # timezone 설정
            }
        }
    }
}
```

### 지리 정보 데이터 버킷팅

- Geo distance 집계

  Geo distance 집계를 사용하면 거리에 대한 버킷을 만들 수 있습니다.

  ```http
  GET bigginsight/usageReport/_search?size=0
  {
    "aggs": {
      "within_radius": {
        "geo_distance": {
          "field": "location",
          "origin": {
            "lat": "32.1212", "lon": "32.123223"
          },
          "ranges": [
            {
              "to": 5
            }
          ]
        }
      }
    }
  }
  ```

- GeoHash grid 집계
  
  GeoHash 시스템은 세계 지도를 다른 정밀도를 가진 직사각형 영역으로 구성된 격자무늬로 분리합니다.

  ```http
  {
    "aggs": {
      "geo_hash": {
        "geohash_grid": {
          "field": "location",
          "precision": 7 # 1 ~ 12(낮을수록 더 넓은 지리학상의 영역을 나타냅니다.)
        }
      }
    }
  }
  ```

### Pipeline 집계

다른 집계 결과를 토대로 다시 집계할 수 있습니다.

- Parent Pipeline 집계: 다른 집계 안에 Pipeline 집계를 중첩해 사용
- Sibling Pipeline 집계: Pipeline이 완료된 원본 집계의 형제로 사용


