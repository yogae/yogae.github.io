---
layout: post
title: kubernetes args
data: 2019-05-05
categories: Kubernetes
author: yogae
---

## 쿠버네티스에서 명령과 인자 재정의

```yaml
kind: Pod
spec:
 containers:
 - image: some/image
   command: ["/bin/command"] # docker의 ENTRYPOINT에 해당
   args: ["arg1", "arg2"] # docker의 CMD에 해당
```

## 컨데이너의 환경 변수 설정

```yaml
kind: Pod
spec:
 containers:
 - name: html-generator
   image: luksa/fortune:env
   env:
   - name: INTERVAL
     value: "30"
```

```yaml
# 다른 환경 변수 참조
   env:
   - name: FIRST_VAR
     value: "foo"
   - name: SECOND_VAR
     value: "$(FIRST_VAR)bar"
```

## ConfigMap

- 쿠버네티스는 설정 옵션을 ConfigMap이라는 별도의 객체로 분리할 수 있습니다.

### ConfigMap 생성

```bash
# kubectl create configmap 명령 사용
kubectl create configmap fortune-config --from-literal=sleep-interval=25

# 파일로 설정
kubectl create configmap fortune-config --from-file=conig-file.conf

# 파일의 내용을 특정 키 아래에 설정
kubectl create configmap fortune-config --from-file=customkey=conig-file.conf
```

```yaml
# yaml 파일 생성
apiVersion: v1
data:
 sleep-interval: "25"
kind: ConfigMap
metadata:
 name: fortune-config
```

###  ConfigMap 사용

- valueFrom

    ConfigMap에서 각각의 key로 접근하여 value를 받아옵니다.

    ```yaml
    # pod에서 ConfigMap 사용
    apiVersion: v1
    kind: Pod
    metadata:
     name: fortune-env-from-configmap
    spec:
     containers:
     - image: luksa/fortune:env
       env:
       - name: INTERVAL
         valueFrom:
          configMapKeyRef:
           name: fortune-config # 참조할 ConfigMap 이름
           key: sleep-interval # ConfigMap에서 사용할 key
    ```

- envFrom

  ConfigMap의 모든 항목을 한번에 설정합니다.

  대시(-)를 포함하는 항목은 건너뜁니다.

  ```yaml
  spec:
   containers:
   - image: some-image
     envFrom:
     - prefix: CONFIG_ # 모든 환경변수에 CONFIG_ 접두어를 붙임
       configMapRef:
        name: fortune-config
  ```

### ConfigMap 볼륨 사용

- 포드를 다시 만들거나 컨테이너를 다시 시작하지 않고도 설정을 업데이트할 수 있습니다.

```bash
# 예시 file 설정
mkdir configmap-files
cat "ngnix-conf-file.conf" > configmap-files/ngnix-config.conf
echo "25" > configmap-files/sleep-interval
```

```bash
# folder안에 있는 파일로 ConfigMap 생성
kubectl create configmap fortune-config --from=configmap-files
```

```yaml
# 파일로 마운트된 ConfigMap 사용
apiVersion: v1
kind: Pod
metadata:
 name: configmap-volume
spec:
 volumes:
 - name: config
   configMap:
    name: fortune-config
    # items: # 특정 파일만 선택할 경우
    # - key: ngnix-config.conf
    #   path: gzip.conf
 containers:
 - image: nginx:alpine
   name: web-server
   volumeMounts:
   ...
   - name: config
     mountPath: /etc/ngnix/config.d
     # subPath: <fileName> # 특정 파일만 mount할 때 사용
     readOnly: true
```