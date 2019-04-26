---
layout: post
title: kubernetes 데몬셋
data: 2019-04-26
categories: kubernetes
author: yogae
---

- 데몬셋에 의해 만들어진 포드는 이미 대상 노드가 지정됩니다.
- 쿠버네티스 스케줄러를 건너뜁니다.
- 노드가 있는 수만큼 포드를 생성하고 노드 각각에 포드를 하나씩 배포합니다.
- 노드가 다운돼도 데몬셋은 어느 곳에서도 포드를 생성하지 않습니다. 새 노드가 클러스터에 추가되면 데몬셋은 즉시 새 포드 인스턴스를 배포합니다.

## 데몬셋 yaml 파일

```yaml
# ssd-monitor-daemonset.yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
 name: ssd-monitor
spec:
 selector:
  matchLabels:
   app: ssd-monitor
 template:
  metadata:
   labels:
    app: ssd-monitor
  spec:
   nodeSelector:
    disk: ssd # 포드 템플릿은 disk=ssd 라벨이 있는 노드를 선택하는 노드 셀렉터가 포함돼 있다.
   containers:
   - name: main
     image: luksa/ssd-monitor
```

## 데몬셋 생성

```bash
kubectl create -f ssd-monitor-daemonset.yaml

kubectl label node minikube disk=ssd # 기존의 node의 라벨 변경 
```