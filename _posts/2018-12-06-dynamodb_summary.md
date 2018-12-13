---
layout: post
title:  "DynamoDB 정리"
date: 2018-12-06
categories: AWS
author: yogae
---

## 1. 핵심 구성 요소

1. 구성
   - 테이블: 테이블은 데이터의 집합	
   - 항목: 각 테이블은 0개 이상의 항목으로 구성, 항목은 모든 기타 항목 중에서 고유하게 식별할 수 있는 속성들의 집합
   - 속성: 각 항목은 하나 이상의 속성으로 구성, 속성은 기본적인 데이터 요소로서 더 이상 나뉠 필요가 없는 것
   - 테이블의 각 항목에는 다른 모든 항목과 구별해 주는 고유 식별자인 기본 키가 존재, 테이블에서 기본 키는 한 개의 속성으로 구성
   - 기본 키를 제외하고 테이블에는 스키마가 없음
   - 일부 항목은 내포속성을 갖으며, 최대 32 수준 깊이까지 내포 속성을 지원
2. 기본 키
   - 파티션 키
     - 내부 해시 함수에 대한 입력으로 파티션 키값을 사용
     - 해시 함수 출력에 따라 항목을 저장할 파티션(DynamoDB 내부의 물리적 스토리지)이 결정
     - 파티션 키로만 구성되어 있는 테이블에서는 동일한 파티션 키 값을 가질 수 없음
   - 파티션 키 및 정렬 키(복합 기본 키)
     - 내부 해시 함수에 대한 입력으로 파티션 키값을 사용
     - 해시 함수 출력에 따라 항목을 저장할 파티션(DynamoDB 내부의 물리적 스토리지)이 결정
     - 파티션 키가 동일한 모든 항목은 정렬 키 값을 기준으로 정렬
     - 동일한 파티션 키 값을 가질 수 있으며, 두 아이템의 정렬 키 값은 달라야함
     - 정렬 키 값으로만 검색할 경우 scan작업을 사용
