---
layout: post
title: kubernetes deployment
data: 2019-05-15
categories: Kubernetes
author: yogae
---

Deployment는 포드를 직접 관리하지 않고 ReplicaSet을 생성하고 ReplicaSet이 관리를 하도록 위임합니다.

Deployment는 ReplicationContoller대신 ReplicaSet을 사용하여 배포합니다.

## yaml file 작성

```yaml
# kubia-deployment-v1.yaml
apiVersion: apps/v1beta1
kind: Deployment
metadata:
 name: kubia
spec:
 replicas: 3
 minReadySeconds: 10
 strategy:
  rollingUpdate:
   maxSurge: 1
   maxUnavailable: 0
  type: RollingUpdate
 template:
  metadata:
   name: kubia
   labels:
    app: kubia
  spec:
   containers:
   - image: luksa/kubia:v1
     name: nodejs
     readinessProbe:
      periodSeconds: 1
      httpGet:
       path: /
       port: 8080
```

```bash
kubectl create -f kubia-deployment-v1.yaml --record # --record 포함하여 리비전 히스토리에 명령이 기록되며 나중에 유용하게 사용할 수 있습니다.
```

## deployment 상태 확인

```bash
kubectl rollout status deployment kubia # 실행 중인 pod 상태 확인
```

## deployment 전략

- Deployment의 디폴트 배포 전략은 RollingUpdate입니다.
- RollingUpdate 전략은 오래된 포드를 하나씩 제거하는 동시에 새로운 포드를 추가해 전체 업데이트 프로세스에 걸쳐 애플리케이션을 사용할 수 있도록 합니다.(애플리케이션이 이전 버전과 새 버전을 동시에 처리할 수 있는 경우에만 사용해야 합니다.)
- Recreate 전략을 사용하면 새 포드를 만들기 전에 모든 이전 포드를 삭제할 수 있습니다. (애플리케이션이 여러 버전을 동시에 실행할 수 없으며 새 버전을 시작하기 전에 이전 버전을 완전히 중지해야 하는 경우 사용합니다. 이 전략에는 애플리케이션을 완전히 사용할 수 없게 되는 짧은 시간이 포함됩니다.)

## 롤링 업데이트 트리거

```bash
kubectl set image deployment kubia nodejs=luksa/kubia:v1 # kubia 디플로이먼트의 포드 템플리시 업데이트돼 nodejs 컨테이너에서 사용하고 잇는 이미지가 v1에서 luksa/kubia:v2로 변경됩니다.
```

Deployment를 이용하여 배포된 pod는 새 레플리카셋에 의해 관리되고 기존 레플리카셋은 삭제되지 않고 남아 있습니다. update를 진행하면서 문제가 발생하면 쉽게 롤백할 수 있도록 합니다.

### maxSurge와 maxUnavailable 속성

```yaml
...
spec:
 stategy:
  rollingUpdate:
   maxSurge: 1
   maxUnavailable: 0
  type: RollingUpdate
```

- maxSurge:  deployment에 설정되어 있는 기본 pod개수보다 여분의 pod가 몇개가 더 추가될 수 있는지를 설정할 수 있습니다.
- maxUnavailable: 업데이트하는 동안 몇 개의 pod가 이용 불가능하게 되어도 되는지를 설정하는데 사용됩니다. 

### minReadySeconds 속성

새로 생성된 포드가 사용 가능한 상태로 전환하기 전 준비 상태로 머무를 시간을 지정합니다.

> minReadySeconds를 올바르게 설정하지 않고 readiness probe만 정의하는 경우 readiness probe의 첫 번째 호출이 성공하면 새 포드를 즉시 사용할 수 있는 거으로 간주된다. 잠시 후 readiness probe가 실패하면 잘못된 버전이 모든 포드에 롤아웃된다.

## Rollout

### Rollout rollback

```bash
kubectl rollout undo deployment kubia # 이전 버전으로 롤백

kubectl rollout undo deployment kubia --to-revision=1 # revision 1로 rollback
```

### Rollout history

디플로이먼트는 리비전 히스토리를 유지하므로 롤아웃 롤백이 가능합니다. 히스토리는 레플리카셋 내부에 저장되고 레플리카셋은 이전 버전뿐만 아니라 모든 버전으로 롤백할 수 있습니다.

```bash
kubectl rollout history deployment kubia # history 확인
```

리비전 히스토리의 크기는 디플로이먼트 리소스의 revisionHistoryLimit 속성에 의해 제한됩니다.

### Rollout 중지 및 재개

```yaml
kubectl rollout pause deployment kubia # 롤아웃 중지 -> 카나리아 릴리스가능

kubectl rollout resume deployment kubia # 롤아웃 재개
```

