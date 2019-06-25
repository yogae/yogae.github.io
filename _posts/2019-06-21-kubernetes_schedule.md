---
layout: post
title: kubernetes schedule
data: 2019-06-21
categories: Kubernetes
author: yogae
---

쿠버네티스 클러스터의 특정 노드에 taint를 지정할 수 있습니다. taint가 걸린 노드에 포드들을 스케쥴링 하려면 toleration을 이용해서 지정해 주어야합니다.

node의 트인트와 일치하는 pod의 톨러레이션이 있는 경우에만 노드에 pod가 스케줄됩니다. 그렇지 않은 경우 node에서 pod를 스케줄하지 않습니다.

테인트는 {key}={value}:{effect} 형식으로 표시됩니다.

```bash
kubectl describe node master.k8s

Name: master.k8s
...
Taints: node-role.kubernetes.io/master:NoSchedule
```

```bash
kubectl describe po kube-pod-drbdv

...
Tolerations: node-role.kubernetes.io/master:NoSchedule # 위 node의 taint와 일치
             node-role.kubernetes.io/notReady:NoExcute for 300s # 준비되지 않았거나 도달할 수 없는 노드에서 포드가 실행되는 시간을 정의합니다.
             node-role.kubernetes.io/unreachable:NoExcute for 300s # 준비되지 않았거나 도달할 수 없는 노드에서 포드가 실행되는 시간을 정의합니다.
```

### 테인트 effect

- NoSchedule: 노드가 테인트를 허용하지 않는 경우 포드가 노드에 스케줄되지 않음
- PreferNoSchedule: 스케줄러가 노드 스케줄을 피하려고 하지만 다른 곳에서 스케줄할 수 없는 경우 스케줄합니다.
- NoExcute: 노드에 NoExcute 테인트를 추가하면 노드에서 이미 실행 중인 포드중 NoExcute 톨러레이션하지 않은 포드가 제거됩니다.

## 노드에 사용자 정의 테인트 추가

```
kubectl taint node node1 node-type=production:NoSchedule
```

```yaml
# node 테인트에 맞게 pod deploy
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
 name: prod
spec:
 replicas: 5
 template:
  spec:
   ...
   tolerations:
   - key: node-type
     opertaion: Equal # 특정 값을 허용 # Exists 연산자를 사용하는 경우에는 특정 테인트의 값을 허용
     vale: production
     effect: NoSchedule
```

## 노드 친화성

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: kubia-gpu
spec:
 affinity:
  nodeAffinity:
   requiredDuringSchedulingIgnoredDurationExcution: # 친화성이 현재 포드 스케줄링에만 영향을 주고 이미 실행 중인 포드가 노드에서 계속 실행할 수 있음을 알려준다.
    nodeSelectorTerms:
    - matchExpressions:
      - key: gpu
        operator: In
        values:
        - "true"
```

노드 친화성 기능의 장점은 특정 포드를 스케줄할 때 스케줄러가 선호하는 노드를 지정할 수 있다는 점입니다. 이것은 preferredDuringSchedulingIgnoredDurationExcution 필드에서 수행됩니다.

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: kubia-gpu
spec:
 affinity:
  nodeAffinity:
   preferredDuringSchedulingIgnoredDurationExcution: # 선호도
   - weight: 80
     preference:
      matchExpressions:
      - key: availability-zone
        operator: In
        values:
        - zone1
   - weight: 20
     preference:
      matchExpressions:
      - key: share-type
        operator: In
        values:
        - dedicated
```

## 포드 친화성 및 반친화성

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
 name: frontend
spec:
 replicas: 5
 template:
  ...
  spec:
   affinity:
    podAffinity:
     requiredDuringSchedulingIgnoredDurationExcution:
     # app=backend 라벨이 있는 포드와 디플로이먼트가 동일한 노드에 배포돼야 한다는 엄격한 요구 사항을 갖는 포드를 생성한다.
     - topologyKey: kubernetes.io/hostname # label이 app=backend인 pod가 속한 node의 kubernetes.io/hostname 값을 확인하고 kubernetes.io/hostname 값이 같은 node에 배포한다.
       labelSelector:
        matchLables:
         app: backend
```

```yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
 name: frontend
spec:
 replicas: 5
 template:
  ...
  spec:
   affinity:
    podAffinity: # podAntiAffinity -> 반친화성
     preferredDuringSchedulingIgnoredDurationExcution: # 선호도
     - weight: 80
       podAffinityTerm:
        topologyKey: kubernetes.io/hostname 
        labelSelector:
         matchLables:
          app: backend
```

