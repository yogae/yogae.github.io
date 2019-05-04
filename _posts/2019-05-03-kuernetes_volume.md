---
layout: post
title: kubernetes volume
data: 2019-05-03
categories: Kubernetes
author: yogae
---

## 사용 가능한 볼륨

### emptyDir 볼륨

- 일시적인 데이터를 저장하는 데 사용되는 비어있는 단순한 디렉터리

- 볼륨의 수명이 포드와 연관되어 있기 때문에 포드를 삭제하면 볼륨의 내용이 손실됩니다.

- 동일한 포드에서 실행 중인 컨테이너 간에 파일을 공유할 때 특히 유용합니다.

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: fortune
spec:
 containers:
 - image: luksa/fortune
   name: html-generator
   volumeMounts:
   - name: html
     mountPath: /var/htdocs
 - image: nginx:airpline
   name: web-server
   volumeMounts:
   - name: html
     mountPath: /usr/share/nginx/html
     readOnly: true
   ports:
   - containerPort: 80
     protocol: TCP
 volumes:
 - name: html
   emptyDir: {}
```

### gitRepo 볼륨

- volume이 생성될 때 git repository에서 emptyDir volume으로 파일을 복제합니다.
- gitRepo 볼륨은 생성된 후에는 참조하는 repo와 동기화되지 않습니다. => 레플리케이션컨트롤러가 관리하는 경우 포드를 삭제하면 새 포드가 만들어지고 새 포드의 볼륨에 최신 커밋이 포합됩니다.

```yaml
apiVersion: v1
kind: Pod
metadata:
 name: gitrepo-volume-pod
spec:
 containers:
 - image: nginx:alpine
   name: web-server
   volumeMounts:
   - name: html
     mountPath: /usr/share/nginx/html
     readOnly: true
   ports:
   - containerPort: 80
     protocol: TCP
 volumes:
 - name: html
   gitRepo:
    repository: <git url>
    revigion: master # master 브랜치로 체크아웃
    directory: .
```

### hostPath 볼륨

- 노드의 파일 시스템에 있는 특정 파일 또는 디렉터리를 가리킵니다.

## 영구 스토리지 사용

```yaml
apiVersion: v1
kind: Pod
metatdata:
 name: mongodb
spec:
 volumes:
 - name: mongodb-data
  # gcePersistentDisk: # GCE 영구 스토리스 사용
  #  pdName: mongodb
  #  fsType: ext4
   awsElasticBlockStore: # AWS EBS 사용
    volumeId: my-volume
    fsType: ext4
 containers:
 - image: mongo
   name: mongodb
   volumeMounts:
   - name: mongodb-data
     mountPath: /data/db
   ports:
   - containerPort: 27017
     protocol: TCP
```

```yaml
...
 volumes:
 - name: mongodb-data
   nfs: # NFS 사용
    server: 1.2.3.4
    path: /some/path
...
```

## PersistentVolume and PersistentVolumeClaim

- 애플리케이션이 인프라 세부 사항을 처리하지 않고도 쿠버네티스 클러스터의 스토리지를 요청할 수 있도록합니다.
- 시스템 관리자가 실제 물리 디스크를 생성한 후에, 이 디스크를 PersistentVolume이라는 이름으로 쿠버네티스에 등록한다. 개발자는 Pod를 생성할때, 볼륨을 정의하고, 이 볼륨 정의 부분에 물리적 디스크에 대한 특성을 정의하는 것이 아니라 PVC를 지정하여, 관리자가 생성한 PV와 연결한다.

출처: <https://bcho.tistory.com/tag/PersistentVolumeClaim> [조대협의 블로그]

```yaml
apiVersion: v1
kind: PersistentVolume
metatdata:
 name: mongo-pv
spec:
 capacity:
  storage: 1Gi
 accessModes: # 단인 클라이언트가 읽기 및 쓰기용으로 마운트하거나 여러 클라이언트가 읽기 전용으로 마운트할 수 있음
 - ReadWriteOnce   # RWO
 - ReadOnlyMany    # ROX
 # - ReadWirteMany # RWX
 persistentVolumeReclaimPolicy: Retain # claim이 해제된 후에는 PersistentVolume을 삭제하거나 삭제된 상태로 유지
 gcePersistentDisk:
  pdName: mongodb
  fsType: ext4
```

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metatdata:
 name: mongodb-pvc
spec:
 resources:
  requests:
   storage: 1Gi # 스토리지의 1Gib 요청
 accessModes:
 - ReadWriteOnce
storageClassName: "" # 빈 문자열을 스토리지 클래스 이름으로 정정하면 PVC가 새 문자열을 동적으로 프로비저닝하는 대신 사전 프로비저닝된 PV에 바인딩합니다. => 빈 문자열로 설정하지 않으면 동적 볼륨 프로비저너가 미리 준비된 PersistentVolume이 있음에도 새 PersistentVolume을 프로비저닝합니다.
```

> `PersistentVolumes` binds are exclusive, and since `PersistentVolumeClaims` are namespaced objects, mounting claims with “Many” modes (`ROX`, `RWX`) is only possible within one namespace.

```yaml
# pod에서 pvc 정의
apiVerison: v1
kind: Pod
metadata:
 name: mongodb
spec:
 volumes:
 - name: mongodb-data
   persistentVolumeClaim:
    claimName: mongodb-pvc # 포드 볼륨에서 PVC이름으로 접근
 containers:
 - image: mongo
   name: mongodb
   volumeMounts:
   - name: mongodb-data
     mountPath: /data/db
   ports:
   - containerPort: 27017
     protocol: TCP
```

### StorageClass 리소스

- PersistentVolumeClaim이 스토리지클래스를 요청할 때 PersistentVolume을 프로비저닝하는 데 사용합니다.

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
 name: fast
provisioner: kubernetes.io/gce-pd # PersistentVolume프로비저닝에 사용할 볼륨 플러그인
parameters: # 제공자에게 전달될 먀갸 변수
 type: pd-ssd
 zone: europe-west1-b
```

```yaml
# storage class를 사용하는 pvc 생성
apiVersion: v1
kind: PersistentVolumeClaim
metatdata:
 name: mongodb-pvc
spec:
 storageClassName: fast
 resources:
  requests:
   storage: 1Gi # 스토리지의 1Gib 요청
 accessModes:
 - ReadWriteOnce
```

