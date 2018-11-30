---
layout: post
title:  "Terraform 사용법"
date: 2018-11-28
categories: Terraform
author: yogae
---
Terraform 사용법 정리

# Terraform

## Terraform 명령어

- apply: terraform.tfstate file과 비교하여 change 또는 build
  - -auto-approve: 자동 승인
- destroy: terraform으로 관리하는 ingrastructures 제거
- plan: terraform.tfstate file과 비교하여 변경사항 확인
- Init: .terraform folder 생성, module이 있는 경우 module import
- state rm: Remove one or more items from the Terraform state

## remote state

- terraform.tfstate 파일을 지정한 storage에 저장하여 state를 공유
- 공동작업하는 경우 remote state를 관리할 필요가 있음
- S3 저장소를 remote state로 사용하는 방법
  ```tf
  terraform {
    backend "s3" {
      bucket = "state-bucket"
      key    = "infra.tfstate"
      region = "us-east-1"
    }
    required_version = ">= 0.11.8"
  }
  ```

## 환경변수

1. Defining Variables
  ```tf
  variable "access_key" {}
  variable "secret_key" {}
  variable "region" {
    default = "us-east-1"
  }
  ```
2. Using Valiables in Configuration
  ```tf
  provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region     = "${var.region}"
  }
  ```

3. Assigning Variables
- Command-line flags
  ```bash
  $ terraform apply \
    -var 'access_key=foo' \
    -var 'secret_key=bar'
  # ...
  ```

- From a file
  ````bash
  # Create a file named terraform.tfvars
  access_key = "foo"
  secret_key = "bar"
  
  $ terraform apply \
    -var-file="secret.tfvars" \
    -var-file="production.tfvars"
  ​```
  ````

- From environment variables
  Terraform will read environment variables in the form of TF_VAR_name to find the value for a variable.

> For example, the TF_VAR_access_key variable can be set to set the access_key variable.

## import

기존에 이미 존재하는 resource를 terraform.tfstate에 등록하여 terraform에서 관리할 수 있도록 함

- resource를 선언하고 import 시켜야함

- 선언

  ```tf
  resource "aws_instance" "example" {
    # ...instance configuration...
  }
  ```

- Import

  ```bash
  terraform import aws_instance.example i-abcd1234
  ```

## module

- module 생성

  ```tf
  module "ecs-detail-share" {
  	# import할 module의 위치
  	# ./ecs/detail-share의 위치에 있는 모든 tf 파일을 import 한  다.
  
  	source = "./ecs/detail-share"
  	# module에 필요한 config 정보
      STAGE = "${var.STAGE}"
  }
  ```

- module file

  ```
  variable "STAGE" {}
  
  resource "aws_ecs_cluster" "ecs_cluster" {
    name = "${var.STAGE}-api-cluster"
  }
  ```

## structure

- stage별 구분

  ```
  /tf
    /modules
    /dev
    /stg
    /prd
  ```

- service별 구분

  ```
  /tf
   /modules
      /ecs_cluster
      /consumer_service
        main.tf
        output.tf
      /publishing_service
        main.tf
        kinesis.tf
        lambda.tf
        output.tf
   /stg
      main.tf // here we import publishing_service and consumer_service
  ```

  [참고](https://medium.com/hdeblog/terraform-sane-practices-project-structure-c4347c1bc0f1)

- 전체 구성

  ```
  ├── README.md
  ├── variables.tf
  ├── main.tf
  ├── outputs.tf
  ├── modules
  │   ├── compute
  │   │   ├── README.md
  │   │   ├── variables.tf
  │   │   ├── main.tf
  │   │   ├── outputs.tf
  │   ├── networking
  │   │   ├── README.md
  │   │   ├── variables.tf
  │   │   ├── main.tf
  │   │   ├── outputs.tf
  ```

  [참고](https://www.terraform.io/docs/enterprise/workspaces/repo-structure.html)

## 주의사항

- terraform apply시 같은 folder에 있는 tf파일만 실행 됨 
  - 다른 folder 안에 있는 tf 파일은 실행되지 않음 
  - 파일들을 구조화하기 위해서 module로 관리 필요
  - module import 시 같은 folder에 있는 tf파일만 실행 됨
- variable은 따로 tf 파일을 만들거나 file별로 관리할 수 있음
  - 모든 variable은 중복 할 수 없음
  - module안에 선언된 variable과는 별도로 관리됨