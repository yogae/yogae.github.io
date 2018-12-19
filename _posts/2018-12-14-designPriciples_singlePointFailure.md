---
layout: post
title:  "Design Principles - Removing Single Points of Failure"
date: 2018-12-14
categories: SAA
author: yogae
---

생산 시스템은 일반적으로 가동 시간에 대해 정의되거나 암묵적인 목표를 가지고 있습니다. 시스템은 hard disks, servers, network links와 같은 하나 또는 여러 component의 실패를 버틸 수 있을 때 가용성이 높습니다. 높은 가용성을 가지는 시스템을 만들기 위해서는 자동으로 복구하는 방법과 architecture의 모든 계층에 중단을 줄이는 방법을 고려할 수 있습니다.

## Introducing Redundancy

Single points of failure는 redundancy를 도입하여 제거할 수 있습니다. redundancy는 같은 작업에 여러 resource를 보유하는 것을 의미합니다. redundancy는 standby 또는 active mode 중 하나로 구현 될 수 있습니다.

standby redundancy에서는 resource가 실패한 경우 기능이 failover 처리를 통해 secondary resource로 복구 됩니다. failover는 일반적으로 완료되기 전까지 시간이 걸리고 그 기간동안 resource는 사용할 수 없습니다. secondary resource는 필요할 때 또는 이상적으로 이미 동작하고 있을 때(failover를 가속하고 장애를 최소하 하기위해) 실행될 수 있습니다. Standby redundancy는 relational databases와 같은 stateful component에 종종 상용됩니다.

active redundancy에서는 여러 redundant compute resource를 배포 해야합니다. resource 중 하나가 실패했을 때 나머지 resource는 작업 부하의 더 큰 부분을 흡수 할 수 있습니다. standby redundancy와 비교하면 active redundancy 장애가 있을 때 보다 좋은 성능과 더 적은 영향을 받을 수 있습니다.

## Detect Failure

장애를 감지하고 반응하기 위해 가능한 많은 자동화를 설계해야합니다. 정상적인 endpoint에 트래픽을 라우팅하여 health check와 mask failure구성하기 위해 ELB와 Amazon Route 5 같은 service를 사용할 수 있습니다. Auto Scaling 또는  Amazon EC2 auto-recovery feature는 사용하거나 Elastic Beanstalk와 같은 service를 사용하여 장애가 발생한 node를 자동으로 대체할 수 있습니다. 하루만에 가능한 모든 실패 scenario를 예측할 수 없습니다. 충분한 log를 수집하고 보통의 system의 동작을 이해하기 위한 측정을 해야합니다. 동작을 이해하면 manual 또는 자동으로 응답하는 alarm을 구성할 수 있습니다.

### Design Good Health Checks

application을 위한 알맞은 health check를 구성은 다양한 실패 scenario에 정확하고 즉각적인 대응할 수 있게 합니다. 잘못된 health check를 지정하는 것은 application의 성능을 감소시킬 수 있습니다.

일반적인 three-tier application에서는 ELB에 health check를 구성합니다. back-end node의 상태를 안정적으로 평가하는 것을 목표로 health check를 설계해야합니다. instance가 정상상태이나 web server proess가 중단된 경우 간단한 TCP health check는 감지하지 못할 것입니다. 대신에 간단한 requeset를 위해서는 web server가 200 response를 반환하는지 평가해야합니다.

성공적으로 application의 다른 layer를 의존하는 test를 하는 deep health check를 구성하는 것은 좋은 생각이 아닐 것입니다. 예를 들어 health check로 instancerk back-end database에 접속할 수 있는지 확인한다면 database가 단기적으로 사용할 수 없을 때 모든 web server를 비정상태로 표시하는 위험이 있습니다. 계층화 된 접근 방식이 가장 좋습니다.  deep health check는 Amazon Route 53 계층에서 구현이 적절합니다. 환경이 필요한 기능을 실제로 제공하는지 여부를 결정하는 포괄적인 검사를 실행하면 database가 가동되어 다시 실행될 때까지 Amazon Route 53이 website의 정적 버전으로 failover할 수 있도록 합니다.

