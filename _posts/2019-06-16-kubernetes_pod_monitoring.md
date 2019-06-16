---
layout: post
title: kubernetes 포드 모니터링
data: 2019-06-16
categories: Kubernetes
author: yogae
---

Kubelet에 cAdvisor라는 에이전트가 포함되어 있어 노드와 노드 전체에서 실행되는 개별 컨테이너에 대한 리소스 소비 데이터의 수집을 수행합니다.

전체 클러스터의 통계를 중앙에서 수집하려면 Heapster라는 컴포넌트를 실행해야 합니다. Heapster는 노드 중 하나에서 포드 형태로 실행되며 일반 쿠버네티스 서비스를 통해 노출되므로 안정적인 IP 주소에서 액세스할 수 있습니다. 

cAdvisor와 Heapster는 짧은 시간 동안 리소스 사용 데이터만 보유하여 일주일전에 사용량은 저장하지 않습니다. 장기간에 걸쳐 포드의 리소스 사용량을 분석하려면 통계 데이터를 저장하기 위해 InfluxDB와 Grafana를 사용해야합니다.

## 클러스터 노드의 CPU 및 메모리 사용량 표시

```bash
# 노드의 실제 CPU와 메모리 사용량
kubectl top node

# 포드의 실제 CPU 및 메모리 사용량
kubectl top pod --all-namespaces
```





