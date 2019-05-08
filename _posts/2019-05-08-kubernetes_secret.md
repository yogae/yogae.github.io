---
layout: post
title: kubernetes secret
data: 2019-05-08
categories: Kubernetes
author: yogae
---

쿠버네티스는 중요한 정보를 저장하고 분류하기 위해 시크릿이라고 하는 별도의 객체를 제공합니다.

마스터 노드 자체에서 시크릿은 암호화되지 않은 형태로 저장되어 있습니다.

모든 포드에는 자동으로 연결된 secret 볼륨이 있습니다.

## Secret 생성

```bash
kubectl create secret generic fortune-https --from-file=<file or folder>
```

## Secret 사용

```yaml
# fortune-config ConfigMap
# ConfigMap의 데이터 수정
...
data:
 may-nginx-config.conf: |
  server {
      listen	80;
      listen	443 ssl;
      ...
      ssl_certificate		certs/https.cert # /etc/nginx/certs에 secret을 mount할 것
      ssl_certificate_key	certs/https.key
  }
```

```yaml
# yaml 정의
apiVersion: v1
kind: Pod
metadata:
 name: fortune-https:
spec:
 containers:
 - image: nginx:alpine
   name: web-server
   volumeMounts:
   - name: config
     mountPath: /etc/nginx/conf.d
     readOnly: true
   - name: certs
     mountPath: /etc/nginx/certs/
     readOnly: true
 volumes:
 - name: config
   configMap:
    name: fortune-config
    items:
    - key: my-nginx-config.conf
      path: https.conf
 - name: certs
   secret:
    secretName: fortune-https
```

```yaml
# 환경변수로서 시크릿 항목 사용
env:
- name: FOO_SECRET
  valueFrom:
   secretKeyRef:
    name: fortune-https
    key: foo
```

## private docker 레지스트리 인증

```bash
kubectl create secret docker-registry mydockerhub --docker-username=<name> --docker-password=<password> --docker-email=<email>
```

```yaml
# 이미지 풀 시크릿을 이용한 포드 yaml
apiVersion: v1
kind: Pod
metadata:
 name: private-pod
spec:
 imagePullSecrets:
 - name: mydockerhub
 containers:
 - image: <username/private:tag>
   name: main
```

