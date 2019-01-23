---
layout: post
title:  "Lambda Layer - 사용법"
date: 2019-01-07
categories: AWS
author: yogae
---

## Layer console 배포

```bash
$ cd myTestLayer
# nodejs runtime을 사용하기 위해서는 nodejs folder 이름을 사용해야합니다.
$ mkdir -p layer/nodejs
$ cd layer/nodejs
$ npm install --save lodash moment
```

layer folder를 zip으로 생성하여 layer에 추가합니다.

##Serverless 사용 

### Layer 생성

```yml
# serverless.yml
layers:
  hello:
    path: layer-dir # required, path는 layer에 배포된 directory의 path입니다.
    name: ${self:provider.stage}-layerName # optional, layer 이름
    description: Description of what the lambda layer does # optional
    compatibleRuntimes: # optional, 호환가능한 runtime list
      - python3.7
    licenseInfo: GPLv3 # optional, license 정보
    allowedAccounts: # optional, layer에 접근할 수 있는 AWs account id list
```

### Using your layers

```yml
# serverless.yml
functions:
  hello:
    handler: handler.hello
    layers:
      - arn:aws:lambda:region:XXXXXX:layer:LayerName:Y
```

## Reference

- https://medium.com/neami-apps/how-to-add-nodejs-library-dependencies-in-a-aws-lambda-layer-with-serverless-framework-d774cb867197
- https://serverless.com/framework/docs/providers/aws/guide/layers/