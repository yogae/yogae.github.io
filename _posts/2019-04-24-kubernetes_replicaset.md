---
layout: post
title:  "Kubernetes 레플리카셋"
date: 2019-04-23
categories: Kubernetes
author: yogae
---

## 레플리카셋 yaml 파일

```yaml
apiVersion: apps/v1beta2 # apps/v1로 공식 문서에 작성되어 있음
kind: ReplicaSet
metadata:
 name: kubia
spec:
 replica: 3
 selector:
  matchLabels:
   app: kubia
 template:
  metadata:
   labels:
    app: kubia
  spec:
   containers:
   - name: kubia
     image: luksa/kubia
```

## 레플리카셋 확인

```bash
kubectl get rs # kubectl get replicasets와 동일

kubectl describe rs
```

## 레플리카셋 라벨 셀렉터

- matchExpressions에서는 연산자를 사용하여 label을 선택할 수 있습니다.
- matchLabels와 matchExpressions을 함께사용하면 모든 라벨이 일치해야 하고 모든 표현식이 true로 평가되어야 합니다.

### 유효한 연산자

- In: 라벨의 값이 지정된 값 중 하나와 일치해야 한다.
- NotIn: 라벨의 값이 지정된 값과 일치해서는 안 된다.
- Exists: 포드에는 지정된 키가 있는 라벨이 포함돼야 한다.
- DoesNotExist: 포드에는 지정된 키가 있는 라벨을 포함하면 안 된다.

### 연산자를 사용한 yaml

```yaml
 selector:
  matchExpressions:
  - key: app
    operator: In
    values:
    - kubia
```

