---
layout: post
title:  "Kubernetes namespace"
date: 2019-04-20
categories: Kubernetes
author: yogae
---

- 많은 구성 요소를 포함하는 복잡한 시스템을 더 작은 그룹으로 분할할 수 있습니다.

- 리눅스 네임스페이스가 아니며 서로 프로세스를 격리시키는 데 사용합니다.

- 리소스 이름은 네임스페이스 내에서만 고유해야 합니다. 두개의 네임스페이스는 동일한 이름의 리소스를 포함할 수 있습니다.
- 네임스페이스는 특정 사용자에게만 특정 리소스 접근을 허용하고 개별 사용자가 사용할 수 있는 컴퓨팅 리소스의 양을 제한하는 데에도 사용할 수 있습니다.

## namespace 확인

```bash
kubectl get ns # 네임스페이스 확인

kubectl get pods --namespace kube-system # 네임스페이스에 속하는 pod 확인
=> kubectl get pods --n kube-system
```

### 기본으로 설정되어 있는 namespace

```bash
NAME          STATUS    AGE
default       Active    4d
kube-public   Active    4d
kube-system   Active    4d
```

Kube-system namespace는 쿠버네티스 시스템과 관련된 리소스입니다.

## namespace 생성

### yaml 파일로 namespace 생성

```yaml
# custom-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
 name: custom-namespace # namespace의 이름
```

```bash
kubectl create -f custom-namespace.yaml
```

### kubectl로 namespace 생성

```bash
kubectl create namespace custom-namespace # 새로운 namespace 생성

kubectl create -f kubia-manual.yaml -n custom-namespace # 리소스를 생성할 때 namespace를 지정
```

다른 네임스페이스의 객체를 나열, 설명, 수정, 삭제할 때 --namespace 플래그를 전달해야 합니다. 네임스페이스를 지정하지 않으면 현재 컨텍스트에 구성된 기본 네임스페이스에서 작업을 수행합니다.

## namespace 삭제

### namespace를 삭제해 포드 삭제

```bash
kubectl delete ns custom-namespace # 포드는 네임스페이스와 함께 자동으로 삭제
```

