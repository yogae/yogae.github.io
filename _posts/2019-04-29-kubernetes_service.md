---
layout: post
title: kubernetes 서비스
data: 2019-04-29
categories: Kubernetes
author: yogae
---

- 동일한 서비스를 제공하는 포드 그룹에 다일 진입점을 만들기 위해 생성하는 리소스입니다.

## service yaml 파일 생성

```yaml
# kubia-svc.yaml
apiVersion: v1
kind: Service
metadata:
 name: kubia
spec:
 sessionAffinity: ClientIP # 특정 클라이언트에서 생성된 모든 요청을 매번 같은 포드로 리디레션할 때 사용(default: NONE)
 ports:
 - port: 80 # 서비스가 사용할 포트
   targetPort: 8080 # 서비스가 포워드할 컨테이너 포트
 selector:
  app: kubia # 라벨이 app=kubia인 모든 포드는 이 서비스에 속한다.
```

### 다중 포트 설정

- 다중 포트를 갖는 서비스를 생성할 때 각 포트에 이름을 꼭 지정해야 합니다.
- 서로 다른 포드의 세트에 개별적으로 라벨 셀렉터를 지정하고 싶다면 두 개의 서비스를 만들어야 합니다.

```yaml
apiVersion: v1
kind: Service
metadata:
 name: kubia
spec:
 ports:
 - name: http
   port: 80
   targetPort: 8080
 - name: https
   port: 443
   targetPort: 8443
 selector:
  app: kubia
```

### 이름이 지정된 포트 사용

```yaml
kind: Pod
spec:
 containers:
 - name: kubia
   ports:
   - name: http # 컨테이너 포트 8080을 http 이름으로 설정
     containerPort: 8080 
   - name: https # 컨테이너 포트 8443을 https 이름으로 설정
     containerPort: 8443
```

```yaml
apiVersion: v1
kind: Service
metadata:
 name: kubia
spec:
 ports:
 - name: http # 포트 80은 http라 불리는 컨테이너 Port에 매핑
   port: 80
   targetPort: http
 - name: https # 포트 443은 https라 불리는 컨테이너 Port에 매핑
   port: 443
   targetPort: https
 selector:
  app: kubia
```

## 환경 변수를 이용한 서비스 검색

```bash
kubectl exec kubia-3inlr env # 컨테이너 안의 환경변수 목록을 조회
```

```bash
# response
PATH=...
...
HOSTNAME=kubia-3inlr
KUBIA_SERVICE_HOST=10.100.88.242 # 서비스 IP
KUBIA_SERVICE_PORT=80 # 서비스가 사용 가능한 포트
...
```

## 서비스 엔드포인트

- 엔드포인트라 불리는 리소스가 포드와 서비스 사이에 위치합니다.
- 엔드포인트 리소스는 서비스에 의해 노출되는 IP주소와 포트의 목록입니다.
- 포드 셀렉터가 서비스 스펙에 정이돼 있더라도 들어오는 연결을 리다이렉트할 때 직접 사용하진 않습니다. 대신 셀렉터는 IP와 포트의 목록을 만드는 데 사용되고 엔드포인트 리소스에 저장됩니다.

```bash
kubectl get endpoints kubia
```

### 수동으로 서비스 엔드포인트 설정

포드 셀렉터 없이 서비스를 만들었다면 쿠버네티스는 엔드포인트 리소스를 만들지 못 합니다.

```yaml
# external-service.yaml
apiVersion: v1
kind: Service
metadata:
 name: external-service
spec:
 # type: ExternalName
 # externalName: api.company.com # 도메인 주소 
 ports:
 - port: 80
```

```yaml
# external-service-endpoints.yaml
apiVersion: v1
kind: Endpoints
metadata:
 name: external-service # 엔드포인트 객체 이름은 서비스의 이름과 매칭돼야 합니다.
subsets:
- addresses: # 서비스가 연결을 포워딩할 엔드포인트의 IP
  - ip: 11.11.11.11
  - ip: 22.22.22.22
  ports:
  - port: 80
```

- 엔드포인트 오브젝트는 서비스와 동일한 이름이어야 하고 서비스를 위한 IP와 포트 정보를 담고 있습니다.

