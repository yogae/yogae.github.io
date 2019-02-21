---
layout: post
title:  "AWS Storage Services Overview - Amazon Glacier"
date: 2019-02-12
categories: SAA
author: yogae
---

Amazon Glacier는 data archiving과 online backup을 위한 보안, 내구성, 탄력성을 제공하는 매우 저렴한 스토리지 서비스입니다. Amazon Glacier를 사용하면 스토리지 운영 및 관리의 관리 부담을 AWS로 줄일 수 있습니다.

Amazon Glacier에서 archive를 검색하기 위해서는 초기화 작업이 필요합니다. archive를 저장소에 준비합니다. 

S3 data lifecycle 정책을 사용하여 Amazon Glacier와 Amazon S3 간에 data를 이동할 수 있습니다.

## 용어

### Vault

Glacier에서 Vault는 achive 보관용 컨테이너입니다.

### Achive

achive는 사진, 동영상, 문서 등 모든 데이터가 될 수 있으며, Glacier의 기본 스토리지 단위로 사용됩니다.

### Job

Glacier job은 achive에서 선택 쿼리를 수행하거나 achive를 가져오거나 vault의 인벤토리를 가져올 수 있습니다.

## Usage Patterns

Amazon Glacier는 모든 보관 상황에는 적합하지 않습니다. Glacier 외의 다른 저장소를 사용해야하는 경우는 아래와 같습니다.

- 빠르게 변하는 data:
  - data 자주 변경되는 경우 더 적은 read/write latency의 저장소를 사용하는 것이 좋습니다.
  - Amazon EBS, Amazon RDS, Amazon EFS, Amazon DynamoDB, Amazon EC2
- 즉시 접근:
  - Amazon Glacier에 저장된 data는 즉시 사용할 수 없습니다. object data에 즉시 접근해야 하다면 Amazon S3를 선택하는 것이 좋습니다.

## Performance

Amazon Glacier는 자주 접근하지 않고 오랜기간 저장되어야하는 data를 적은 비용으로 저장할 수 있도록 설계된 service입니다. Amazon Glacier 검색 작업은 일반적으로 3 - 5 시간이 걸립니다.

Multipart upload를 사용하여 upload 속도를 향상시킬 수 있습니다(single archive limit 40TB). 특정 archive의 영역이나 일부를 지정하여 Amazon Glacier에 저장된 archive에서 range retrievals을 수행할 수 있습니다.

> 데이터 검색 

> Amazon S3 Glacier는 다양한 액세스 시간과 비용 요구 사항을 충족하기 위해 긴급, 표준 및 대량 검색이라는 3가지 아카이브 검색 기능을 제공합니다. 긴급 검색으로 요청하는 경우 보통 1~5분 이내에 아카이브가 제공되므로 아카이브 하위 집합을 긴급하게 사용해야 하는 경우 데이터에 신속하게 액세스할 수 있습니다. 표준 검색의 경우 보통 3~5시간 이내에 아카이브에 액세스할 수 있습니다. 또는 대량 검색을 사용하여 GB당 단 25센트로 상당한 양의 데이터(페타바이트 규모까지)에 비용 효율적으로 액세스할 수 있습니다.

## Durability and Availability

Amazon Glacier는 평균 연간 99.999999999(11 nines)퍼센트의 내구성을 제공하도록 설계되었습니다. redundant하게 여러 시설에 data를 저장하고 각각의 시설에서는 여러 device에 저장합니다. 내구성을 높이기 위하여 Amazon glacier는 archive uploading이 성공을 반환하기 전에 동기적으로 여러 시설에 data를 저장합니다.

## Scalability and Elasticity

Amazon Glacier는 성장과 종종 예측할 수 없는 저장소의 요구 사항을 충족시키기 위해 확장됩니다. 하나의 achive는 용량이 40 TB까지  제한되며, service에서 저장할 수 있는 전체 data는 제한이 없습니다.

## Security

Amazon Glacier느 모든 data를 encrypt하기 위해 server-side encryption을 사용합니다. Amazon Glacier는 가장 강력한 블록 암호(256-bit Advanced Encryption Standard(AES-256)) 중 하나를 사용하여 키 관리 및 키 보호를 처리합니다. 자신의 키를 관리하고 싶은 고객은 upload하기 전에 데이터를 암호화 할 수 있습니다.

Amazon Glacier는 장기간 저장이 규정 또는 규정 준수에 따라 의무화되는 vault를 잠글 수 있습니다. 규정 준수 control을 개인 Amazon Glacier vault에 설정할 수 있고 잠글 수 있는 policy를 사용하여 이를 강화할 수 있습니다.

data 접근 monitor를 돕기위해 AWS CloudTrail을 사용할 수 있습니다. 

## Interfaces

1. REST wen service interface를 제공(AWS SDK, AWS management console ....)
2. Amazon S3에서 object lifecycle 관리를 사용하여 Amazon Glacier에 S3 data를 아카이빙을 할 수 있습니다.

## Cost Model

Amazon Glacier는 사용할 만큼 요금이 부과되고 기본 요금이 없습니다. 세가지 가격 구성이 있습니다. storage (per GB per month), data transfer out (per GB per month), and requests (per thousand UPLOAD and RETRIEVAL requests per month).