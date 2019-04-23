---
layout: post
title:  "Kubernetes 레플리케이션컨트롤러"
date: 2019-04-22
categories: Kubernetes
author: yogae
---

레플리케이션컨트롤러는 포드가 항상 실행되도록 유지하는 쿠버네티스 리소스입니다.

노드가 클러스터에서 사라지는 경우 또는 노드에서 포드가 제거된 경우와 같이 어떤 이유로든 포드가 사라지면 레플리케이션컨트롤러는 누락된 포드를 감지하고 대체 포드를 만듭니다.

- 라벨 셀렉터와 일치하는 포드를 관리합니다.
- 포드는 metadata.ownerReferences 필드를 통해 레플리케이션컨트롤러를 참조합니다.
- 레플리카셋으로 대체되어 사용되지 않게 될 것 예정

## 레플리케이션컨트롤러의 세가지 요소

- 레플리케이션컨트롤러 범위에 있는 포드를 결정하는 라벨 셀렉터
- 실행해야 하는 포드의 원하는 수를 지정하는 복제본 수 
- 새로운 포드 복제본을 만들 때 사용되는 포드 템플릿

## 레플리케이션컨트롤러 생성

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
 name: kubia # 레플리케이션컨트롤러의 이름
spec:
 replicas: 3 # 원하는 포드 인스턴스 수
 selector: # 포드 셀렉터를 통해 RC가 관리하려는 포드를 결정
  app: kubia
template:
 metadata:
  labels:
   app: kubia
 spec:
  containers:
  - name: kubia
    image: luska/kubia
    ports:
    - containerPort: 8080
```

> 템플릿의 포드 라벨은 분명히 레플리케이션컨트롤러의 라벨 셀렉터와 일치해야 합니다. 그렇지 않으면 컨트롤러는 새로운 포드를 무기한 생성합니다. 이런 경우를 방지하기 위해 API 서버는 레플리케이션컨트롤러 정의를 검사하고 잘못 구성된 경우 이를 수락하지 않습니다.
>
> 셀렉터를 지정하는지 않는 것은 선택 사항입니다. 지정하지 않는 경우 포드 템플릿의 라벨에서 자동으로 구성됩니다.

## 레플리케이션컨트롤러 확장

```bash
kubectl scale rc kubia --replica=10

kubectl edit rc kubia # edit 모드에서 spec.replicas 설정을 변경한다.
```

## 레플리케이션컨트롤러 삭제

```bash
kubectl delete rc kubia # 해당 레플리케이션컨트롤러와 레플리케이션컨트롤러에 관리되는 pod 모두 제거됨

kubectl delete rc kubia --cascade=false # 해당 레플리케이션컨트롤러만 제거
```