> deep health check pattern: deep health check pattern은 instance를 load balancer에 연결시기고??????

## Durable Data Storage

application과 user는 다양한 데이터를 만들고 유지할 것입니다. architecture가 data의 가용성과 무결성을 보호하는 것이 중요합니다. 데이터 복제는 데이터의 중복 사본을 도입하는 기술입니다. 이것은 수평적으로 read 성능을 향상시키고 data 내구성과 가용성을 증가시킵니다. 복제는 몇가지 다른 mode에서 발생할 수 있습니다.

동기식 복제는 transaction이 primary location와 replica에 영구적으로 정장된 후에만 transaction을 인식합니다. primary node의 실패 event로부터 무결성을 지키기 위해 이상적인 방법입니다. 동기식 복제는 최신 data를 요구하는 query의 read 성능을 확장할 수 있습니다(strong consistency). 동기식 복제의 약점은 primary node가 replica로 연결되는 것입니다. Transaction은 모든 write를 수행하기 전에 인식할 수 없습니다. 특히 신뢰할 수 없거나 대기 시간이 긴 네트워크 연결에서 실행되는 topology에서는 성능과 가용성을 저하시킬 수 있습니다. 같은 이유로 많은 동기식 replica를 유지하는 것은 추천하지 않습니다.

solution의 내구성과 관계없이 backup을 위한 대체가 없습니다. 버그나 error의 결과일지라도 동기식 복제는 모든 update를 중복하여 저장합니다. 그러나 특히 Amazon S3에 저장되는 object은 유지하고, 검색하고, 재저장하기 위해 versioning을 사용할 수 있습니다. versioning으로 의도하지 않은 사용자 행동과 application 실패로 부터 복구할 수 있습니다.

비동기식 복제는 primary node를 replica로 부터 분리합니다. premary node에서의 변화가 replica에 즉시 반영되지 않는 것을 의미합니다. 비동기 replica는 query를 위한 read 용량의 수평적인 확장에 사용됩니다. failover하는 동안 최근 transaction의 유실을 허용 될 수 있을 때 data의 내구성 증가를 위하여 사용됩니다. 예를 들어 disaster recovery solution으로 분리된 AWS Region에 비동기식 database replica를 유지할 수 있습니다.

Quorum-based 복제는 대용량 분산 database system의 장애를 극복하기 위하여 동기와 비동기 복제가 결합되어 있습니다.

여러 node로 복제는 성공적인 write opertaion에 참여해야하는 최소의 node를 정의하여 관리될 수 있습니다. 

Data storage model에 맞는 각각의 기술이 어디에 사용되는지 이해하는 것이 중요합니다. 다양한 장애 조치 또는 백업 / 복원 시나리오에서의 해당 동작은  recovery point objective (RPO) 및 recovery time objective (RTO)와 일치해야합니다. 얼마나 많은 data를 손실 할 수 있는지 얼마나 빠르게 operation를 재개할 수 있는지 확실히 해야합니다. 예를 들어, Amazon EleastiCache에 Redis engine은 자동 failover를 지원하지만 Redis engine의 복제는 비동기입니다. failover하는 동안 최근 transaction은 손실하게 됩니다. 그러나, Multi-AZ 기능을 지원하는 Amazon RDS는 동기식 복제를 제공하도록 설계되었습니다.

> RPO는 재난이 발생 event로 부터 복구 가능한 지점까지의 시간을 말하는 용어입니다. 재난이 발생면 지정한 RPO 지점까지의 모든 data를 손실 할 수 있다는 것을 의미합니다. 4시간의 RPO를 지정한다면 4시간 동안의 data를 손실 할 수 있다는 것입니다.
>
> RTO는 data와 application이 복구되는데 걸리는 시간을 의미합니다. 

## Automated Multi-Data Center Resilience



## Fault Isolation and Traditional Horizontal Scaling

