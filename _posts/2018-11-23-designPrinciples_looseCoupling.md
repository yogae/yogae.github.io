---
layout: post
title:  "Design Principles - Loose Coupling"
date: 2018-12-02
categories: SAA
author: yogae
---

application의 복잡성이 증가하면서 IT system의 요구 속성이 더 작고 느슨하게 결함된 components로 세분화 되었습니다. 이것은 IT system이 상호 의존성을 감소시키는 방법으로 디자인 되어야 한다는 것을 의미합니다. (하나의 component에서의 변화나 실패가 다른 component에 종속되어서는 안 됩니다.)

## Well-Defined Interfaces

system에서 상호작용을 감소시키는 방법은 다양한 conponent이 RESTful API같은 기술에 의존하는 않는 interfaces를 통하여 소통하도록 하는 것입니다. 기술 구현 세부 정보가 숨겨져서 다른 component에 영향을 주지 않으면서 내부 구현을 수정할 수 있도록 할 수 있습니다. 이러한 인터페이스가 하위 호환성을 유지하는 한 다른 component의 배포가 분리됩니다. 이 세분화된 디자인 패턴은 microservuces architecture에 보통 언급됩니다.

Amazon API Gateway는 개발자가 모든 규모의 API를 쉽게 create, publish, maintain, monitor, 그리고  secure하는 완전 관리형 서비스 입니다. traffic 관리, authorization그리고 access control, monitoring, API version 관리하면서 수십만 이르는 동시 API콜까지 처리할 수 있습니다.

## Service Discovery

작은 서비스의 집합으로 배포되는 application은 각각의 서비스들과의 상호작용에 의존합니다. 각각의 스비스는 여러 compute resource로 운영되기 때문에 각 서비스를 처리 할 수 있는 방법이 필요합니다. 

- 예를 들어 전통적인 infrastructure에서는 front-end web 서비스가 back-end web 서비스에 연결되어야 한다면 이 서비스가 운영되거 있는 compute resource의 IP 주소 hardcode했었습니다. cloud computing에서 이 방법은 아직 가능하지만 서비스들의 느슨한 결합을 위해서 네트워크 기술의 세부정보의 사전지식 없이 서비스를 사용할 수 있어야 합니다. 복잡성을 숨기는 것 외에도 아무때나 infrastructure의 세부사항을 변경할 수 있게 합니다.
- 아무때나 새로운 resource를 시작하거나 중지할 수 있는 cloud computing의 탄력성을 이용하려면  느슨한 결합은 중요한 요소입니다. 이를 달성하기 위해 service discovery를 구현하는 방법이 필요합니다.

### Implement Service Discovery

EC2-hosted service를 위해서 ELB로 서비스를 사용하여 service discovery를 달성하는 것이 간단한 방법입니다. 각각의 load balancer는 자신의 hostname을 가지기 때문에 안정적인 endpoint 통해 서비스를 사용할 수 있습니다. Load balancer의 endpoint가 언제든지 추상화되고 수정되기 위해서 DNS와 private Route 53 zone에 결합 할 수 있습니다.

다른 option은 모든 서비스에서 endpoint IP 주소와 port 번호를 검색할 수 있도록 service registration와 discovery method를 사용하는 것이다. service discovery는 component 간에 접착제가 되기 때문에 고가용성과 신뢰성이 중요합니다. load balancer가 사용되지 않으면 service discovery는 health check 같은 option을 허용해야합니다. microservices를 위해서 Route 53은 instance를 더 쉽게 provision할 수 있도록 자동 naming을 지원합니다. 자동 naming은 정의한 설정을 기반으로 DNS record를 자동으로 생성합니다.

## Asynchronous Integration

Asynchronous Integration은 서비스간의 loose coupling의 다른 형태 입니다. 즉시 응답을 받을 필요가 없고 요청이 등록되었다는 승인이 확실한 interaction에 알맞는 모델입니다. event를 만드는 하나의  component와 event를 소비하는 다른 component들이 필요합니다. 두 component는 direct point-to-point interaction 통하여 통합하지 않고 intermediate durable storage layer(SQS queue, Kinesis와 같은 streaming data 플렛폼, cascading Lambda events, AWS Step Functions, 또는 Amazon Simple Workflow 서비스)를 통하여 통합합니다.

이러한 접근은 두 component를 분리하고 추가적은 탄력성을 제공합니다. Queue로 부터message를 읽는 처리가 실패한다면 message는 여전히 queue에 추가 될 수 있고 system이 복구되었을 때 처리 될 수 있습니다. 또한, Front-end 스파이크에서 덜 확장 가능한 back-end 서비스를 보호할 수 있고 비용과 processing 지연 간의 절충을 찾을 수 있도록 합니다. 

## Distributed Systems Best Practices

loose coupleing을 증가시키는 다른 방법은 component 실패를 처리하는 application를 구성하는 것입니다. 최종 사용자에게 미치는 영향을 줄이는 방법을 식별하고 일부 구성 요소 오류가 발생하는 경우에도 오프라인 절차에 대한 진행 능력을 향상시킬 수 있습니다

### Graceful Failure in Practice

exponential backoff and Jitter 전략으로 실패한 request를 재시도하거나 나중에 처리하기 위하여 queue에 저장할 수 있습니다. front-end interface를 위하여, 예를들어 database server가 문제가 있을 때 실패 처리를 하는 대신 대체 또는 캐시 된 컨텐츠를 제공 할 수 있습니다. Route 53 DNS failover 기능 또한 website를 monitoring 할 수 있고 자동적으로 primary site에 문제가 있으면 backup site로 route합니다.