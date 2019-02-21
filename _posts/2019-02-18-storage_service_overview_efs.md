---
layout: post
title:  "AWS Storage Services Overview - Amazon EFS"
date: 2019-02-18
categories: SAA
author: yogae
---

Amazon Elatic File System(Amazon EFS)는 EC2 instance에 service하는 network file system입니다. Network File System version 4(NFSv4)과 4.1(NFSv4.1)를 지원합니다. provision 할 필요가 없고 최소 사용료 및 setup 비가 없습니다(사용한 만큼만 비용 지불). Amazon EFS는 petabytes까지 성장할 수 있는 높은 확장성을 제공하여 EC2 instance에서 resion 내에서 data로 대규모 병렬 접근을 지원하도록 설계되었습니다. 또한 region내에서 여러 Availability Zone에 걸쳐 data와 metadata를 저장할 수 있어 고가용성과 높은 내구성을 지원합니다.

## Usage Patterns

multi threaded, 여러 EC2 instance에서 동시에 data에 접근하거나 높은 수준의 처리량 및 초당 input / output 처리하는 application의 요구를 충족하도록 설계되었습니다. 각 file 처리를 위한 latency overhead가 작도록 설계 되어 높은 성능과 multi-client 접근을 필요로 하는 상황에 Amazon EFS가 이상적입니다.

Amazon EFS는 고도로 병렬화된 workload를 지원하며 대규모 데이터 및 분석, 미디어 처리, 컨텐츠 관리, 웹 서비스 및 홈 디렉토리의 성능 요구 사항을 충족하도록 설계되었습니다.

## Performance

Amazon EFS file system은 petabyte 크기로 탄력적으로 증가시키고 region 내에서 EC2 instance로 부터 대량 병렬 접근을 허용하여 storage server의 숫자를 무제한적으로 증가시킬 수 있습니다.

Amazon EFS에는 General Purpose와 Max I/O 두가지 performance mode가 있습니다. General Purpose performance mode는 default mode이고 대부분의 file system에 적합합니다. 그러나 file system에 초당 7,000 file operation이 초과하는 workload가 발생한다면 Max I/O performance mode를 추천합니다. Max I/O performance mode에서는 더 file operation에 더 높은 latency가 발생하지만 더 높은 수준의 operation과 처리량이 가능하도록 file system을 확장합니다.

file-based workload의 까다로운 성격때문에 Amazon EFS는 단기간에 높은 처리량 수준으로 burst하도록 최적화되어 있으며 나머지 시간에는 낮은 처리량을 제공합니다. Credit system은 EFS file system이 burst할 수 있는지 측정합니다. 활동이 없거나 처리량이 기본 속도 미만일 때 credit을 누적합니다. 이렇게 누적된 burst credit을 통해 파일 시스템은 처리량을 기준 속도 이상으로 높일 수 있습니다.

새롭게 만들어진 file system은 2.1Tib의 credit balace(기준 속도가 50 Mib/s이고 burst 속도가 100 Mib/s)로 시작합니다.

>If your application is parallelizable across multiple instances, you can drive higher throughput levels on your file system in aggregate across instances. If your application can handle asynchronous writes to your file system, and you’re able to trade off consistency for speed, enabling asynchronous writes may improve performance.

## Durability and Availability

Amazon EFS는 높은 내구성과 가용성을 지원하도록 설계되었습니다. 각 Amazon EFS file system object는 region에 여러 Availability Zone에 중복되어 저장됩니다.

## Scalability and Elasticity

Amazon EFS는 application의 방해하지 않고 file을 추가하거나 삭제하면서 자동으로 file system 저장소의 용량을 증가시키거나 감소시킵니다.  EFS file system는 빈 file system에서 수 petabyte까지 자동적으로 증가할 수 있고 준비, 할당 또는 관리가 없습니다.

## Security

EFS file system 보안을 계획할 때 3가지 접근 제어 level이 있습니다. IAM 권한; EC2 instance 와 mount taget의 security group; Network File System-level 사용자, 그룹 그리고 권한

EFS file system object는 object에 action을 수행하는데 필요한 권한을 정의하는 Unix-style mode에서 작동합니다. 사용자와 그룹은 숫자 식별자에 mapping 되어 file의 ownership을 나타냅니다. Amazon EFS에 있는 file과 directory 하나의 소유자와 하나의 그룹이 소유합니다. 사용자가 file system object에 접근하려할 때 Amazon EFS는 숫자 식별자를 사용하여 권한을 확인합니다.

## Cost Model

file을 추가할 때 EFS file system은 동적으로 확장하고 사용한 저장소의 용량만큼 지불합니다. file을 제거할 때는 Amazon EFS는 동적으로 줄어들고 제거된 data에 대한 지불은 중지됩니다. 대역폭이나 요청에 대한 요금은 없으며 최소한의 약속이나 선불 수수료는 없습니다.