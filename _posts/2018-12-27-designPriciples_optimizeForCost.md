---
layout: post
title:  "Design Principles - Optimize for Cost"
date: 2018-12-27
categories: SAA
author: yogae
---

존재하는 architecture를 cloud로 옮길 때 AWS의 규모의 경제 효과로 자본 지출을 줄이고 비용 절감 효과를 얻을 수 있습니다. 더 많은 AWS 기능 반복 및 사용하여 비용 최적화 된 cloud architecture를 만들 수있는 기회를 더 많이 얻을 수 있습니다.

> [Cost Optimization with AWS](https://d0.awsstatic.com/whitepapers/Cost_Optimization_with_AWS.pdf)

## Right Sizing

AWS는 많은 use case를 위해 넓은 범위의 resource type과 configuration을 제공합니다. 예를 들어, Amazon EC2, Amazon RDS, Amazon Redshift 그리고 Amazon ES와 같은 서비스는 많은 instance type을 제공합니다. 어떤경우에는 가장 싼 type이 요구조건에 알맞은 처리일 것입니다. 다른 경우, 더 적지만 더 큰 instacne type을 사용하는 것이 전체 비용을 줄이고 더 좋은 성능을 야기시킬 것 입니다. 작업 부하가 CPU, RAM, 네트워크, 저장소 크기 및 I/O를 사용하는 방식에 따라 응용 프로그램 환경을 벤치마킹하고 올바른 instance type을 선택해야합니다.

비슷하게 요구에 맞게 알맞은 storage solution을 선택하여 비용을 줄일 수 있습니다. 예를들어, Amazon S3는 다양한 storage class(standard, Reduced Redundancy, Standard-Infrequent Access)를 제공합니다. Amazon EC2, Amazon RDS, Amazon ES와 같은 다른 서비스는 다른 EBS volume type(magnetic, general purpose SSD, provisioned IOPS SSD)을 지원합니다.

continuous monitoring과 tagging으로 계속 비용을 감소시킬 수 있습니다. application 개발 처럼 cost optimization은 반복적인 과정입니다. application과 이것의 사용은 시간이 지남에 따라 발전하고 AWS에서는 계속하여 새로운 option을 출시하기 때문에 지속적으로 solution을 평가하는 것은 중요합니다.

AWS는 비용 절감 기회를 파악하고 리소스를 올바른 크기로 유지하는 데 도움이되는 도구를 제공합니다. 이러한 도구의 결과를 해석하기 쉽게하려면 AWS 리소스에 대한 tagging 정책을 정의하고 구현해야합니다. build process에서 tagging을 만들 수 있고 tagging을 AWS Elastic Beanstalk와 AWS OpsWorks와 같은 AWS 관리 도구로 자동화 할 수 있습니다. AWS Config에서 제공하는 관리되는 규칙을 사용하여 특정 태그가 리소스에 적용되는지 여부를 평가할 수도 있습니다.

## Elasticity

AWS를 사용하면서 비용을 절약하는 다른 방법은 platform의 단력성의 이점을 이용하는 것 입니다. 필요할 때 수평적으로 확장하고 필요없을 때 자동적으로 축소하기 위하여 가능한 많은 Amazon EC2를 자동으로 확장할 수 있도록 구현해야합니다. 추가적으로 사용하지 않을 때 비 생산 작업 부하를 자동으로 끌 수 있습니다. 궁극적으로 유휴 또는 중복 reosurce에 비용을 지불하지 않기 위하여 어떤 compute 부하를 AWS Lambda로 구현할 수 있는지 고려해야합니다.

용량을 결정할 필요가 없는 AWS 관리 서비스(ELB, CloudFront, SQS, Kinesis Firehose, Lambda, SES, CloudSearch, EFS)로 EC2 부하를 대체하거나 용량을 쉽게 조정(DynamoDB, RDS, ES)할 수 있도록 합니다.

## Take Advantage of the Variety of Purchasing Options

Amazon EC2 On-Demand instance 가격 책정은 장기적인 약속없이 최대 유연성을 제공합니다. 비용을 감소시킬 수 있는 Reserved Instance와 Spot Instance가 있습니다. 

### Reserved Instances

Amazon EC2 reserved instance는 On-Demand instance 가격과 비교하여 할인된 가경으로 EC2 computiong 용량을 예약할 수 있습니다. 최소 용량 요구사항을 예측할 수 있는 application에서는 이상적입니다. 가장 많이 사용하고 예약이 필요한  compute resource를 찾기 위해 AWS Trusted Advisor 또는 Amazon EC2 usage report와 같은 도구를 사용할 수 있습니다. reserved instance 구매에 따라 할인은 매월 계산서에 반영됩니다. 기술적으로 On-Demand EC2 instance와 reserved instance의 차이는 없습니다.

reserved 용량 option은 다른 service(Redshift, RDS, DynamoDB, CloudFront)에도 존재합니다.

### Spot Instances

덜 안정된 작업 부하의 경우 spot instance를 사용하는 것을 고려해야합니다. Amazon EC2 Spot instance는 예비 Amazon EC2 computing 용량을 사용할 수 있습니다. spot instance는 On-Demand 가격과 비교하여 할인된 가격으로 사용가능하므로 application 운영의 비용을 절약할 수 있습니다.

EC2 비용을 낮출 수 있도록 EC2 instance는 사용하지 않도록 요청할 수 있습니다. spot instance의 시간별 가격은 Amazon EC2에 의해 정해지고 스팟 인스턴스의 장기 공급 및 수요에 따라 점진적으로 조정됩니다. Spot instance는 용량이 사용가능하고 요청한 최대 시간당 가격이 spot 가격을 초과한다면 언제든지 사용할 수 있습니다.

결론적으로 spot instance는 장애를 견디기 위한 부하 처리에 훌륭합니다. 또한 spot instance를 보다 예측가능한 사용을 요구할 때 사용할 수 있습니다. 예를들어 예측가능한 최소 용량과 예측할 수 없는 추가 compute resource를 결합하기 위해 reserved, On-Demand, 그리고 spot instance를 결합할 수 있습니다. 이것은 처리량과 application의 성능을 향상시키는 비용효율적인 방법입니다.