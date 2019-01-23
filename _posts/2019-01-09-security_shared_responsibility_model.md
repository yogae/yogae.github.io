---
layout: post
title:  "AWS Security Bsest Practices - Know the AWS Shared Responsibility
Model"
date: 2019-01-09
categories: SAA
author: yogae
---

AWS는 service의 type에 따라 다른 shared responsibility model을 제공합니다.

- Infrastructure services 
- Container services 
- Abstracted services 

Amazon EC2와 같은 infrastructure service를 위한 shared responsibility model은 AWS는 아래의 asset의 보안을 관리하도록 지정합니다.

- Facilities 
- Physical security of hardware 
- Network infrastructure 
- Virtualization infrastructure 

Amazon EC2에서 고객은 아래의 asset의 보안을 책임집니다.

- Amazon Machine Images (AMIs) 
- Operating systems 
- Applications 
- Data in transit 
- Data at rest 
- Data stores 
- Credentials 
- Policies and configuration 

## Understanding the AWS Secure Global Infrastructure 

AWS secure global infrastructure와 AWS에서 관리하는 service는 AWS가 관리를하고 기업의 system과 개인 application을 위한 신뢰할 수 있는 기반을 제공합니다.

### Using the IAM Service

IAM service는 AWS secure global infrastructure의 구성요소 중에 하나입니다. IAM으로 사용자, password 같은 security credential, access keys 그리고 permissions policies를 중앙 집중적으로 관리할 수 있습니다. 

IAM 사용자가 수행하는 활동들은 모두 AWS account에 비용이 청구됩니다.

### Regions, Availability Zones, and Endpoints

AWS secure global infrastructure의 구성요소인 regions, Availability Zones, and endpoints와 친숙할 것 입니다. 

network 대기 시간 및 규정 준수 관리를 위해 AWS region을 사용해야합니다. 특정 region에 data를 저장할 때 region의 외부에는 복제되지 않습니다. data를 across region에 복제하는 것은 사용자의 책임입니다. 준수와 network 대기 시간을 염두에 두고 data를 저장할 지역을 선택해야합니다.

지역은 가용성을 염두해 두고 설계되었으며 최소한 두 개 이상의 Availability Zones으로 구성됩니다. 시스템은 여러 가용 영역에 걸쳐있을 수 있으며 재해 발생시 가용성 영역의 일시적 또는 장기간의 장애를 극복하기 위해 시스템을 설계하는 것이 좋습니다.

## Sharing Security Responsibility for AWS Services

AWS는 다양한 infrastructure와 platform service를 제공합니다. security와 AWS service의 shared responsibility를 이해하기 위해서  infrastructure, container 그리고 abstracted services 세가지의 카테고리로 분류할 수 있습니다. 각각의 카테고리는 조금씩 다른 보안 ownership model을 가지고 있습니다.

- Infrastructure Services: 
  - 이 카테고리는 compute service를 포함합니다. 이 service로 cloud infrastructure를 architect하고 구성할 수 있습니다. 운영 체제를 제어하고 가상화 스택의 사용자 계층에 대한 액세스를 제공하는 ID 관리 시스템을 구성하고 운영합니다.
  - Amazon EC2와 관련 service인 Amazon EBS, Auto Scaling, Amazon VPC service를 포함합니다.
- Container Services:  
  - 이 카테고리의 service는 일반적으로 별도의 Amazon EC2 또는 기타 infrastructure instance에서 실행되지만 때로는 운영 체제 또는 플랫폼 계층을 관리하지 않습니다. AWS container application을 위한 관리 service를 제공합니다. Network 제어(firewall rule 같은) 구성과 관리에 책임을 지고 IAM과 별도로 플랫폼 수준의 ID와 접근을 관리에 책임이 있습니다.
  - contatiner service에 접근하기 위한 Data 그리고 firewall rule은 사용자에게 책임이 있습니다.
  - Amazon Relational Database Services (Amazon RDS), Amazon Elastic Map Reduce (Amazon EMR) and AWS Elastic Beanstalk 을 포함합니다.
- Abstracted Services: 
  - 이 카테고리는 높은 수준의 storage, database, 그리고 messaging service를 포함합니다. 이 service는 platform 또는 cloud application을 구성하고 운영하는 관리 계층을 추상화합니다. AWS API를 사용하여 추상화된 service의 endpoint에 접근하고 AWS는 기반 service component 또는 운영 system을 관리합니다.
  - Amazon Simple Storage Service(Amazon S3), Amazon Glacier, Amazon DynamoDB, Amazon Simple Queuing Service (Amazon SQS), and Amazon Simple Email Service (Amazon SES).

## Using the Trusted Advisor Tool

일부 AWS Premium 지원 계획에는 service의 snapshot을 제공하는 Trusted Advisor 도구에 대한 액세스가 포함되어 있습니다. 일반적인 보안 잘못된 구성, 시스템 성능 향상을 위한 제안 및 활용도가 낮은 리소스를 식별하는 데 도움이 됩니다.

Trusted Advisor는 아래 추천 보안 사항을 확인합니다.

- 오직 작은 주소의 subnet을 위한 보통의 관리 port로 접근 제한합니다. 22(SSH), 23(Telnet), 3389(RDP), 5500(VNC)
- 보통의 database port으로의 접근을 제한합니다. 1433(MSSQL Server), 1434(MSSQL Monitor), 3306(MySQL), Oracle(1521), 5432(PostgreSQL)
- 루트 AWS 계정에 two-factor 인증이 사용되고 있는지 확인합니다.

