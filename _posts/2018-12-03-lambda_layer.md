---
layout: post
title:  "AWS Lambda Layers"
date: 2018-12-03
categories: AWS
author: yogae
---

layer는 library, costume runtime, 다른 dependency를 포함하는 ZIP file입니다. function의 library를 Deploy package에 포함 시키지 않고 사용할 수 있습니다. 

layer는 function 실행 환경에서 `/opt` directory에 추출됩니다. 각각 runtime은  `/opt`에서 language에 따라 다른 위치에 library를 찾습니다.

제한:

- 하나의 function에서 5개의 layer까지 사용가능합니다.
- 전체 unzip file 크기와 모든 layer는 250MB의 unzip deployment package 크기 제한을 넘을 수 없습니다.

## Configuring a Function to Use Layers

function에 layer를 추가하기 위해서는 `update-function-configuration`를 사용합니다. layer version의 전체 ARN을 제공하여 사용할 각 layer version을 지정해야합니다.

function은 실행되는 동안 layer의 content를 `/opt`에서 접근할 수 있습니다. layer는 명시된 순서로 적용되며, 같은 이름으로 folder를 통합합니다. 같은 이름의 file이 layer에 있다면 최신 버전의 layer가 사용됩니다.

Layer verision이 제거 되었을 때 레이어 버전이 여전히 존재하는 것처럼 함수가 계속 실행됩니다. layer configuration이 업데이트 되었을 때 제거된 version에 관련된 참초를 제거해야합니다.

## Managing Layers

layer를 생성하기 위해서 `publish-layer-version`명령을 사용합니다. Runtime list는 optional이지만 layer를 더 쉽게 찾을 수 있게 합니다.

```bash
$ aws lambda publish-layer-version --layer-name my-layer --description "My layer" --license-info "MIT" \
--content S3Bucket=lambda-layers-us-east-2-123456789012,S3Key=layer.zip --compatible-runtimes python3.6 python3.7
```

## Including Library Dependencies in a Layer

layer에 runtime dependency를 넣어서 function code 밖으로 이동시킬 수 있습니다. function code가 layer에서 포함된 library에 접근가능한지를 확인하기 위해서 Lambda runtime은 `/opt` directory에 path를 포함하고 있습니다

- **Node.js** – `nodejs/node_modules`, `nodejs/node8/node_modules` (`NODE_PATH`)
- **Python** – `python`, `python/lib/python3.7/site-packages` (site directories)
- **All** – `bin` (`PATH`), `lib` (`LD_LIBRARY_PATH`)

## Reference
- https://docs.aws.amazon.com/ko_kr/lambda/latest/dg/configuration-layers.html
