---
layout: post
title:  "Amazon DynamoDB On-demand & Transaction"
date: 2019-02-25
categories: AWS
author: yogae
---

# Amazon DynamoDB 온디멘드와 트랜젝션

## 용량 산정 방식

- Provisioned
  - Read/write capacity를 정하여 사용
  - use pattern: 변동이 없는 경우
- Auto-scale
  - Max capacity를 정하고 사용되는 부하에 따라 자동으로 scale in/out 할 수 있음
  - scale-up하는 지연시간이 있음
  - use pattern: 변동이 있으나, 예측가능한 경우
- On-Demand
  - 제한이 없음
  - provisioned와 auto-scale보다 비용이 비쌈
  - use pattern: 예측 불가능
  - 기능:
    - 용량 계산, 계획 하거나 예약할 필요없음
    - 상요한 읽기, 쓰기 개수만큼 과금
  - 장점:
    - 용량을 남비하거나 부족함이 없음
    - 트래픽에 따라 즉각적으로 작업 부하를 자동 조정

## Transaction

### 사용

- 동시다발적 쓰기(정합성이 중요한 경우)
- 처리하기 전에 여러가지 조건 검사
- 다양한 테이블간에 데이터의 일관성 유지

### 장점

- 데드락이 없음
- 긴 트랜잭션 시간이 없음
- 열린 드랜잭션 없음
- 관리되지 않은 동시성

### 추가된 트랜잭션 API

- TransactWriteItems
  - 작업을 10개까지 묶을 수 있음
  - 조건 추가 가능
  - 모든 조건이 맞을 때 쓰기 작업 수행
- TransactGetItems
  - 작업을 10개 까지 묶을 수 있음
  - 일관되게, 모든 항목의 격리된 스냅생을 가지고 옴