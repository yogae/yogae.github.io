---
layout: post
title:  "Kubernetes probe"
date: 2019-04-22
categories: Kubernetes
author: yogae
---

## Liveness Probe

컨테이너가 아직 살아 있는지 확인할 수 있습니다.

쿠버네티스 주기적으로 검사를 실행하고 검사가 실패할 경우 컨테이너를 다시 시작합니다.

### 컨테이너 상태 확인 메커니즘

- HTTP GET 포로브는 지정한 IP 주소, 포트 경로에 HTTP GET 요철을 수행합니다. 프로브가 응답을 수신하고 응답 코드가 오류를 나타내지 않으면 프로브는 성공한 것으로 간주합니다.
- TCP 소켓 프로브가 컨테이너의 지정된 포트에 TCP 연결을 열려고 시도합니다. 성공적으로 연결되면 프로브가 성공한 것으로 간주합니다.
- Exec 프로브는 컨테이너 내부에 임의의 명령을 실행하고 명령의 상태 코드를 확인합니다.

### HTTP 기반 Liveness Probe 생성

```yaml
apiVersion: v1
kind: pod
metadata:
 name: kubia-liveness
spec:
 containers:
 - image: luksa/kubia-unhealthy
   name: kubia
   livenessProbe: # httpGet liveness prob를 정의합니다.
    httpGet:
     path: /
     port: 8080
    initialDelaySeconds: 15 # 첫 번째 프로브 실행 전 15초 지연
```

```bash
kubectl logs mypod --provious # 이전 컨테이너가 종료된 이유를 log로 확인하기
```

## Readiness Probe

레디네스 프로브는 주기적으로 호출되고 틀적 포드가 클라이언트 요청이 수락 여부를 결정합니다. 컨테이너의 레디네스 프로브가 성공을 반환한다면 커테이너가 요청을 받아들일 준비가 됐다는 신호입니다.

```yaml
apiVersion: v1
kind: ReplicationController
...
spec:
 ...
 template:
  ...
  spec:
   contatiners:
   - name: kubia
     image: luksa/kubia
     readinessProbe:
      exec:
       command:
       - ls
       - /var/ready
  
```

