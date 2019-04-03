---
layout: default
title: About
---

## 개발
- [ ] log 분석기 - elastic search, python 사용하여 구성
    - 순서
        1. cron형식으로 lambda 실행하여 log(CloudWatch) 분석 및 ETL 실행
        2. 저장된 log data를 볼수 있는 api 구성
        3. web application에서 api 호출로 log 정보 viewing
    - 구성
        - aws-sdk(cloud watch) insight를 사용하여 metric 분석 확인
        - ETL 작업
            - lambda python(직접 작업), Logstash, AWS glue
        - ETL 작업이후 저장할 위치
            - Elastic Search, CloudSearch, Amazon ElasticSearch 확인
        - Viewing
            - D3.js 직접 구성, Amazon QuickSight, Kibana
            - mongoDB connection 확인 방법 
- [ ] python을 확용한 간단한 application 구성 - python(flask, zappa)활용
- [ ] 행동분석 모델링 - merchine learning활용

## TODO
- [ ] Kubernetes
- [ ] Elastic Search
- [ ] AWS Service
    - [x] IoT MQTT - Amplify
    - [ ] SageMaker
    - [ ] EKS
- [ ] Webpack
- [ ] GraphQL
- [ ] machine learning
    - [ ] TensorFlow
    - [ ] SageMaker
- [ ] GCP
- [ ] Nest

## In Progress
- [ ] Elastic Search
- [ ] Python
    - [x] django - 파이썬 웹프로그래밍 
    - [x] [flask](http://flask.pocoo.org/docs/1.0/)
    - [ ] zappa

## Done
- [x] CircleCI
- [x] Jekyll
- [x] Typescript - 타입스크립트 마스터 2/e
- [x] Serverless
- [x] Terraform
- [x] AWS Service
    - [x] ECS
    - [x] CloudFront
    - [x] Cognito
- [x] SAA 시험 준비
    - [x] [Amazon Web Service 개요](https://d1.awsstatic.com/International/ko_KR/whitepapers/aws-overview.pdf)
    - [x] [Architecting for the Cloud](https://d1.awsstatic.com/whitepapers/AWS_Cloud_Best_Practices.pdf) (진행중)
    - [x] [AWS Security Best Practices](https://d1.awsstatic.com/whitepapers/Security/AWS_Security_Best_Practices.pdf)
    - [x] [AWS Storage Services Overview](https://d1.awsstatic.com/whitepapers/Storage/AWS%20Storage%20Services%20Whitepaper-v9.pdf)
    - [x] FAQ
