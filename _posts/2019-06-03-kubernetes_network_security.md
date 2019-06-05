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

securityContext 속성을 통해 포드와 컨테이너에 보안 관련 기능을 설정할 수 있습니다.

### 보안 컨텍스트에서 설정 가능한 것

- 컨테이너의 프로세스에서 실행할 수 있는 사용자 지정하기
- 컨테이너가 루트로 실행되는 것을 방지하기
- 컨테이너를 권한 모드로 실행해 노드의 커널에 대한 모든 액세스 권한을 부여하기
- 권한 모드로 실행해 컨테이너에 가능한 모든 권한을 주는 것과는 대조적으로 기능을 추가하거나 삭제해 세부적으로 권한 구성하기
- 컨테이너를 강력하게 잠그기 위해 SELinux 옵션을 설정하기
- 프로세스가 컨테이너의 파일 시스템에 쓰지 못하게 하기

```bash
# 사용자 및 그룹 ID 확인
kubectl exec pod-with-default id
```

> 컨테이너를 실행하는 사용자는 컨테이너 이미지에 지정됩니다. 도커 파일에서 이것을 USER 지시어를 사용해 수행됩니다. 생략하면 컨테이너는 루트로 실행됩니다.

### 특정 사용자로 컨테이너 실행

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: pod-as-user-guest
spec:
 containers:
 - name: main
   image: alpine
   command: ["/bin/sleep", "999999"]
   securityContext:
    runAsUser: 405 # 사용자 이름이 아닌 사용자 ID를 설정합니다. 사용자 ID 405는 게스트 사용자를 뜻합니다.
    # runAsNonRoot: true # 루트 사용자로 실행하는 것을 허용하지 않는다.
    # privileged: true # 권한 모드로 실행 -> 노드으이 커널에 대한 모든 액세스 권한을 얻는다.
    # readOnlyRootFilesystem: true # 이 컨테이너의 파일 시스템은 쓰여질 수 없다.
```

```bash
kubectl exec pod-as-user-guest
# response: uid=405(guest) gid=100(users)
```

> 프로덕션 환경에서 포드를 실행할 때 보안을 강화하려면 컨테이너의 readOnlyRootFileSystem 속서을 true로 설정합니다.

### 컨테이너가 다른 사용자로 실행될 때 볼륨 공유

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: pod-with-shared-volume-fsgroup
spec:
 securityContext:
  fsGroup: 555 # fsGroup, supplementalGroup는 포드 수준에서 보안 컨텍스트에 정의되어 있다.
  supplementalGroup: [666, 777]
 containers:
 - name: first
   image: alpine
   command: ["sleep","999999"]
   securityContext:
    runAsUser: 1111
   volumeMounts:
   - name: shared-volume
     mountPath: /volume
     readOnly: false
 - name: second
   image: alpine
   command: ["sleep","999999"]
   securityContext:
    runAsUser: 2222
   volumeMounts:
   - name: shared-volume
     mountPath: /volume
     readOnly: false
 volumes:
 - name: shared-volume
   emptyDir:
```

> 마운트된 볼륨의 디렉터리에 파일을 작성하면 파일은 사용자 ID 1111 및 그룹 ID 555에 소유된다.

## PodSecurityPolicy 리소스

PodSecurityPolicy는 사용자가 포드에서 사용할 수 있거나 사용할 수 없는 보안 관련 기능이 무엇인지 정의하는 클러스터 수준 리소스입니다.

누군가가 API 서버로 포드 리소스를 게시하면 PodSecurityPolicy 승인 제어 플러그인은 구성된 PodSecurityPolicies를 기반해 포드 정의의 유효성을 검사합니다.

```yaml
apiVersion: extensions/v1beta1
kind: PodSecurityPolicy
metadata:
 name: default
spec:
 hostIPC: false
 hostPID: false
 hostNetwork: false
 hostPorts:
 - min: 10000
   max: 11000
 - min: 13000
   max: 14000
 privileged: false
 readOnlyRootFilesystem: true # 읽기 전용
 runAsUser:
  rule: RunAsAny # 어떤 유저나 그룹이든 실행할 수 있다.
  # 또는 아래와 같이 범위를 지정 가능
  # rule: MustRunAs
  # range:
  # - min: 2
  #   max: 2
  
 fsGroup:
  rule: RunAsAny
 supplementalGroup:
  rule: RunAsAny
 seLinux:
  rule: RunAsAny
 volumes:
 - '*' # 모든 volume의 유형이 포드에서 사용될 수 있다.
 allowedCapabilities: # 컨테이너에 추가할 수 있는 기능 지정
 - SYS_TIME
 defaultAddCapabilities: # 모든 컨테이너에 기능 추가
 - CHOWN
 requiedDropCapabilities: # 컨테이너에서 기능 사용 못하게 함
 - SYS_ADMIN
 - SYS_MODULE
```

> PodSecurityPolicy는 포드를 생성하거나 업데이트할 때만 반영되기 때문에 정책을 변경해도 기존 포드에는 아무런 영향을 미치지 않는다.

### 여러 사용자에게 다른 PodSecurityPolicy 할당하기 위해 RBAC 사용

```bash
kubectl create clusterrole psp-default --verb=use --
resource=podsecuritypolicies --resource-name=default # use라는 특별한 동사 구문을 사용
```

```bash
kubectl create clusterrolebinding psp-all-users --clusterrol=psp-default --group=system:authenticated
```

## NetworkPolicy

NetworkPolicy는 포드의 인바운드나 아웃바운드 트래픽을 제한하기 위해 사용합니다.

네임스페이스의 포드는 기본적으로 누구든지 액세스할 수 있습니다.

```yaml
# 모든 클라이언트가 네임스페이스의 모든 포드에 연결할 수 없도록 설정
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
 name: default-deny
spec:
 podSelector: # 포드 셀렉터를 비우면 동일한 네임스페이스의 모든 포드와 매치된다.
 
```

```yaml
# 특정 pod에서 접근가능하도록 설정
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
 name: database-network
spec:
 podSelector:
  matchLabels:
   app: database # app=database 라벨을 갖는 포드의 접근을 보호
 ingress:
 - from:
   - podSelector:
      matchLabels:
       app: webserver # app=webserver 라벨을 갖는 포드만이 연결을 허용
   ports:
    - port: 5432 # 허용할 포트
```

```yaml
# 특정 네임스페이스에서 접근가능하도록 설정
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
 name: shoppingcart-network
spec:
 podSelector:
  matchLabels:
   app: shoppingcart # app=database 라벨을 갖는 포드의 접근을 보호
 ingress:
 - from:
   - namespaceSelector:
      matchLabels:
       tenent: manning
   ports:
    - port: 80 # 허용할 포트
```

```yaml
# CIDR
ingress:
- from:
  - ipBlock:
     cidr: 192.168.1.0/24
```

```yaml
# 트래픽 제한
egress:
- from:
  - ipBlock:
     cidr: 192.168.1.0/24
```