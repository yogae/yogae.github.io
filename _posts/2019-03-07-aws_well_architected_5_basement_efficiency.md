---
layout: post
title:  "AWS Well-Architected 프레임워크 - 5가지 기반(성능 효율성 기반)"
date: 2019-03-07
categories: SAA
author: yogae
---

요구 사항에 따라 컴퓨팅 리소스를 효율적으로 사용하고, 수요 변화 및 기술 진화에 발맞춰 효율성을 유지하는 데 초점을 맞춥니다.

## 설계 원칙

- **고급 기술의 대중화**

  기술에 대한 지식과 복잡성을 클라우드 업체가 제공하는 서비스로 극복하면서, 구현하기 어려운 기술도 쉽게 사용할 수 있습니다.

- **즉각적인 세계화**

  클릭 몇 번으면 전 세계 여러 리전에 손쉽게 시스템을 배포할 수 있습니다.

- **서버리스 아키텍처 사용**

  클라우드에서 서버 없는 아키텍처를 이용하면 서버를 실행하고 유지하는 등의 전통적인 컴퓨팅 관리 업무를 할 필요가 없습니다.

- **실험 횟수 증가**

  자동화할 수 있는 가상 리소스를 활용하며 여러 가지 인스텀스, 스토리지 또는 구성에 대한 비교 테스트를 신속하게 수행할 수 있습니다.

- **기계적 동조**

  보관 대상에 가장 적합한 기술 접근 방식을 사용합니다.

## 모범 사례

### 선택

AWS에서는 리소스가 가상화되고 다양한 유형 및 구성으로 제공됩니다. 따라서 보다 손쉽게 요구에 보다 근사하게 일치하는 접근 방식을 찾을 수 있을 뿐만 아니라, 온프레미스 인프라에서와 달리 다양한 스토리지 옵션을 손쉽게 찾을 수 있습니다.

아키텍처에 대한 패턴 및 구현을 선택할 때는 최적의 솔루션에 대한 데이터 기반 접근 방식을 사용합니다. 아키텍처를 최적화하기 위해서는 벤치마킹 또는 부하 테스트를 통해 획득한 데이터가 필요합니다.

최상의 성능을 제공하는 아키텍처 구성을 위한 고려사항

- 컴퓨팅

  특정 시스템에 가장 적합한 컴퓨팅 솔루션은 **애플리케이션의 설계**, **사용 패턴** 및 **구성 설정**에 따라 달라질 수 있습니다.

  AWS에서는 컴퓨팅이 인스턴스, 컨테이너, 기능 등 세 가지 형태로 제공됩니다.

  - **인스턴스**는 가상화된 서버입니다. AWS에서는 인스턴스를 다양한 제품군과 크기로 제공하며 SSD와 GPU를 비롯한 매우 다양한 기능을 사용할 수 있습니다.
  - **컨테이너**는애플리케이션 및 종속 요소를 리소스가 격리된 프로세스에서 실행할 수 있는 일종의 운영 체제 가상화입니다.
  - **기능**은 실행하여는 코드로부터 실행 환경을 추상화합니다.

- 스토리지

  특정 시스템에 대한 최적의 스토리지 솔루션은 **액세스 방식**(블록, 파일 또는 객체), **액세스 패턴**(무작위 또는 순차적), **필요한 처리량**, **액세스 빈도**(온라인, 오프라인, 보관), **업데이트 빈도**, **가용성** 및 **내구성 제약**에 따라 다릅니다. 제대로 구축된 시스템은 여러 스토리지 솔루션을 사용하며 성능을 향상하기 위해 다양한 기능을 활용합니다.

- 데이터베이스

  특정 시스템에 대한 최적의 데이터베이스 솔루션은 **가용성**, **일관성**, **파티션 허용치**, **지연 시간**, **내구성**, **확장성** 및 **쿼리 용량**에 대한 요구 사항에 따라 다릅니다. 많은 시스템들은 다양한 아휘 스스템에 대해 서로 다른 데이터베이스 솔루션을 사용하며, 성능을 향상시키기 위해 다양한 기능을 사용합니다.

  한 워크로드의 데이터베이스(RDBMS, NoSQL 등)는 시스템의 성능 효율에 큰 영향을 미치지만, 이는 보통 데이터 기반 접근 방식보다는 조직적 기본 사항에 따라 선택됩니다. 스토리지와 마찬가지로 워크로드의 액세스 패턴을 고려하는 것이 중요하며, 다른 비데이터베이스 솔루션이 보다 효율적으로 문제(예: 검색 엔진 또는 데이터 웨어하우스 사용)를 해결할 수 있는지 여부도 고려해야 합니다.

- 네트워크

  특정 시스템에 대한 최적의 네트워크 솔루션은 **지연 시간**, **처리량** 요구 사항 등에 따라 다릅니다. 사용자 또는 온프레미스 리소스와 같은 물리적 제약 조건이 위치 옵션을 좌우하며, 이는 에지 기술 또는 리소스 배치를 사용하여 상쇄될 수 있습니다.

  네트워크 솔루션을 선택할 때는 위치를 고려해야 합니다. AWS를 사용하면 리소스를 사용할 위치 가까이 해당 리소스가 배치되도록 선택하여 거리를 줄일 수 있습니다. 리전, 배치 그룹 및 에지 위치를 활용하여 성능을 현저히 개선할 수 있습니다.

### 검토

**솔루션을 설계할 때 선택 가능한 옵션 세트는 유한합니다. 하지만 시간이 지나면서 아키텍처의 성능을 개선시킬 수 있는 새로운 기술 및 접근 방식을 사용할 수 있게 됩니다.**

AWS를 사용하면 고객의 요구를 충족하기 위해 지속적으로 추진되는 혁신의 혜택을 받을 수 있습니다. AWS는 정기적으로 새로운 리전, 에지 위치, 서비스 및 기능을 출시합니다.

### 모니터링

아키텍처를 구현한 후에는 고객이 인지하기 전에 모든 문제를 해결할 수 있도록 성능을 모니터링해야 합니다. 임계값을 초과할 경우 경보가 생성되도록 모니터링 측정치를 사용해야 합니다.

### 트레이드오프

솔루션을 설계할 때는 최적의 접근 방식을 선택할 수 있도록 트레이드오프를 고려해야 합니다. 상황에 따라서는 일관성, 내구성 및 공간을 위해 시간 또는 지연 시간을 희생함으로써 보다 고성능을 제공할 수 있습니다.


