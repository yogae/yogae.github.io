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

## Security as Code

## Real-Time Auditing