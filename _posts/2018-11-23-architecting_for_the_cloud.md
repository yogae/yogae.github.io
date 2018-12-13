---
layout: post
title:  "Architecting for the Cloud"
date: 2018-11-23
categories: SAA
author: yogae
---
## Design Principles

### Scalability

#### Scaling Vertically

#### Scaling Horizontally

#### 시나리오

- Stateless Applications
- Distribute Load to Multiple Nodes
  - Push model
    - 서버에서 정보를 clients에서 전송 형태
    - Ex) push notification
    - ELB를 사용할 수 있음 -> 
    - Route 53의 DNS round robin을 사용 -> 사용하기 쉬우나 항상 route 설정에 따라 동작하지 않을 수 있는 문제가 있음
  - Pull model
    - clients가 서버에 요청하여 정보를 받아오는 형태
    - Ex) 전통적인 client / server architecture
    - 비동기 또는 event-driven 작업에 적용가능
    - SQS 또는 Kinesis를 사용가능

- Statless Components

  - http cookie를 사용하여 session 정보를 저장

    - 문제점: 

      1. cookie를 항상 validate 해야함

      2. cookie가 모든 request에 전송되므로 불필요한 latency 발생

    - 해결방안:

      - database에 정보를 저장(DynamoDB 는 확장성, 고가용성 및 내구성 면에서 좋음)

  - 용량이 큰 파일을 요구하는 시나리오

    - 해결방안:
      - s3, EFS를 공유 저장 공간으로 사용

  - 복잡한 multi-step workflow

    - AWS Step Functions을 사용

- Stateful Components
  - 모든 transactions의 session을 특정 compute resource에 바인드할 것이다.
  - 이미 존재하는 session은 새로운 compute node를 할달해도 바로 효과가 없다.(기존에 존재하는 transactions들은 기존의 session을 그대로 사용해야하기 때문에)
  - node가 종료되거나 사용할 수 없게 되었을 경우 session에 저장 되어 있는 정보를 찾을 수 없다.
- Implement Session Affinity
  - ALB의 Sticky session feature 사용하 특정 instance에 user의 session을 바인딩할 수 있다.
  - Client-side에 load balancing하는 코드를 작성하여 컨트롤 할 수 있다.
    - 더 복잡함을 더할 수 있다.
    - load balancer가 요구조건에 충족되지 않을 경우 유용할 수 있다.

- Distributed Processing
  - 많은 양의 데이터를 하나의 compute resource로 처리하지 못할 경우 분산 처리가 필요하다.
  - task와 데이터를 작은 단위의 일로 나누어 compute resource로 실행 할 수 있다.

- Implement Distributed Processing
  - offline batch job을 AWS Batch, AWS Glue, and Apache Hadoop등의 distributed data processing engine을 사용하여 수평적으로 스케일할 수 있다.
  - AWS에서는 Hadoop workload를 실행하기 위해서 EMR을 사용할 수 있다.
  - Amazon Kinesis는 확장성을 위해 여러 Amazon EC2 또는 AWS 람다 리소스가 사용할 수 있는 여러 개의 샤드로 데이터를 분할합니다.

### Disposable Resources Instead of Fixed Servers

#### Instantiating Compute Resources

구성 및 코드를 사용하여 새 리소스를 수동으로 설정하지 않을 수 있습니다. 

이 프로세스를 자동화되고 반복 가능한 프로세스로 만들어 리드 타임이 길지 않고 사람의 실수가 발생하지 않도록 해야 합니다. 이것을 달성하기 위한 몇 가지 방법이 있다.

- Bootstrapping
  - AWS reosource를 시작할 때 default configuration으로 시작할 수 있다. 그리고 sftware 또는 data를 copy하는 bootstrapping actions을 실행할 수 있다.
  - user data scripts and cloud-init 지시사항으로 새로운 EC2 instance를 설정할 수 있다. Chef or Puppet 같은 configuration management tool과 간단한 scripts를 사용할 수 있다.
- Golden Images
  - 특정 AWS resource type을 그 resource의 snapshot인 Golden Image로 시작할 수 있다. bootstrapping과 비교하면 Golden Image는 더 빠른 시작시간과 dependencies를 제거할 수 있다. Auto-scaled 환경에서 중요하다.
  - EC2 instance를 customize하고 AMI을 만들어 저장할 수 있다. 매번 configuration을 변경하고 싶다면 Golden Image를 만들어야 한다.
  - On-promise 가상환경을 가지고 있다면 다양한 가상환경 포맷에서 AMI로 변환하기 위해서 VM Import/Export를 사용할 수 있다.
