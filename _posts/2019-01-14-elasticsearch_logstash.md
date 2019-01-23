---
layout: post
title:  "Logstash"
date: 2019-01-14
categories: ES
author: yogae
---

Logstash는 형식이나 스키마에 관계없이 모든 데이터를 수집, 통합하기위한 Elastic Stack의 중앙 데이터 흐름 엔진입니다.

Logstash는 `input` 과 `output` 필수사항과 `filter` optional 사항이 있습니다. input plugin은 source data를 소비하고 filter plugin은 data를 수정하고 output plugin은 destination에 data를 씁니다.

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
            "Resource": "arn:aws:s3:::<access-s3-bucket- name>/<prefix>/*"
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