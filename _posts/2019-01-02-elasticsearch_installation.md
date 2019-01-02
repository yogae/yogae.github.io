---
layout: post
title:  "Installation"
date: 2019-01-02
categories: ES
author: yogae
---

Elasticsearch는 최소 Java 8이 필요합니다. 

[Elasticsearch download](http://www.elastic.co/downloads)

```bash
# homebrew installation
brew install elasticsearch
```

## Successfully running node

```bash
# 실행
elasticsearch # default로 정해지는 cluster name과 node name을 사용합니다.
```

```bash
# cluster name과 node 이름 지정
elasticsearch -Ecluster.name=my_cluster_name -Enode.name=my_node_name
```

기본적으로 Elasticsearch는 REST API에 접근하기 위하여 `9200` port를 사용합니다. Port 번호는 설정가능합니다.