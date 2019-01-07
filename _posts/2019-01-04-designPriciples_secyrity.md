---
layout: post
title:  "Design Principles - Security"
date: 2019-01-04
categories: SAA
author: yogae
---

전통적인 IT infrastructure에서 이미 익숙한 대부분의 보안관련 도구나 기술은 cloud에서 사용가능합니다. 동시에 AWS는 다양한 방법으로 보안을 개선합니다. AWS는 보안 관리의 설계를 정형화할 수 있는 platform입니다. 이는 관리자와 IT 부서에서 system의 사용을 단순화하여 지속적인 방법으로 보다 쉽게 보안 심사를 할 수 있는 환경을 만듭니다.

## Use AWS Features for Defense in Depth

AWS는 심층적인 방법으로 방어 기능을 갖춘 아키텍처를 구축하는데 도움이 되는 많은 기능을 제공합니다. network 계층에서는 subnet, security group, routing control을 사용하여 infrastructure를 독립시키는 VPC topology를 구축할 수 있습니다. AWS WAF 같은 service는 SQL injection과 application code의 취약점으로 부터 web application을 보호합니다. access controll을 위해서는 policy의 집합을 정의하고 그것들을 user, group, AWS resource에 할당하여 사용할 수 있습니다. AWS는 data를 보호하기 위하여 많은 option을 제공합니다.

> [AWS Cloud Security](https://aws.amazon.com/ko/security/)

## Share Security Responsibility with AWS

AWS는 공유 보안 책임 model을 기반으로 운영됩니다. AWS는 기본 cloud infrastructure의 보안을 책임지고 AWS에서 배포한 작업 보안의 책임은 서비스 AWS 사용자에게 있습니다. 공유 보안 책임 model은 책임의 범위를 줄이고 AWS 관리 service의 사용을 통한 핵심 역량에 집중할 수 있도록 합니다. 예를들어 RDS와 Amazon ElastiCache와 같은 service를 사용할 때 보안 패치는 자동으로 적용됩니다. 이는 팀의 운영 overhead를 줄여줄뿐만 아니라 취약성에 대한 노출을 줄일 수 있습니다.

## Reduce Privileged Access

server가 프로그램 가능한 reosource일 때 많은 보안 관련 혜택을 얻을 수 있습니다. 필요할 때 언제든지 server를 변경할 수 있는 능력은 게스트가 제품 환경에 액세스할 필요성을 없앨 수 있습니다. instance에 issue가 있다면 자동 또는 수동으로 instance를 제거하고 대체할 수 있습니다. 그러나 instance를 대체하기 전에 배포 환경에서 문제를 재현하고 지속적인 배포 프로세스를 통해 수정 사항으로 배포 할 수 있도록 log data를 수집하고 중앙 집중식으로 저장해야합니다. 이 방법을 사용하면 로그 데이터가 troubleshooting에 도움이되고 보안 event에 대한 인식이 높아집니다. 이는 server가 일시적인 elastic compute 환경에서는 특히 중요합니다. log 정보를 수집하기 위하여 Amazon CloudWatch Logs를 사용할 수 있습니다. 직접 접근이 불가한 곳에서 view를 통합하고 resource 그룹에 활동을 자동화하기 위해 AWS Systems Manager와 같은 서비스를 구현할 수 있습니다. 이러한 요청을 ticketing system과 통합하여 액세스 요청을 승인 한 후에만 추적하고 동적으로 처리 할 수 있습니다.

다른 보통의 보안 위험은 저장된 long term credentials 또는 service 계정을 사용하는 것 입니다. 전통적인 환경에서는 service 계정에는 종종 configuration file에 저장되어 있는 long term credentials이 할당됩니다. AWS에서는 EC2 instance에서 application 운영을 위한 권한을 수여하기 위하여 short-term credentials(자동으로 분배되고 순환하는) 사용하는 IAM role을 사용합니다. Mobile application에서는   임시 token으로 client 기기가 AWS resource에 접근할 수 있도록 Amazon Cognito를 사용할 수 있습니다. AWS Management Console 사용자 처럼 AWS 계정에서 IAM user를 생성하는 것 대신 임시 token을 사용하여 federated 접근을 제공할 수 있습니다. 직원이 조직을 떠나 조직의 ID directory에서 제거되면 해당 직원도 자동으로 AWS 계정에 대한 액세스 권한을 잃습니다.

## Security as Code

## Real-Time Auditing