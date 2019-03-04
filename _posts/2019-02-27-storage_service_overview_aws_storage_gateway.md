---
layout: post
title:  "AWS Storage Services Overview - AWS Storage Gateway
date: 2019-02-27
categories: SAA
author: yogae
---

AWS Storage Gateway는 회사의 on-premise IT 환경과 AWS 저장소 infrastructure간에 integration을 제공하기 위해 on-premise software appliance와 cloud 기반의 저장소를 연결합니다. AWS Storage Gateway는 industry-standard 저장소 protocol을 지원합니다.

AWS Storage Gateway software appliance를 data center나 EC2 instance에 설치할 수 있는 virtual machine(VM) image나로 다운받을 수 있습니다. gateway를 설시하고 AWS account를 할당하면 gateway-cached volume, gateway-sorted volume, 또는 gateway-virtual tpe library(VTL)를 생성하기위해 AWS Management Console을 사용할 수 있습니다.

 gateway-cached volume으로 Amazon S3를 primary data를 cache하기 위해 사용할 수 있습니다. 

Gateway-stored volume은 비동기적으로 AWS에 data를 backup하면서 primary data를 local에 저장합니다.

gateway-VTL은 offline data를 archiving할 수 있습니다.

## Usage Patterns

기업 file 공유, 기존 사내 backup application이 Amazon S3에 기본 백업을 저장하고, 재난 복구를 수행하고, cloud를 기반으로하는 compute resource에 data를 mirroring하고 나중에 Amazon Glacier에 archiving하는 사례가 있습니다.

## Performance

AWS Storage Gateway VM은 application, Amazon S3, 기반으로하는 on-promise 저장소 사이에 있어서 그 성능은 여러가지 요소에 따라 달라집니다.(속도, 기반으로하는 local disk의 구성, network bandwidth)

AWS Storage Gateway는 변화가 있는 data만 upload합니다. throughput을 증가시키고 network 비용을 감소시키기 위해서 on-premises gateway와 AWS를 연결하는 AWS Direct Connect를 사용할 수 있습니다.

## Durability and Availability

AWS Storage Gateway는 Amazon S3 또는 Amazon Glacier에 upload하여 on-premise application data를 영원히 저장합니다.

## Scalability and Elasticity

gateway-cached와 gateway-stored volume을 구성하면 AWS Storage Gateway는 data를 Amazon S3에 저장합니다. 따라서 s3의 확장성과 탄력성을 보장합니다.

gateway-VTL 구성하면 AWS Storage Gateway는 Amazon s3 또는 Amazon Glacier에 data를 저장합니다.

## Security

IAM는 AWS Storage Gateway로 접근을 관리하여 보안을 제공합니다.

AWS Storage Gateway는 AWS로 전송하거나 받는 모든 data를 SSL을 사용하여 encrypt합니다. 