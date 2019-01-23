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

## Basic read model

###  Failure handling

## A few simple implications

## Failures

