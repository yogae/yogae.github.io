---
layout: post
title:  "AWS Storage Services Overview - AWS Snowball
date: 2019-02-28
categories: SAA
author: yogae
---

AWS Snowball은 secure Snowball applicace을 사용하여 많은 양의 data를 AWS 안밖으로 이동시키는 것을 가속화합니다. Snowball appliance는 효율적인 data 저장과 전송을 목적으로 제작되었습니다. 

AWS Snowball은 Amazon S3 bucket에서 data를 exporting, importing하도록 지원합니다. 

## Usage Patterns

Snowball은 terabytes에서 petabytes이 이르는 data를 AWS Cloud의 안밖으로 전송하기에 이상적입니다. network infrastructure를 비싸게 upgrade할 수 없거나 빠른 속도의 internet을 사용할 수 없는 곳에서 효과적입니다.

Internet으로 일주일 이하로 전송할 수 있는 data는 Snowball이 이상적인 solution이 아닐 것 입니다.

## Performance

data 전송 시간을 최소화하도록 10 Gbps network connection을 구성하고 2.5일 이내에 data 원본에서 appliance로 최대 80TB의 data를 전송할 수 있습니다. 기본 AWS data center로 Shipping과 handling 시간을 포함하여 대략 1주일의 시간이 걸립니다. 160TB의 data를 copying하는 것은 80TB Snowball을 2개를 parallel로 사용하여 같은 시간에 완료할 수 있습니다.

## Durability and Availability

일단 data가 AWS로 import되면 대상 저장소의 내구성과 가용성 특성이 적용됩니다.

## Scalability and Elasticity

각 AWS Snowball appliance는 50TB 또는 80TB의 data를 저장할 수 있습니다. 

## Cost Model

Snowball은 세가지 요금 구성이 있습니다. service 요금(job당), 추가된 날짜(처음 10일은 무료), data 전송

