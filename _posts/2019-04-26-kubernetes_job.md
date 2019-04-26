---
layout: post
title: kubernetes 잡 리소스
data: 2019-04-26
categories: kubernetes
author: yogae
---

- 실행 중인 프로세스가 성공적으로 완료되면 컨테이너가 다시 시작되지 않습니다.(레플리카셋 및 데몬셋은 작업의 완료를 고려하지 않고 계속적으로 태스크를 실행)
- 노드 장애가 발생하면 잡이 관리하는 해당 노드의 포드는 다른 노드로 재스케줄됩니다.

## 잡 리소스 생성

```yaml
# export.yaml
apiVersion: batch/v1
kind: Job
metadata:
 name: batch-job
spec:
 template:
  metadata:
   labels:
    app: batch-job
  spec:
   restartPolicy: OnFailure # default alway
   containers:
   - name: main
     image: luksa/batch-job
```

```bash
kubectl create -f export.yaml
```

## 여러 포드 실행

```yaml
apiVersion: batch/v1
kind: Job
metadata:
 name: multi-batch-job
spec:
 completions: 5 # 5개의 포드를 성곡적으로 완료할 때까지 실행
 parallelism: 2 # 최대 두개의 포드를 병렬로 실행
 activeDeadlineSeconds: 100 # 100초 동안 실행하고 넘어가면 실패
```

```bash
kubectl scale job multi-batch-job --replicas 3 # 실행중인 job의 병렬 처리 크기를 증가시킴
```

## CronJob 생성



## 잡 리소스 확인

```bash
kubectl get jobs

kubectl get po

kubectl get po -a # job이 완료된 이후 job을 실행한 pod를 확인
# Flag --show-all has been deprecated, will be removed in an upcoming release
```