3. 보조 인덱스
   - [Global secondary index](https://docs.aws.amazon.com/ko_kr/amazondynamodb/latest/developerguide/GSI.html)
     - 모든 글로벌 보조 인덱스에는 파티션 키가 있어야 하며 선택 사항으로 정렬 키를 가질 수 있습니다.
     -  파티션 키 및 정렬 키가 기본 테이블의 파티션 및 정렬 키와 다를 수 있는 인덱스. 모든 파티션에서 인덱스의 쿼리가 기본 테이블의 모든 데이터에 적용될 수 있으므로 글로벌 보조 인덱스는 "글로벌"하게 간주됩니다.
     - 글로벌 보조 인덱스es에는 크기 제한이 없습니다.
     - 글로벌 보조 인덱스 쿼리 또는 스캔을 사용하면 인덱스로 프로젝션되는 속성만 요쳥할 수 있습니다. DynamoDB는 테이블에서 속성을 가져오지 않습니다.
     - DynamoDB는 각 글로벌 보조 인덱스를 기본 테이블과 자동으로 동기화합니다. 
     - Global secondary index는 최종적 일관된 읽기를 지원하며, 각각 읽기 용량 단위의 50%를 소비합니다. 즉, 단일 글로벌 보조 인덱스 쿼리는 읽기 용량 단위당 최대 2×4 KB = 8KB까지 검색할 수 있습니다.
     - 속성 프로젝션
       - *KEYS_ONLY* – 인덱스의 각 항목은 테이블 파티션 키 및 정렬 키 값, 그리고 인덱스 키 값으로만 구성됩니다. `KEYS_ONLY` 옵션은 보조 인덱스의 크기를 최소화합니다.
       - *INCLUDE* – `KEYS_ONLY`에서 설명한 속성뿐만 아니라 키 외에 다른 속성을 지정하여 보조 인덱스에 추가합니다.
       - *ALL* – 보조 인덱스에 원본 테이블의 모든 속성이 추가됩니다. 모든 테이블 데이터가 인덱스에 복사되기 때문에 `ALL` 프로젝션은 보조 인덱스의 크기를 최대화합니다.
     - 장애 발생 처리: 테이블에 항목을 추가하거나 삭제하면 해당 테이블의 글로벌 보조 인덱스가 최종 일관성 방식으로 업데이트됩니다. 정상적인 조건에서 해당 테이블 데이터의 변경 사항은 거의 밀리초 수준으로 글로벌 보조 인덱스에 적용됩니다. 하지만, 간혹 장애가 발생할 경우 긴 적용 지연이 발생할 수 있습니다. 애플리케이션은 글로벌 보조 인덱스의 쿼리가 최신이 아닌 결과를 반환할 수 있음을 예상하고 그러한 상황을 처리할 수 있어야 합니다.
   - [로컬 보조 인덱스](https://docs.aws.amazon.com/ko_kr/amazondynamodb/latest/developerguide/LSI.html)
     - 기본 테이블과 파티션 키는 동일하지만 정렬 키는 다른 인덱스. local secondary index는 local secondary index의 모든 파티션이 동일한 파티션 키 값을 가진 기본 테이블 파티션으로 한정된다는 의미에서 "로컬"입니다.
     - 파티션 키 값마다 인덱싱된 모든 항목의 전체 크기가 10GB 이하여야 합니다. 초과할 경우 DynamoDB에서 `ItemCollectionSizeLimitExceededException`을 반환하며 항목 컬렉션에 더 이상 항목을 추가하거나 항목 컬렉션에 있는 항목의 크기를 늘릴 수 없습니다. 애플리케이션은 출력에 있는 `ReturnItemCollectionMetrics` 객체를 조사하고 항목 컬렉션이 사용자 정의 한도(예: 8GB)를 초과할 때마다 오류 메시지를 기록해야 합니다.
     - 모든 local secondary index에는 기본 테이블의 파티션 및 정렬 키가 자동적으로 포함되며, local secondary index를 쿼리하거나 스캔할 경우 인덱스로 프로젝션되지 않는 속성을 요청할 수 있습니다. DynamoDB는 자동으로 테이블에서 해당 속성을 가져옵니다. DynamoDB는 기본 테이블에서 이러한 속성을 자동으로 가져오지만 지연 시간이 길어지고 할당 처리량 비용이 높아집니다.
     - DynamoDB는 자동으로 모든 local secondary index를 관련 기본 테이블과 동기화 상태로 유지합니다.

4. DynamoDB 스트림
   - 데이터 수정 이벤트를 캡터하는 선택적 기능
   - event
     - 테이블에 새로운 항목이 추가되면 스트림이 해당 속성을 모두 포함하여 전체 항목의 이미지를 캡처합니다.
     - 항목이 업데이트되면 스트림이 항목에서 수정된 속성의 "사전" 및 "사후" 이미지를 캡처합니다.
     - 테이블에서 항목이 삭제되면 스트림이 항목이 삭제되기 전에 전체 항목의 이미지를 캡처합니다.
   - 스트림 레코드의 수명은 24시간이며, 24시간이 지나면 스트림에서 자동으로 제거

## 2. DynamoDB API

1. 제어 플레인

   테이블을 생성하고 관리, 인덱스, 스트림 및 테이블에 따라 다른 다양한 객체를 사용

   - CreateTable
   - DescribeTable
   - ListTables
   - UpdateTable
   - DeleteTable

2. 데이터 플레인

   테이블의 데이터에 대해 생성, 읽기, 업데이트 및 삭제(*CRUD*) 작업을 수행

   - 데이터 생성
     - PutItem
     - BatchWriteItem
   - 데이터 읽기
     - GetItem: 테이블에서 단일 항목을 가져옵니다. 원하는 항목의 기본 키를 지정해야 합니다.
     - BatchGetItem: 하나 이상의 테이블에서 최대 100개의 항목을 가져옵니다.
     - Query: 해당 파티션 키를 갖는 모든 항목을 가져옵니다. 선택 사항으로, 정렬 키 값에 조건을 적용하여 동일한 파티션 키가 있는 데이터 일부만 검색할 수도 있습니다. 
     - Scan: 지정한 테이블 또는 인덱스의 모든 항목을 가져옵니다.
   - 데이터 업데이트
     - UpdateItem
   - 데이터 삭제
     - DeleteItem
     - BatchWriteItem

3. DynamoDB 스트림

   *DynamoDB 스트림* 작업을 사용하면 테이블에 스트림을 설정하거나 해제할 수 있으며, 스트림에 들어 있는 데이터 수정 레코드에 액세스할 수 있습니다.

   - ListStreams
   - DescribeStream
   - GetShardIterator
   - GetRecords

## 3. 데이터 형식

최대 DynamoDB 항목 크기 **400 KB**에 제한

- 문자열
- number
- 이진수
- bool
- Null
- 목록
  - 목록은 JSON 배열과 유사
  - 목록 요소에 저장할 수 있는 데이터 형식에는 제한이 없으며, 한 목록 요소에 있는 요소의 형식이 달라도 상관없음
- 맵
  - 맵은 JSON 객체와 유사
  - 맵 요소에 저장할 수 있는 데이터 형식에는 제한이 없으며, 한 맵에 형식이 다른 요소도 함께 있을 수 있음
- 집합

## 4. 읽기 일관성

- 최종적 일관된 읽기: 응답은 최근 완료된 쓰기 작업의 결과를 반영하지 않을 수 있음
- 강력한 일관된 읽기: 모든 이전 쓰기 작업의 업데이트를 반영하여 가장 최신 데이터로 응답을 반환
- 달리 지정하지 않는 한, DynamoDB는 최종적 일관된 읽기(Eventually Consistent Read)를 사용합니다. `GetItem`, `Query` 및 `Scan`과 같은 읽기 작업은 `ConsistentRead` 파라미터를 제공합니다. 매개 변수를 true로 설정하면 DynamoDB는 작업 시 강력한 일관된 읽기를 사용합니다.

## 5. 처리량

- *읽기 용량 단위* 1은 초당 강력한 일관된 읽기(Strongly Consistent Read) 1회 또는 초당 최종적 일관된 읽기(Eventually Consistent Read) 2회(최대 4 KB 크기 항목의 경우)를 나타냅니다. 4 KB보다 큰 항목을 읽어야 하는 경우, DynamoDB가 추가 읽기 용량 단위를 사용해야 합니다. 필요한 총 읽기 용량 단위 수는 항목 크기 및 최종적 일관된 읽기(Eventually Consistent Read)와 강력한 일관된 읽기(Strongly Consistent Read) 중 어느 것을 원하는지에 따라 달라집니다.

- *기 용량 단위* 1은 최대 크기가 1 KB인 항목에 대해 초당 쓰기 1회를 나타냅니다. 1 KB보다 큰 항목을 써야 하는 경우, DynamoDB가 추가 쓰기 용량 단위를 사용해야 합니다. 필요한 총 쓰기 용량 단위 수는 항목 크기에 따라 결정됩니다.

- 읽기 또는 쓰기 요청이 테이블에 할당된 처리량 설정을 초과하는 경우, DynamoDB에서 해당 요청을 *조절(throttle)*할 수 있습니다.

  > [처리량 계산 방법 설명](https://docs.aws.amazon.com/ko_kr/amazondynamodb/latest/developerguide/HowItWorks.ProvisionedThroughput.html)

## 6. 특성

- 빈번한 읽기 쓰기로 처리 속도가 빠름(모바일 게임이나 소셜 네트워크 같은 짧은 작업들을 처리하는 경우 아주 유용하게 사용될 수 있음)
- JOIN과 같은 복잡한 테이블 데이터 처리과정에 비적합
- 비정형적인 데이터를 저장하는데 유용
- 일반적으로 핫 파티션의 조절이 시작되고 5-30분 후에 조정 용량이 활성화

## 7. 주의사항

- partition key와 range key를 사용하고range key를 sorting을 위하여 time으로 설정하는 경우 문제점
  - delete 시 partition key와 range key 모두 알아야만 항목을 제거할 수 있음

## 8. 참고

- [파티션 및 데이터 배포](https://docs.aws.amazon.com/ko_kr/amazondynamodb/latest/developerguide/HowItWorks.Partitions.html)
- [효과적으로 파티션 키를 설계해 사용하는 모범 사례](https://docs.aws.amazon.com/ko_kr/amazondynamodb/latest/developerguide/bp-partition-key-design.html)
- [요금](https://aws.amazon.com/ko/dynamodb/pricing/)
  - 월별로 소비한 최초 25GB는 무료이며 이후 이 가격은 월 단위로 GB당 0.25 USD부터 과금됩니다.
- [on-demand 기능 출시](https://aws.amazon.com/ko/blogs/korea/amazon-dynamodb-on-demand-no-capacity-planning-and-pay-per-request-pricing/)
  - 새로운 애플리케이션 또는 데이터베이스 워크로드를 예측하기 까다로운 애플리케이션
  - 사용량에 따라 요금을 지불하는 서버리스 스택을 작업 중인 개발자
  - 구독자별로 테이블을 배포하는 데 있어서 단순성과 리소스 분리를 원하는 SaaS 제공업체 및 ISV(Independent Software Vendor)