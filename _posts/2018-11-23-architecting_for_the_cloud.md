---
layout: post
title:  "Architecting for the Cloud"
date:   2018-11-23 21:11:42 +0900
category: SAA
author: yogae
---
SAA 시험 정리

## Design Principles

### Scalability

#### Scaling Vertically

#### Scaling Horizontally

#### 시나리오

- Stateless Applications
- Distribute Load to Multiple Nodes
  - Push model
    - 서버에서 정보를 clients에서 전송 형태
    - Ex) push notification
    - ELB를 사용할 수 있음 -> 
    - Route 53의 DNS round robin을 사용 -> 사용하기 쉬우나 항상 route 설정에 따라 동작하지 않을 수 있는 문제가 있음
  - Pull model
    - clients가 서버에 요청하여 정보를 받아오는 형태
    - Ex) 전통적인 client / server architecture
    - 비동기 또는 event-driven 작업에 적용가능
    - SQS 또는 Kinesis를 사용가능

- Statless Components

  - http cookie를 사용하여 session 정보를 저장

    - 문제점: 

      1. cookie를 항상 validate 해야함

      2. cookie가 모든 request에 전송되므로 불필요한 latency 발생

    - 해결방안:

      - database에 정보를 저장(DynamoDB 는 확장성, 고가용성 및 내구성 면에서 좋음)

  - 용량이 큰 파일을 요구하는 시나리오

    - 해결방안:
      - s3, EFS를 공유 저장 공간으로 사용

  - 복잡한 multi-step workflow

    - AWS Step Functions을 사용

- Stateful Components
  - 모든 transactions의 session을 특정 compute resource에 바인드할 것이다.
  - 이미 존재하는 session은 새로운 compute node를 할달해도 바로 효과가 없다.(기존에 존재하는 transactions들은 기존의 session을 그대로 사용해야하기 때문에)
  - node가 종료되거나 사용할 수 없게 되었을 경우 session에 저장 되어 있는 정보를 찾을 수 없다.
- Implement Session Affinity
  - ALB의 Sticky session feature 사용하 특정 instance에 user의 session을 바인딩할 수 있다.
  - Client-side에 load balancing하는 코드를 작성하여 컨트롤 할 수 있다.
    - 더 복잡함을 더할 수 있다.
    - load balancer가 요구조건에 충족되지 않을 경우 유용할 수 있다.

- Distributed Processing
  - 많은 양의 데이터를 하나의 compute resource로 처리하지 못할 경우 분산 처리가 필요하다.
  - task와 데이터를 작은 단위의 일로 나누어 compute resource로 실행 할 수 있다.

- Implement Distributed Processing
  - offline batch job을 AWS Batch, AWS Glue, and Apache Hadoop등의 distributed data processing engine을 사용하여 수평적으로 스케일할 수 있다.
  - AWS에서는 Hadoop workload를 실행하기 위해서 EMR을 사용할 수 있다.
  - Amazon Kinesis는 확장성을 위해 여러 Amazon EC2 또는 AWS 람다 리소스가 사용할 수 있는 여러 개의 샤드로 데이터를 분할합니다.

### Disposable Resources Instead of Fixed Servers

#### Instantiating Compute Resources

구성 및 코드를 사용하여 새 리소스를 수동으로 설정하지 않을 수 있습니다. 

이 프로세스를 자동화되고 반복 가능한 프로세스로 만들어 리드 타임이 길지 않고 사람의 실수가 발생하지 않도록 해야 합니다. 이것을 달성하기 위한 몇 가지 방법이 있다.

- Bootstrapping
  - AWS reosource를 시작할 때 default configuration으로 시작할 수 있다. 그리고 sftware 또는 data를 copy하는 bootstrapping actions을 실행할 수 있다.
  - user data scripts and cloud-init 지시사항으로 새로운 EC2 instance를 설정할 수 있다. Chef or Puppet 같은 configuration management tool과 간단한 scripts를 사용할 수 있다.
- Golden Images
  - 특정 AWS resource type을 그 resource의 snapshot인 Golden Image로 시작할 수 있다. bootstrapping과 비교하면 Golden Image는 더 빠른 시작시간과 dependencies를 제거할 수 있다. Auto-scaled 환경에서 중요하다.
  - EC2 instance를 customize하고 AMI을 만들어 저장할 수 있다. 매번 configuration을 변경하고 싶다면 Golden Image를 만들어야 한다.
  - On-promise 가상환경을 가지고 있다면 다양한 가상환경 포맷에서 AMI로 변환하기 위해서 VM Import/Export를 사용할 수 있다.
- Containers
  - 