## 외부 클라이언트로 서비스 노출

### 서비스가 외부에서 액세스 가능하게 하는 방법

#### 1. NodePort 서비스 타입으로 설정하기

- NodePort 서비스를 생성해 쿠버네티스가 모든 노드를 대상으로 포트를 예약합니다.

- 모든 노드에 동일한 포트 번호를 사용하게 됩니다.

```yaml
apiVersion: v1
kind: Service
metadata:
 name: kubia-nodeport
spec:
 type: NodePort # 서비스 타입을 NodePort로 설정
 ports:
 - port: 80 # ClusterIP port
   targetPort: 8080 # 이 서비스에 연결되는 포트의 대상 포트
   nodePort: 30123 # 노드의 port
 selector:
  app: kubia
```

#### 2. LoadBalancer 서비스 타입으로 설정하기

- 쿠버네티스 클러스터는 클라우드 인프라스트럭처로부터 로드 밸런서를 자동으로 프로비전하는 기능을 지원합니다.
- LoadBalancer 서비스는 NodePort 서비스의 확장이기 때문에 서비스는 NodePort 서비스처럼 동작합니다.
- 특정 노드를 위한 포트를 설정하지 않습니다. 쿠버네티스에서 알아서 선택합니다.

```yaml
# kubia-svc-loadbalancer.yaml
apiVersion: v1
kind: Service
metadata:
 name: kubia-loadbalanver
spec:
 type: LoadBalancer
 ports:
 - port: 80
   targetPort: 8080
 selector:
  app: kubia
```

#### 3. 인그레스 리소스 생성하기

- 수십 가지 서비스에 액세스를 제공할 수 있습니다.
- 인그레스 리소스를 작동시키려면 클러스터에서 인그레스 컨트롤러를 실행해야 합니다.

```yaml
apiVersion: extentions/v1
kind: Ingress
metadata:
 name: kubia
 spec:
  rules:
  - host: kubia.example.com # kubia.example.com 도메인 이름을 서비스로 매핑
    http:
     paths:
     - path: /
       backend:
        serviceName: kubia-nodeport
        serviceProt: 80
```

##### yaml 설정

- 동일한 호스트 다른 서비스

    ```yaml
    ...
    - host: kubia.example.com
      http:
       paths:
       - path: /kubia
         backend:
          serviceName: kubia
          servicePort: 80
       - path: /bar
         backend:
          seviceName: bar
          servicePort: 80
    ```

- 다른 호스트 다른 서비스

    ```yaml
    ...
    spec:
     rules:
     - host: foo.example.com
       http:
        paths:
        - path: /
          backend:
           serviceName: foo
           serviceProt: 80
     - host: bar.example.com
       http:
        paths:
        - path: /
          backend:
           serviceName: bar
           servicePort: 80
    ```

##### TLS 트래픽을 처리하기 위한 인그레스 설정

TLS의 인증서는 secret이라는 쿠버네티스 리소스에 저장됩니다.

```yaml
kubectl create secret tls tls-secret --cert=<path/인증서.cert> --key=<path/키.key> # kubernetes secret 리소스 생성
```

```yaml
apiVersion: extentions/v1
kind: Ingress
metadata:
 name: kubia
 spec:
  tls:
  - secretName: tls-secret
    hosts: 
    - kubia.example.com 
  rules:
  - host: kubia.example.com # kubia.example.com 도메인 이름을 서비스로 매핑
    http:
     paths:
     - path: /
       backend:
        serviceName: kubia-nodeport
        serviceProt: 80
```

- aws certificate manager 사용하기

  ```yaml
  kind: Ingress
  metadata:
    name: test-app
    annotations:
      zalando.org/aws-load-balancer-ssl-cert: <certificate ARN>
  ...
  ```

> <https://kubernetes-on-aws.readthedocs.io/en/latest/user-guide/ingress.html>

> 참고: [Kubernetes Ingress with AWS ALB Ingress Controller](https://aws.amazon.com/ko/blogs/opensource/kubernetes-ingress-aws-alb-ingress-controller/)