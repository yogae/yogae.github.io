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



## Durable Data Storage

## Automated Multi-Data Center Resilience

## Fault Isolation and Traditional Horizontal Scaling

