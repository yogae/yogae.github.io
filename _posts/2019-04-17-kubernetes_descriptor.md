---
layout: post
title:  "Kubernetes 디스크립터"
date: 2019-04-17
categories: Kubernetes
author: yogae
---

## 기본적인 포드 매니페스트

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: kubia-manual
spec:
 containers:
 - image: luksa/kubia
   name: kubia
   ports:
   - containerPort: 8080
	 protocol: TCP
```

## 디스크립터를 활용한 포드 만들기

```bash
kubectl create -f kubia-manual.yaml # pods todtjd

kubectl get po kubia-manual -o yaml # pods 정보 확인

kubectl get pods # 포드 상태 확인

kubectl logs kubia-manual # log 가져오기

kubectl port-forward kubia-manual 8888:8080 # 로컬 네트워크 8888포트를 pod의 8080으로 전달
```

