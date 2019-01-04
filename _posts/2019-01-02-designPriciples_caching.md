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

Amazon CloudFront edge location에 정적 content(image, CSS, streaming pre-recorded video)의 복사본과 동적 content(HTML, live video)는 cache할 수 있습니다. Edge caching은 보는 사람에게 더 가까운 infrastructure에서 content를 제공할 수 있게 합니다. 많이 사용되는 객체를 최종 사용자에게 제공하기 위하여 시간을 줄이고 높고 지속적인 데이터 전송 속도를 제공합니다.

content의 요청은 Amazon S3나 origin server로 route됩니다. AWS에서 origin이 운영되고 있다면 요청은 최적화된 경로로 전송되므로 보다 안정적이고 일관된 환경을 경험할 수 있습니다. cache할수 없는 content를 포함하는 전체 website를 Amazon CloudFront르 제공할 수 있습니다. 이런 경우 Amazon CloudFront은 Amazon CloudFront edge와 origin server간의 connection을 재사용하는 이점이 있습니다. connection을 재사용하여 connection 설정 지연시간을 감소시킬 수 있습니다. 다른 연결 최적화는 인터넷 병목 현상을 피하고 가장자리 위치와 뷰어간에 사용 가능한 대역폭을 완전히 사용하도록 적용됩니다. 이것은 Amazon CloudFront가 신속하게 정적 content 제공하고 사용자에게 지속적이고 믿을 수 있는 경험을 제공하는 것을 의미합니다. Amazon CloudFront는 동적인 content를 다운로드할 때의 요청과 같이 업로드 요청에서도 같은 성능을 지원합니다