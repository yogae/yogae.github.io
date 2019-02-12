---
layout: post
title:  "AWS Storage Services Overview - S3"
date: 2019-02-10
categories: SAA
author: yogae
---

## Amazon S3

s3는 다른 사용 사례를 위해 설계된 다양한 storage class를 제공합니다.

- **Amazon S3 Standard**: 일반적인 목적으로 자주 접근하여 사용하는 data 저장
- **Amazon S3 Standard-Infrequent Access**(Standard-IA): 자주 접근하지 않으면서 장기 저장하는 data
- **Amazon Glacier**: 적은 비용으로 data를 archive

### Usage Patterns

일반적인 4가지 사용 패턴

1. Amazon S3를 static web content와 media를 저장하고 배포하기 위해 사용합니다. Amazon S3는 Amazon CloudFront같은 CDN의 origin store으로 사용할 수 있습니다.
2. Amazon S3를 전체 static website를 host하기 위해 사용합니다.
3. Amazon S3를 conputation과 큰 규모의 분석을 위한 data 저장소로 사용합니다.
4. Amazon S3를 중요한 data의 높은 내구성, 확장성, 그리고 보안을 위한 backup과 archiving을 위해 사용합니다.

### Performance

Amazon S3는 internet latency에 비해 server-side latency가 중요하지 않도록 설계되었습니다. 게다가 Amazon S3는 대량의 web-scale application을 지원하기 위해 저장소, 요청 및 사용자 수를 확장 할 수 있도록 설계 되었습니다.

큰 규모의 object(일반적으로 100MB 이상)의 upload 성능을 향상시키기 위해서 Amazon S3는 multipart upload 명령을 제공합니다. multipart upload를 사용하여 향상된 throuput과 network issue에 대한 빠른 복구 효과를 얻을 수 있습니다. multipart upload를 사용하여 얻는 다른 장점은 single object를 병렬적으로 처리할 수 있고 작은 부분의 upload를 재시작할 수 있습니다.

관련 data에 접근 속도을 향상시키기 위하여 많은 개발자들은 Amazon S3와 Amazon CloudSearch 또는 a database(Amazon DynamoDB or Amazon RDS)같은 검색 엔진을 함께 사용합니다.

Amazon S3 Transfer Acceleration은 client와 Amazon S3 bucket간의 거리가 먼 file의 전송을 빠르고, 쉽고, 안전하게 합니다.Amazon CloudFront의 글로벌 분산 에지 위치를 활용하여 Amazon에서 최적화된 네트워크 경로를 통해 Amazon S3 bucket으로 트래픽을 라우팅합니다.

### Durability and Availability

Amazon S3 Standard storage와 Standard-IA storage는 선택한 region에 여러 device와 시설에 걸쳐 data를 저장하여 data의 높은 내구성과 가용성을 제공합니다. error 수정 기능이 내장되어 있으며 single points of failure가 없습니다. Amazon S3는 1년의 기간동안 99.999999999(11 nines) 퍼센트의 내구성과 99.99 퍼센트의 가용성을 가지고 있습니다.

각각의 S3 bucket을 cross-region replication가 가능하도록 설정할 수 있습니다. cross-region replication는 비동기적으로 다른 AWS Region에 있는 bucket으로 object를 자동적으로 복사합니다.

### Scalability and Elasticity

Amazon S3는 자동적으로 높은 확장성과 탄력성을 제공하도록 설계되었습니다. directory에 많은 file을 저장할 때 문제가 있는 일반적인 file system과 다르게 Amazon S3는 어느 bucket에서도 file 개수의 제한이 없습니다. 전체 data의 용량 제한이 있는 disk drive와 다르게 Amazon S3 bucket은 용량의  한계가 없습니다. Amazon S3는 자동적으로 확장을 관리하고 같은 region의 다른 위치에 있는 server로 정보를 redundant 사본을 배포합니다.

### Security

다른 AWS Account에 권한을 부여하고 사용자의 권한을 접근 policy를 작성하여 Amazon S3 접근을 관리할 수 있습니다.

server-side encryption나 client-side encryption을 사용하여 Amazon S3 data를 보호할 수 있습니다. 

> server-side encryption: data center의 disk에 쓰여지기 전에 encrypt하고 download할 때 decrypt합니다.
>
> client-side encryption: data를 client side에서 encrypt하고 encrypt된 data를 Amazon S3로 upload합니다.

Secure Sockets Layer (SSL) 또는 client-side encryption을 사용하여 전송 중인 data를 보호할 수 있습니다.

versioning을 사용하여 Amazon S3 bucket에 저장된 모든 object의 모든 version을 보존, 검색 및 복원할 수 있습니다. versioning하여 의도하지 않은 사용자 행동과 application failure를 쉽게 복구시킬 수 있습니다. 또한 MFA 설정을 활성화시켜 bucket의 versioning을 관리할 수 있습니다.

access logging 설정을 활성화하여 bucket으로 접근하는 요청을 추적할 수 있습니다.

### Interfaces

Amazon S3는 관리와 data의 처리를 위해 standards-based REST web service API를 제공합니다. unique한 bucket의 이름에 모든 object가 저장되며 bucket 안에 있는 모든 object는 unique한 object key(file name)를 가집니다.

bucket에 특정 event가 발생했을 때 Amazon S3 notification 기능을 사용하여 notification을 받을 수 있습니다. 현재 Amazon S3는 object가 upload되거나 삭제 되었을 때 event를 publish할 수 있습니다. notification은 SNS의 topic, SQS, AWS Lambda function으로 발행될 수 있습니다.

### Cost Model

Amazon S3는 실제로 사용하는 저장 용량에  대해서만 비용을 지불합니다. 기본으로 지불하는 비용이 없고 setup 비용이 없습니다. Amazon S3 Standard는 세가지 가격 구성이 있습니다. 저장(per GB per month), data 전송 또는 수신(per GB per month), requests(per thousand requests per month).

