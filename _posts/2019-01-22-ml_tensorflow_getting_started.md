---
layout: post
title:  "tensorflow 개념"
date: 2019-01-22
categories: ML
author: yogae
---

 ## 개념 개요

텐서플로우는 임의의 차원을 갖는 배열들을 뜻하는 **텐서**에서 그 이름이 유래되었습니다. 텐서플로우 **연산**은 텐서를 만들고 없애고 조작합니다. 일반적인 텐서플로우 프로그램에서 대부분의 코드 행은 연산입니다.

### 그래프

텐서플로우 **그래프**(또는 **산출 그래프**나 **데이터플로 그래프**)는 그래프 데이터 구조입니다. 많은 텐서플로우 프로그램은 하나의 그래프로 구성되어 있지만, 텐서플로우 프로그램은 여러 그래프를 만들 수도 있습니다. 그래프의 노드는 연산이고; 그래프의 엣지는 텐서입니다. 텐서는 그래프를 따라 흐르고, 각 노드에서 연산에 의해 조작됩니다. 한 연산의 출력 텐서는 보통 다음 연산의 입력 텐서가 됩니다.

### 텐서

- **스칼라**:  0-d 배열(0번째 텐서)입니다. 예: `\'Howdy\'` 또는 `5` 
- **벡터**:  1-d 배열(1번째 텐서)입니다. 예: `[2, 3, 5, 7, 11]` 또는 `[5]`
- **행렬**: 2-d 배열(2번째 텐서)입니다. 예: `[[3.1, 8.2, 5.9][4.3, -2.7, 6.5]]`

텐서는 그래프에서 **상수** 또는 **변수**로 저장될 수 있습니다. 예상할 수 있듯이 상수는 값이 변하지 않는 텐서를 가지고, 변수는 값이 변할 수 있는 텐서를 가집니다. 하지만 상수와 변수가 그래프에서 또 다른 연산이라는 것입니다. 상수는 항상 같은 텐서 값을 반환하는 연산이고, 변수는 할당된 텐서를 반환합니다.

```python
## 상수
x = tf.constant([5.2])
## 변수(항상 기본 값을 지정)
y = tf.Variable([0])
## 변수에 값 할당
y = y.assign([5])
```

### 연산

일부 상수 또는 변수를 정의하면 이를 `tf.add`와 같은 연산과 병합할 수 있습니다. `tf.add` 연산을 평가할 때 `tf.constant` 또는 `tf.Variable` 연산을 호출하여 값을 얻은 다음 그 값의 합으로 새 텐서를 반환합니다.

### 세션

그래프는 반드시 텐서플로우 **세션** 내에서 실행되어야 합니다. 세션은 다음을 실행하는 그래프의 상태를 가집니다.

```
with tf.Session() as sess:
  initialization = tf.global_variables_initializer()
  print(y.eval())
```

`tf.Variable`을 사용할 때 위에서와 같이 세션 시작 시 `tf.global_variables_initializer`를 호출하여 명시적으로 초기화해야 합니다. 

**참고:** 세션은 여러 시스템에 그래프 실행을 분산할 수 있습니다(프로그램이 분산 계산 프레임워크에서 실행된다고 가정). 자세한 정보는 [분산 텐서플로우](https://www.tensorflow.org/deploy/distributed)를 참조하세요.

## High Level APIS

- [Keras](https://www.tensorflow.org/guide/keras), TensorFlow's high-level API for building and training deep learning models.
- [Eager Execution](https://www.tensorflow.org/guide/eager), an API for writing TensorFlow code imperatively, like you would use Numpy.
- [Importing Data](https://www.tensorflow.org/guide/datasets), easy input pipelines to bring your data into your TensorFlow program.
- [Estimators](https://www.tensorflow.org/guide/estimators), a high-level API that provides fully-packaged models ready for large-scale training and production.

## Reference

- https://colab.research.google.com/notebooks/mlcc/tensorflow_programming_concepts.ipynb?utm_source=mlcc&utm_campaign=colab-external&utm_medium=referral&utm_content=tfprogconcepts-colab&hl=ko#scrollTo=NzKsjX-ufyVY
- https://www.tensorflow.org/guide