- Containers
  - AWS Elastic Beanstalk, Amazon Elastic Container Service(ECS) 그리고 AWS Fargate는 EC2 instance cluster를 통해 multi container를 배포하고 관리할 수 있게 한다. golden Docker images를 빌드 할 수 있고 ECS Container Registry를 이용하여 관리할 수 있다.
  - container환경의 대안으로 Kubernetes와 EKS를 사용할 수 있다. 
- Hybrid
  - 2가지의 접근을 결하하여 사용할 수 있다. configuration의 어떤 부부은 golden image에 넣고 다른 부분은 bootstrapping으로 동적으로 설정할 수 있다.
    - 변하지 않거나 외부 dependencies를 넣는 아이템은 golden image의 부분이 된다.
    - 자주 변하거나 다양한 환경들은 bootstrapping으로 동적으로 set up 한다. 
  - AWS Elastic Beanstalk는 hybrid 모델을 따른다. preconfigured run
    time environments을 제공하여 자신의 AMI로 초기화 한다. 또한, .ebextensions configuration 파일로 bootstrap action을 실행할 수 있다.

#### Infrastructure as Code

지금까지 논의한 원칙의 적용을 개별 리소스 수준으로 제한할 필요는 없습니다. AWS asset은 프로그램화 할 수 있기때문에 소프트웨어 개발에서 techniques, practices, and tool를 적용하여 전체 인프라를 재사용 가능하고, 유지 관리 가능하고, 확장 가능하며, 테스트할 수 있습니다.

- AWS CloudFormation templates
  - AWS CloudFormation templates은 관련 AWS 리소스 모음을 만들고 관리할 수 있는 쉬운 방법을 제공합니다. 또한, 순차적이고 예측가능한 fashion으로 provision하고 update할 수 있습니다.

### Automation

전통적인 IT 인프라스트럭처에서는 다양한 event에 대하여 수동적으로 대응해야만 합니다. AWS에서 배포할 때 시스템의 안정성과 조직의 효율성을 향상시키기 위하여 자동화 할 수 있다.

#### Serverless Management and Deployment

serverless 패턴을 채택하면,  deployment pipeline의 자동화에 초점을 둡니다. AWS는 기본 서비스, 규모 및 가용성을 관리합니다. AWS CodePipeline, AWS CodeBuild 및 AWS CodeDeploy는 이러한 프로세스의 배포 자동화를 지원합니다.

#### Infrastructure Management and Deployment

- AWS Elastic Beanstalk

  - 이 서비스를 사용하여 web application과 Java, .NET, PHP, Node.js, Python, Ruby, Go, Docker로 개발된 서비스를 Apache, NGINX, Passenger, IIS와 같은 친숙한 서버에 배포와  확장할 수 있습니다
  - 개발자들은 application code을 쉽게 업로드하고 자동적으로 resource provisioning, load balancing, auto scaling, monitoring과 같은 세부사항을 관리할 수 있습니다.

- Amazon EC2 auto recovery

  EC2 instance와 자동적으로 복구하는 Amazon CloudWatch alarm을 만들 수 있다. 복구된 instance는 인스턴스 ID,  private IP addresses, Elastic IP addresses, and all instance, metadata를 포함하여 원본 instance와 같다. 하지만 이 기능은 해당 instance 구성에서만 사용할 수 있습니다. instance가 스턴스가 복구되는 동안 instance reboot으로 마이그레이션 되고 메모리에 있는 데이터는 사라집니다.

- AWS Systems Manager

  software inventory를 모으고 Windows와 Linux로 설정된 system image 만들고 임의의 명령을 자동적으로 실행할 수 있습니다. 이러한 서비스를 프로비저닝하면 운영 모델을 단순화하고 최적의 환경 구성을 보장 할 수 있습니다.

- Auto Scaling

  애플리케이션 가용성을 유지하고 정의한 조건에 따라 Amazon EC2, Amazon DynamoDB, Amazon ECS, Amazon Elastic Container Service for Kubernetes (Amazon EKS) 용량을 자동으로 늘리거나 줄일 수 있습니다.

  Auto Scaling을 운영하고 있는 원하는 수의 multiple AZ에 있는 정상적인 EC2 instance를 사용하고 있는지 확인할 수 있습니다. Auto Scaling은 수요가 급증하는 동안 자동적으로 EC2 instance의 수를 증가시킬 수 있고 사용량이 적이면 비용 절감을 위하여 용량을 감소시킬수 있다.

