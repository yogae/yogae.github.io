# workspace
- - - -
layout: post
title: terraform workspace 사용
data: 2019-07-26
categories: Terraform
author: yogae
- - - -
#terraform

환경에 따라 다른 변수를 설정 하여 다른 배포 환경의 인프라를 관리할 수 있다.
## workspace 관련 명령어
- new: workspace 추가
```bash
terraform workspace new dev
```

- select: workspace 변경
```bash
terraform workspace select dev
```

- list: workspace list 확인
```bash
terraform workspace select list
```

## workspace 개발 환경 분리

### Interpolation사용
```terraform
resource "aws_instance" "default" {
    count = "${terraform.workspace == "prod" ? "1" ? "2"}"
}
```

### Map 사용
```terraform
# variables.tf 설정
variable "ec2_type" {
    type = "map"
    default = {
        dev  = "t3.small"
        qa   = "t3.medium"
        prod = "t3.xlarge"
    }
}
```
 
```terraform
# resource에 사용
resource "aws_vpc" "default" {
    cidr_block = "${var. ec2_type[terraform.workspace]}"
    tags {
        Name = "VPC - ${terraform.workspace}"
    }                                                                            
}     
```