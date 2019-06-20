---
layout: post
title: kubernetes 오토스케일링
data: 2019-06-18
categories: Kubernetes
author: yogae
---

포드의 수평적 오토스케일링은 HorizontalPodAutoscaler(HPA) 리소스를 만들어 활성화 및 구성되는 Horizontal 컨트롤러가 수행합니다.

오토스케일링 프로세스는 아래와 같은 수행과정으로 진행됩니다.

1. 관리하는 pod의 메트릭을 가지고 온다.

   포드 및 노드 메트릭은 cAdvisor라는 에이전트에 의해 수집되고 힙스터에서 클러스터 전체 구성 요소로 집계됩니다. 오토스케일링 컨트롤러는 REST 호출을 통해 힙스터를 쿼리하여 모든 포드의 메트릭을 가져옵니다.

2. 지정된 모표 값에 메트릭을 가져오는 데 필요한 포드 수를 계산한다.

3. 스케일된 리소스의 복제본 필드를 업데이트한다.

오토스케일러에 붙일 수 있는 객체들

- 디플로이먼트
- 레플리카셋
- 레플리케이션컨트롤러
- 스테이트풀셋

## CPU 사용률에 따른 스케일링

```yaml
# deploy 객체 생성
apiVersion: apps/v1
kind: Deployment
metadata:
 name: kubia
spec:
 replicas: 3
 selector:
  matchLables:
   app: kubia
 template:
  metadata:
   name: kubia
   labels:
    app:kubia
  spec:
   containers:
   - image: luksa/kubia:v1
     name: nodejs
     resources:
      requests:
       cpu: 100m
```

디플로이먼트를 작성한 후 포드의 수평 오토스케일링 기능을 사용하려면 HPA 객체를 생성하고 디플로이먼트를 가리켜야 합니다.

```bash
kubectl autoscale deployment kubia --cpu-percent=30 --min=1 --max=5
```

> docker에서 실행하는 kubernetes으로 위와 같이 실행 시 문제 발생: 
>
> HPA was unable to compute the replica count: unable to get metrics for resource 
>
> cpu: unable to fetch metrics from resource metrics API: the server could not find the requested resource

## 사용자 지정 메트릭을 기반으로 한 오토스케일링

```yaml
# 리소스 메트릭 유형
...
spec:
 maxReplicas: 5
 metrics:
 - type: Resource
   resoruce:
    name: cpu
    targetAverageUtilization: 30
...
```

```yaml
# 포드 메트릭 유형
...
spec:
 metrics:
 - type: Pods
   resoruce:
    metricName: qps # Query Per Second
    targetAverageValue: 100
...
```

```yaml
# 객체 메트릭 유형
# 포드와 직접 관련이 없는 메트릭을 기반으로 만들 때 사용
...
spec:
 metrics:
 - type: Object
   resource:
    metricName: latencyMillis
    target:
     apiVersion: extensions/v1beta1
     kind: Ingress
     name: frontend
    targetValue: 20
 scaleTargetRef:
  apiVersion: extensions/v1beta1
  kind: Deployment
  name: kubia
...
```

> 포드를 사용하지 않는다고 해서 minReplicas 필드를 0으로 설정하면 안 됩니다. 0으로 설정하면 하드웨어 활용도가 크게 놓아질 수 있습니다. 이런경우 Idling 기능을 활용해야 합니다.

## 클러스터 오토스케일러

클러스터 오토스케일러는 노드의 리소스가 보족해서 기존 노드에 스케줄할 수 없는 경우 scale out하고 오랜 기간동안 충분히 활용되지 않으면 node를 scale in 합니다. 클러스터 오토스케일러는 클라우드 제공 업체에게 추가 노드를 요청합니다.

### 클러스터 scale in 최소 pod 지정

최소 pod 수를 지정하기 위해서 PodDisruptionBudget 리소스를 사용합니다.

```bash
kubectl create pdb kubia-pdb --selector=app=kubia --min-available=3
```

```yaml
# PodDisruptionBudget 정의
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
 name: kubia-pdb
spec:
 minAvailable: 3
 selector:
  matchLabels:
   app: kubia
   status:
   ...
```

