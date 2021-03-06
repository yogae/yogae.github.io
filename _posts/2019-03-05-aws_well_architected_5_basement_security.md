---
layout: post
title:  "AWS Well-Architected 프레임워크 - 5가지 기반(보안 기반)"
date: 2019-03-05
categories: SAA
author: yogae
---

보안 기반에는 위험 평가 및 완화전략을 통해 정보, 시스템 및 자산을 보호하는 동시에 비즈니스 가치를 제공하는 능력이 포함됩니다.

## 설계 원칙

- **모든 계층에 보안 적용**

  모든 리소스에서 방화벽을 비롯한 각정 보안 제어를 사용하십시오.

- **추적 가능성 활성화**

  사용 환경에 대한 모든 변경 사항 및 작업을 기록하고 감사합니다.

- **최소 권한 원칙 구현**

  권한 부여가 AWS 리소스 각각에 적합해야 하며 리소스에 대해 집접적으로 강력한 논리적 액세스 제어를 구현합니다.

- **시스템 보안에 집중**

  AWS 공동 책임 모델에 따라 사용자는 애플리케이션, 데이터 및 운영 체제 보안에 집중하고, 보안 인프라 및 서비스는 AWS에서 제공합니다.

- **보안 모범 사례의 자동 적용**

  루팀 및 이상 보안 이벤트 모두에 대한 응답을 자동화합니다.

## 모범 사례

### ID 및 액세스 관리

허가 받고 인증된 사용자에 한해 허용되는 방식으로만 리소스에 액세스할 수 있도록하는 것을 말합니다. AWS에서는 기본적으로 AWS 서비스 및 리소스에 대한 사용자 액세스를 고객이 직접 제어할 수 있도록 하는 AWS IAM(Identity and Access Mangement)서비스로 권한 관리를 지원합니다. 또한 복잡성 수준, 재사용 금지, Multi-Factor Authentocation(MFA) 사용 등 강력한 암호 관행을 요구할 수도 있습니다. 시스템이 AWS에 액세스해야하는 워크로드의 경우 IAM이 인스턴스 프로필, 자격 증명 연동, 임시 자격 증명을 통해 보안 액세스를 보장합니다.

### 탐지 제어

타미 제어를 사용하여 잠재적 보안 인시던트를 식별할 수 있습니다. 품질 프로세스, 법룰 준수 의무 및 위협 식별 및 대응 과정을 지원하는 데 사용합니다. AWS에서는 로그, 이벤트 및 모니터링을 처리하여 탐지 제어를 구현할 수 있습니다. AWS CloudTrail 로그, AWS API 호출 및 Amazon CloudWatch는 측정치 모니터링을 경보와 함께 제공하며 AWS Config는 구성 내역을 제공합니다. 

Well-Architected 설계에서 로그 관리가 중요한 이유는 보안/과학수사에서 규제 또는 법적 요구 사항에 이르기까지 다양합니다. 잠재적 보안 인시던트를 식별하려면 로그를 분석 및 대응하는 것이 매우 중요합니다.

### 인프라 보호

AWS 기본 기술을 사용하거나 AWS Marketplace 에서 제공되는 파트너 제품 및
서비스를 사용하여 상태 저장 및 상태 비저장 방식의 패킷 검사를 구현할 수
있습니다. 이와 함께 Amazon Virtual Private Cloud(VPC)를 통해 안전하고 확장 가능한 프라이빗 환경을 만들고, 여기에서 게이트웨이, 라우팅 테이블,
퍼블릭/프라이빗 서브넷 같은 토폴로지를 정의할 수 있습니다.

### 데이터 보호

AWS에서는 다음과 같은 관행으로 데이터 보호를 가능하게 합니다.

- AWS 고객들은 데이터에 대한 완전한 통제력을 유지합니다.
- AWS는 정기적인 키 교체 등 키 고나리 및 데이터 암호화를 더 간편하게 처리하도록 만들어 드립니다. AWS 기본 서비스를 이용하거나 고객이 직접 관리하여 손쉽게 자동화할 수 있습니다.
- 파일 액세스, 변경 사항 등 중요한 내용이 수록된 상세 로그를 확인할 수 있습니다.
- AWS는 탁원한 회복력을 목표로 스토리지 시스템을 설계했습니다.
- 광범위한 데이터 수명 주기 관리 프로세스에 버전 관리를 포함시켜 우발적인 덮어쓰기나 삭제 및 그와 유사한 손해를 방지할 수 있습니다.
- AWS는 절대로 리전 간 데이터 이동을 하지 않습니다. 특정 리전에 저장된 콘텐츠는 고객이 명시적으로 기능을 활성화하거나 그 기능을 제공하는 서비스를 이용하지 않는 한 해당 리전을 벗어나지 않습니다.

### 인시던트 대응

매우 성숙한 예방 및 탐지 제어를 사용하더라도 조직은 잠재적 보안 인시던트에 대응하고 그 영향을 완화하기 위한 프로세스를 마련해야 합니다.

AWS에서는 다음과 같은 관행이 효과적인 인시던트 대응을 지원합니다.

- 파일 액세스, 변경 사항 등 중요한 내용이 수록된 상세 로그를 확인할 수 있습니다.
- 이벤트가 자동으로 처리할 수 있고 AWS API 사용을 통해 실행서를 자동화하는 스크립트를 트리거 할 수 있습니다.
- AWS CloudFormation을 사용하여 도구 및 안전한 공간을 사전 프로비저닝할 수 있습니다. 이를 통해 안전하고 격리된 환경에서 과학수사를 수행할 수 있습니다. 