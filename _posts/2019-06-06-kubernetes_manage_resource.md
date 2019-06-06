---
layout: post
title: kubernetes 리소스 관리
data: 2019-06-06
categories: Kubernetes
author: yogae
---

## 포드 컨테이너의 리소스 요청

포드를 만들 때 컨테이너가 필요로 하는 CPU 및 메로리의 양과 한계를 지정할 수 있습니다.

```yaml
apiVerison: v1
kind: Pod
metadata:
 name: requests-pod
containers:
- image: busybox
  command: ["do", "if=/dev/zero", "of=/dev/null"]
  name: main
  resources:
   requests:
    cpu: 300m # cpu core의 1/5(200밀리 코어)
    memory: 10Mi
```

### 스케줄러가 포드의 요청 처리

스케줄러는 리소스가 얼마나 많이 사용되고 있는지 보지 않고 노드에 배포된 기존 포드가 요청한 리소스의 합계만 봅니다.

스케줄러가 포드에게 맞지 않는 노드 목록부터 제거해 노드 목록을 필터링한 다음 구성된 우선순위 지정 함수에 따라 남은 노드의 우선순위(LeastRequestPeriority와 MostRequestPeriority)를 저장합니다. 

- LeastRequestPeriority: 요청된 리소스가 더 적은 노드를 선호

- MostRequestPeriority: 요청된 리소스가 더 많은 노드를 선호

```bash
# 노드의 사용 가능한 리소스와 연관된 두 가지 세트인 노드의 cacacity와 allocatable 리소스가 표시됩니다.
kubectl describe nodes
```

### 리소스 양에 대한 한계 설정

프로세스에게 메모리 한 조각이 주어지면 프로세스 자체라 메모리가 해제될 때까지 해당 메모리를 제거할 수 없습니다. 따라서 컨테이너에 제공할 수 있는 최대 메모리양을 제한해야 합니다.

```yaml
apiVerison: v1
kind: Pod
metadata:
 name: limited-pod
spec:
 containers:
 - image: busybox
   command: ["dd", "if=/dev/zero","of=/dev/null"]
   name: main
   resources:
    limits:
     cpu: 1
     memory: 20Mi
```





