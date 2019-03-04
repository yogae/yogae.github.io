---
layout: post
title:  "분석기"
date: 2019-02-26
categories: ES
author: yogae
---

## 기본 구성

분석기에는 다음과 같은 구성 요소가 있습니다.

```
문자필터(Character filters) -> 토크나이저(Tokenizer) -> 토큰 필터(Token filters)
```

### 문자 필터(Character filters)

각 문자 필터는 입력 필드의 문자를 추가, 삭제, 변경할 수 있습니다.

```json
"char_filter": {
    "my_char_filter": {
        "type": "mapping",
        "mappings": [
            ":) => _smile_",
            ":( => _sad_",
            ":D => _laugh_"
        ]
    }
}
```

문자 필터는 분석기 과정의 맨 앞에 위치합니다. 따라서 다음에 위치한 토크나이저는 항상 대체된 문자를 얻습니다. 

###토크나이저(Tokenizer) 

분석기는 정확히 하나의 토크나이저를 갖고 있습니다. 토크나이저는 문자열을 받아 토큰 스트림을 생성하는 역할을 담당합니다. 해당 토큰을 역색인을 만들 때 사용합니다. 토큰은 단어와 같다고 봐도 무방합니다. 

> 컴퓨터 과학에서 **역색인**, **역 인덱스**(inverted index), **역 파일**(inverted file)은 낱말이나 숫자와 같은 내용물로부터의 매핑 정보를 데이터베이스 파일의 특정 지점이나 문서 또는 문서 집합 안에 저장하는 색인 데이터 구조이다. 역색인의 목적은 문서가 데이터베이스에 추가될 때 늘어나는 처리를 위해 빠른 전문 검색을 가능케 하는 것이다.

#### 표준 토크나이저

문자열을 공백 문자와 구두점을 기반으로 분해합니다.

```http
POST _analyze
{
 	"tokenizer": "standard",
    "text": "Tokenizer breaks characters into tokens"
}
```

```json
{
    "tokens": [
        {
            "token": "Tokenizer",
            "start_offset":0,
            "end_offset": 9,
            "type": "<ALPHANUM>",
            "position": 0
        },
        {
            "token": "breaks",
            "start_offset":10,
            "end_offset": 16,
            "type": "<ALPHANUM>",
            "position": 1
        },
        ......
    ]
}
```

### 토큰 필터

모든 토근 필터는 수신한 입력 토큰 스트림에 있는 토큰의 추가, 삭제, 변경이 가능합니다. 분석기는 여러 토큰 필터를 가질 수 있으며, 각 토큰 필터의 결과는 모든 토큰 필터가 동작할 때까지 다음 토큰 필터로 전송됩니다.

##내장형 분석기

대부분의 내장형 분석기는 추가 구성 없이도 동작하며, 일부 매개변수를 설정하여 유연하게 사용할 수 있습니다.

- 표준 분석기

  - 구성: 표준 토크나이저, 표준 토큰 필터, 소문자 토큰 필터, 불용어 토큰 필터

  - 생성 예시

    ```http
    PUT index_standard_analyzer
    {
    	"setting": {
            "analysis": {
                "analyzer": {
                    "std": {
                        "type": "standard",
                        # "stopwords": "_english_"
                    }
                }
            }
    	},
    	"mappings": {
            "my_type": {
                "properties": {
                    "my_text": {
                        "type": "text",
                        "analyzer": "std"
                    }
                }
            }
    	}
    }
    ```

  - 분석한 token 확인 예시

    ```http
    POST index_standard_analyzer/_analyze
    {
        "field": "my_text",
        "text": "The Standard Analzyer works this way"
    }
    ```

    ```json
    {
        "tokens": [
            {
                "token": "the",
                "start_offset":0,
                "end_offset": 3,
                "type": "<ALPHANUM>",
                "position": 0
            },
            {
                "token": "standard",
                "start_offset":4,
                "end_offset": 12,
                "type": "<ALPHANUM>",
                "position": 1
            },
            ......
        ]
    }
    ```

- keyword type

  keyword type을 사용하는 field는 내부적으로 키워드 분석기를 사용합니다. Keyword 분석기는 noop 토크나이저라는 keywork 토크나이저로 구성되며, 입력 전체를 토큰 하나로 반환합니다.

