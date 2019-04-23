---
layout: post
title:  "Kubernetes 라벨 & 주석"
date: 2019-04-19
categories: Kubernetes
author: yogae
---

라벨은 포드뿐만 아니라 쿠버네티스의 모든 리소스를 구성하는 쿠버네티스 기능입니다.

리소스에 첨부하는 Key / value 쌍입니다.

리소스는 해당 라벨의 키가 해당 자원 내에서 고유한 경우 하나 이상의 라벨을 가질 수 있습니다.

## 라벨 지정하여 포드 만들기

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: kubia-manual-v2
 labels: # label
  create_method: manual
  env: prod
spec:
 containers:
 - image: luksa/kubia
   name: kubia
   ports:
   - containerPort: 8080
	 protocol: TCP
```

```bash
kubectl create -f kubia-manual-with-labels.yaml # pod 생성

kubectl get --show-labels # 라벨 확인

kubectl get pods -L creation_method, env # 특정 label만 열에 표시

kubectl label pods kubia-manual create_method=manual # label 추가

kubectl label pods kubia-manual-v2 env=debug --overwrite # 기존 label 변경

kubectl label node ip-172-22-22-22.ec2.internal gpu=false # node에 label
```

### 라벨 셀렉터

특정 라벨로 태그가 지정된 포드의 하위 집합을 선택하고 해당 포드에서 작업을 수행할 수 있습니다.

```bash
kubectl get pods -l creation_method=manual # 특정 label 선택

kubectl get pods -l env # label의 value와 상관없이 env label을 포함하는 pod 선택

kubectl get pods -l '!env' # env label을 포함하지 않는 pod 선택

kubectl get pods -l env=prod,creation_method=manual # 다중 선택

kubectl get nodes -l gpu=false
```

## 노드 지정을 위한 포드 스케줄링

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: kubia-gpu
spec:
 nodeSelector: 
  gpu: "false" # gpu=false 라벨을 포함하는 노드에만 포드를 배포하도록 지시합니다.
 containers:
 - image: luksa/kubia
   name: kubia
```

## 주석

라벨과 유사하지만 식별 정보를 보유하지 않습니다.

주석을 잘 사용하면 각 포드나 API 객체 설명이 추가 되므로 클러스터를 사용하는 모든 사람이 각 객체의 정보를 빠르게 찾을 수 있습니다.

주석은 비교적 짧은 것이 좋지만 주석에는 비교적 큰 데이터 블롭(256KB)이 포함될 수 있습니다.

### 주석 추가

```yaml
apiVersion: v1
kind: Pod
metadata:
 annotatoions:
  kubernets.io/create-by: |
   {"kind": "SerializedReference", ......}
```

```bash
kubectl annotate pod kubia-manual mycompany.com/comeannotation="foo bae"
```

> 고유한 접두사를 사용하지 않으면 의도치 않게 주석을 덮어 쓸 수가 있습니다.

### 주석 확인

```bash
kubectl describe pod kubia-manual
```

## 라벨 셀렉터 포드 삭제

```bash
kubectl delete pods kubia-gpu # 이름으로 pod 삭제

kubectl delete pods -l create_method=menual # 라벨로 pod 삭제

kubectl delete pods --all # 모든 pod 삭제
```

> 레플리케이션컨트롤러에 의해 생성된 포드를 삭제하면 즉시 새 포드가 생성됩니다. 포드를 삭제하려면 레플리케이션컨트롤러도 삭제해야 합니다.

