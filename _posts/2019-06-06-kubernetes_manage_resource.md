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

한 노드에 있는 모든 포드의 모든 한계의 합이 노드의 용량의 100%를 초과할 수 있습니다.

### QoS 클래스

#### 포드의 QoS 클래스

리소스 한계가 과도하게 사용될 때 리소스를 확보하기 위해 제거할 포드를 선택해야합니다. 이런 경우 우선순위를 저정해야하는 데 Kubernetes는 다음과 같이 포드를 3가지 QoS 클래스로 분류합니다.

- BestEffort(최하위 우선순위)

  운선순위가 가장 낮은 QoS 클래스이며 한계가 설정되지 않은 포드에 할당됩니다.

- Burstable(버스트 가능)

  BestEffort와 Guranteed 사이에는 Burstable QoS 클래스가 있습니다. 컨테이너의 한계 사항이 요청과 일치하지 않는 단일 컨테이너 포드와 최소한 하나의 컨테이너에 지정된 리소스 여청이 있지만 한계가 없는 모든 포드가 포함됩니다. Burstable 포드는 요청한 리소스의 양을 얻지만 필요할 경우 추가 리소스를 사용할 수 있습니다. 

- Guranteed(최우선)

  이 클래스는 컨테이너의 요청이 모든 리소스에 대한 한계와 동일한 포드에 제공됩니다. 해당 포드의 컨테이너는 요청한 리소스 양을 얻지만 추가 리소스를 소비할 수 없습니다.(해당 한계가 요청보다 높지 않기 때문에)

#### 컨테이너 QoS 클래스

- CPU: 미설정, Memory: 미설정               컨테이너 QoS 클래스: BestEffort
- CPU: 요청=한계, Memory: 요청=한계    컨테이너 QoS 클래스: Guranteed

- 나머지                                                      컨테이너 QoS 클래스: Burstable

#### 다수의 컨테이너의 포드 QoS 클래스

- 컨테이너 QoS: BestEffort, 컨테이너 QoS: BestEffort      포드 QoS: BestEffort
- 컨테이너 QoS: Guranteed, 컨테이너 QoS: Guranteed    포드 QoS: Guranteed
- 나머지                                                                                  포드 QoS: Burstable

#### QoS 우선순위

메모리가 부족할 경우 BestEffort, Burstable, Guranteed순으로 프로세스가 종료됩니다. 두 개의 단일 컨테이너 포드가 같은 QoS클래스인 경우, 시스템은 백분율을 기준으로 요청된 메모리가 많은 것부터 강제로 종료합니다.

## LimitRange

LimitRange 리소스에 지정된 한계는 LimitRange 객체와 동일한 네임스페이스에 만들어진 개별 포드/ 컨테이너 똔느 그 밖의 개게 종류에 적용됩니다.

네임스페이스의 모든 포드에서 사용할 수 있는 리소스의 총량을 제한하지는 않습니다.(총량은 ResourceQuota 객체를 통해 제한)

```yaml
apiVersion: v1
kind: LimitRange
metadata:
 name: example
spec:
 limits:
 - type: Pod
   min:
    cpu: 50m
    memory: 5Mi
   max:
    cpu: 1
    momory: 1Gi
 - type: Container
   defaultRequest: # 명시적으로 지정하지 않는 컨테이너에 적용될 CPU 및 memory에 대한 요청
    cpu: 100m
    memory: 10Mi
   default: # 컨테이너를 지정하지 않은 컨테이너의 기본 한계 사항
    cpu: 200m
    memory: 100Mi
   min:
    cpu: 50m
    memory: 5Mi
   max:
    cpu: 1
    momory: 1Gi
   maxLimitRequestRatio: # 각 리소스의 한계와 요청 간의 최대 비율
    cpu: 4 # CPU 한계가 CPU 요처보다 4이상 클 수 없음
    memory: 10
 - type: PersistentVolumeClaim # PVC가 요청할 수 있는 최소 최대 스토리지 용량을 설정
   min:
    storage: 1Gi
   max:
    storage: 10Gi
```

## ResourceQuota

네임스페이스에서 사용할 수 있는 총 리소스의 양을 제한합니다.

포드가 사용할 수 있는 계산 리소스 양과 네임스페이스에서 영구볼륨 클레임 용량을 제한합니다. 또한 사용자가 네임스페이스 내에서 생성할 수 있는 포드, 클레임, 그 밖의 API 객체의 수를 제한할 수 있습니다.

ResourceQuota 객체는 생성된 네임스페이스에 적용되며, 모든 포드의 리소스 요청 및 한계에 적용되며 각 포드 또는 컨테이너별로 별도로 적용되지 않습니다.

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
 name: cpu-and-mem
spec:
 hard:
  requests.cpu: 400m
  requests.memory: 300Mi
  limits.cpu: 600m
  limits.memory: 500Mi
```

> ResourceQuota를 사용할 때 리소스의 요청 및 제한 용량을 설정하면 포드 또한 ResourceQuota로 제한한 리소스의 요청 및 제한 용량을 설정해야 합니다. 그렇지 않으면 API 서버가 포드를 허용하지 않습니다.

```yaml
# 영구 스토리지에 할당량 지정
apiVersion: v1
kind: ResourceQuota
metadata:
 name: storage
spec:
 hard:
  request.storage: 500Gi # PersistentVolumeClaim이 요청할 수 있는 스토리지 양을 500GiB로 제한
  # StorageClass에 동적으로 할당하는 경우
  ssd.storageclass.storage.k8s.io/requests.storage: 300Gi 
  standard.storageclass.storage.k8s.io/requests.storage: 1Ti
```

```yaml
# 생성 가능한 객체 수 제한
apiVersion: v1
kind: ResourceQuota
metadata:
 name: objects
spec:
 hard:
  pods: 10
  replicationcontrollers: 5
  secrets: 10
  configmaps: 10
  persistentvolumeclaims: 4
  services: 5
  services.loadbalancers: 1
  services.nodeports: 2
   ssd.storageclass.storage.k8s.io/persistentvolumeclaims: 2
```

```yaml
# QoS별 제한
apiVersion: v1
kind: ResourceQuota
metadata:
 name: besteffort-notterminating-pods
spec:
 scopes:
 - bestEffort
 - NotTerminating
 hard:
  pods: 4
```

