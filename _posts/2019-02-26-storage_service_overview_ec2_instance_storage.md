---
layout: post
title:  "AWS Storage Services Overview - Amazon EC2 Instance Storage"
date: 2019-02-26
categories: SAA
author: yogae
---

Amazon EC2 instance store volume은 많은 EC2 instance type에 일시적인 block-level 저장소를 제공합니다. 이 저장소는 EC2 instance를 hosting하는 물리적인 server에 같은 곳에 있는 미리 구성되어는 disk 저장소의 block으로 구성됩니다. disk 저장소의 용량은 EC2 instance type에 따라 다양합니다. (micro instance와 c4 instance 같은 instance type은 instance storage가 제공되지 않고 오직 Amazon EBS만 사용합니다.)

AWS는 두가지 EC2 instance families(storage-optimized(i2), dense-storage(d2))를 제공합니다.

## Usage Patterns

EC2 local instance store volume은 계속적으로 변하는 정보를 일시적으로 저장하기에 이상적입니다. 이 저장소는 instance의 lifetime동안 하나의 EC2 instance에서만 오직 사용될 수 있습니다. EBS volume과 다르게 Instance store volume은 다른 instancedp detach되거나 attach 될 수 없습니다. 

## Performance

SSD를 기반으로 하지않는 대부분의 EC2 instance families는 standard EBS volume과 유사한 성능 특징을 가집니다. EC2 instance virtual machine과 local instance store volume은 같은 물리적인 server에 위치하기 때문에 이 저장소와의 상호작용이 매우 빠릅니다. 

EC2가 디스크를 가상화하는 방식 때문에  instance store volume의 모든 위치에 대한 첫 번째 쓰기 작업은 후속 쓰기 작업보다 느리게 수행됩니다.(prewarm 작업을 통하여 높은 disk 성능을 보장할 수 있습니다.)

## Durability and Availability

Amazon EC2 local instance store volume은 내구성있는 disk 저장소로써 사용되도록 설계되지 않았습니다. EBS volume data와 다르게 instance store volume에 있는 data는 EC2 instance의 life 기간 동안만 유지됩니다. instance를  reboot하면 instance store volume data는 유지되지만, EC2 instance가 stop, restart, terminate 또는 fail하면 모든 data가 손실됩니다.

## Scalability and Elasticity

Instance type에 따라 Amazon EC2 local instance store volume의 숫자와 용량은 정해져있습니다. 비록 instance store volume은 숫자를 증가시키거나 감소시킬 수 없지만 확장가능하고 탄력적입니다. 실행중인 EC2 instance의 숫자를 증가시키거나 감소시켜서 확장가능합니다.

## Security

IAM는 user가 수행할 수 있는 처리를 안전하게 관리할 수 있도록 도와줍니다. EC2 instance로 접근은 guest operation system으로 관리됩니다. instance storage volume에 있는 data를 민감한 data를 저장하고 싶다면 data를 encrypt하기를 추천합니다.

## Cost Model

EC2 instance의 비용은 local instance store volume을 포함합니다. 다른 Availability Zone 또는 Amazon EC2 region 외부의 Amazon EC2 instance storage volume으로 전송되거나 이로 부터 데이터가 전송되는 경우 데이터 전송 요금이 부과 될 수 있습니다.

