---
layout: post
title:  "Amazon Redshift"
date: 2019-03-24
categories: SAA
author: yogae
---

Amazon Redshift는 클라우드에서 완벽하게 관리되는 페타바이트급 데이터 웨어하우스 서비스입니다. 기본적으로 Amazon Redshift는 사용자가 선택한 AWS 리전 내에서 가용 영역(AZ)을 무작위로 선택하여 클러스터를 프로비저닝합니다. 클러스터 노드는 모두 동일한 AZ에 프로비저닝됩니다.

- **노드 중 하나에 있는 드라이브에 장애가 발생하면 데이터 웨어하우스 클러스터 가용성 및 데이터 내구성에 어떤 일이 발생합니까?**

  Amazon Redshift 데이터 웨어하우스 클러스터는 드라이브 장애 이벤트에서 사용 가능하게 유지되지만 특정 쿼리의 성능이 약간 떨어질 수 있습니다. 드라이브 장애 시 Amazon Redshift는 해당 드라이브의 데이터 복제본을 사용하는데 이 복제본은 해당 노드 내의 다른 드라이브에 저장되어 있습니다. 또한 Amazon Redshift는 정상 드라이브로 데이터를 옮기려고 시도하거나 그렇게 할 수 없는 경우 노드를 교체합니다. 단일 노드 클러스터는 데이터 복제를 지원하지 않습니다.

- **데이터 웨어하우스 클러스터의 가용 영역(AZ)이 중단되면 데이터 웨어하우스 클러스터 가용성 및 데이터 내구성에 어떤 일이 발생합니까?**

  Amazon Redshift 데이터 웨어하우스 클러스터의 가용 영역이 사용할 수 없게 되면 AZ에 대한 전원 및 네트워크 액세스가 복구될 때까지 클러스터를 사용할 수 없습니다.  데이터 웨어하우스 클러스터의 데이터는 보존되므로 AZ가 다시 사용 가능해지는 대로 Amazon Redshift 데이터 웨어하우스를 사용하여 시작할 수 있습니다.

- **Amazon Redshift는 다중 AZ 배포를 지원합니까?**

  현재 Amazon Redshift는 단일 AZ 배포만 지원합니다. 동일한 Amazon S3 입력 파일 세트에서 별도의 AZ에 있는 두 개의 Amazon Redshift 데이터 웨어하우스 클러스터로 데이터를 로드하면 다중 AZ에서 데이터 웨어하우스 클러스터를 실행할 수 있습니다. Redshift Spectrum에서는 여러 AZ에 걸쳐 여러 클러스터를 가동하고, 데이터를 클러스터로 로딩하지 않고도 Amazon S3에 있는 데이터에 액세스할 수 있습니다. 또한, 데이터 웨어하우스 클러스터 스냅샷을 사용해 데이터 웨어하우스 클러스터를 다른 AZ로 복원할 수도 있습니다.

## 개요

### 클러스터

Amazon Redshift 클러스터는 리더 노드 1개와 컴퓨팅 노드 1개 이상으로 구성된 노드 집합입니다.

### 리더 노드

클라이언트 애플리케이션의 쿼리를 수신하여 분석하고 이러한 쿼리를 처리하기 위한 여러 단계의 순차적인 집합인 실행 계획을 개발합니다. 그런 다음 리더 노드는 컴퓨팅 노드를 사용하여 이러한 계획의 병렬 실행을 조정하고 이들 노드에서 중간 결과를 집계하여 마지막으로 클라이언트 애플리케이션에 결과를 반환합니다.

### 컴퓨터 노드 

실행 플랜에 지정되어 있는 단계를 실행하고 쿼리를 처리하기 위해 노드 간에 데이터를 전송합니다. 중간 결과는 클라이언트 애플리케이션으로 보내지기 전에 집계를 위해 리더 노드로 보내집니다.

### 노드 유형

DS(*고밀도 스토리지*)는 스토리지에 최적화된 노드 유형이고, DC(*고밀도 컴퓨팅*)는 컴퓨팅에 최적화된 노드 유형입니다. DC 노드 유형은 SSD 스토리지를 사용하기 때문에 DS 노드 유형에 비해 I/O 속도가 훨씬 빠르지만 스토리지 공간은 작습니다.

## 기능

### Redshift Spectrum

Redshift Spectrum은 로딩이나 ETL 필요 없이 Amazon S3에 있는 엑사바이트 규모의 비정형 데이터에 대해 쿼리를 실행할 수 있는 Amazon Redshift의 기능입니다.

### Amazon Redshift Enhanced VPC Routing

- Amazon Redshift는 클러스터와 데이터 리포지토리 간의 모든 COPY 및 UNLOAD 트래픽이 Amazon VPC를 통하게 합니다.
- Enhanced VPC Routing을 사용하지 않을 경우, Amazon Redshift는 AWS 네트워크 내의 다른 서비스로 전송되는 트래픽을 포함하여 인터넷을 통해 트래픽을 라우팅합니다.

- Enhanced VPC Routing 사용에 따른 추가 요금은 없습니다. 특정 작업에 대해 데이터 전송 요금이 추가로 발생할 수 있습니다. 여기에는 다른 AWS 리전에서의 Amazon S3로 UNLOAD 등과 같은 작업이 포함됩니다.
- VPC 엔드포인트를 사용하면 VPC의 Amazon Redshift 클러스터와 Amazon Simple Storage Service(Amazon S3) 사이에 연결을 생성하여 관리할 수 있습니다. 이때는 Amazon S3의 클러스터와 데이터 간 COPY 및 UNLOAD 트래픽이 Amazon VPC를 벗어나지 않습니다.