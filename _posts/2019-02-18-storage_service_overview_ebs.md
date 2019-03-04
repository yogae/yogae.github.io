---
layout: post
title:  "AWS Storage Services Overview - Amazon EBS"
date: 2019-02-19
categories: SAA
author: yogae
---

Amazon Elasti Block Store(Amazon EBS) volume은 EC@ instance와 함께 사용하기 위한 내구성 있는 block-level 저장소를 제공합니다. Amazon EBS volume은 EC2 instance의 운영하는 life로 부터 독립적으로 유지되는 network-attached 저장소입니다. 대부분의 Amazon Machine Images (AMI)는 Amazon EBS의 지원을 받고 EBS 볼륨을 사용하여 EC2 인스턴스를 부팅합니다. 여러 EBS volume을 하나의 EC2 instance에 붙일 수 있지만 하나의 EBS volum은 오직 하나의 EC2 instance에 붙을 수 있습니다.

EBS는 volume의 Amazon S3에 저장되는 point-in-time snapshot을 생성할 수 있습니다. snapshot은 새로운 EBS volume의 시작 point로 사용할 수 있고 장기간 내구성을 위하여 data를 보호하기 위해 사용할 수 있습니다. 이러한 snapshot을을 AWS region 전체에 복사 할 수 있으므로 지리적 확장, 데이터 센터 마이그레이션 및 재해 복구를 위해 여러 AWS region을 보다 쉽게 활용할 수 있습니다. EBS volume의 크기는 volume 유형에 따라 1 GiB에서 16 TiB까지 다양하며, 1 GiB 단위로 할당됩니다.

## Usage Pattern

Amazon EBS는 비교적 자주 변경되고 EC2 instance의 life를 넘어 유지가 필요한 data를 위해 구성되었습니다. Amazon EBS는 Database 또는 file system을 위한 primary storage로 사용하거나 block-level 저장소에 직접 접근할 필요가 있는 application 또는 instance에 사용하기에 알맞습니다. Amazon EBS는 다양한 option을 제공하고 이 option은 2가지의 주요 category로 분리됩니다. 데이터 및 데이터웨어 하우스와 같은 처리량이 많은 workload를 위한 database 및 부팅 volume (성능은 주로 IOPS에 따라 다름) 및 하드 디스크 드라이브 (HDD) 백업과 같은 트랜잭션 workload를 위한 SSD (Solid-State Drive) 로그 처리 (성능은 주로 MB / s에 달려 있음).

## Performance

Amazon EBS는 다양한 volume type을 제공합니다.

- General Purpose SSD (gp2):

  광범위한 workload에 이상적인 비용 효율적인 저장소를 제공합니다. 

- Provisioned IOPS SSD (io1):

  작은 I/O 크기로 예측가능한 높은 성능의 I/O-intensive workload를 제공하도록 설계되었습니다. database 같은 storage 성능과 random access I/O 처리량의 일관성에 민감한 workload에 적합합니다.

- Throughput Optimized HDD (st1):

  자주 접근하고 큰 dataset과 I/O 크기를 가지는 throughput-intensive workload에 이상적입니다. Streaming workload, big data, data warehouse, log processing, ETL workload와 같은 throughput이 중요한 곳에 적합합니다.

- Cold HDD (sc1):

  EBS volume type 중에 GiB 당 가장 적은 비용에 사용할 수 있는 volume입니다. 자주 접근하지 않으면서 큰 I/O 크기를 가지는 cold dataset workload에 이상적입니다.

> Cassandra using General Purpose (SSD) volumes for data but Throughput Optimized (HDD) volumes for logs, or Hadoop using General Purpose (SSD) volumes for both data and logs

## Durability and Availability

Amazon EBS는 높은 가용성과 신뢰성을 가지도록 설계되었습니다. EBS volume data는 data의 유실을 방지하기 위해 하나의 Availability zone에 있는 여러 server에 복제됩니다. EBS volume의 snapshot은 저장된 data의 내구성을 증가시킵니다. EBS snapshot는 미자막 snapshot이후에 변화된 data block만 포함하는  point-in-time backup입니다. 

application-consistent backup을 위해서는 volume에 write operation을 정지하거나  volume을 unmount하기를 추천합니다. 특정 Availability Zone에서 EBS volume이 만들어지기 때문에 Availability Zone 자체를 사용할 수 없으면 볼륨을 사용할 수 없습니다. 그러나 볼륨의 snapshot은 region 내의 모든 Availability Zone에서 사용할 수 있으며 snapshot을 사용하여 해당 region의 Availability Zone에서 하나 이상의 새로운 EBS volume을 만들 수 있습니다.

## Security

IAM은 EBS volume에 접근 제어를 할 수 있습니다. EBS 부팅 volume과 data volume은 물론 snapshot도 완벽하게 암호화합니다.

## Cost Model

Amazon EBS은 provision한 것에 대해서만 지불합니다. Amazon EBS는 3가지 지불 구성 요소가 있습니다. provisioned storage, I/O requests, 그리고 snapshot storage. Amazon EBS General Purpose (SSD),
Throughput Optimized (HDD), 그리고 Cold (HDD) volumes은 provision된 저장소의 GB당 월 별  요금이 청구됩니다. Amazon EBS Provisioned IOPS (SSD) volumes GB당 월 별 요금과 Provision된 IOPS당 월 별 청구됩니다. 
모든 종류의 volume에 대하여, Amazon EBS snapshots 저장된 data의 GB 당 월 별 요금이 청구됩니다.

