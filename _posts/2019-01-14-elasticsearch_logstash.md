---
layout: post
title:  "Logstash"
date: 2019-01-14
categories: ES
author: yogae
---

Logstash는 형식이나 스키마에 관계없이 모든 데이터를 수집, 통합하기위한 Elastic Stack의 중앙 데이터 흐름 엔진입니다.

Logstash는 `input` 과 `output` 필수사항과 `filter` optional 사항이 있습니다. input plugin은 source data를 소비하고 filter plugin은 data를 수정하고 output plugin은 destination에 data를 씁니다.

## 이키텍처

- Logstash 이벤트 처리 파이프라인은 입력, 필터, 출력 세가지 단계로 구성된다.
- 기본적으로 파이프라인 단계(입력 -> 필터, 필터 -> 출력)마다 이벤트를 버퍼에 담기 위해 인메모리 바운드 큐를 사용합니다.
- Logstash가 불안정한 상태로 종료되면 인메모리에 저장된 이벤트는 손실됩니다. 데이터 손실 방지를 위해 영구 큐를 사용해 실행중인 이벤트를 디스크에 유지할 수도 있습니다.(영구 큐는 LOGSTASH_HOME/config 디렉토리 아래에 있는 logstash.yml 파일에서 queue.type: persisted 속성을 설정하면 활성화할 수 있습니다.)

## 인제스트 노드

- 인제스트 노드는 Elasticsearch에서 색인을 생성하기 전에 도큐먼트를 사전 처리하고, 도큐먼트를 풍부하게 해주는 경량 솔루션입니다.
- 5.x에서 인제스트 노드라는 기능이 도입되었습니다. 
- 인제스트 노드는 도큐먼트에 실제로 색인을 생성하기 전에 사전 처리하는 데 사용할 수 있습니다.
- 사전 처리작업은 벌크 및 인덱스 요청을 가로채 데이터를 변환하고, 벌크 또는 인덱스 API로 다시 도큐먼트를 전달합니다.

### 파이프라인 정의

- 파이프라인은 일련의 프로세서를 정의합니다. 각 프로세서는 도큐먼트를 특정 방법으로 변환하고, 각 프로세서는 파이프라인에 정의한 순서대로 실행됩니다.

## logstash config file 설정

아래의 설정은 s3에서 cloudfront log file을 input으로 받고 lostash에서 filter작업을 하고 amazon elasticsearch로 data를 전송하는 logstash config file입니다.

```
#cloudfront.conf
input {
  s3 {
    bucket => ""
    prefix => ""
    region => ""
    access_key_id => ""
    secret_access_key => ""
  }
}

filter {
  grok {
    match => { "message" => "%{DATE_EU:date}\t%{TIME:time}\t%{WORD:x_edge_location}\t(?:%{NUMBER:sc_bytes:int}|-)\t%{IPORHOST:c_ip}\t%{WORD:cs_method}\t%{HOSTNAME:cs_host}\t%{NOTSPACE:cs_uri_stem}\t%{NUMBER:sc_status:int}\t%{GREEDYDATA:referrer}\t%{GREEDYDATA:User_Agent}\t%{GREEDYDATA:cs_uri_stem}\t%{GREEDYDATA:cookies}\t%{WORD:x_edge_result_type}\t%{NOTSPACE:x_edge_request_id}\t%{HOSTNAME:x_host_header}\t%{URIPROTO:cs_protocol}\t%{INT:cs_bytes:int}\t%{GREEDYDATA:time_taken}\t%{GREEDYDATA:x_forwarded_for}\t%{GREEDYDATA:ssl_protocol}\t%{GREEDYDATA:ssl_cipher}\t%{GREEDYDATA:x_edge_response_result_type}" }
  }

  mutate {
    add_field => [ "listener_timestamp", "%{date} %{time}" ]
  }

  date {
    match => [ "listener_timestamp", "yy-MM-dd HH:mm:ss" ]
    target => "@timestamp"
  }

  geoip {
    source => "c_ip"
  }

  useragent {
    source => "User_Agent"
    target => "useragent"
  }

  mutate {
    remove_field => ["date", "time", "listener_timestamp", "cloudfront_version", "message", "cloudfront_fields", "User_Agent"]
  }
}

output {
  amazon_es {
    hosts => [""]
    region => ""
    index => "cloudfront-logs-%{+YYYY.MM.dd}"
    template => ""
    ## 아래의 key가 없는 경우 elasticsearch의 endpoint에 접근할 수 없습니다.
    ## aws elasticsearch에 acccess 정책을 "Principal": { "AWS": "*" }로 설정하여도 필요
    ## 설정하지 않으면 credential을 찾지 못하는 error 발생
    aws_access_key_id => ""
    aws_secret_access_key => ""
  }
}
```

