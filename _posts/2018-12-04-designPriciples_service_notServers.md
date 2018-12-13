---
layout: post
title:  "Design Principles - Service, Not Servers"
date: 2018-12-04
categories: SAA
author: yogae
---

배포하고 관리하고 운영하기 위해서 다양한 기본 기술 component가 필요합니다. 전통적인 infrastructure에서는 회사에서 모든 component를 구성하고 운영했습니다. 

AWS는 기업이보다 신속하게 IT 비용을 절감 할 수 있도록 광범위한 컴퓨팅, 스토리지, 데이터베이스, 분석, 애플리케이션 및 배포 서비스를 제공합니다.

## Managed Services

AWS 관리 서비스는 개발자가 application 개발에 집중할 수 있도록 building block을 제공합니다. 

관리 서비스 예시:

 - Amazon SQS
 - Amazon S3
 - Amazon CloudFront for content delivery 
- ELB for load balancing 
- Amazon DynamoDB for NoSQL databases 
- Amazon CloudSearch for search workloads 
- Amazon Elastic Transcoder for video encoding 
- Amazon Simple Email Service (Amazon SES) for sending and receiving emails

## Serverless Architectures

Serverless achitecture는 작동하고 있는 application을 운영하는 복잡성을 감소시킵니다. server infrastructure의 관리하지 않고 mobile, web, analytics, CDN business logic, 그리고 IoT를 위한 Event-driven과 sychronous 서비스를 구성할 수 있습니다. 관리할 필요가 없고 사용하지 않는 server에 비용을 지불하지 않기 때문에 비용이 감소시킬수 있으며, 고 가용성 구현을 위한 redundant infrastructure를 구축할 수 있습니다.

예를들어, AWS Lambda compute service에 code를 올리고 AWS infrastructure를 사용하여 code를 실행 할 수 있습니다. AWS Lambda는 code가 실행되는 100ms마다 그리고 code가 trigger되는 횟수에 따라 비용이 청구됩니다. Amazon API Gateway를 사용하여 infinitely scalable synchronous API를 개발할 수 있습니다. static content를 serving하는 Amazon S3와 결합하여 완벽한 web application을 제공할 수 있습니다. 

mobile과 web application에서는 authentication, network state, storage, sync를 처리하는 back-end solution를 관리하지 않기 위해 Amazon Cognito를 사용할 수 있습니다. Amazon Cognito는 사용자를 위한 unique 식별자를 생성합니다.

식별자는 다른 AWS resource를 사용가능하게하고 제한하는 정책과 연관되어 있습니다.  Amazon Cognito는 일시적은 AWS credentials를 사용자에게 제공하므로 mobile application이 AWS service를 보호하는 IAM과 상호작용 할 수 있습니다. 예를들어, IAM을 사용하여 특정 end user가 s3 bucket folder에 접근을 제한할 수 있습니다.

IoT application에서는 회사는 전통적으로 device와 서버간의 통신을 위하여 device gateway로서 자체 서버를  준비, 운영, 규모, 유지해야했습니다. AWS IoT는 운영 overhead없이 사용에 따라 자동적으로 확장되는 완전 관리 device gateway를 제공합니다.

Serverless architecture는 edge location에 반응형 서비스를 운영할 수 있도록 합니다. AWS Lambda@Edge는 lambda function이 Amazon CloudFront edge location에서 Cloud Event에 응답합니다. 이를 통해  low-latency solutions의 패턴과 기본 응용 프로그램을 변경하지 않고 기능을 도입 할 수 있습니다.

Data 분석에서는 큰 규모의 data query를 관리하는 것은 복잡한 infrastructure의 관리가 필요합니다. Amazon Athena는 standard SQL을 사용하여 쉽게 S3에 저장된 data를 분석할 수 있는 interactive query service 입니다. Athena는 serverless이여서 관리할 infrastructure가 없고 query한 만큼만 지불합니다.