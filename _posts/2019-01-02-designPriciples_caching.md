---
layout: post
title:  "Design Principles - Caching"
date: 2019-01-02
categories: SAA
author: yogae
---

caching은 미래에 사용을 위해 이전에 계산된 data를 저장하는 기술입니다. 이 기술은 application의 성능을 향상시키고 비용의 효율성을 증가시키기 위해 사용됩니다. IT architecture의 여러 layer에서 적용될 수 있습니다.

## Application Data Caching

Application은 cache 정보를 저장하고 검색하기 위해 설계될 수 있습니다. cache된 정보는 I/O 집약적인 database query의 결과 또는 계산 집약적인 처리의 결과를 포함할 것 입니다. cahge에서 그 결과를 찾지 못 할 때 application은 이것을 계산하거나 이것을 database 또는 비싸고 느리게 변하는 third-party contents로 부터 검색할 수 있습니다. 후속 요청을 위하여 cache에 이것을 저장합니다. 그러나 cache에서 결과는 찾았을 때 application은 지연이 개선되고 back-end system에 부하를 감소시키면서 결과를 바로 사용할 수 있습니다. application은 얼마나 오래 cache된 정보를 보관할지 관리할 수 있습니다. 매우 많이 사용되는 정보는 몇 초만 caching 하더라도 database의 부하를 급진적으로 감소시킬 수 있습니다.

Amazon ElasticCashe는 in-memory cache를 cloud에 쉽게 배포하고 운영하고 확장할 수 있는 web service입니다. open-source in-memory caching engine인 Memcached와 Redis을 지원합니다.

>  [Performance at Scale with Amazon ElastiCache](https://d0.awsstatic.com/whitepapers/performance-at-scale-with-amazon-elasticache.pdf)

Amazon DynamoDB Accelerator(DAX)는 높은 처리량을 위한 완전관리형 고가용성 in-memory cache입니다. 밀리 초에서 마이크로 초까지 성능 향상을 제공합니다. DAX는 cache invalidation, data population, cluster management를 관리할 필요가 없이 in-memory 가속을 DynamoDB table에 추가합니다.

## Edge Caching

