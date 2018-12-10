---
layout: post
title:  "Design Principles - Database"
date: 2018-12-06
categories: SAA
author: yogae
---

전통적인 IT infrasructure에서는 database와 storage 기술에서 종종 제한을 받습니다. licensing 비용에과 다양한 database engine을 지원성에 대한 제한이 있습니다. AWS에서는 open-source비용으로 enterprise 성능을 제공하는 database 서비스로 이러한 제한을 없애줍니다. 결과적으로 응용 프로그램이 각 작업 부하에 적합한 기술을 선택하는 다중 언어 데이터 계층에서 실행되는 경우는 드뭅니다.

### Choose the Right Database Technology for Each Workload

아래의 질문은 어떤 solution을 architecture에 포함할지에 대한 결정을 도와줍니다.

- read-heavy, write-heavy, or balanced workload입니까? 초당 얼마나 많이 읽고 씁니까? 사용자가 증가하면 어떻게 값을 변경합니까?
- 얼마나 많은 data를 얼마나 오래 저장해야하고 합니까? 성장이 얼마나 빠릅니까? 가까운 미래에 상한성에 있습니까? 각 object의 크기는 얼마입니까? object에 어떻게 접급합니까?
- data의 내구성에 관한 요구 사항을 무엇입니까? data가 "source of truth"가 될 것입니까?
- 지연 요구사항이 무엇입니까? 얼마나 많이 동시 접속자가 필요합니까?
- data model이 무엇이고 어떻게 query할 것 입니까? query가 관계형 query(다중 table을 Join)입니까? 쉽게 확장할 수 있는 data structure를 flat하게 만들기 위하여 schema를 비정규화 할 수 있습니까?

> 정규화: 데이터 모델을 검증하는 방법
>
>  - 중복 컬럼 삭제
>  - 유일키 전체에 대해 종속
>  - 유일키가 아닌 것에 영향을 받는 속성 분리
>
> 비정규화: 구현될 시스템의 성능을 고려하여 분석단계에서 실시한 정규화 작업을 역으로 비정규화 하는 작업을 실행
>
> - 중복 컴럼의 허용
> - 유도 컴럼의 생성
> - 테이블의 병합 및 분리
> - 분산 환경에서 테이블의 중복 또는 스냅샷
> - 마스터 테이블과 이력테이블의 결합

- 어떤 종류의 기능이 필요합니까? 강한 통합 제어가 필요합니까? 또는 flexibility를 찾고 있습니까(schema-less data stores)? 정교한 보고 또는 검색 기능이 필요합니까? NoSQL보다 관계형 database에 친숙합니까?
- 관련된 데이터베이스 기술 라이센스 비용은 얼마입니까? 이러한 비용은 시간이 지남에 따라 애플리케이션 개발 투자, 스토리지 및 사용 비용을 고려합니까? 라이센스 모델이 예상 성장을 지원합니까? Amazon Aurora와 같은 클라우드 고유의 데이터베이스 엔진을 사용하여 오픈 소스 데이터베이스의 단순성과 비용 효율성을 얻을 수 있습니까?

## Relational Databases

관계형 database(RDBS 또는 SQL database)는 행과 열로 구성된 테이블로 알려진 표 구조로 정규화합니다. 빠르고 효과적인 방법으로 query 언어, 유연한 indexing, 통합 관리, 그리고 다중 테이블을 결합할 수 있습니다. Amazon RDS는 cloud에서 친숙한 database engine을 지원하면서 관계형 database의 set up, 운영, 그리고 확장을 쉽게 만듭니다.

#### Scalability

관계형 database는 더 큰 Amazon RDS DB instance로 upgrading하여 vertically 확장할 수 있습니다. 추가적으로, standard MySQL과 비교했을 때 같은 하드웨어에서 훨씬 더 높은 처리량을 제공하기 위해 디자인된 database engine인 Amazon Aurora를 사용하는 것을 고려해보아라. read-heavy application에서는 하나 또는 그 이상의 read replica를 생성하여 하나의 DB instance의 제한을 넘어 horizontally 확장할 수도 있습니다.

Read replica는 비동기적으로 복제되는 별도의 database instance입니다. 따라서 복제 지연의 영향을 받아 최신 transaction이 누락 될 수 있습니다. application 디자이너는 약간의 데이터에 대한 허용 오차가있는 쿼리를 고려해야합니다. 이러한 query는 read replica에서 실행될 수 있으며, 나머지는 primary node에서 실행되어야 합니다. Read replica는 write query를 처리할 수 없습니다.

하는의 DB instance의 제한을 넘는 wirte량의 확장이 필요한 관계형 database의 처리부하는 partitioning 또는 sharding이라는 다른 접전이 필요합니다. 이 모델에서 data는 자체 자율 primary DB 인스턴스에서 각각 실행되는 여러 database schema로 분할됩니다. Amazon RDS instance가 운영되는 overhead를 제거할지라도 sharding은 application에 복잡성을 가지고 옵니다. application의 data access layer는 알맞는 instance에 query를 하기 위해서 어떻게 data가 분할되어 있는지 알도록 수정해야합니다.게다가, schema의 변화는 여러 database schema에 수행되어야 합니다. 그래서 이 process를 자동화하기 위해 약간의 노력을 투자 할 가치가 있습니다.

#### High Availability

관계형 database 제품에서는 다른 Availability Zone에 동기적으로 복제된 instance를 생성하는 Amazon RDS Multi-AZ deployment feature를 사용하는 것을 추천합니다. primary node가 실패하면 Amazon RDS는 manual 개입 없이 대기 모드로 자동으로 failover를 수행합니다. failover가 수행될 때, primary node가 사용 불가한 짧은 시간이 있습니다. 탁력적인 application은 read replica와 같은 축소된 기능(primary가 불가능하므로 write는 안 되지만 read는 read replica에서 수행할 수 있음)을 제공함으로써 정상적인 실패를 위해 설계될 수 있습니다. Amazon Aurora는 Availability Zone에 걸쳐 read와 write가 가능한 multi-master를 제공하고 cross-Region replication을 지원합니다.

### Anti-Patterns

application이 주로 join또는 복잡한 transaction이 필요없는 data를 index하거나 query 한다면 특히 하나의 instance의 제한은 넘는 write 처리량을 기대한다면 NoSQL database를 고려해야합니다. 큰 규모의 binary file(audio, video, image)을 가지고 있다면 Amazon S3사용하고 file의 metadata만 database에 저장하는 것이 더 효율적이다.