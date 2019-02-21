---
layout: post
title:  "Basic Concepts"
date: 2018-12-28
categories: ES
author: yogae
---

# Elastic Search

- 실시간 분산 검색 및 분석 엔진
- Apache Lucene을 기반

## 특징

- schemaless와 document-oriented
- JSON document를 저장(1급 객체로 취급)
- 감색 분야 특히 전문 텍스트 검색(Full-Test Search)에 특화
- 분석을 위해 폭넓고 다양한 집계 기능을 지원
- 풍부한 클라이언트 라이브러리와 REST API 지원
- 운영 및 확장 용이
- Near real time
- 신속성 - 기본적으로 document의 모든 필드에 대해 색인을 생성
- Fault tolerant(장애 상황에서도 계속 실행가능)

> 1급 객체는 3 가지조건을 충족한다면 1급 객체라고 할수 있습니다.
> 1. 변수나 데이타에 할당 할 수 있어야 한다.
> 2. 객체의 인자로 넘길 수 있어야 한다.
> 3. 객체의 리턴값으로 리턴 할수 있어야 한다.

## ES Stack 구성

### Elastic Search

- 모든 데이터를 저장하고 검색과 분석 기능 제공

### Logstash

- 로그, 메트릭 또는 다른 형식의 이벤트 데이터를 한 곳으로 모으는데 사용
- 데이터를 저장소로 보내기 전에 여러 방법으로 가공할 수 있음

### Beat

- 핵심 라이브러리인 립비트로 구성
- 클라이언트 측에서 동작
- Beat 종류
    - Filebeat: Logstash 서버나 ElasticSearch 서버로 로그 파일을 전송
    - Metricbeat: 서버에서 실행 중인 운영체제와 서비스 정보를 주기적으로 수집하기 위한 서버 모니터링 에이전트
    - Packetbeat .....
### Kibana

- 시각화 도구(Elastic Search Stack의 창문이라고 불림)

### X-Pack

- 보안, 모니터링, 알림 보고서 그래프 기능을 지원

### Elastic Cloud

- Elastic 스택 구성 요소를 클라우드 기반으로 호스팅하고 설정을 관리해주는 서비스

## 용어 정리

### Near Realtime(NRT)

Elasticsearch는 near-realtime 검색 platform입니다. document를 index하는 시간에서 이것을 검색할 수 있을 때 까지 조금의 지연이 있다는 것을 의미합니다. 

### Cluster

cluster는 전체 data를 보유하고 전체 node에 연결된 indexing과 검색 기능을 제공하며, 하나 또는 하나 이상의 node의 집합입니다. cluster는 unique한 name으로 식별되고 default name은 "elastic search"입니다. node는 오직 cluster의 부분이며, node는 cluster의 이름으로 cluster에 join됩니다.

서로 다른 환경에서 동일한 cluster 이름을 재사용하지 않도록합니다. 그렇지 않으면 잘못된 클러스터에 참여하는 노드로 끝날 수 있습니다.

### Node

node는 cluster의 부분이고 data를 저장하고, cluster의 indexing과 search 기능에 참여하는 단일 server입니다. Cluster 처럼 node는 이름(default: UUID)으로 식별됩니다. default로 이름을 설정하는 것을 원하지 않는다면 node이름을 설정해야 합니다. 이름은 network에 어느 server가 Elasticsearch cluster에서 어느 node에 대응하는지 식별하는 관리를 위해 중요합니다. 

node는 cluster의 이름으로 특정 cluster에 결합될 수 있습니다. 기본적으로 각각의 node는 `elasticsearch`라는 이름의 cluster에 결합됩니다.

다일 cluster에는 원하는 만큼 많은 node를 가질 수 있습니다. network에서 실행되고 있는 Elasticsearch node가 없다면 node는 default로 `elasticsearch` 의 이름을 가지는 single-node cluster를 생성할 것 입니다.

### Index

index는 다소 유사한 특성을 가진 document의 모음입니다. 예를 들어 고객의 data를 위한 index를 가질 수 있고 제품 catalog를 위한 index, data를 정렬하기 위하여 index를 가질 수 있습니다. index는 이름으로 식별되고(소문자로 구성) 이름은 indexing, 검색, update, 그리고 그 안에 있는 문서에 대한 작업을 삭제할 때 사용됩니다.

### ~~Type~~

같은 index에 다른 type의 document를 저장하기 위하여 index의 논리적인 category/partition을 하기 위해 사용합니다. 더이상 index에서 다중 type를 생성할 수 없고 제거될 예정입니다.

### Document

document는 index할 수 있는 information의 기본 단위입니다. document는 JSON format으로 표현됩니다. index / type을 사용하여 원하는 만큼 많은 document를 저장할 수 있습니다. 

### Shards & Replicas

index는 잠재적으로 단일 node의 hardware의 제한을 초과하는 data를 저장할 수 있습니다. 예를들어, 1TB의 disk 공간을 차지하는 10억 개의 문서의 단일 index는 단일 node의 disk에 알맞지 않거나 단일 node 하나만으로는 너무 느릴 것입니다.

이 문제를 해결하기 위해서 elasticsearch는 shard라고 하는 다중 조작으로 index를 나눌 수 있습니다. index를 생성할 때, 원하는 shard 수를 정의할 수 있습니다. 각각의 shard는 이 자체로 cluster의 모든 노드에서 호스트 될 수 있는 fully-functional하고 독립적인 index입니다.

shard를 하는 2가지의 중요한 이유가 있습니다.

- content의 부피를 수평적으로 나누거나 확장할 수 있게 합니다.
- shard의 operation을 분산하고 병렬화 하여 성능과 처리량을 증가시킵니다.

Shard가 배포되는 방법과 document가 검색 요청으로 다시 집계되는 방법은 Elasticsearch에 의해 완벽하게 관리되며 사용자로서 사용자에게 투명합니다.

장애가 발생할 수 있는 network나 cloud 환경에서 샤드 / 노드가 어떻게든 오프라인 상태가되거나 어떤 이유로든 사라지면 failover mechanism을 가지는 것을 추천합니다.

복제를 하는 2가지의 중요한 이유가 있습니다.

- shard나 node의 장애에 대하여 고가용성을 제공합니다. 이러한 이유로 replica shard를 원본 shard 같은 node에 할당되지 않습니다.
- 검색이 모든 replica에서 병렬적으로 수행되기 때문에 검색 처리량을 scale out할 수 있습니다.

각각의 index는 여러 shard로 분리될 수 있습니다. index는 여러개로 복제될 수 있습니다. 일단 복제되면 각각의 index는 primary shard와 replica shard를 가집니다.

index가 생성되는 시점에 index에 따라 shard와 replica의 숫자를 지정할 수 있습니다. index가 생성된 이후에도 아무때나 replica의 숫자를 변경할 수 있습니다. shard의 개수를 변경은 `_shrink` 와 `_split` API를 사용할 수 있습니다. 그러나 shard의 개수를 변경은 hard한 operation이므로 적절한 수의 shard에 대한 사전 계획을 세우는 것이 최적의 방법입니다.

default로 각각의 index는 5개의 primary shard와 1개의 replica(최소한 2개의 node)를 할당합니다. index는 5개의 primary shard와 다른 5개의 replica shard 총 index당 10의 shard를 가지고 됩니다.

### 역색인

document에 나타난 용어을 Document에 매핑하는 방식으로 사용한다.

주의사항:

- term은 document에서 구두정을 제거하고 소문자로 치환한 후 분리된 글자를 나타낸다.
- term은 알파벳 순으로 정렬된다.