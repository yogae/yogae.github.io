---
layout: post
title: kubernetes stateful set
data: 2019-05-16
categories: Kubernetes
author: yogae
---

애플리케이션의 인스턴스가 안정적인 이름과 사태를 가지면서 대처할 수 없고 개별적으로 처리돼야 하는 애플리케이션에 맞게 저정됩니다.

스테이트풀셋에 의해 생성된 포드에는 순서형 색인이 할당됩니다.

## 스케일 다운

스테이트풀셋을 스케일다운하면 항상 가장 높은 서수 인덱스가 있는 인스턴스가 제거됩니다.

특정 스테이트풀 애플리케이션은 빠른 스케일다우능ㄹ 제대로 처리하지 못하므로 스테이트풀셋은 한 번에 하나의 포드 인스턴스를 스케일다운합니다.

## yam file 생성

```yaml
# stateful persistent volume
kind: List
apiVersion: v1
items:
- apiVersion: v1
  kind: PersistentVolume
  metadata:
   name: pv-a
  spec:
   capacity:
    storage: 1Mi
   accessModes:
   - ReadWriteOnce
   persistentVolumeReclaimPolicy: Recycle # 클레임이 볼륨을 해제하면 다시 사용하기 위해 재사용됩니다.
   gcePersistentDisk:
    pdName: pv-a
    fsType: nfs4
- ...
# pv-b, pv-c 정의
```

```yaml
# statful service
apiVersion: v1
kind: Service
metadata:
 name: kubia
spec:
 clusterIP: None # 스테이트풀셋의 관리 서비스는 헤드리스이어야 합니다.
selector:
 app: kubia
 ports:
 - name: http
   port: 80
```

> 서비스는 헤드리스이기 때문에 서비스를 통해 포드와 통신할 수 없습니다.

> statefulset에서 데이타베이스와 같이 master,slave 구조가 있는 서비스들의 경우에는 service를 통해서 로드밸런싱을 하지 않고, service 를 통해서 로드 밸런싱을 하는 것을 잘 사용하지 않고 개별 pod의 주소를 알고 접속해야 한다. 그래서 개별 Pod의 dns 이름이나 주소를 알아야 한다. 
>
> Pod들은 DNS이름을 가질 수 는 있으나, {pod name}.{service name}.{name space}.svc.cluster.local 식으로 이름을 가지기 때문에, pod 를 DNS를 이용해서 접근하려면 service name이 있어야 한다. 그러나 statefulset에 의한 서비스들은 앞에서 언급하였듯이 쿠버네티스 service를  이용해서 로드밸런싱을 하는 것이 아니기 때문에, 로드밸런서의 역할은 필요가 없고, 논리적으로, pod들을 묶어줄 수 있는 service만 있으면 되기 때문에 headless 서비스를 활용한다. 
>
> 출처: [https://bcho.tistory.com/tag/headless service](https://bcho.tistory.com/tag/headless%20service) [조대협의 블로그]

```yaml
# stateful set
apiVersion: v1
kind: StatefulSet
metadata:
 name: kubia
spec:
 serviceName: kubia
 replicas: 2
 template:
  metadata:
   labels:
    app: kubia
  spec:
   containers:
   - name: kubia
     image: luksa/kubia-pet
     ports:
     - name: http
       containerPort: 8080
   volumeMounts:
   - name: data
     mountPath: /var/data
 volumeClaimTemplates:
 - metadata:
    name: data
   spec:
    resources:
     requests:
      starage: 1Mi
    accessModes:
    - ReadWriteOnce
```

