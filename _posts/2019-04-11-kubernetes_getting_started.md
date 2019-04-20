---
layout: post
title:  "Kubernetes 시작하기"
date: 2019-04-11
categories: Kubernetes
author: yogae
---

## Kubernetes 클러스터

- 마스터 노드

  전체 쿠버네티스 시스템을 관리하고 동제하는 쿠버네티스 컨트롤 플레인을 관장

- 워커 노드

  실제 배포하고자 하는 애플리케이션 실행을 담당

### 컨트롤 플레인

클러스터를 관리하고 클러스터의 기능을 실행합니다.

- 사용자와 컨트롤 플레인과 통신하는 쿠버네티스 API서버
- 애플리케이션을 예약하는 스케줄러
- 구성 요소 복제, 워커 노드 추적, 노드 장애 처리 등 클러스터 수준 기능을 실행하는 컨트롤러 매니저
- etcd는 클러스터 구성을 지속적으로 저장하는 안정적은 분산 데이터 스토리지

### 워커 노드

워커 노드는 컨테이너화된 애플리케이션을 실행하는 시스템입니다. 

- 컨테이너를 실행하는 런타임
- API 서버와 통신하고 노드에서 컨테이서를 관리하는 Kubelet
- 애필리케이션 구성 요소 간에 네트워크 트래픽을 분산하는 쿠버네티스 서비스 프록시(kube-proxy)

## Kubernetes에서 애플리케이션 실행

하나 이상의 컨테이너 이미지들을 패키지로 만들어 이미지 레지스트리에 푸시한 다음 쿠버네티스 API 서버에 애플리케이션의 디스크립션을 게시해야 합니다.

### 디스크립션

컨테이너 이미지 또는 애플리케이션 컴포넌트가 들어있는 이미지가 있고, 컴포넌트 간 관련성 및 노드 배치 정보도 있습니다.

### 포드

앱 디스크립터에서 컨테이너를 세트로 묶어서 관리할 수 있습니다. 이 세트를 포드라고 합니다. 같은 포드 안에 있는 컨테이너는 같은 위치에 있어야 하며 서로 격리되어서는 안 됩니다.

- 포드에는 원하는 만큼의 컨테이너를 포함시킬 수 있습니다.
- 포드는 고유한 개인 IP 주소와 호스트 이름을 갖습니다.
- 포드의 모든 컨테이너는 동일한 네트워크 및 UTS 네임스페이스에서 실행되기 때문에 모두 같은 호스트 이름 및 네트워크 인터페이스를 공유합니다.
- 동일한 포드의 컨테이너에서 실행 중인 프로세스는 동일한 포트 번호에 바인딩되지 않도록 주의해야합니다.

> 리눅스 네임스페이스: 커널 인스턴스를 만들기 않고 기존의 리소스들을 필요한 만큼의 namesapce로 분리하여 묶어 관리하는 방법으로 사용

### 레플리케이션컨트롤러

항상 포드 인스턴스를 정화히 하나만 실행합니다.

포드가 사라지면 레플리케이션컨트롤러는 누락된 포드를 대체할 새로운 포드를 만듭니다.

### 서비스

포드는 언제든지 사라질 수 있습니다. 포드가 사라지면 레플리케이션컨트롤러가 손실된 포드를 새로운 포드로 대체합니다. 새로운 포드는 대체할 포드와 다른 IP 주소를 할당 받습니다. 서비스는 포드 IP 주소이 문제를 해결하고 단일 IP 포트 쌍에서 여러 개의 포트를 노출시킵니다.

## Kubernetes 클러스터 설정

### Minikube

미니큐브는 쿠버네티스를 테스트하고 로컬에서 애플리케이시션을 개발하는 데 유용한 다일 노드 클러스터를 설정하는 도구입니다.

미니 큐브는 VirtualBox 또는 KVM을 통해 실행되는 VM 내부에서 쿠버네티스를 실행하므로 미니큐브 클러스터를 시작하기 전에 VirtualBox 또는 KVM를 설치해야 합니다.

#### 설치

- brew 사용: brew cask install minikube

- manually: curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-darwin-amd64 && sudo install minikube-darwin-amd64 /usr/local/bin/minikube

### Amazon EKS(Amazon Elastic Container Service for Kubernetes)
- https://docs.aws.amazon.com/ko_kr/eks/latest/userguide/getting-started.html
### GKE(Google Kubernetes Engine)

## Kubernetes 명령

- Kubernetes 정보 확인

  - kubectl cluster-info
  - kubectl get nodes
  - kubectl get pods
  - kubectl get replication controllers
  - kubectl get services

- yaml을 다루지 않고 image 배포

  - kubectl run kubia --image=luksa/kubia --port=8080 --generator=run/v1

- 서비스 객체 생성

  - kubectl expose rc kubia --type=LoadBalancer --name kubia-http
