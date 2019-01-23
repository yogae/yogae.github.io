---
layout: post
title:  "Amazon Elasticsearch Service"
date: 2019-01-09
categories: AWS
author: yogae
---

Amazon Elasticsearch Service(Amazon ES)는 AWS 클라우드에서 Elasticsearch 클러스터를 쉽게 배포, 운영 및 조정할 수 있는 관리형 서비스입니다.

## ES 정리

### 전용 마스터 노드

전용 마스터 노드는 클러스터 관리 작업을 수행하지만 데이터를 보유하지 않거나 데이터 업로드 요청에 응답하지 않습니다. 클러스터 관리 작업을 오프로드하면 도메인의 안정성이 높아집니다.

각 프로덕션 Amazon ES 도메인에 대해 전용 마스터 노드 **3개**를 할당하는 것이 좋습니다.

전용 마스터 노드는 다음 클러스터 관리 작업을 수행합니다.

- 클러스터의 모든 노드 추적
- 클러스터에 있는 인덱스 수 추적
- 각 인덱스에 속한 샤드 수 추적
- 클러스터에 있는 노드에 대한 라우팅 정보 유지
- 상태 변경(인덱스 생성, 클러스터에서 노드 추가 또는 제거) 후 클러스터 상태 업데이트
- 클러스터의 모든 노드 간에 클러스터 상태 변경 사항 복제
- *하트비트 신호*를 보내 모든 클러스터 노드의 상태를 모니터링(정기적인 신호는 클러스터에 있는 데이터 노드의 가용성을 모니터링함)

### Amazon ES 대상에 대한 인덱스 로테이션

Amazon ES 대상에 대해 **NoRotation**, **OneHour**, **OneDay**, **OneWeek**, **OneMonth** 등 다섯 가지 옵션 중 하나에서 시간 기반 인덱스 로테이션 옵션을 지정할 수 있습니다.

선택한 로테이션 옵션에 따라 Kinesis Data Firehose가 UTC 도착 타임스탬프의 일부를 지정된 인덱스 이름에 추가합니다. 

| RotationPeriod | IndexName               |
| -------------- | ----------------------- |
| `NoRotation`   | `myindex`               |
| `OneHour`      | `myindex-2016-02-25-13` |
| `OneDay`       | `myindex-2016-02-25`    |
| `OneWeek`      | `myindex-2016-w08`      |
| `OneMonth`     | `myindex-2016-02`       |

## Amazon Kinesis Data Firehose에서 Amazon ES로 스트리밍 데이터 로드

**Amazon ES는 VPC에 상주하는 도메인에 대해 Amazon Kinesis Data Firehose와 통합을 지원하지 않습니다. Amazon ES에서 이 서비스를 사용하려면 퍼블릭 액세스가 가능한 도메인을 사용해야 합니다.**

Amazon ES를 대상으로 선택

- index: Amazon ES 클러스터로 데이터를 인덱싱할 때 사용될 Elasticsearch 인덱스 이름입니다.
- Index rotation: Elasticsearch 인덱스의 로테이션 여부와 주기를 선택합니다. 인덱스 로테이션이 활성화되면 Kinesis Data Firehose가 지정된 인덱스 이름과 회전에 해당 타임스탬프를 추가합니다. 
- Type: Amazon ES 클러스터로 데이터를 인덱싱할 때 사용될 Amazon ES 유형 이름입니다. Elasticsearch 6.x의 경우 인덱스당 유형은 한 개입니다. 다른 유형을 가진 기존 인덱스에 새 유형을 지정하면 런타임 동안 Kinesis Data Firehose가 오류를 반환합니다.
- Retry duration: Amazon ES 클러스터에 대한 인덱스 요청이 실패할 경우 Kinesis Data Firehose가 다시 시도하는 시간(0–7200초)입니다.
- 백업 모드: 실패한 레코드만 백업하거나 모든 레코드를 백업하도록 선택할 수 있습니다. 실패한 레코드만 백업하도록 선택하면 Kinesis Data Firehose가 Amazon ES 클러스터로 전송하지 못하는 데이터 또는 Lambda 함수가 변환하지 못하는 데이터가 지정된 S3 버킷에 백업됩니다. 모든 레코드를 백업하도록 선택하면 Amazon ES로 데이터가 전송됨과 동시에 Kinesis Data Firehose가 S3 버킷으로 수신되는 모든 소스 데이터를 백업합니다. 

## Amazon ES VPC 도메인 접근

1. Amazon ES 도메인과 동일한 VPC, 서브넷 및 보안 그룹에 Amazon Linux Amazon EC2 인스턴스를 생성합니다.

2. 보안 그룹의 경우 두 가지 인바운드 규칙을 지정합니다.

   | Type       | 프로토콜 | 포트 범위 | 소스                     |
   | ---------- | -------- | --------- | ------------------------ |
   | SSH(22)    | TCP(6)   | 22        | *your-cidr-block*        |
   | HTTPS(443) | TCP(6)   | 443       | *your-security-group-id* |

3. 터널 생성

   ```bash
   ssh -i ~/.ssh/your-key.pem ec2-user@your-ec2-instance-public-ip -N -L 9200:vpc-your-amazon-es-domain.region.es.amazonaws.com:443 
   ```

4. 웹 브라우저에서 https://localhost:9200/_plugin/kibana/로 이동

## Reference

- [Amazon ES](https://docs.aws.amazon.com/ko_kr/elasticsearch-service/latest/developerguide/what-is-amazon-elasticsearch-service.html)

- [Amazon ES 대상에 대한 인덱스 로테이션](https://docs.aws.amazon.com/ko_kr/firehose/latest/dev/basic-deliver.html#es-index-rotation)

- [VPC 도메인 테스트](https://docs.aws.amazon.com/ko_kr/elasticsearch-service/latest/developerguide/es-vpc.html#kibana-test)