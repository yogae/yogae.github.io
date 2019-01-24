---
layout: post
title:  "Reading and Writing documents"
date: 2019-01-23
categories: ES
author: yogae
---

Elasticsearch에서 index는 shard로 분리되고 각각의 shard는 여러개의 복사본을 가질 수 있습니다. Shard 복사 sync를 유지하고 읽을 수 있도록 serving하는 process를 **data replication model**이라고 합니다.

**data replication model**은 *primary-backup model*([참고](https://www.microsoft.com/en-us/research/publication/pacifica-replication-in-log-based-distributed-storage-systems/))을 기반으로 만들어졌습니다. 이 model은 primary shard로 행동하는 replication group에 single copy를 가지는 것을 기본으로 합니다. 다른 복사본은 replica shards라고 부릅니다. primary는 모든 indexing operation의 기본 진입점 역할을 합니다. primary는 indexing operation의 validating과 올바른지 확인하는 것을 책임집니다. 또한, primary가 index operation을 받으면 다른 복사본으로 복사 operation(다른 replica shard로 복사)을 책임집니다. 

## Basic write model

Elasticsearch 모든 indexing operaion은 routing을 사용하는 replication group이 처리합니다. 일단 replication group이 결정되면 그 operation은 group의 primary shard로 이동합니다. Primary shard는 operation의 validating과 다른 replica로 이동시키는 것을 책임집니다. replica가 offline일 수 있기 때문에 primary는 모든 replica에 복제하지 않습니다. 대신에 Elasticsearch는 operation을 받아야하는 shard 복제의 list를 유지합니다. 이 list는 in-sync copies라고 부르며 master node에서 유지됩니다. 

### Failure handling

primary 자체가 실패한 경우 primary를 hosting하는 node는 master에서 장애 발생 message를 보냅니다. 장애가 발한 Indexing operation은 replica 중에 하나가 새로운 primary가 되었다는 것을 master를 알리기 전까지 기다립니다. 그 이후 새로운 primary로 보내져 처리됩니다. master는 node의 상태를 모니터하고 primary node를 강등시킬 수도 있습니다. 

primary에서 성공적으로 operation이 처리되면 replica shard에서 실행할 때 발생할 수 있는 실패를 처리해야합니다. replica에서 발생하는 오류이거나 network의 문제일 수 있습니다. 불변성을 유지하기 위하여 primary는 master에게 in-sync replica set에서 문제가 있는 shard를 제거하라는 메세지를 보냅니다. master는 system을 정상 상태로 복원하기 위해 다른 노드에 새 샤드 사본을 작성하도록 지시합니다.

replica로 operation이 이동하는 동안 primary는 활동중인 primary인지 validate하기 위해 replica를 사용할 것입니다. primary가 network 문제가 발생하여 고립된다면(indexing operation은 받을 수 있으나 replica와 통신장애) 강들되었다는 것을 알기전까지 primary는 들어오는 indexing operation을 계속 처리합니다. 문제가 있는 primary에서 들어오는 operation은 replica에서 거부될 것 입니다. master에게 접근하여 더 이상 primary가 아니라는 것을 확인하고 operaion을 새로운 primary로 이동시킵니다.

## Basic read model

node가 read request를 받았을 때 node는 관련되 shard가 있는 node로 forwarding하고 response를 종합하고 client에게 응답하는 것을 책임집니다. 이러한 node를 **coordinating node**라고 합니다.

### Failure handling

read reqeust에 응답을 실패했을 때, coordinating node는 같은 replication group에서 다른  복사본을 선택하고 그 복사본에 대신 search request를 보냅니다. 

