---
layout: post
title: kubernetes 네트워트 보안
data: 2019-06-03
categories: Kubernetes
author: yogae
---

## 포드 네임스페이스

포드 내의 컨테이너는 일반적으로 다른 컨테이너 또는 노드의 기본 네임스페이스에서 실행 중인 프로세스와 컨테이너상의 프로세스를 분리하는 변도의 네임스페이스아래에서 실행됩니다.

### 포드에서 노드의 네트워크 네임스페이스 사용하기

특정 포드(일반적으로 시스템 포드)는 호스트의 기본 네임스페이스에서 동작해야 노드 레벨 리소스와 장치를 살펴보고 조작할 수 있습니다. 포트 스펙의 hostNetwork 속성을 true로 설정해 수행할 수 있습니다.

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: pod-with-host-network
spec:
 hostNetwork: true
 containers:
 - name: main
   image: alpine
   commacd: ["/bin/sleep", "999999"]
```

### 호스트 네임스페이스를 사용하지 않고 호스트 포트에 바인딩

hostPort를 사용할 때 해당 노드에서 실행중인 포드로 직접 전달됩니다. hostPort 기능은 데몬셋을 사용해 모든 노드로 배포하는 시스템 서비스를 노풀하는데 주로 사용됩니다.

```yaml
# hostPort 기능
apiVersion: v1
kind: Pod
metadata:
 name: kubia-hostport
spec:
 containers:
 - image: luksa/kubia
   name: kubia
   ports:
   - containerPort: 8080
     hostPort: 9000
     protocol: TCP
```

NodePort 서비스에서는 무작위로 선택된 포드로 전달됩니다.

### 노드의 PID와 IPC 네입스페이스 사용

hostPID와 hostIPC 포드 스텍 속성을 true로 설정하면 포드의 컨테이넌는 노드의 PID 및 IPC 네임스페이스를 사용함로 컨테이너에서 실행 중인 포로세스가 노드의 모든 프로세스를 보거나 IPC를 통해 노드와 통신할 수 있습니다.

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: pod-with-host-pid-ipc
spec:
 hostPID: true
 hostIPC: true
 containers:
 - image: luksa/kubia
   name: kubia
   ports:
   - containerPort: 8080
     hostPort: 9000
     protocol: TCP
```

## 컨테이너 보안 컨텍스트 설정

