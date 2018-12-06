---
layout: post
title:  "Design Principles - Databases"
date: 2018-12-06
categories: SAA
author: yogae
---

전통적인 IT infrasructure에서는 database와 storage 기술에서 종종 제한을 받습니다. licensing 비용에과 다양한 database engine을 지원성에 대한 제한이 있습니다. AWS에서는 open-source비용으로 enterprise 성능을 제공하는 database 서비스로 이러한 제한을 없애줍니다. 결과적으로 응용 프로그램이 각 작업 부하에 적합한 기술을 선택하는 다중 언어 데이터 계층에서 실행되는 경우는 드뭅니다.

## Choose the Right Database Technology for Each Workload

아래의 질문은 어떤 solution을 architecture에 포함할지에 대한 결정을 도와줍니다.

- read-heavy, write-heavy, or balanced workload입니까? 초당 얼마나 많이 읽고 씁니까? 사용자가 증가하면 어떻게 값을 변경합니까?
- 