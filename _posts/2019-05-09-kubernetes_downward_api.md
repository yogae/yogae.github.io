---
layout: post
title: kubernetes Downward API
data: 2019-05-09
categories: Kubernetes
author: yogae
---

Downward API를 사용하면 해당 포드의 내부에서 실행 중인 프로세스에 포드 자체의 메타 데이터를 노출할 수 있습니다.

## 사용 가능한 메타 데이터

- 포드의 이름
- 포드의 IP 주소
- 포드가 속한 네임스페이스
- 포드가 실행되고 있는 노드의 이름
- 포드가 실행 중인 서비스 계정의 이름
- 각 컨테이너에 대한 CPU 및 메모리 요청
- 각 컨테이너의 CPU 및 메모리 한계
- 포드의 라벨
- 포드의 주석

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: downward
spec:
 containers:
 - name: main
   image: busybox
   command: ["sleep", "99999999"]
   resources:
    requests:
     cpu: 15m
     memory: 100Ki
    limits:
     cpu: 100m
     memory: 4Mi
 env:
 - name: POD_NAME
   valueFrom:
    fieldRef:
     fieldPath: metadata.name
 - name: POD_NAMESPACE
   valueFrom:
    fieldRef:
     fieldPath: metadata.namespace
 - name: POD_IP
   valueFrom:
    fieldRef:
     fieldPath: status.podIP
 - name: NODE_NAME
   valueFrom:
    fieldRef:
     fieldPath: spec.nodeName
 - name: SERVICE_NAME
   valueFrom:
    fieldRef:
     fieldPath: spec.nodeName
 - name: SERVICE_ACCOUNT
   valueFrom:
    fieldRef:
     fieldPath: spec.serviceAccountName
 - name: CONTAINER_CPU_REQUEST_MILLICORES
   valueFrom:
    resourceFieldRef:
     resource: requests.cpu
     divisor: 1m
 - name: CONTAINER_MEMORY_LIMIT_KIBIBYTES
   valueFrom:
    resourceFieldRef:
     resource: limit.memory
     dinisor: 1Ki
```

```bash
# downward 포드의 환경 변수 확인
kubectl exec downward env
```

## Downward API 볼륨

환경 변수 대신 파일을 통해 메타 데이터를 노출하려면 Downward API 볼륨을 사용해야 합니다.

포드의 라벨이나 주석을 표시하는 데는 Downward API 볼륨을 사용해야 합니다.

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: downward
 labels:
  foo: bar
 annotations:
  key1: value1
  key2: |
   multi
   line
   value
spec:
 containers:
 - name: main
   image: busybox
   command: ["sleep", "99999999"]
   resources:
    requests:
     cpu: 15m
     memory: 100Ki
    limits:
     cpu: 100m
     memory: 4Mi
 volumeMounts:
 - name: downward
   mountPath: /etc/downward
 volumes:
 - name: downdard
   downwardAPI:
    items:
    - path: "podName"
      fieldRef:
       fieldPath: metadata.name
    - path: "podNameSpace"
      fieldRef:
       fieldPath: metadata.namespace
    - path: "labels"
      fieldRef:
       fieldPath: metadata.labels
    - path: "annotations"
      fieldRef:
       fieldPath: metadata.annotations
    - path: "containerCpuRequestMilliCores"
      resourceFieldRef:
       cotainerName: main
       resource: requests.cpu
       dinisor: 1m
    - path: "containerMemoryLimitBytes"
      resourceFieldRef:
       cotainerName: main
       resource: limits.memory
       dinisor: 1
```