## filter plugin

### Mutate filter

Mutate 필터를 사용하면 이벤트 필드 변환, 제거, 수정, 이름 변경 등 다양한 변형 작업을 수행합니다.

```
...
filter {
  csv {
    autodetect_column_names => true
  }
  mutate {
    convert => { # 데이터 타입을 변경(유효한 변환 대상은 integer, string, float, boolean)
      "Age" => "integer"
      "Salary" => "float"
    }
    rename => { # 필드 이름을 변경
      "FName" => "Firstname"
      "LName" => "Lastname"
    }
    gsub => ["EmailId", "\.", "_"] # 필드 값과 비교해 일치하는 모든 문자를 대체 문자열로 치환(3개의 필드 요소 => 필드 이름, 정규식, 대체할 문자열)
    strip => ["Firstname", "Lastname"] # 문자열에서 공백을 제거
    uppercase => ["Gender"]
  }
}
```

### Grok filter

불규칙한 데이터를 분석해 구조화하고, 구조환된 데이터를 쉽게 쿼리하고 필더링하는 데 자주 사용하는 강력한 플러그인입니다.

```
......
filter {
  grok {
    match => {"message" => "%{TIMESTAMP_ISO8601:eventtime} %{USERNAME:userid} %{GREEDYDATA:data}"}
  }
}
......
```

### Date filter

필드에서 날짜를 분석할 때 사용하는 Date 필터는 시계열 이벤트 작업 시 매우 편리하고 유용합니다. 로그스태시는 기본적으로 각 이벤트에 이벤트 처리 시간을 나타내는 @timestamp 필드를 추가합니다.

```
......
filter {
  date {
    match => ["timestamp", "dd/MMM/YYYY:HH:mm:ss Z"]
  }
}
......
```

### Geoip filter

IP 주소가 있을 때 Geoip 필터를 사용해 IP 주소의 위치 정보를 추가할 수 있습니다.

### Useragent filter

사용자 에이전트 문자열을 구조화된 데이터로 분석하고, 운영체제 및 번전, 장치 등 사용자 정보를 추가합니다.

## s3 접근 권한 설정

s3에 접근하기 위한 권한을 IAM에 설정해야합니다.

위에서 설정한 aws_access_key_id의 user에 아래의 권한을 부여해야합니다.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::<access-s3-bucket-name>/<prefix>/*"
        },
        {
            ## 아래의 권한이 없을 경우 logstash에서 list할 권한 error 발생
            ## ListBucket 권한은 s3 bucket에 할당해야한다.("arn:aws:s3:::<access-s3-bucket- name>/<prefix>에 할당하지 않는다.)
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket"
            ],
            "Resource": "arn:aws:s3:::<access-s3-bucket- name>"
        }
    ]
}
```

## memory 부족 error

lostash에서 사용하는 min, max memory 용량이 있어서 이보다 적은 memory가 남아있다면 memory 부족하여 error가 발생합니다.

lostash에서 default 설정으로 지정한 memory 사이즈를 변경합니다.

```
# <logstash>/config/jvm.options
-Xms1g -> min size 1g
-Xmx1g -> max size 1g
```

```
# <logstash>/config/jvm.options
-Xms512m -> min size 512m
-Xmx512m -> max size 512m
```

> t2.micro instance로 logstash를 사용하는 경우 logstash에서 사용하는 default  memory가 1g로 지정되어 있고 t2.micro에서 1g의 memory가 할당되므로 문제가 발생한다.