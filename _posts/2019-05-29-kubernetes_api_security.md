---
layout: post
title: API 보안
data: 2019-05-29
categories: Kubernetes
author: yogae
---

## 인증

다음의 방법을 사용해 크라이언트의 ID를 얻습니다.

- 클라이언트 인증서
- HTTP 헤더로 전달된 인증 토큰
- 기본 HTTP 인증
- 기타

인증 플러그인은 인증된 사용자의 사용자 이름, 사용자 ID, 그룹을 반환합니다.

### 사용자

쿠버네티스는 계정 체계를 관리함에 있어서 하람이 사용하는 사용자 어카운트와 시스템이 사용하는 서비스 어카운트 두가지 개념을 제공합니다.

### 그룹

사용자 및 서비스 어카운트는 모두 하나 이상의 그룹에 속할 수 있습니다.

프러그인에 의해 반환되는 그룹은 임의의 그룹 이름을 나타내는 문자열일 뿐이지만 시스템에서 제공하는 기본 그룹은 특별한 의미가 있습니다.

- system:unauthenticated 어느 클라이언트도 인증할 수 없을 때
- system:authenticated 성공적으로 인증된 사용자
- system:serviceaccount 시스템의 모든 서비스어카운트를 포함
- system:serviceaccount:<namespace> 특정 네임스페이스의 모든 서비스어카운트를 포함

### 서비스어카운트

토큰 파일(secret 볼륨상의 각 컨테이너의 파일 시스템에 마운트된 /var/run/secrets/kuberetes.io/serviceaccount/token)은 서비스어카운트의 인증 토큰을 가지고 있습니다. 포드에서 실행중인 애플리케이션이 이 토큰을 사용해 API 서버에 연결하면 인증 플러그인이 서비스어카운트를 인증하고 서비스어카운트의 사용자 이름(system:serviceaccount:<namespace>:<service account name>)을 API 서버 코어로 다시 전달합니다.

서비스어카운트는 리소스이며 개별 네임스페이스로 범위가 지정됩니다.

```bash
# 서비스어카운트 나열
kubectl get sa

kubectl get serviceaccount
```

포드 매니페스트에서 계정 이름을 지정해 포드에 서비스어카운트를 할당할 수 있습니다. 명시적으로 지정하지 않으면 포드는 네임스페이스의 디폴트 서비스어카운트를 사용하게 됩니다.

포드에 각기 다른 서비스어카운트를 할당하면 각 포드에 접근할 수 있는 리소스를 제어할 수 있습니다.

```bash
kubectl describe sa foo
```

```
## response
Name:              foo
Namespace:         default
Labels:            <none>
Image pull secret: <none> # 모든 포드에 자동으로 추가됩니다.
Mountable secret:  foo-token-qzie3 # mount할 수 있는 secret
Tokens:            foo-token-qzie3 # 인증 토큰
```

서비스어카운트는 포드가 생성될 때 반드시 지정돼야 합니다. 생성된 이후에는 변경할 수 없습니다.

```yaml
# 사용자 지정 서비스어카운트를 사용한 포드
apiVersion: v1
kind: Pod
metadata:
 name: curl-custom-sa
spec:
 serviceAccountName: foo # 이 포드는 default 대신에 foo 서비스어카운트를 사용
 containers:
 ...
```

### RBAC 클러스터 보안

#### 네임스페이스 내에 존재하는 롤과 롤바인딩

RBAC 인증 플러그인은 사용자의 역할을 보고 사용자가 액션을 수행할 수 있는지 여부를 결정할 때 핵심 요소로 사용합니다.

```yaml
# 롤 정의: service-reader.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
 namespace: foo
 name: service-reader
rules:
- apiGroups: [""] # 서비스는 이름이 없는 core apiGroup의 리소스
  verbs: ["get", "list"]
  resources: ["services"]
```

```bash
# 롤 생성 명령
kube create role service-read --verb=get --verb=list --resource=service -n bar
```

롤은 수행할 수 있는 액셕을 정의하지만 누가 수행할 수 있는지는 지정하지 않습니다. 이를 수행하려면 롤을 사용자, 서비스어카운트 또는 그룹이 될 수 있는 주체에 바인딩해야 합니다.

```bash
# 롤 바인딩
kubectl create rolebinding test --role=service-reader --serviceaccount=foo:default -n foo
```

롤바인딩은 항상 하나의 롤을 참조하지만 롤을 어러 subject에 바인딩할 수 있습니다.

#### 클러스터 수준의 RBAC

네임스페이스와 연관 없는 리소스나 리소스가 아닌 URL, 또는 개별 네임스페이스 내부에 바인되는 공통된 롤로 사용하므로 필요할 때마다 동일한 롤을 다시 정의하지 하지 않을 수 있습니다.

```bash
# PersistentVolume을 나열하도록 허용하는 role
kubectl create clusterrole pv-reader --verb=get,list --resource=persistentvolumes

# rolebinding 
kubectl create clusterrolebinding pv-test --clusterrole=pv-reader --serviceaccount=foo:default

# 주의 아래와 같이 namespace 수준의 rolebinding을 하지 않도록 한다.
kubectl create rolebinding pv-test --clusterrole=pv-reader --serviceaccount=foo:default -n foo
```

#### 비리소스 URL 접근 허용

비리소스 url에는 명시적으로 접근 권한을 부여해야합니다. 

일반적으로 이 작업은 system:discovery 클러스터롤과 이름이 같은 클러스터롤바인딩을 통해 자동으로 수행됩니다.

#### 특정 네임스테이스에서 클러스터롤 사용

클러스터롤바인딩을 생성하고 클러스터롤을 참조할 경우 바인딩에 나열된 주체는 모든 네임스페이스에서 지정된 리소스를 볼 수 있습니다. 반면에 롤바인딩을 만들고 바인딩에 나열된 주체는 롤바인딩의 네임스페이스에 있는 리소스만 볼 수 있습니다.

#### 디폴트 클러스터롤

디폴트 클러스터롤 목록에는 system: 접두사로 시작하는 많은 수의 default 클러스터롤이 있습니다.

중요한 디폴트 클러스터롤

- view: 네임스페이스내의 대부분의 리소스를 읽을 수 있습니다.(롤, 롤바인딩, 스크릿 제외)
- edit: 네임스페이스의 리소스를 수정할 수 있을 뿐만아니라 시크릿을 읽고 수정 가능
- admin: 네임스페이스의 리소스를 완별하게 제어 가능
- cluster-admin: 모든 네임스페이스 제어 가능

#### 롤과 바인딩 타입의 특정 조합 정리

| 접근                                             | 롤 타입    | 사용할 바인딩 타입 |
| ------------------------------------------------ | ---------- | ------------------ |
| 클러스터 수준 리소스                             | 클러스터롤 | 클러스터롤바인딩   |
| 비리소스 URL                                     | 클러스터롤 | 클러스터롤바인딩   |
| 모든 네임스페이스의 네임스페이스로 지정된 리소스 | 클러스터롤 | 클러스터롤바인딩   |
| 여러 네임스페이스의 동일한 클러스터롤 재사용     | 클러스터롤 | 롤바인딩           |
| 각 네임스페이스에 롤를 정의                      | 롤바인딩   | 롤바인딩           |

