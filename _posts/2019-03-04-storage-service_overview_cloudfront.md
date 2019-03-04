---
layout: post
title:  "AWS Storage Services Overview - AWS Snowball
date: 2019-03-04
categories: SAA
author: yogae
---

Amazon CloudFront global network of edge location에서 content를 이용가능하도록 하여 dynamic, static, stream contents의 배포를 빠르게 하는 content-delivery web service입니다. 사용자가 Amazon CloudFront로 serving하는 content를 요청하였을 때, 사용자는 가장 적은 지연시간이 걸리는 edge location으로 routing 됩니다. 가장 적은 지연시간이 걸리는 edge location에 이미 content가 있다면 Amazon CloudFront는 즉시 content를 제공합니다. Edge location에 현재 content가 존재하지 않는다면 Amazon CloudFront는 설정해놓은 origin에서 검색합니다. 

## Usage Patterns

CloudFront는 edge 전달에 이점이 있는 자주 접근하는 static content의 배포에 이상적입니다. Amazon CloudFront 또한 HTTP를 사용하는 dynamic web application을 전달하기 위해 사용할 수 있습니다. Amazon CloudFront는 audio와 video file을 stream하기 위해 사용합니다.

object가 마기되기 전에 Amazon CloudFront Edge-server cache에서 object를 제거하려면 object를 invalidate하거나 object versioning을 사용할 수 있습니다.

## Performance

request는 지연시간에 따라 가장 가까운 Amazon CloudFront edge location으로 routing됩니다. 이 접근은 사용자의 사용자의 request가 지나가야만하는 network의 숫자를 감소시키고 성능을 향상시킵니다.

## Durability and Availability

CDN은 edge cache이기 때문에 Amazon CloudFront는 저장소의 내구성을 제공하지 않습니다. origin server가 file의 내구성을 제공합니다. edge location의  global network를 사용하여 고가용성을 제공합니다. origin request(edge location에서 AWS origin server로 요청)은 Amazon에서 지속적으로 모니터링하고 가용성 및 성능 모두를 위해 최적화하는 네트워크 경로를 통해 전송됩니다.

## Scalability and Elasticity

Amazon CloudFront은 가용성과 탁력성을 제공하기위해 설계되었습니다. traffic이 spike할 수 있는 요구를 충족시키기 위하여 비싼 web server 용량을 유지하는 것에 대하여 걱정할 필요가 없습니다. 자동적으로 spike 요구에 대하여 반응하고 content를 변동시킵니다. 

Amazon CloudFront는 각 edge location에서 여러 계층의 caching을 사용하고 origin server에 접속하기 전에 동일한 객체에 대한 동시 요청을 축소합니다.

## Cost Model

Amazon CloudFront에는 장기 계약이나 최소 사용 요금이 없습니다. 오직 실제로 제공한 content 만큼만 지불합니다. Amazon CloudFront는 2가지 비용 구성 요소가 있습니다. regional data 이동(GB당)과 request(10,000당). Free Usage Tier로 새로운 AWS 고객은 1년동안 달마다 50GB data 이동과 2,000,000 request에 대하여 비용이 청구되지 않습니다.

origin으로 AWS service를 사용한다면 origin에서 edge location으로 data 이동은 무료입니다. 

CloudFront는 3가지 다른 비용 class를 제공합니다. 전세계에 content가 배포되지 않고 특정 location에 배포되어야 한다면 특정 location만 포함하는 배포를 설정하여 적은 비용에 이용할 수 있습니다.