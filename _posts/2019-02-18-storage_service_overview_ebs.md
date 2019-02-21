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

- Provisioned IOPS SSD (io1)

- Throughput Optimized HDD (st1)

- Cold HDD (sc1)