#### Alarms and Events

- Amazon CloudWatch alarms

  특정 메트릭이 특정 기간 동안 한계치를 넘었을 때 SNS message를 보내는 CloudWatch alarm을 만들 수 있습니다. SNS 메세지는 자동적으로 구독된 lambda function 실행할 수 있고 경고 message를 SQS queue에 쌓을 수 있습니다. 또한 HTTP 또는 HTTPS endpoint에 post request을 실행할 수 있습니다.

- Amazon CloudWatch Events

  AWS resources에서 변화를 설명하는 system event의 실시간 stream를 제공합니다. 간단한 rule을 사용하여 하나 또는 여러 대상(Lambda functions, Kinesis streams, SNS topics)에게 각각의 유형이 event를 route할 수 있습니다.

- AWS lambda scheduled events

  규칙적인 schedule에 lambda function을 만들고 AWS Lambda를 실행하기 위하여 설정할 수 있습니다.

- AWS WAF Secyrity automations

  AWS WAF는 응용 프로그램 가용성에 영향을 미치거나 보안을 손상 시키거나 과도한 자원을 소비 할 수 있는 웹 응용 프로그램 방화벽입니다. 

  일반적인 공격 패턴을 차단하는 응용 프로그램 별 사용자 지정 규칙을 만들 수있는 있습니다. 

  API를 통해 AWS WAF를 완벽하게 관리 할 수 있으므로 보안 자동화가 쉬워져 신속한 규칙 전파와 신속한 사고 대응이 가능합니다.

### Loose Coupling

application의 복잡성이 증가하면서 IT system의 요구 속성이 더 작고 느슨하게 결함된 components로 세분화 되었습니다. 이것은 IT system이 상호 의존성을 감소시키는 방법으로 디자인 되어야 한다는 것을 의미합니다. (하나의 component에서의 변화나 실패가 다른 component에 종속되어서는 안 됩니다.)

#### Well-Defined Interfaces

system에서 상호작용을 감소시키는 방법은 다양한 conponent이 RESTful API같은 기술에 의존하는 않는 interfaces를 통하여 소통하도록 하는 것입니다. 기술 구현 세부 정보가 숨겨져서 다른 component에 영향을 주지 않으면서 내부 구현을 수정할 수 있도록 할 수 있습니다. 이러한 인터페이스가 하위 호환성을 유지하는 한 다른 component의 배포가 분리됩니다. 이 세분화된 디자인 패턴은 microservuces architecture에 보통 언급됩니다.

Amazon API Gateway는 개발자가 모든 규모의 API를 쉽게 create, publish, maintain, monitor, 그리고  secure하는 완전 관리형 서비스 입니다. traffic 관리, authorization그리고 access control, monitoring, API version 관리하면서 수십만 이르는 동시 API콜까지 처리할 수 있습니다.

#### Service Discovery

작은 서비스의 집합으로 배포되는 application은 각각의 서비스들과의 상호작용에 의존합니다. 각각의 스비스는 여러 compute resource로 운영되기 때문에 각 서비스를 처리 할 수 있는 방법이 필요합니다. 

- 예를 들어 전통적인 infrastructure에서는 front-end web 서비스가 back-end web 서비스에 연결되어야 한다면 이 서비스가 운영되거 있는 compute resource의 IP 주소 hardcode했었습니다. cloud computing에서 이 방법은 아직 가능하지만 서비스들의 느슨한 결합을 위해서 네트워크 기술의 세부정보의 사전지식 없이 서비스를 사용할 수 있어야 합니다. 복잡성을 숨기는 것 외에도 아무때나 infrastructure의 세부사항을 변경할 수 있게 합니다.
- 아무때나 새로운 resource를 시작하거나 중지할 수 있는 cloud computing의 탄력성을 이용하려면  느슨한 결합은 중요한 요소입니다. 이를 달성하기 위해 service discovery를 구현하는 방법이 필요합니다.

##### Implement Service Discovery

EC2-hosted service를 위해서 ELB로 서비스를 사용하여 service discovery를 달성하는 것이 간단한 방법입니다. 각각의 load balancer는 자신의 hostname을 가지기 때문에 안정적인 endpoint 통해 서비스를 사용할 수 있습니다.

